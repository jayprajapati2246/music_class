import 'dart:async';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:music_class/Logic/Servisses/attendance.dart';
import 'due.dart';

class HomeController extends GetxController {
  final AttendanceService _attendanceService = AttendanceService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final DueController _dueController = DueController();

  // Reactive Variables
  final RxInt totalStudents = 0.obs;
  final RxInt todaysPresent = 0.obs;
  final RxDouble totalDues = 0.0.obs;
  final RxDouble paymentsToday = 0.0.obs;
  final RxInt studentsWithDues = 0.obs;

  // Stream Subscriptions
  StreamSubscription? _studentsSub;
  StreamSubscription? _todayPaymentsSub;
  StreamSubscription? _attendanceSub;

  @override
  void onInit() {
    super.onInit();
    _setupListeners();
    refreshData();
  }

  void _setupListeners() {
    // Listen total students
    _studentsSub?.cancel();
    _studentsSub = _firestore
        .collection('students')
        .snapshots()
        .listen((snapshot) {
      totalStudents.value = snapshot.docs.length;
    });

    // Bind today's attendance stream
    _attendanceSub?.cancel();
    _attendanceSub = _attendanceService
        .getTodaysPresentCountStream()
        .listen((count) {
      todaysPresent.value = count;
    });

    // Listen today's payments
    _listenToTodaysPayments();
  }

  void _listenToTodaysPayments() {
    _todayPaymentsSub?.cancel();
    DateTime now = DateTime.now();
    DateTime startOfDay = DateTime(now.year, now.month, now.day);
    DateTime endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59);

    _todayPaymentsSub = _firestore
        .collection('payments')
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
        .where('date', isLessThanOrEqualTo: Timestamp.fromDate(endOfDay))
        .snapshots()
        .listen((snapshot) {
      double total = 0;
      for (var doc in snapshot.docs) {
        total += (doc.data()['amount'] ?? 0).toDouble();
      }
      paymentsToday.value = total;
    });
  }

  // Combined refresh method
  Future<void> refreshData() async {
    // Re-trigger listeners to ensure we have fresh stream connections
    _setupListeners();

    // Manually refresh the calculated data
    await refreshDues();

    // Fetch non-stream data if any
    await _manualFetchStats();
  }

  Future<void> _manualFetchStats() async {
    // Manually fetch counts to ensure UI updates immediately even if stream is slow
    try {
      final students = await _firestore.collection('students').get();
      totalStudents.value = students.docs.length;

      // Fixed: changed getTodaysAttendance to getTodaysAttendanceCount to match AttendanceService
      final attendanceCount = await _attendanceService.getTodaysAttendanceCount();
      todaysPresent.value = attendanceCount;

      // Payments today manual fetch
      DateTime now = DateTime.now();
      DateTime startOfDay = DateTime(now.year, now.month, now.day);
      DateTime endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59);

      final payments = await _firestore
          .collection('payments')
          .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
          .where('date', isLessThanOrEqualTo: Timestamp.fromDate(endOfDay))
          .get();

      double total = 0;
      for (var doc in payments.docs) {
        total += (doc.data()['amount'] ?? 0).toDouble();
      }
      paymentsToday.value = total;
    } catch (e) {
      Get.log("Error refreshing stats: $e");
    }
  }

  Future<void> refreshDues() async {
    try {
      final duesList = await _dueController.calculateDues();

      double total = 0;
      int count = 0;

      for (var item in duesList) {
        total += (item['dueAmount'] as num).toDouble();
        if (item['dueAmount'] > 0) {
          count++;
        }
      }

      totalDues.value = total;
      studentsWithDues.value = count;
    } catch (e) {
      Get.log("Error calculating dues: $e");
    }
  }

  @override
  void onClose() {
    _studentsSub?.cancel();
    _todayPaymentsSub?.cancel();
    _attendanceSub?.cancel();
    super.onClose();
  }
}
