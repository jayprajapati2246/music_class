import 'package:cloud_firestore/cloud_firestore.dart';

class PaymentModel {
  final String? id;
  final String studentName;
  final double amount;
  final DateTime date;

  PaymentModel({
    this.id,
    required this.studentName,
    required this.amount,
    required this.date,
  });

  Map<String, dynamic> toMap() {
    return {
      'studentName': studentName,
      'amount': amount,
      'date': Timestamp.fromDate(date),
    };
  }

  factory PaymentModel.fromMap(Map<String, dynamic> map, String documentId) {
    return PaymentModel(
      id: documentId,
      studentName: map['studentName'] ?? '',
      amount: (map['amount'] ?? 0).toDouble(),
      date: (map['date'] as Timestamp).toDate(),
    );
  }
}
