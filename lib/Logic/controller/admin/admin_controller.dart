import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import '../../model/Student.dart';

class AdminController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  var users = <Map<String, dynamic>>[].obs;
  var isLoadingUsers = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchAllUsers();
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
      Get.snackbar("Error", "Failed to fetch users: $e");
    } finally {
      isLoadingUsers.value = false;
    }
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

      Get.snackbar("Success", "Student updated successfully");
    } catch (e) {
      Get.snackbar("Error", "Update failed: $e");
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

      Get.snackbar("Success", "Student deleted successfully");
    } catch (e) {
      Get.snackbar("Error", "Delete failed: $e");
    }
  }
}