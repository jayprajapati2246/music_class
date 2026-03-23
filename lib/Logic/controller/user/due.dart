import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../model/Student.dart';


class DueController {
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

  Future<List<Map<String, dynamic>>> calculateDues() async {
    List<Map<String, dynamic>> dueList = [];

    try {

      QuerySnapshot studentSnapshot = await _studentCollection.get();
      List<StudentModel> students = studentSnapshot.docs
          .map((doc) => StudentModel.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .toList();

      for (var student in students) {
        final dueData = await calculateStudentDue(student);
        if (dueData['dueAmount'] > 0) {
          dueList.add(dueData);
        }
      }
    } catch (e) {
      print("Error calculating dues: $e");
    }

    return dueList;
  }

  Future<Map<String, dynamic>> calculateStudentDue(StudentModel student) async {
    double totalPaid = 0;
    
    // Get payments from the nested collection
    QuerySnapshot paymentSnapshot = await _studentCollection
        .doc(student.id)
        .collection('payments')
        .get();

    for (var doc in paymentSnapshot.docs) {
      totalPaid += (doc.data() as Map<String, dynamic>)['amount'] ?? 0;
    }

    // Calculate expected payment
    DateTime now = DateTime.now();
    int months = _calculateMonthsDifference(student.joinDate, now);

    // At least 1 month if they joined
    if (months <= 0) months = 1;

    double totalExpected = months * student.monthlyFee;
    double dueAmount = totalExpected - totalPaid;

    return {
      'student': student,
      'dueAmount': dueAmount,
      'totalPaid': totalPaid,
      'monthsPending': months,
    };
  }

  int _calculateMonthsDifference(DateTime startDate, DateTime endDate) {
    return (endDate.year - startDate.year) * 12 + endDate.month - startDate.month + 1;
  }
}
