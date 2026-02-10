import 'package:cloud_firestore/cloud_firestore.dart';

class StudentModel {
  final String? id;
  final String name;
  final String phone;
  final String course;
  final String batchTime;
  final String batchType;
  final String paymentType;
  final double monthlyFee;
  final DateTime joinDate;


  StudentModel({
    this.id,
    required this.name,
    required this.phone,
    required this.course,
    required this.batchTime,
    required this.batchType,
    required this.paymentType,
    required this.monthlyFee,
    required this.joinDate,
    Timestamp? createdAt,
  }) : createdAt = createdAt ?? Timestamp.now();

  final Timestamp createdAt;


  // Convert model → Firestore map
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'phone': phone,
      'course': course,
      'batchTime': batchTime,
      'batchType': batchType,
      'paymentType': paymentType,
      'monthlyFee': monthlyFee,
      'joinDate': Timestamp.fromDate(joinDate),
    };
  }

  // Convert Firestore map → model
  factory StudentModel.fromMap(
      Map<String, dynamic> map,
      String documentId,
      ) {
    return StudentModel(
      id: documentId,
      name: map['name'] ?? '',
      phone: map['phone'] ?? '',
      course: map['course'] ?? '',
      batchTime: map['batchTime'] ?? '',
      batchType: map['batchType'] ?? '',
      paymentType: map['paymentType'] ?? '',
      monthlyFee: (map['monthlyFee'] ?? 0).toDouble(),
      joinDate: (map['joinDate'] as Timestamp).toDate(),
    );
  }
}
