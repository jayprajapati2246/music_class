import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:music_class/Logic/Servisses/attendance.dart';
import 'due.dart';

class HomeController extends GetxController {
  final AttendanceService _attendanceService = AttendanceService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final DueController _dueController = DueController();

  final RxInt totalStudents = 0.obs;
  final RxInt todaysPresent = 0.obs;
  final RxDouble totalDues = 0.0.obs;
  final RxDouble paymentsToday = 0.0.obs;

  @override
  void onInit() {
    super.onInit();
    
    // Stream for total students
    _firestore.collection('students').snapshots().listen((snapshot) {
      totalStudents.value = snapshot.docs.length;
      refreshDues(); // Recalculate dues when students change
    });

    // Stream for today's present count
    todaysPresent.bindStream(_attendanceService.getTodaysPresentCountStream());

    // Stream for today's payments
    _listenToTodaysPayments();
    
    refreshDues();
  }

  void _listenToTodaysPayments() {
    DateTime now = DateTime.now();
    DateTime startOfDay = DateTime(now.year, now.month, now.day);
    DateTime endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59);

    _firestore.collection('payments')
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

  Future<void> refreshDues() async {
    final duesList = await _dueController.calculateDues();
    double total = 0;
    for (var item in duesList) {
      total += item['dueAmount'];
    }
    totalDues.value = total;
  }
}
