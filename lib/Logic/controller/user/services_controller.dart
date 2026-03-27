import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class UserServicesController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  var courses = <String>[].obs;
  var batchTimes = <String>[].obs;
  var fees = <String>[].obs;
  var isLoading = false.obs;

  final TextEditingController courseController = TextEditingController();
  final TextEditingController batchController = TextEditingController();
  final TextEditingController feeController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    fetchUserServices();
  }

  Future<void> fetchUserServices() async {
    try {
      isLoading.value = true;
      String uid = _auth.currentUser!.uid;
      DocumentSnapshot doc = await _firestore
          .collection('users')
          .doc(uid)
          .get();

      if (doc.exists) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        if (data['services'] != null) {
          Map<String, dynamic> services = data['services'];
          courses.value = List<String>.from(services['courses'] ?? []);
          batchTimes.value = List<String>.from(services['batchTimes'] ?? []);
          fees.value = List<String>.from(services['fees'] ?? []);
        }
      }
    } catch (e) {
      showTopSnackbar(
        "Error",
        "Failed to fetch services: $e",
        Colors.red,
        Icons.signal_wifi_connected_no_internet_4,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> addCourse() async {
    String course = courseController.text.trim();
    if (course.isEmpty) return;

    try {
      String uid = _auth.currentUser!.uid;
      courses.add(course);
      await _firestore.collection('users').doc(uid).set({
        'services': {
          'courses': courses,
        }
      }, SetOptions(merge: true));
      courseController.clear();
      showTopSnackbar(
        "Success",
        "Course added successfully",
        Colors.green,
        Icons.check_circle,
      );
    } catch (e) {
      showTopSnackbar(
        "Error",
        "Failed to add course: $e",
        Colors.red,
        Icons.layers_clear_rounded,
      );
    }
  }

  Future<void> addBatch() async {
    String batch = batchController.text.trim();
    if (batch.isEmpty) return;

    try {
      String uid = _auth.currentUser!.uid;
      batchTimes.add(batch);
      await _firestore.collection('users').doc(uid).set({
        'services': {
          'batchTimes': batchTimes,
        }
      }, SetOptions(merge: true));
      batchController.clear();
      showTopSnackbar(
        "Success",
        "Batch added successfully",
        Colors.green,
        Icons.check_circle,
      );
    } catch (e) {
      showTopSnackbar(
        "Error",
        "Failed to add batch: $e",
        Colors.red,
        Icons.history_toggle_off_rounded,
      );
    }
  }



  Future<void> removeCourse(int index) async {
    try {
      String uid = _auth.currentUser!.uid;
      courses.removeAt(index);
      await _firestore.collection('users').doc(uid).set({
        'services': {
          'courses': courses,
        }
      }, SetOptions(merge: true));
    } catch (e) {
      Get.snackbar("Error", "Failed to remove course: $e");
    }
  }

  Future<void> removeBatch(int index) async {
    try {
      String uid = _auth.currentUser!.uid;
      batchTimes.removeAt(index);
      await _firestore.collection('users').doc(uid).set({
        'services': {
          'batchTimes': batchTimes,
        }
      }, SetOptions(merge: true));
    } catch (e) {
      Get.snackbar("Error", "Failed to remove batch: $e");
    }
  }

  Future<void> removeFee(int index) async {
    try {
      String uid = _auth.currentUser!.uid;
      fees.removeAt(index);
      await _firestore.collection('users').doc(uid).set({
        'services': {
          'fees': fees,
        }
      }, SetOptions(merge: true));
    } catch (e) {
      Get.snackbar("Error", "Failed to remove fee: $e");
    }
  }

  Future<void> clearCourses() async {
    try {
      String uid = _auth.currentUser!.uid;
      courses.clear();
      await _firestore.collection('users').doc(uid).set({
        'services': {
          'courses': [],
        }
      }, SetOptions(merge: true));
      showTopSnackbar(
          "Success",
          "All courses cleared",
        Colors.green,
        Icons.check_circle,
      );
    } catch (e) {
      Get.snackbar("Error", "Failed to clear courses: $e");
    }
  }

  Future<void> clearBatches() async {
    try {
      String uid = _auth.currentUser!.uid;
      batchTimes.clear();
      await _firestore.collection('users').doc(uid).set({
        'services': {
          'batchTimes': [],
        }
      }, SetOptions(merge: true));
      showTopSnackbar(
        "Success",
        "All batches cleared",
        Colors.green,
        Icons.check_circle,
      );
    } catch (e) {
      Get.snackbar("Error", "Failed to clear batches: $e");
    }
  }

  Future<void> clearAllServices() async {
    try {
      String uid = _auth.currentUser!.uid;
      courses.clear();
      batchTimes.clear();
      fees.clear();
      await _firestore.collection('users').doc(uid).set({
        'services': {
          'courses': [],
          'batchTimes': [],
        }
      }, SetOptions(merge: true));
      showTopSnackbar(
        "Success",
        "All services cleared",
        Colors.green,
        Icons.check_circle,
      );
    } catch (e) {
      Get.snackbar("Error", "Failed to clear services: $e");
    }
  }

  void showTopSnackbar(String title, String message, Color color,
      IconData icon) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.TOP,
      backgroundColor: color,
      colorText: Colors.white,
      margin: const EdgeInsets.all(12),
      borderRadius: 14,
      icon: Icon(icon, color: Colors.white),
      duration: const Duration(seconds: 2),
      snackStyle: SnackStyle.FLOATING,
      boxShadows: [
        BoxShadow(
          color: Colors.black26,
          blurRadius: 10,
          offset: Offset(0, 4),
        ),
      ],
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }

}
