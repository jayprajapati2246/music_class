import 'package:cloud_firestore/cloud_firestore.dart';

class AttendanceRecordModel {
  final String? id;
  final String studentId;
  final String name;
  final String status; // 'present', 'absent'
  final DateTime date;
  final String? userId;

  AttendanceRecordModel({
    this.id,
    required this.studentId,
    required this.name,
    required this.status,
    required this.date,
    this.userId,
  });

  Map<String, dynamic> toMap() {
    return {
      'studentId': studentId,
      'name': name,
      'status': status,
      'date': Timestamp.fromDate(date),
      if (userId != null) 'userId': userId,
    };
  }

  factory AttendanceRecordModel.fromMap(Map<String, dynamic> map, String id) {
    return AttendanceRecordModel(
      id: id,
      studentId: map['studentId'] ?? '',
      name: map['name'] ?? '',
      status: map['status'] ?? '',
      date: (map['date'] as Timestamp).toDate(),
      userId: map['userId'],
    );
  }
}