import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:music_class/Logic/model/payment.dart';

class PaymentService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collectionPath = 'payments';

  Future<void> addPayment(PaymentModel payment) async {
    await _firestore.collection(_collectionPath).add(payment.toMap());
  }

  Stream<List<PaymentModel>> getPaymentsForStudent(String studentId) {
    return _firestore
        .collection(_collectionPath)
        .where('studentId', isEqualTo: studentId)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => PaymentModel.fromMap(doc.data(), doc.id))
            .toList());
  }

  Stream<List<PaymentModel>> getPaymentsForToday() {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    return _firestore
        .collection(_collectionPath)
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
        .where('date', isLessThan: Timestamp.fromDate(endOfDay))
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => PaymentModel.fromMap(doc.data(), doc.id))
            .toList());
  }
}
