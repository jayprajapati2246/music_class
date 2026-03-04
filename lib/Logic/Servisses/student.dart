import 'package:cloud_firestore/cloud_firestore.dart';
import '../model/Student.dart';

class AddStudentService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Consistent collection name: 'students'
  Future<void> addStudent(StudentModel student) async {
    await _firestore.collection('students').add(student.toMap());
  }

  Future<List<StudentModel>> getStudents() async {
    final snapshot = await _firestore.collection('students').get();

    return snapshot.docs
        .map(
          (doc) => StudentModel.fromMap(
        doc.data(),
        doc.id,
      ),
    )
        .toList();
  }

  Future<void> updateStudent(StudentModel student) async {
    if (student.id == null) return;
    await _firestore
        .collection('students')
        .doc(student.id)
        .update(student.toMap());
  }

  Future<void> deleteStudent(String studentId) async {
    await _firestore.collection('students').doc(studentId).delete();
  }
}
