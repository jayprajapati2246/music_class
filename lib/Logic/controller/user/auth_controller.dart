import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:get/get_navigation/src/snackbar/snackbar.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/get_rx/src/rx_workers/rx_workers.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:get/get_utils/src/get_utils/get_utils.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../../screen.dart';
import '../../../screen/auth/login_screen.dart';
import '../../../screen/auth/reset_password_screen.dart';

class AuthController extends GetxController {
  static AuthController instance = Get.find();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  late Rx<User?> _user;

  // Observables
  Rx<Map<String, dynamic>> userData = Rx<Map<String, dynamic>>({});
  RxBool isLoading = false.obs;
  RxBool isAdmin = false.obs;

  bool _isInitialLoad = true;

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
        isAdmin.value = false;

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

  void _initialScreen(User? user) {
    if (user == null) {
      Get.offAll(() => const LoginScreen());
    } else {
      Get.offAll(() => const Mainscreen());
    }
  }

  Future<void> getUserDetails(String uid) async {
    try {
      DocumentSnapshot doc = await _firestore
          .collection('users')
          .doc(uid)
          .get();

      if (doc.exists) {
        userData.value = doc.data() as Map<String, dynamic>;

        // Admin role logic
        isAdmin.value = userData.value['role'] == 'Admin';
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

          userData.value = newUserStub;
          isAdmin.value = false;
        }
      }
    } catch (e) {
      debugPrint("Error in getUserDetails: $e");
    }
  }

  void _showSnackbar(String title, String message, {bool isError = false}) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.TOP,
      backgroundColor: isError
          ? Colors.red.withOpacity(0.9)
          : const Color(0xff6A5AE0).withOpacity(0.9),
      colorText: Colors.white,
      margin: const EdgeInsets.all(15),
      borderRadius: 15,
      icon: Icon(
        isError ? Icons.error_outline : Icons.check_circle_outline,
        color: Colors.white,
      ),
      duration: const Duration(seconds: 3),
      boxShadows: [
        BoxShadow(
          color: Colors.black.withOpacity(0.2),
          blurRadius: 10,
          offset: const Offset(0, 5),
        ),
      ],
    );
  }

  Future<void> checkEmailAndNavigate(String email) async {
    if (email.isEmpty || !GetUtils.isEmail(email)) {
      _showSnackbar(
        "Error",
        "Please enter a valid email address",
        isError: true,
      );
      return;
    }

    try {
      isLoading.value = true;

      QuerySnapshot query = await _firestore
          .collection('users')
          .where('email', isEqualTo: email)
          .get();

      if (query.docs.isEmpty) {
        _showSnackbar(
          "Not Found",
          "No account registered with this email.",
          isError: true,
        );
        return;
      }

      resetEmail.value = email;
      Get.to(() => const ResetPasswordScreen());
    } catch (e) {
      _showSnackbar("Error", e.toString(), isError: true);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> resetPasswordDirectly(String newPassword) async {
    try {
      isLoading.value = true;

      await _auth.sendPasswordResetEmail(email: resetEmail.value);

      _showSnackbar(
        "Reset Link Sent",
        "A password reset link has been sent to ${resetEmail.value}",
      );

      Future.delayed(
        const Duration(seconds: 2),
        () => Get.offAll(() => const LoginScreen()),
      );
    } catch (e) {
      _showSnackbar("Error", e.toString(), isError: true);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> register(
    String name,
    String email,
    String password,
    String role, {
    required String phone,
  }) async {
    final phoneRegex = RegExp(r'^\+[0-9]{1,4}[0-9]{10}$');

    if (!phoneRegex.hasMatch(phone)) {
      _showSnackbar(
        "Invalid Phone",
        "Please enter country code (+) followed by 10 digits",
        isError: true,
      );
      return;
    }

    try {
      isLoading.value = true;

      UserCredential credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
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

      await _firestore
          .collection('users')
          .doc(credential.user?.uid)
          .set(userMap);

      userData.value = userMap;
      isAdmin.value = role == 'Admin';

      _showSnackbar("Success", "Account created successfully");

      _initialScreen(credential.user);
    } catch (e) {
      _showSnackbar("Error", e.toString(), isError: true);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> login(String email, String password) async {
    try {
      isLoading.value = true;

      UserCredential credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      await getUserDetails(credential.user!.uid);

      _initialScreen(credential.user);
    } catch (e) {
      _showSnackbar("Login Failed", e.toString(), isError: true);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> signInWithGoogle() async {
    try {
      isLoading.value = true;

      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser != null) {
        final GoogleSignInAuthentication googleAuth =
            await googleUser.authentication;

        final AuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        UserCredential userCredential = await _auth.signInWithCredential(
          credential,
        );

        User? user = userCredential.user;

        if (user != null) {
          DocumentSnapshot doc = await _firestore
              .collection('users')
              .doc(user.uid)
              .get();

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
            isAdmin.value = false;
          } else {
            userData.value = doc.data() as Map<String, dynamic>;
            isAdmin.value = userData.value['role'] == 'Admin';
          }

          _initialScreen(user);
        }
      }
    } catch (e) {
      _showSnackbar("Google Sign In Failed", e.toString(), isError: true);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> logout() async {
    await _googleSignIn.signOut();
    await _auth.signOut();

    userData.value = {};
    isAdmin.value = false;
  }
}
