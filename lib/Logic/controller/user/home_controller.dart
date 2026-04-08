import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:music_class/Logic/Servisses/attendance.dart';

import 'due.dart';


class HomeController extends GetxController {
  final AttendanceService _attendanceService = AttendanceService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DueController _dueController = DueController();

  String? get _userId => _auth.currentUser?.uid;

  // Reactive Variables
  final RxInt totalStudents = 0.obs;
  final RxInt todaysPresent = 0.obs;
  final RxDouble totalDues = 0.0.obs;
  final RxDouble paymentsToday = 0.0.obs;
  final RxInt studentsWithDues = 0.obs;

  // Stream Subscriptions
  StreamSubscription? _studentsSub;
  StreamSubscription? _attendanceSub;

  @override
  void onInit() {
    super.onInit();
    _setupListeners();
    refreshData();
  }

  void _setupListeners() {
    if (_userId == null) return;

    // Listen total students
    _studentsSub?.cancel();
    _studentsSub = _firestore
        .collection('users')
        .doc(_userId)
        .collection('students')
        .snapshots()
        .listen((snapshot) {
      totalStudents.value = snapshot.docs.length;
    });

    // Listen for today's attendance updates
    _attendanceSub?.cancel();
    _attendanceSub = _attendanceService.getTodaysPresentCountStream().listen((count) {
      todaysPresent.value = count;
    });
  }

  // Combined refresh method
  Future<void> refreshData() async {
    if (_userId == null) return;

    // Re-trigger listeners
    _setupListeners();

    // Manually refresh the calculated data
    await refreshDues();

    // Fetch non-stream data
    await _manualFetchStats();
  }

  Future<void> _manualFetchStats() async {
    if (_userId == null) return;

    try {
      final studentDocs = await _firestore
          .collection('users')
          .doc(_userId)
          .collection('students')
          .get();

      totalStudents.value = studentDocs.docs.length;

      double totalPaymentsToday = 0;

      DateTime now = DateTime.now();
      DateTime startOfDay = DateTime(now.year, now.month, now.day);
      DateTime endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59);

      for (var studentDoc in studentDocs.docs) {
        // Fetch payments for today for this student (Payments are nested under students)
        final payments = await studentDoc.reference
            .collection('payments')
            .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
            .where('date', isLessThanOrEqualTo: Timestamp.fromDate(endOfDay))
            .get();

        for (var p in payments.docs) {
          totalPaymentsToday += (p.data()['amount'] ?? 0).toDouble();
        }
      }

      paymentsToday.value = totalPaymentsToday;

      // Use service to get attendance count (Optimized path)
      final attendanceCount = await _attendanceService.getTodaysAttendanceCount();
      todaysPresent.value = attendanceCount;

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
    _attendanceSub?.cancel();
    super.onClose();
  }
}