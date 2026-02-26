import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:music_class/Logic/model/attundance.dart';
import 'package:music_class/Logic/Servisses/attendance.dart';

class AttendanceController extends GetxController {
  final AttendanceService _attendanceService = AttendanceService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final Rx<DateTime> selectedDate = DateTime.now().obs;
  final RxMap<String, String> attendanceStatus = <String, String>{}.obs;

  String get formattedDate => "${selectedDate.value.year}-${selectedDate.value.month}-${selectedDate.value.day}";

  void changeToPreviousDay() {
    selectedDate.value = selectedDate.value.subtract(const Duration(days: 1));
    fetchAttendanceForSelectedDate();
  }

  void changeToNextDay() {
    selectedDate.value = selectedDate.value.add(const Duration(days: 1));
    fetchAttendanceForSelectedDate();
  }

  Future<void> fetchAttendanceForSelectedDate() async {
    attendanceStatus.clear();
    final startOfDay = DateTime(selectedDate.value.year, selectedDate.value.month, selectedDate.value.day);
    final endOfDay = DateTime(selectedDate.value.year, selectedDate.value.month, selectedDate.value.day, 23, 59, 59);

    final snapshot = await _firestore
        .collection('Attendance')
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
        .where('date', isLessThanOrEqualTo: Timestamp.fromDate(endOfDay))
        .get();

    for (var doc in snapshot.docs) {
      final data = doc.data();
      attendanceStatus[data['studentId']] = data['status'];
    }
  }

  Future<void> markPresent(String studentId, String name) async {
    final record = AttendanceRecordModel(
      studentId: studentId,
      name: name,
      status: 'present',
      date: selectedDate.value,
    );
    await _attendanceService.markAttendance(record);
    attendanceStatus[studentId] = 'present';
  }

  Future<void> markAbsent(String studentId, String name) async {
    final record = AttendanceRecordModel(
      studentId: studentId,
      name: name,
      status: 'absent',
      date: selectedDate.value,
    );
    await _attendanceService.markAttendance(record);
    attendanceStatus[studentId] = 'absent';
  }

  int getPresentCount() => attendanceStatus.values.where((e) => e == 'present').length;
  int getAbsentCount() => attendanceStatus.values.where((e) => e == 'absent').length;
  int getUnmarkedCount(int totalStudents) => totalStudents - attendanceStatus.length;

  @override
  void onInit() {
    super.onInit();
    fetchAttendanceForSelectedDate();
  }
}
