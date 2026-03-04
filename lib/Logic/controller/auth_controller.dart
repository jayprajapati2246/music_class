import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:music_class/screen.dart';
import '../../screen/auth/login_screen.dart';

class AuthController extends GetxController {
  static AuthController instance = Get.find();
  
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  late Rx<User?> _user;
  
  // Observables for user data
  Rx<Map<String, dynamic>> userData = Rx<Map<String, dynamic>>({});
  RxBool isLoading = false.obs;
  bool _isInitialLoad = true;

  @override
  void onReady() {
    super.onReady();
    _user = Rx<User?>(_auth.currentUser);
    _user.bindStream(_auth.userChanges());
    
    // Initial fetch if already logged in
    if (_user.value != null) {
      getUserDetails(_user.value!.uid);
    }

    // Listen for auth changes to update userData and handle navigation
    ever(_user, (user) {
      if (user != null) {
        getUserDetails(user.uid);
      } else {
        userData.value = {};
      }

      // Handle navigation: Skip initial redirect to allow Splash Screen to show for 5 seconds
      if (!_isInitialLoad) {
        _initialScreen(user);
      }
    });

    // Wait for 5 seconds (Splash Screen duration) for the VERY FIRST redirect
    Future.delayed(const Duration(seconds: 5), () {
      _isInitialLoad = false;
      _initialScreen(_user.value);
    });
  }

  _initialScreen(User? user) {
    if (user == null) {
      Get.offAll(() => const LoginScreen());
    } else {
      Get.offAll(() => const Mainscreen());
    }
  }

  Future<void> getUserDetails(String uid) async {
    try {
      DocumentSnapshot doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        userData.value = doc.data() as Map<String, dynamic>;
      } else {
        User? currentUser = _auth.currentUser;
        if (currentUser != null && currentUser.uid == uid) {
          Map<String, dynamic> newUserStub = {
            'name': currentUser.displayName ?? 'User',
            'email': currentUser.email ?? '',
            'phone': currentUser.phoneNumber ?? '',
            'role': 'Student',
            'uid': uid,
            'createdAt': FieldValue.serverTimestamp(),
            'profileImage': currentUser.photoURL ?? '',
          };
          await _firestore.collection('users').doc(uid).set(newUserStub);
          DocumentSnapshot newDoc = await _firestore.collection('users').doc(uid).get();
          userData.value = newDoc.data() as Map<String, dynamic>;
        }
      }
    } catch (e) {
      print("Error in getUserDetails: $e");
    }
  }

  Future<void> register(String name, String email, String password, String role, {required String phone}) async {
    final phoneRegex = RegExp(r'^\+[0-9]{1,4}[0-9]{10}$');
    
    if (!phoneRegex.hasMatch(phone)) {
      Get.snackbar("Invalid Phone", "Please enter country code (+) followed by 10 digits",
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red,
          colorText: Colors.white,
          margin: const EdgeInsets.all(15));
      return;
    }

    try {
      isLoading.value = true;
      UserCredential credential = await _auth.createUserWithEmailAndPassword(
        email: email, 
        password: password
      );
      await credential.user?.updateDisplayName(name);
      Map<String, dynamic> userMap = {
        'name': name,
        'email': email,
        'phone': phone,
        'role': role,
        'uid': credential.user?.uid,
        'createdAt': FieldValue.serverTimestamp(),
        'profileImage': '',
      };
      await _firestore.collection('users').doc(credential.user?.uid).set(userMap);
      userData.value = userMap;
      Get.snackbar("Success", "Account created successfully",
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.green,
          colorText: Colors.white,
          margin: const EdgeInsets.all(15));
    } catch (e) {
      Get.snackbar("Error", e.toString(),
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red,
          colorText: Colors.white,
          margin: const EdgeInsets.all(15));
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> login(String email, String password) async {
    try {
      isLoading.value = true;
      UserCredential credential = await _auth.signInWithEmailAndPassword(email: email, password: password);
      await getUserDetails(credential.user!.uid);
    } catch (e) {
      Get.snackbar("Login Failed", e.toString(),
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red,
          colorText: Colors.white,
          margin: const EdgeInsets.all(15));
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> signInWithGoogle() async {
    try {
      isLoading.value = true;
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser != null) {
        final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
        final AuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );
        UserCredential userCredential = await _auth.signInWithCredential(credential);
        User? user = userCredential.user;
        if (user != null) {
          DocumentSnapshot doc = await _firestore.collection('users').doc(user.uid).get();
          if (!doc.exists) {
            Map<String, dynamic> newUser = {
              'name': user.displayName,
              'email': user.email,
              'phone': user.phoneNumber ?? "",
              'role': 'Student',
              'uid': user.uid,
              'createdAt': FieldValue.serverTimestamp(),
              'profileImage': user.photoURL ?? '',
            };
            await _firestore.collection('users').doc(user.uid).set(newUser);
            userData.value = newUser;
          } else {
            userData.value = doc.data() as Map<String, dynamic>;
          }
        }
      }
    } catch (e) {
      Get.snackbar("Google Sign In Failed", e.toString(),
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red,
          colorText: Colors.white,
          margin: const EdgeInsets.all(15));
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> forgotPassword(String email) async {
    if (email.isEmpty || !GetUtils.isEmail(email)) {
      Get.snackbar("Error", "Please enter a valid email address",
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.orange,
          colorText: Colors.white,
          margin: const EdgeInsets.all(15));
      return;
    }
    try {
      isLoading.value = true;
      await _auth.sendPasswordResetEmail(email: email);
      Get.snackbar("Reset Email Sent", "Check your inbox to reset password",
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.green,
          colorText: Colors.white,
          margin: const EdgeInsets.all(15));
    } catch (e) {
      Get.snackbar("Error", e.toString(),
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red,
          colorText: Colors.white,
          margin: const EdgeInsets.all(15));
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> logout() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
    userData.value = {};
  }
}
