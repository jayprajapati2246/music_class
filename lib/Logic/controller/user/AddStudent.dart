import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../Servisses/student.dart';
import '../../model/Student.dart';

class Addstudentcontroller extends GetxController {
  final AddStudentService _service = AddStudentService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? targetUserId;

  String? selectedCourse;
  String? selectedBatchType;
  String? selectedPaymentType;
  String? selectedBatchTime;
  String selectedStatus = 'Active';

  var courses = <String>[].obs;
  final List<String> batchTypes = ['Everyday', 'Alternate Days'];
  final List<String> paymentTypes = ['Per Class', 'Monthly'];
  final List<String> statuses = ['Active', 'Inactive'];
  var batchTime = <String>[].obs;

  DateTime? joinDate;

  DateTime? get initialDate => joinDate;

  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController amountController = TextEditingController();
  final TextEditingController joinDateController = TextEditingController();
  final TextEditingController sourceController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    fetchUserServices();
  }

  Future<void> fetchUserServices() async {
    try {
      String uid = targetUserId ?? _auth.currentUser!.uid;
      DocumentSnapshot doc = await _firestore
          .collection('users')
          .doc(uid)
          .get();

      if (doc.exists) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        if (data['services'] != null) {
          Map<String, dynamic> services = data['services'];

          List<String> userCourses = List<String>.from(
            services['courses'] ?? [],
          );
          List<String> userBatches = List<String>.from(
            services['batchTimes'] ?? [],
          );

          if (userCourses.isNotEmpty) {
            courses.value = userCourses;
          } else {
            courses.value = [];
          }

          if (userBatches.isNotEmpty) {
            batchTime.value = userBatches;
          } else {
            batchTime.value = [];
          }
        } else {
          courses.value = [];
          batchTime.value = [];
        }
      }
    } catch (e) {
      debugPrint("Error fetching user services: $e");
    }
  }

  Future<void> addStudent() async {
    if (!_validate()) return;

    final student = StudentModel(
      name: nameController.text.trim(),
      phone: phoneController.text.trim(),
      course: selectedCourse!,
      batchTime: selectedBatchTime!,
      batchType: selectedBatchType!,
      paymentType: selectedPaymentType!,
      monthlyFee: double.parse(amountController.text.trim()),
      joinDate: joinDate!,
      source: sourceController.text.trim(),
      status: selectedStatus,
    );

    try {
      await _service.addStudent(student, userId: targetUserId);
      Get.back(result: true);

      Get.snackbar(
        "Success",
        "Student added successfully",
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

      clearControllers();
    } catch (e) {
      Get.snackbar(
        "Error",
        "Failed to add student: ${e.toString()}",
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> updateStudent(String studentId) async {
    if (!_validate()) return;

    final student = StudentModel(
      id: studentId,
      name: nameController.text.trim(),
      phone: phoneController.text.trim(),
      course: selectedCourse!,
      batchTime: selectedBatchTime!,
      batchType: selectedBatchType!,
      paymentType: selectedPaymentType!,
      monthlyFee: double.parse(amountController.text.trim()),
      joinDate: joinDate!,
      source: sourceController.text.trim(),
      status: selectedStatus,
    );

    try {
      await _service.updateStudent(student, userId: targetUserId);
      Get.back(result: true);

      Get.snackbar(
        "Success",
        "Student updated successfully",
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

      clearControllers();
    } catch (e) {
      Get.snackbar(
        "Error",
        "Failed to update student: ${e.toString()}",
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  bool _validate() {
    if (nameController.text.trim().isEmpty ||
        phoneController.text.trim().isEmpty ||
        selectedCourse == null ||
        selectedBatchTime == null ||
        selectedBatchType == null ||
        selectedPaymentType == null ||
        amountController.text.trim().isEmpty ||
        joinDate == null) {
      Get.snackbar(
        "Error",
        "Please fill all fields",
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    }
    return true;
  }

  void clearControllers() {
    nameController.clear();
    phoneController.clear();
    amountController.clear();
    joinDateController.clear();
    sourceController.clear();

    selectedCourse = null;
    selectedBatchTime = null;
    selectedBatchType = null;
    selectedPaymentType = null;
    selectedStatus = 'Active';
    joinDate = null;
    targetUserId = null;
  }

  @override
  void onClose() {
    nameController.dispose();
    phoneController.dispose();
    amountController.dispose();
    joinDateController.dispose();
    sourceController.dispose();
    super.onClose();
  }
}
