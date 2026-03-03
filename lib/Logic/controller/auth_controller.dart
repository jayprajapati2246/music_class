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
  
  // Loading state
  RxBool isLoading = false.obs;

  @override
  void onReady() {
    super.onReady();
    _user = Rx<User?>(_auth.currentUser);
    _user.bindStream(_auth.userChanges());
    
    // Wait for 5 seconds (Splash Screen duration) before redirecting
    Future.delayed(const Duration(seconds: 5), () {
      ever(_user, _initialScreen);
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

  Future<void> register(String name, String email, String password, String role, {required String phone}) async {
    final phoneRegex = RegExp(r'^\+[0-9]{1,4}[0-9]{10}$');
    
    if (!phoneRegex.hasMatch(phone)) {
      Get.snackbar("Invalid Phone", "Please enter country code (+) followed by 10 digits",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.withOpacity(0.1),
          colorText: Colors.red);
      return;
    }

    try {
      isLoading.value = true;
      
      UserCredential credential = await _auth.createUserWithEmailAndPassword(
        email: email, 
        password: password
      );

      await credential.user?.updateDisplayName(name);

      await _firestore.collection('users').doc(credential.user?.uid).set({
        'name': name,
        'email': email,
        'phone': phone,
        'role': role,
        'uid': credential.user?.uid,
        'createdAt': DateTime.now(),
      });

      Get.snackbar("Success", "Account created successfully",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green.withOpacity(0.1),
          colorText: Colors.green);

    } catch (e) {
      Get.snackbar("Error", e.toString(),
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.withOpacity(0.1),
          colorText: Colors.red);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> login(String email, String password) async {
    try {
      isLoading.value = true;
      await _auth.signInWithEmailAndPassword(email: email, password: password);
    } catch (e) {
      Get.snackbar("Login Failed", e.toString(),
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.withOpacity(0.1),
          colorText: Colors.red);
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

        if (userCredential.additionalUserInfo!.isNewUser) {
          await _firestore.collection('users').doc(user?.uid).set({
            'name': user?.displayName,
            'email': user?.email,
            'phone': user?.phoneNumber ?? "",
            'role': 'Student',
            'uid': user?.uid,
            'createdAt': DateTime.now(),
          });
        }
      }
    } catch (e) {
      Get.snackbar("Google Sign In Failed", e.toString(),
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.withOpacity(0.1),
          colorText: Colors.red);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> forgotPassword(String email) async {
    if (email.isEmpty || !GetUtils.isEmail(email)) {
      Get.snackbar("Error", "Please enter a valid email address",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.orange.withOpacity(0.1),
          colorText: Colors.orange);
      return;
    }
    try {
      isLoading.value = true;
      await _auth.sendPasswordResetEmail(email: email);
      Get.snackbar("Reset Email Sent", "Check your inbox to reset password",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green.withOpacity(0.1),
          colorText: Colors.green);
    } catch (e) {
      Get.snackbar("Error", e.toString(),
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.withOpacity(0.1),
          colorText: Colors.red);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> logout() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }
}
