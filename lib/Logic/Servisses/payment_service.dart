import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:music_class/Logic/model/payment.dart';

class PaymentService {
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

  Future<void> addPayment(PaymentModel payment) async {
    await _paymentCollection(payment.studentId).add(payment.toMap());
  }

  Stream<List<PaymentModel>> getPaymentsForStudent(String studentId) {
    return _paymentCollection(studentId)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => PaymentModel.fromMap(doc.data() as Map<String, dynamic>, doc.id))
            .toList());
  }
}
