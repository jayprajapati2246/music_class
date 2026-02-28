import 'package:cloud_firestore/cloud_firestore.dart';
import '../model/payment.dart';

class PaymentController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Add a new payment
  Future<void> addPayment(PaymentModel payment) async {
    try {
      await _firestore.collection('payments').add(payment.toMap());
    } catch (e) {
      print("Error adding payment: $e");
      rethrow;
    }
  }

  // Get all payments for a specific student
  Stream<List<PaymentModel>> getStudentPayments(String studentId) {
    return _firestore
        .collection('payments')
        .where('studentId', isEqualTo: studentId)
        .orderBy('date', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => PaymentModel.fromMap(doc.data(), doc.id))
              .toList(),
        );
  }

  // Get all payments
  Stream<List<PaymentModel>> getAllPayments() {
    return _firestore
        .collection('payments')
        .orderBy('date', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => PaymentModel.fromMap(doc.data(), doc.id))
              .toList(),
        );
  }
}
