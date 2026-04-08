import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/utils/snackbar_utils.dart';
import '../../model/Student.dart';
import '../../model/service_model.dart';

class AdminController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  var users = <Map<String, dynamic>>[].obs;
  var isLoadingUsers = false.obs;

  var totalUsers = 0.obs;
  var totalStudents = 0.obs;
  var totalFees = 0.0.obs;

  @override
  void onInit() {
    super.onInit();
    fetchAllUsers();
    fetchStats();
  }

  Future<void> fetchStats() async {
    try {
      // 1. Count Total Users
      QuerySnapshot usersSnapshot = await _firestore.collection('users').get();
      totalUsers.value = usersSnapshot.docs.length;

      // 2. Count Total Students & Fees
      int studentCount = 0;
      double feesSum = 0.0;

      for (var userDoc in usersSnapshot.docs) {
        QuerySnapshot studentSnapshot = await _firestore
            .collection('users')
            .doc(userDoc.id)
            .collection('students')
            .get();
        studentCount += studentSnapshot.docs.length;

        for (var studentDoc in studentSnapshot.docs) {
          // Calculate total fees from payments subcollection
          QuerySnapshot paymentsSnapshot = await studentDoc.reference.collection('payments').get();
          for (var paymentDoc in paymentsSnapshot.docs) {
            feesSum += (paymentDoc.data() as Map<String, dynamic>)['amount'] ?? 0;
          }
        }
      }

      totalStudents.value = studentCount;
      totalFees.value = feesSum;
    } catch (e) {
      print("Error fetching stats: $e");
    }
  }

  Future<double> getTotalCollectedForUser(String userId) async {
    double total = 0.0;
    try {
      final studentsSnapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('students')
          .get();

      for (var studentDoc in studentsSnapshot.docs) {
        final paymentsSnapshot = await studentDoc.reference.collection('payments').get();
        for (var paymentDoc in paymentsSnapshot.docs) {
          final data = paymentDoc.data() as Map<String, dynamic>;
          total += (data['amount'] ?? 0).toDouble();
        }
      }
    } catch (e) {
      print("Error fetching total collected for user: $e");
    }
    return total;
  }

  Future<void> fetchAllUsers() async {
    try {
      isLoadingUsers.value = true;

      QuerySnapshot snapshot = await _firestore.collection('users').get();

      users.value = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['uid'] = doc.id;
        return data;
      }).toList();
    } catch (e) {
      SnackbarUtils.showAttractiveSnackbar("Error", "Failed to fetch users: $e", isError: true);
    } finally {
      isLoadingUsers.value = false;
    }
  }

  Stream<DocumentSnapshot> getUserStream(String userId) {
    return _firestore.collection('users').doc(userId).snapshots();
  }

  Stream<List<ServiceModel>> getServicesStream(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('services')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return ServiceModel.fromMap(doc.data(), doc.id);
      }).toList();
    });
  }

  Stream<List<StudentModel>> getStudentsForUser(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('students')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return StudentModel.fromMap(doc.data(), doc.id);
      }).toList();
    });
  }

  Future<void> updateStudentDetails(String userId, StudentModel student) async {
    try {
      if (student.id == null) return;

      await _firestore
          .collection('users')
          .doc(userId)
          .collection('students')
          .doc(student.id)
          .update(student.toMap());

      SnackbarUtils.showAttractiveSnackbar("Success", "Student updated successfully");
      fetchStats(); // Refresh stats
    } catch (e) {
      SnackbarUtils.showAttractiveSnackbar("Error", "Update failed: $e", isError: true);
    }
  }

  Future<void> deleteStudent(String userId, String studentId) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('students')
          .doc(studentId)
          .delete();

      SnackbarUtils.showAttractiveSnackbar("Success", "Student deleted successfully");
      fetchStats(); // Refresh stats
    } catch (e) {
      SnackbarUtils.showAttractiveSnackbar("Error", "Delete failed: $e", isError: true);
    }
  }

  Future<void> deleteUser(String userId) async {
    try {
      // 1. Delete all students in the subcollection
      var studentDocs = await _firestore
          .collection('users')
          .doc(userId)
          .collection('students')
          .get();

      for (var doc in studentDocs.docs) {
        await doc.reference.delete();
      }

      // 2. Delete all services in the subcollection
      var serviceDocs = await _firestore
          .collection('users')
          .doc(userId)
          .collection('services')
          .get();

      for (var doc in serviceDocs.docs) {
        await doc.reference.delete();
      }

      // 3. Delete the user document
      await _firestore.collection('users').doc(userId).delete();

      // 4. Update local state
      users.removeWhere((u) => u['uid'] == userId);

      SnackbarUtils.showAttractiveSnackbar("Success", "User and all associated data deleted");
      fetchStats(); // Update dashboard stats
    } catch (e) {
      SnackbarUtils.showAttractiveSnackbar("Error", "Failed to delete user: $e", isError: true);
    }
  }
}