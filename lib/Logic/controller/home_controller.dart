import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:music_class/Logic/Servisses/attendance.dart';

class HomeController extends GetxController {
  final AttendanceService _attendanceService = AttendanceService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final RxInt totalStudents = 0.obs;
  final RxInt todaysPresent = 0.obs;

  @override
  void onInit() {
    super.onInit();
    // Stream for total students - Using 'students' collection as per AddStudentService
    _firestore.collection('students').snapshots().listen((snapshot) {
      totalStudents.value = snapshot.docs.length;
    });

    // Stream for today's present count
    todaysPresent.bindStream(_attendanceService.getTodaysPresentCountStream());
  }
}
