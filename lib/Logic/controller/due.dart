import 'package:cloud_firestore/cloud_firestore.dart';
import '../model/Student.dart';

class DueController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<Map<String, dynamic>>> calculateDues() async {
    List<Map<String, dynamic>> dueList = [];

    try {
      // 1. Get all students
      QuerySnapshot studentSnapshot = await _firestore.collection('students').get();
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
    QuerySnapshot paymentSnapshot = await _firestore
        .collection('payments')
        .where('studentId', isEqualTo: student.id)
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
