import 'package:cloud_firestore/cloud_firestore.dart';

class StudentModel {
  final String? id;
  // Profile field group
  final String name;
  final String phone;
  
  // Payment field group
  final String paymentType;
  final double monthlyFee;
  
  // StudentDetail field group
  final String course;
  final String batchTime;
  final String batchType;
  final DateTime joinDate;
  final String source;

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
    this.source = 'Unknown',
    Timestamp? createdAt,
  }) : createdAt = createdAt ?? Timestamp.now();

  final Timestamp createdAt;

  // Convert model → Firestore map with new schema structure
  Map<String, dynamic> toMap() {
    return {
      'profile': {
        'name': name,
        'phone': phone,
      },
      'payment': {
        'paymentType': paymentType,
        'monthlyFee': monthlyFee,
      },
      'studentDetail': {
        'course': course,
        'batchTime': batchTime,
        'batchType': batchType,
        'joinDate': Timestamp.fromDate(joinDate),
        'source': source,
      },
      'createdAt': createdAt,
    };
  }

  // Convert Firestore map → model
  factory StudentModel.fromMap(
      Map<String, dynamic> map,
      String documentId,
      ) {
    final profile = map['profile'] as Map<String, dynamic>? ?? {};
    final payment = map['payment'] as Map<String, dynamic>? ?? {};
    final studentDetail = map['studentDetail'] as Map<String, dynamic>? ?? {};

    return StudentModel(
      id: documentId,
      name: profile['name'] ?? '',
      phone: profile['phone'] ?? '',
      course: studentDetail['course'] ?? '',
      batchTime: studentDetail['batchTime'] ?? '',
      batchType: studentDetail['batchType'] ?? '',
      paymentType: payment['paymentType'] ?? '',
      monthlyFee: (payment['monthlyFee'] ?? 0).toDouble(),
      joinDate: (studentDetail['joinDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      source: studentDetail['source'] ?? 'Unknown',
      createdAt: map['createdAt'] as Timestamp?,
    );
  }
}
