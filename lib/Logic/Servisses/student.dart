import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../model/Student.dart';

class AddStudentService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get _currentUserId => _auth.currentUser?.uid;

  CollectionReference _getStudentCollection(String? userId) {
    final targetId = userId ?? _currentUserId;
    if (targetId == null) throw Exception("User ID not provided and no user logged in");
    return _firestore
        .collection('users')
        .doc(targetId)
        .collection('students');
  }

  Future<void> addStudent(StudentModel student, {String? userId}) async {
    await _getStudentCollection(userId).add(student.toMap());
  }

  Future<List<StudentModel>> getStudents({String? userId}) async {
    final snapshot = await _getStudentCollection(userId).get();

    return snapshot.docs
        .map(
          (doc) => StudentModel.fromMap(
        doc.data() as Map<String, dynamic>,
        doc.id,
      ),
    )
        .toList();
  }

  Future<void> updateStudent(StudentModel student, {String? userId}) async {
    if (student.id == null) return;
    await _getStudentCollection(userId)
        .doc(student.id)
        .update(student.toMap());
  }

  Future<void> deleteStudent(String studentId, {String? userId}) async {
    await _getStudentCollection(userId).doc(studentId).delete();
  }
}