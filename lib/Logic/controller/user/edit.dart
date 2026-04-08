import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:music_class/Logic/controller/user/student_controller.dart';
import 'package:music_class/Logic/model/Student.dart';
import 'package:music_class/Logic/model/attundance.dart';
import 'package:music_class/Logic/model/payment.dart';
import 'package:music_class/Logic/Servisses/attendance.dart';
import 'package:music_class/Logic/Servisses/payment_service.dart';
import 'due.dart';

class StudentDetailController extends GetxController {
  late Rx<StudentModel> student;

  StudentDetailController(StudentModel initialStudent) {
    student = initialStudent.obs;
  }

  final StudentController studentController = Get.find<StudentController>();
  final PaymentService _paymentService = PaymentService();
  final AttendanceService _attendanceService = AttendanceService();
  final DueController _dueController = DueController();

  RxInt selectedTab = 0.obs;
  RxDouble balance = 0.0.obs;
  final TextEditingController paymentAmountController = TextEditingController();

  // Attendance related
  Rx<DateTime> focusedDay = DateTime.now().obs;

  late Stream<List<AttendanceRecordModel>> attendanceStream;
  late Stream<List<PaymentModel>> paymentStream;

  @override
  void onInit() {
    super.onInit();
    attendanceStream = _attendanceService.getStudentAttendanceStream(student.value.id!);
    paymentStream = _paymentService.getPaymentsForStudent(student.value.id!);
    calculateBalance();
  }

  void changeTab(int index) {
    selectedTab.value = index;
  }

  Future<void> calculateBalance() async {
    final dueData = await _dueController.calculateStudentDue(student.value);
    balance.value = dueData['dueAmount'];
  }

  void refreshStudent() async {
    final updatedStudent = studentController.students.firstWhereOrNull((s) => s.id == student.value.id);
    if (updatedStudent != null) {
      student.value = updatedStudent;
      calculateBalance();
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
      studentId: student.value.id!,
      amount: amount,
      date: DateTime.now(),
      month: DateFormat('MMMM yyyy').format(DateTime.now()),
      note: "Paid from detail screen",
    );

    try {
      await _paymentService.addPayment(payment);
      paymentAmountController.clear();
      await calculateBalance();
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