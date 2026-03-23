import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../model/attundance.dart';

class AttendanceService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get _userId => _auth.currentUser?.uid;

  // Path: users/{userId}/attendance/{date}/records/{studentId}
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
    if (_userId == null) return;
    
    final dateStr = "${record.date.year}-${record.date.month.toString().padLeft(2, '0')}-${record.date.day.toString().padLeft(2, '0')}";
    
    // Ensure userId is included for Collection Group queries
    final recordWithUser = AttendanceRecordModel(
      studentId: record.studentId,
      name: record.name,
      status: record.status,
      date: record.date,
      userId: _userId,
    );

    await _attendanceRecords(dateStr)
        .doc(record.studentId)
        .set(recordWithUser.toMap());
  }

  // Get real-time stream of attendance for today (for Home screen)
  Stream<List<AttendanceRecordModel>> getTodaysAttendanceStream() {
    if (_userId == null) return Stream.value([]);
    
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
    if (_userId == null) return 0;
    
    final today = DateTime.now();
    final dateStr = "${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}";
    
    try {
      final snapshot = await _attendanceRecords(dateStr)
          .where('status', isEqualTo: 'present')
          .get();
      return snapshot.docs.length;
    } catch (e) {
      print("Error getting attendance count: $e");
      return 0;
    }
  }

  // Get attendance for a specific student across all dates (for Edit/Detail screen)
  Stream<List<AttendanceRecordModel>> getStudentAttendanceStream(String studentId) {
    if (_userId == null) return Stream.value([]);
    
    // Filtering by 'userId' and 'studentId' in a Collection Group query.
    // This requires a Firestore Composite Index on 'records' (Collection Group) for fields: userId, studentId.
    return _firestore
        .collectionGroup('records')
        .where('userId', isEqualTo: _userId)
        .where('studentId', isEqualTo: studentId)
        .snapshots()
        .handleError((error) {
          print("Firestore Collection Group Error: $error");
          // If the index is missing, this will print the URL to create it.
        })
        .map((snapshot) {
          final list = snapshot.docs
            .map((doc) => AttendanceRecordModel.fromMap(doc.data() as Map<String, dynamic>, doc.id))
            .toList();
          list.sort((a, b) => b.date.compareTo(a.date));
          return list;
        });
  }
}
