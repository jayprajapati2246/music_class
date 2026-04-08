import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../model/payment.dart';


class PaymentController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get _userId => _auth.currentUser?.uid;

  CollectionReference _paymentCollection(String studentId) {
    if (_userId == null) throw Exception("User not logged in");
    return _firestore
        .collection('users')
        .doc(_userId)
        .collection('students')
        .doc(studentId)
        .collection('payments');
  }

  // Add a new payment
  Future<void> addPayment(PaymentModel payment) async {
    try {
      await _paymentCollection(payment.studentId).add(payment.toMap());
    } catch (e) {
      print("Error adding payment: $e");
      rethrow;
    }
  }

  // Get all payments for a specific student
  Stream<List<PaymentModel>> getStudentPayments(String studentId) {
    return _paymentCollection(studentId)
        .orderBy('date', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
          .map((doc) => PaymentModel.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .toList(),
    );
  }

// Get all payments (This is expensive in a nested schema without Collection Group)
// For now, if needed, we'd have to use a Collection Group query.
// If your app heavily relies on "all payments" across all students,
// you might need to set up a Firestore Index for a Collection Group query on 'payments'.
}