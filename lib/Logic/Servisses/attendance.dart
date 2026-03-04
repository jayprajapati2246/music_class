import 'package:cloud_firestore/cloud_firestore.dart';
import '../model/attundance.dart';

class AttendanceService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Mark attendance in a flat 'Attendance' collection for easier querying
  Future<void> markAttendance(AttendanceRecordModel record) async {
    final dateStr = "${record.date.year}-${record.date.month.toString().padLeft(2, '0')}-${record.date.day.toString().padLeft(2, '0')}";
    final docId = "${record.studentId}_$dateStr";
    
    await _firestore
        .collection('Attendance')
        .doc(docId)
        .set(record.toMap());
  }

  // Get real-time stream of attendance for today
  Stream<List<AttendanceRecordModel>> getTodaysAttendanceStream() {
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);
    final endOfDay = DateTime(today.year, today.month, today.day, 23, 59, 59);

    return _firestore
        .collection('Attendance')
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
        .where('date', isLessThanOrEqualTo: Timestamp.fromDate(endOfDay))
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => AttendanceRecordModel.fromMap(doc.data(), doc.id))
            .toList());
  }

  // Stream of count for today's present students
  Stream<int> getTodaysPresentCountStream() {
    return getTodaysAttendanceStream().map((records) => 
      records.where((r) => r.status == 'present').length
    );
  }

  // Future for count of today's present students
  Future<int> getTodaysAttendanceCount() async {
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

  // Get attendance for a specific student
  Stream<List<AttendanceRecordModel>> getStudentAttendanceStream(String studentId) {
    return _firestore
        .collection('Attendance')
        .where('studentId', isEqualTo: studentId)
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => AttendanceRecordModel.fromMap(doc.data(), doc.id))
            .toList());
  }
}
