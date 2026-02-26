import 'package:cloud_firestore/cloud_firestore.dart';
import '../model/attundance.dart';

class AttendanceService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Mark attendance for a student on a specific date
  Future<void> markAttendance(AttendanceRecordModel record) async {
    final dateStr = "${record.date.year}-${record.date.month}-${record.date.day}";
    final docId = "${record.studentId}_$dateStr";
    
    await _firestore.collection('Attendance').doc(docId).set(record.toMap());
  }

  // Get real-time stream of attendance for a specific student
  Stream<List<AttendanceRecordModel>> getStudentAttendanceStream(String studentId) {
    return _firestore
        .collection('Attendance')
        .where('studentId', isEqualTo: studentId)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => AttendanceRecordModel.fromMap(doc.data(), doc.id))
            .toList());
  }

  // Get attendance for a specific month
  Stream<List<AttendanceRecordModel>> getMonthlyAttendanceStream(String studentId, DateTime month) {
    final startOfMonth = DateTime(month.year, month.month, 1);
    final endOfMonth = DateTime(month.year, month.month + 1, 0, 23, 59, 59);

    return _firestore
        .collection('Attendance')
        .where('studentId', isEqualTo: studentId)
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfMonth))
        .where('date', isLessThanOrEqualTo: Timestamp.fromDate(endOfMonth))
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => AttendanceRecordModel.fromMap(doc.data(), doc.id))
            .toList());
  }

  // New Stream for today's present count
  Stream<int> getTodaysPresentCountStream() {
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);
    final endOfDay = DateTime(today.year, today.month, today.day, 23, 59, 59);

    return _firestore
        .collection('Attendance')
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
        .where('date', isLessThanOrEqualTo: Timestamp.fromDate(endOfDay))
        .where('status', isEqualTo: 'present')
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  Future<int> getTodaysAttendance() async {
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);
    final endOfDay = DateTime(today.year, today.month, today.day, 23, 59, 59);
    
    final snapshot = await _firestore
        .collection('Attendance')
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
        .where('date', isLessThanOrEqualTo: Timestamp.fromDate(endOfDay))
        .where('status', isEqualTo: 'present')
        .get();
    return snapshot.docs.length;
  }
}
