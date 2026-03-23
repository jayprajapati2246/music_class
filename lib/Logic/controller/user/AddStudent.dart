import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../Servisses/student.dart';
import '../../model/Student.dart';

class Addstudentcontroller extends GetxController {
  final AddStudentService _service = AddStudentService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String? targetUserId; 

  String? selectedCourse;
  String? selectedBatchType;
  String? selectedPaymentType;
  String? selectedBatchTime;

  var courses = <String>['Guitar', 'Piano', 'Drums', 'Violin'].obs;
  final List<String> batchTypes = ['Everyday', 'Alternate Days'];
  final List<String> paymentTypes = ['Per Class', 'Monthly'];
  var batchTime = <String>[
    '7:00 AM - 8:00 AM',
    '8:00 AM - 9:00 AM',
    '9:00 AM - 10:00 AM',
    '10:00 AM - 11:00 AM',
    '11:00 AM - 12:00 PM',
    '12:00 PM - 1:00 PM',
    '1:00 PM - 2:00 PM',
    '2:00 PM - 3:00 PM',
    '3:00 PM - 4:00 PM',
    '4:00 PM - 5:00 PM',
    '5:00 PM - 6:00 PM',
    '6:00 PM - 7:00 PM',
  ].obs;

  DateTime? joinDate;
  DateTime? get initialDate => joinDate;

  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController amountController = TextEditingController();
  final TextEditingController joinDateController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    fetchDynamicSettings();
  }

  Future<void> fetchDynamicSettings() async {
    try {
      DocumentSnapshot doc = await _firestore.collection('settings').doc('app_settings').get();
      if (doc.exists) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        if (data['courses'] != null) {
          courses.value = List<String>.from(data['courses']);
        }
        if (data['batchTimes'] != null) {
          batchTime.value = List<String>.from(data['batchTimes']);
        }
      }
    } catch (e) {
      debugPrint("Error fetching dynamic settings: $e");
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

    selectedCourse = null;
    selectedBatchTime = null;
    selectedBatchType = null;
    selectedPaymentType = null;
    joinDate = null;
    targetUserId = null;
  }

  @override
  void onClose() {
    nameController.dispose();
    phoneController.dispose();
    amountController.dispose();
    joinDateController.dispose();
    super.onClose();
  }
}
