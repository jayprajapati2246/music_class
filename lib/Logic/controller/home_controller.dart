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

  @override
  void onInit() {
    super.onInit();

    // Listen total students - simple count update doesn't cause "random refresh" issues usually
    _studentsSub = _firestore
        .collection('students')
        .snapshots()
        .listen((snapshot) {
      totalStudents.value = snapshot.docs.length;
    });

    // Bind today's attendance stream
    todaysPresent.bindStream(
      _attendanceService.getTodaysPresentCountStream(),
    );

    // Listen today's payments
    _listenToTodaysPayments();

    // We removed the global payments listener that was triggering refreshDues() automatically.
    
    refreshData();
  }

  void _listenToTodaysPayments() {
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
    await refreshDues();
    // You can add other manual refresh logic here if needed
  }

  Future<void> refreshDues() async {
    final duesList = await _dueController.calculateDues();

    double total = 0;
    int count = 0;

    for (var item in duesList) {
      total += item['dueAmount'];
      if (item['dueAmount'] > 0) {
        count++;
      }
    }

    totalDues.value = total;
    studentsWithDues.value = count;
  }

  @override
  void onClose() {
    _studentsSub?.cancel();
    _todayPaymentsSub?.cancel();
    super.onClose();
  }
}
