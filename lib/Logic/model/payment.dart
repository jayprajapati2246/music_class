import 'package:cloud_firestore/cloud_firestore.dart';

class PaymentModel {
  final String? id;
  final String studentId;
  final double amount;
  final DateTime date;
  final String month; // The month this payment is for, e.g., "October 2023"
  final String note;

  PaymentModel({
    this.id,
    required this.studentId,
    required this.amount,
    required this.date,
    required this.month,
    this.note = "",
  });

  Map<String, dynamic> toMap() {
    return {
      'studentId': studentId,
      'amount': amount,
      'date': Timestamp.fromDate(date),
      'month': month,
      'note': note,
    };
  }

  factory PaymentModel.fromMap(Map<String, dynamic> map, String documentId) {
    return PaymentModel(
      id: documentId,
      studentId: map['studentId'] ?? '',
      amount: (map['amount'] ?? 0).toDouble(),
      date: (map['date'] as Timestamp).toDate(),
      month: map['month'] ?? '',
      note: map['note'] ?? '',
    );
  }
}