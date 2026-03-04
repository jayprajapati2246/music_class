import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../model/attundance.dart';

class AttendanceService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get _userId => _auth.currentUser?.uid;

  // Collection for a specific date: users/{userId}/attendance/{date}/records/{studentId}
  CollectionReference _attendanceRecords(String dateStr) {
    if (_userId == null) throw Exception("User not logged in");
    return _firestore
        .collection('users')
        .doc(_userId)
        .collection('attendance')
        .doc(dateStr)
        .collection('records');
  }

  // Mark attendance
  Future<void> markAttendance(AttendanceRecordModel record) async {
    final dateStr = "${record.date.year}-${record.date.month.toString().padLeft(2, '0')}-${record.date.day.toString().padLeft(2, '0')}";
    
    await _attendanceRecords(dateStr)
        .doc(record.studentId)
        .set(record.toMap());
  }

  // Get real-time stream of attendance for today
  Stream<List<AttendanceRecordModel>> getTodaysAttendanceStream() {
    final today = DateTime.now();
    final dateStr = "${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}";

    return _attendanceRecords(dateStr)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => AttendanceRecordModel.fromMap(doc.data() as Map<String, dynamic>, doc.id))
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
    final dateStr = "${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}";
    
    final snapshot = await _attendanceRecords(dateStr)
        .where('status', isEqualTo: 'present')
        .get();
    return snapshot.docs.length;
  }

  // Get attendance for a specific student across all dates
  // Since we changed the schema to be date-centric, we need a Collection Group query 
  // to find all 'records' where 'studentId' matches.
  Stream<List<AttendanceRecordModel>> getStudentAttendanceStream(String studentId) {
    if (_userId == null) return Stream.value([]);
    
    // Note: This requires a Firestore index for collection group 'records' with 'studentId' field.
    return _firestore
        .collectionGroup('records')
        .where('studentId', isEqualTo: studentId)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .where((doc) => doc.reference.path.contains('users/$_userId/attendance'))
            .map((doc) => AttendanceRecordModel.fromMap(doc.data() as Map<String, dynamic>, doc.id))
            .toList()
            ..sort((a, b) => b.date.compareTo(a.date)));
  }
}
