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
      DocumentSnapshot doc = await _firestore.collection('users').doc(uid).get();

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
      Get.snackbar("Error", "Failed to fetch services: $e");
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
      Get.snackbar("Success", "Course added successfully");
    } catch (e) {
      Get.snackbar("Error", "Failed to add course: $e");
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
      Get.snackbar("Success", "Batch added successfully");
    } catch (e) {
      Get.snackbar("Error", "Failed to add batch: $e");
    }
  }

  Future<void> addFee() async {
    String fee = feeController.text.trim();
    if (fee.isEmpty) return;

    try {
      String uid = _auth.currentUser!.uid;
      fees.add(fee);
      await _firestore.collection('users').doc(uid).set({
        'services': {
          'fees': fees,
        }
      }, SetOptions(merge: true));
      feeController.clear();
      Get.snackbar("Success", "Fee option added successfully");
    } catch (e) {
      Get.snackbar("Error", "Failed to add fee: $e");
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
      Get.snackbar("Success", "All courses cleared");
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
      Get.snackbar("Success", "All batches cleared");
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
          'fees': [],
        }
      }, SetOptions(merge: true));
      Get.snackbar("Success", "All services cleared successfully");
    } catch (e) {
      Get.snackbar("Error", "Failed to clear services: $e");
    }
  }
}
