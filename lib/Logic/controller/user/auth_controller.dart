import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:music_class/screen.dart';

import '../../../screen/auth/login_screen.dart';
import '../../../screen/auth/reset_password_screen.dart';


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
  
  // Forgot Password Flow
  RxString resetEmail = "".obs;

  @override
  void onReady() {
    super.onReady();
    _user = Rx<User?>(_auth.currentUser);
    _user.bindStream(_auth.userChanges());
    
    if (_user.value != null) {
      getUserDetails(_user.value!.uid);
    }

    ever(_user, (user) {
      if (user != null) {
        getUserDetails(user.uid);
      } else {
        userData.value = {};
        if (!_isInitialLoad) {
          _initialScreen(user);
        }
      }
    });

    Future.delayed(const Duration(seconds: 3), () {
      _isInitialLoad = false;
      _initialScreen(_user.value);
    });
  }

  _initialScreen(User? user) {
    if (user == null) {
      Get.offAll(() => const LoginScreen());
    } else {
      // Both Admin and Student go to the same Mainscreen
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
      debugPrint("Error in getUserDetails: $e");
    }
  }

  // --- NEW: Email-based Forgot Password (Direct Flow) ---

  Future<void> checkEmailAndNavigate(String email) async {
    if (email.isEmpty || !GetUtils.isEmail(email)) {
      Get.snackbar("Error", "Please enter a valid email address",
          backgroundColor: Colors.orange, colorText: Colors.white);
      return;
    }

    try {
      isLoading.value = true;
      
      // Check if user exists in Firestore
      QuerySnapshot query = await _firestore
          .collection('users')
          .where('email', isEqualTo: email)
          .get();

      if (query.docs.isEmpty) {
        Get.snackbar("Not Found", "No account registered with this email.",
            backgroundColor: Colors.red, colorText: Colors.white);
        return;
      }

      // Store email and navigate to Reset Screen
      resetEmail.value = email;
      Get.to(() => const ResetPasswordScreen());
      
    } catch (e) {
      Get.snackbar("Error", e.toString(),
          backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> resetPasswordDirectly(String newPassword) async {
    try {
      isLoading.value = true;
      
      // Note: Firebase Auth does not allow updating password for an arbitrary email
      // without being logged in or using an OOB code (Email Link/OTP).
      // The standard secure way is sendPasswordResetEmail.
      
      await _auth.sendPasswordResetEmail(email: resetEmail.value);
      
      Get.snackbar(
        "Reset Link Sent", 
        "For security, Firebase requires password resets via email. A link has been sent to ${resetEmail.value}",
        backgroundColor: Colors.green, 
        colorText: Colors.white,
        duration: const Duration(seconds: 5)
      );
      
      Future.delayed(const Duration(seconds: 2), () => Get.offAll(() => const LoginScreen()));
      
    } catch (e) {
      Get.snackbar("Error", e.toString(),
          backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }

  // --- Auth Methods ---

  Future<void> register(String name, String email, String password, String role, {required String phone}) async {
    final phoneRegex = RegExp(r'^\+[0-9]{1,4}[0-9]{10}$');
    if (!phoneRegex.hasMatch(phone)) {
      Get.snackbar("Invalid Phone", "Please enter country code (+) followed by 10 digits",
          backgroundColor: Colors.red, colorText: Colors.white);
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
          backgroundColor: Colors.green, colorText: Colors.white);
      _initialScreen(credential.user);
    } catch (e) {
      Get.snackbar("Error", e.toString(),
          backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> login(String email, String password) async {
    try {
      isLoading.value = true;
      UserCredential credential = await _auth.signInWithEmailAndPassword(email: email, password: password);
      await getUserDetails(credential.user!.uid);
      _initialScreen(credential.user);
    } catch (e) {
      Get.snackbar("Login Failed", e.toString(),
          backgroundColor: Colors.red, colorText: Colors.white);
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
          _initialScreen(user);
        }
      }
    } catch (e) {
      Get.snackbar("Google Sign In Failed", e.toString(),
          backgroundColor: Colors.red, colorText: Colors.white);
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
