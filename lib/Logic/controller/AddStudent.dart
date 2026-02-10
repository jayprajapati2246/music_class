import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../screen/student/addnewstudent.dart';
import '../Servisses/student.dart';
import '../model/Student.dart';

class Addstudentcontroller extends GetxController {
  final AddStudentService _service = AddStudentService();

  String? selectedCourse;
  String? selectedBatchType;
  String? selectedPaymentType;
  String? selectedbatchtime;

  final List<String> courses = ['Guitar', 'Piano', 'Drums', 'Violin'];
  final List<String> batchTypes = ['Everyday', 'Alternate Days'];
  final List<String> paymentTypes = ['Per Class', 'Monthly'];
  final List<String> batchtime = [
    '9:00 AM - 10:00 AM',
    '10:00 AM - 11:00 AM',
    '11:00 AM - 12:00 PM',
    '2:00 PM - 3:00 PM',
    '3:00 PM - 4:00 PM',
    '4:00 PM - 5:00 PM',
    '5:00 PM - 6:00 PM',
    '6:00 PM - 7:00 PM',
  ];

  DateTime? joinDate;

  final TextEditingController joinDateController = TextEditingController();
  final TextEditingController amountController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();

  Future<void> addStudent() async {
    if (nameController.text.trim().isEmpty ||
        phoneController.text.trim().isEmpty ||
        selectedCourse == null ||
        selectedbatchtime == null ||
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
      return;
    }

    final student = StudentModel(
      name: nameController.text.trim(),
      phone: phoneController.text.trim(),
      course: selectedCourse!,
      batchTime: selectedbatchtime!,
      batchType: selectedBatchType!,
      paymentType: selectedPaymentType!,
      monthlyFee: double.parse(amountController.text.trim()),
      joinDate: joinDate!,
    );

    await _service.addStudent(student);

    Get.snackbar(
      "Success",
      "Student added successfully",
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.green,
      colorText: Colors.white,
    );
    // Get.back();
    clearControllers();

    Get.offAll(() => const Addnstudent());
  }

  void clearControllers() {
    nameController.clear();
    phoneController.clear();
    amountController.clear();
    joinDateController.clear();

    selectedCourse = null;
    selectedbatchtime = null;
    selectedBatchType = null;
    selectedPaymentType = null;
    joinDate = null;
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
