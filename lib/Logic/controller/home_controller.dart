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
  StreamSubscription? _todayPaymentsSub;
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

    // For "Today's Attendance" and "Payments Today" in a nested schema,
    // we would ideally use Collection Group queries with a filter for the parent user,
    // or aggregate the data differently.
    // For now, I will update the listeners to use Collection Group if possible, 
    // but that requires indexes. 
    // A simpler way for a small number of students is to refresh them manually or 
    // keep the listeners as they were if we want to keep it simple, 
    // but the user wants the schema changed.
    
    // For now, let's keep it simple and refresh these on manual refresh or 
    // use a more complex logic if needed. 
    // I'll update the manual fetch to reflect the new structure.
    _listenToTodaysPayments();
  }

  void _listenToTodaysPayments() {
    // Note: This is harder with nested schema without Collection Group queries.
    // We'll rely more on manual refresh or update this once Collection Group is set up.
    // For now, I'll stop the listener and rely on manual fetch in refreshData.
    _todayPaymentsSub?.cancel();
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
      int presentTodayCount = 0;
      
      DateTime now = DateTime.now();
      String dateStr = "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";

      for (var studentDoc in studentDocs.docs) {
        // Fetch payments for today for this student
        final payments = await studentDoc.reference
            .collection('payments')
            .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(DateTime(now.year, now.month, now.day)))
            .get();
        
        for (var p in payments.docs) {
          totalPaymentsToday += (p.data()['amount'] ?? 0).toDouble();
        }

        // Check attendance for today for this student
        final attendanceDoc = await studentDoc.reference
            .collection('attendance')
            .doc("${studentDoc.id}_$dateStr")
            .get();
        
        if (attendanceDoc.exists && attendanceDoc.data()?['status'] == 'present') {
          presentTodayCount++;
        }
      }

      paymentsToday.value = totalPaymentsToday;
      todaysPresent.value = presentTodayCount;

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
