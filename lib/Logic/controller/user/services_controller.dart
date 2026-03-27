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
      
      // 1. Try to fetch from the new subcollection structure
      QuerySnapshot snapshot = await _firestore
          .collection('users')
          .doc(uid)
          .collection('services')
          .get();

      List<String> tempCourses = [];
      List<String> tempBatches = [];
      List<String> tempFees = [];

      for (var doc in snapshot.docs) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        if (data['course'] != null && data['course'].toString().isNotEmpty) {
          tempCourses.add(data['course']);
        }
        if (data['batch'] != null && data['batch'].toString().isNotEmpty) {
          tempBatches.add(data['batch']);
        }
        if (data['batchTimes'] is List) {
          tempBatches.addAll(List<String>.from(data['batchTimes']));
        }
        if (data['fee'] != null) {
          tempFees.add(data['fee'].toString());
        }
      }

      // 2. Check for old data in the 'services' field for migration or backward compatibility
      DocumentSnapshot userDoc = await _firestore.collection('users').doc(uid).get();
      if (userDoc.exists) {
        Map<String, dynamic> data = userDoc.data() as Map<String, dynamic>;
        if (data['services'] != null) {
          Map<String, dynamic> servicesField = data['services'];
          
          List<String> oldCourses = List<String>.from(servicesField['courses'] ?? []);
          List<String> oldBatches = List<String>.from(servicesField['batchTimes'] ?? []);
          List<String> oldFees = List<String>.from(servicesField['fees'] ?? []);

          // Add only if not already present in subcollection
          for (var c in oldCourses) {
            if (!tempCourses.contains(c)) {
              tempCourses.add(c);
              // Migrate to subcollection automatically
              await _firestore.collection('users').doc(uid).collection('services').add({
                'course': c,
                'status': 'Active',
                'updatedAt': FieldValue.serverTimestamp(),
              });
            }
          }
          for (var b in oldBatches) {
            if (!tempBatches.contains(b)) {
              tempBatches.add(b);
              await _firestore.collection('users').doc(uid).collection('services').add({
                'batch': b,
                'status': 'Active',
                'updatedAt': FieldValue.serverTimestamp(),
              });
            }
          }
          for (var f in oldFees) {
            if (!tempFees.contains(f)) {
              tempFees.add(f);
              await _firestore.collection('users').doc(uid).collection('services').add({
                'fee': double.tryParse(f) ?? 0.0,
                'status': 'Active',
                'updatedAt': FieldValue.serverTimestamp(),
              });
            }
          }

          // 3. Remove the old 'services' field from the root document
          await _firestore.collection('users').doc(uid).update({
            'services': FieldValue.delete(),
          });
        }
      }

      courses.value = tempCourses.toSet().toList();
      batchTimes.value = tempBatches.toSet().toList();
      fees.value = tempFees.toSet().toList();

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
      
      if (!courses.contains(course)) {
        courses.add(course);
        // Add to subcollection as a separate document
        await _firestore.collection('users').doc(uid).collection('services').add({
          'course': course,
          'status': 'Active',
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }
      
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
      
      if (!batchTimes.contains(batch)) {
        batchTimes.add(batch);
        // Add to subcollection as a separate document
        await _firestore.collection('users').doc(uid).collection('services').add({
          'batch': batch,
          'status': 'Active',
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }
      
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
      String courseName = courses[index];
      courses.removeAt(index);
      
      // Delete documents with this course name in subcollection
      var snapshots = await _firestore
          .collection('users')
          .doc(uid)
          .collection('services')
          .where('course', isEqualTo: courseName)
          .get();
      
      for (var doc in snapshots.docs) {
        await doc.reference.delete();
      }
    } catch (e) {
      Get.snackbar("Error", "Failed to remove course: $e");
    }
  }

  Future<void> removeBatch(int index) async {
    try {
      String uid = _auth.currentUser!.uid;
      String batchName = batchTimes[index];
      batchTimes.removeAt(index);
      
      // Delete documents with this batch name in subcollection
      var snapshots = await _firestore
          .collection('users')
          .doc(uid)
          .collection('services')
          .where('batch', isEqualTo: batchName)
          .get();
      
      for (var doc in snapshots.docs) {
        await doc.reference.delete();
      }
    } catch (e) {
      Get.snackbar("Error", "Failed to remove batch: $e");
    }
  }

  Future<void> removeFee(int index) async {
    try {
      String uid = _auth.currentUser!.uid;
      String feeValue = fees[index];
      fees.removeAt(index);
      
      double? feeNum = double.tryParse(feeValue);
      if (feeNum != null) {
        var snapshots = await _firestore
            .collection('users')
            .doc(uid)
            .collection('services')
            .where('fee', isEqualTo: feeNum)
            .get();
        
        for (var doc in snapshots.docs) {
          await doc.reference.delete();
        }
      }
    } catch (e) {
      Get.snackbar("Error", "Failed to remove fee: $e");
    }
  }

  Future<void> clearCourses() async {
    try {
      String uid = _auth.currentUser!.uid;
      courses.clear();
      
      var snapshots = await _firestore
          .collection('users')
          .doc(uid)
          .collection('services')
          .get();
      
      for (var doc in snapshots.docs) {
        if (doc.data().containsKey('course')) {
          await doc.reference.delete();
        }
      }

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
      
      var snapshots = await _firestore
          .collection('users')
          .doc(uid)
          .collection('services')
          .get();
      
      for (var doc in snapshots.docs) {
        if (doc.data().containsKey('batch')) {
          await doc.reference.delete();
        }
      }

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
      
      var snapshots = await _firestore
          .collection('users')
          .doc(uid)
          .collection('services')
          .get();
      
      for (var doc in snapshots.docs) {
        await doc.reference.delete();
      }

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
