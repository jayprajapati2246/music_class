import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../model/Student.dart';

class AddStudentService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get _userId => _auth.currentUser?.uid;

  CollectionReference get _studentCollection {
    if (_userId == null) throw Exception("User not logged in");
    return _firestore
        .collection('users')
        .doc(_userId)
        .collection('students');
  }

  // Consistent collection name: 'students'
  Future<void> addStudent(StudentModel student) async {
    await _studentCollection.add(student.toMap());
  }

  Future<List<StudentModel>> getStudents() async {
    final snapshot = await _studentCollection.get();

    return snapshot.docs
        .map(
          (doc) => StudentModel.fromMap(
        doc.data() as Map<String, dynamic>,
        doc.id,
      ),
    )
        .toList();
  }

  Future<void> updateStudent(StudentModel student) async {
    if (student.id == null) return;
    await _studentCollection
        .doc(student.id)
        .update(student.toMap());
  }

  Future<void> deleteStudent(String studentId) async {
    await _studentCollection.doc(studentId).delete();
  }
}
