import 'package:cloud_firestore/cloud_firestore.dart';

class ServiceModel {
  final String? id;
  final String course;
  final String batch; 
  final List<String> batchTimes;
  final double fee;
  final String status;

  ServiceModel({
    this.id,
    required this.course,
    required this.batch,
    this.batchTimes = const [],
    this.fee = 0.0,
    this.status = 'Active',
  });

  Map<String, dynamic> toMap() {
    return {
      'course': course,
      'batch': batch,
      'batchTimes': batchTimes,
      'fee': fee,
      'status': status,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  factory ServiceModel.fromMap(Map<String, dynamic> map, String documentId) {
    return ServiceModel(
      id: documentId,
      course: map['course'] ?? '',
      batch: map['batch'] ?? '',
      batchTimes: List<String>.from(map['batchTimes'] ?? []),
      fee: (map['fee'] ?? 0.0).toDouble(),
      status: map['status'] ?? 'Active',
    );
  }
}
