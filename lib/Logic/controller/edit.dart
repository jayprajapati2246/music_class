import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:music_class/Logic/model/Student.dart';
import 'package:music_class/Logic/model/attundance.dart';
import 'package:music_class/Logic/model/payment.dart';
import 'package:music_class/Logic/Servisses/attendance.dart';
import 'package:music_class/Logic/Servisses/payment_service.dart';
import 'package:music_class/Logic/controller/student_controller.dart';

class StudentDetailController extends GetxController {
  late Rx<StudentModel> student;

  StudentDetailController(StudentModel initialStudent) {
    student = initialStudent.obs;
  }

  final StudentController studentController = Get.find<StudentController>();
  final PaymentService _paymentService = PaymentService();
  final AttendanceService _attendanceService = AttendanceService();

  RxInt selectedTab = 0.obs;
  RxBool isLoading = false.obs;
  RxDouble balance = 800.0.obs;

  final TextEditingController paymentAmountController = TextEditingController();

  // Attendance related
  Rx<DateTime> focusedDay = DateTime.now().obs;
  
  Stream<List<AttendanceRecordModel>> get attendanceStream =>
      _attendanceService.getStudentAttendanceStream(student.value.id!);

  Stream<List<PaymentModel>> get paymentStream =>
      _paymentService.getPaymentsForStudent(student.value.name);

  void changeTab(int index) {
    selectedTab.value = index;
  }

  void refreshStudent() {
    final updatedStudent = studentController.students.firstWhereOrNull(
          (s) => s.id == student.value.id,
    );
    if (updatedStudent != null) {
      student.value = updatedStudent;
    }
  }

  Future<void> deleteStudent() async {
    await studentController.deleteStudent(student.value.id!);
    Get.back(result: true);
  }

  Future<void> recordPayment() async {
    if (paymentAmountController.text.trim().isEmpty) {
      Get.snackbar("Error", "Please enter an amount");
      return;
    }

    final amount = double.tryParse(paymentAmountController.text.trim());

    if (amount == null || amount <= 0) {
      Get.snackbar("Error", "Enter valid amount");
      return;
    }

    final payment = PaymentModel(
      studentName: student.value.name,
      amount: amount,
      date: DateTime.now(),
    );

    try {
      await _paymentService.addPayment(payment);
      paymentAmountController.clear();
      selectedTab.value = 1;
      Get.snackbar("Success", "Payment recorded successfully", backgroundColor: Colors.green, colorText: Colors.white);
    } catch (e) {
      Get.snackbar("Error", "Failed to record payment");
    }
  }

  Future<void> markAttendance(DateTime date, String status) async {
    final record = AttendanceRecordModel(
      studentId: student.value.id!,
      name: student.value.name,
      status: status,
      date: date,
    );
    await _attendanceService.markAttendance(record);
  }

  @override
  void onClose() {
    paymentAmountController.dispose();
    super.onClose();
  }
}
