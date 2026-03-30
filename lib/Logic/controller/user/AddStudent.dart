import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../Servisses/student.dart';
import '../../model/Student.dart';

class Addstudentcontroller extends GetxController {
  final AddStudentService _service = AddStudentService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? targetUserId;

  String? selectedCourse;
  String? selectedBatchType;
  String? selectedPaymentType;
  String? selectedBatchTime;

  var courses = <String>[].obs;
  final List<String> batchTypes = ['Everyday', 'Alternate Days','Weekends'];
  final List<String> paymentTypes = ['Per Class', 'Monthly','3 Months','6 Months','One Time'];
  var batchTime = <String>[].obs;

  DateTime? joinDate;

  DateTime? get initialDate => joinDate;

  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController amountController = TextEditingController();
  final TextEditingController joinDateController = TextEditingController();
  final TextEditingController sourceController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    fetchUserServices();
  }

  Future<void> fetchUserServices() async {
    try {
      String uid = targetUserId ?? _auth.currentUser!.uid;
      
      // Fetch from the new services subcollectio
      QuerySnapshot snapshot = await _firestore
          .collection('users')
          .doc(uid)
          .collection('services')
          .get();

      List<String> userCourses = [];
      List<String> userBatches = [];

      for (var doc in snapshot.docs) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        if (data['course'] != null && data['course'].toString().isNotEmpty) {
          userCourses.add(data['course']);
        }
        if (data['batch'] != null && data['batch'].toString().isNotEmpty) {
          userBatches.add(data['batch']);
        }
        if (data['batchTimes'] is List) {
          userBatches.addAll(List<String>.from(data['batchTimes']));
        }
      }

      // Check for legacy services field in case migration hasn't happened for this user
      DocumentSnapshot userDoc = await _firestore.collection('users').doc(uid).get();
      if (userDoc.exists) {
        Map<String, dynamic> data = userDoc.data() as Map<String, dynamic>;
        if (data['services'] != null) {
          Map<String, dynamic> services = data['services'];
          List<String> oldCourses = List<String>.from(services['courses'] ?? []);
          List<String> oldBatches = List<String>.from(services['batchTimes'] ?? []);
          
          for (var c in oldCourses) {
            if (!userCourses.contains(c)) userCourses.add(c);
          }
          for (var b in oldBatches) {
            if (!userBatches.contains(b)) userBatches.add(b);
          }
        }
      }

      courses.value = userCourses.toSet().toList();
      batchTime.value = userBatches.toSet().toList();
      
    } catch (e) {
      debugPrint("Error fetching user services: $e");
    }
  }

  Future<void> addStudent() async {
    if (!_validate()) return;

    final student = StudentModel(
      name: nameController.text.trim(),
      phone: phoneController.text.trim(),
      course: selectedCourse!,
      batchTime: selectedBatchTime!,
      batchType: selectedBatchType!,
      paymentType: selectedPaymentType!,
      monthlyFee: double.parse(amountController.text.trim()),
      joinDate: joinDate!,
      source: sourceController.text.trim(),
    );

    try {
      await _service.addStudent(student, userId: targetUserId);
      Get.back(result: true);

      Get.snackbar(
        "Success",
        "Student added successfully",
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

      clearControllers();
    } catch (e) {
      Get.snackbar(
        "Error",
        "Failed to add student: ${e.toString()}",
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> updateStudent(String studentId) async {
    if (!_validate()) return;

    final student = StudentModel(
      id: studentId,
      name: nameController.text.trim(),
      phone: phoneController.text.trim(),
      course: selectedCourse!,
      batchTime: selectedBatchTime!,
      batchType: selectedBatchType!,
      paymentType: selectedPaymentType!,
      monthlyFee: double.parse(amountController.text.trim()),
      joinDate: joinDate!,
      source: sourceController.text.trim(),
    );

    try {
      await _service.updateStudent(student, userId: targetUserId);
      Get.back(result: true);

      Get.snackbar(
        "Success",
        "Student updated successfully",
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

      clearControllers();
    } catch (e) {
      Get.snackbar(
        "Error",
        "Failed to update student: ${e.toString()}",
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  bool _validate() {
    if (nameController.text.trim().isEmpty ||
        phoneController.text.trim().isEmpty ||
        selectedCourse == null ||
        selectedBatchTime == null ||
        selectedBatchType == null ||
        selectedPaymentType == null ||
        amountController.text.trim().isEmpty ||
        joinDate == null) {
      Get.snackbar(
        "Error",
        "Please fill all fields",
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    }
    return true;
  }

  void clearControllers() {
    nameController.clear();
    phoneController.clear();
    amountController.clear();
    joinDateController.clear();
    sourceController.clear();

    selectedCourse = null;
    selectedBatchTime = null;
    selectedBatchType = null;
    selectedPaymentType = null;
    joinDate = null;
    targetUserId = null;
  }

  @override
  void onClose() {
    nameController.dispose();
    phoneController.dispose();
    amountController.dispose();
    joinDateController.dispose();
    sourceController.dispose();
    super.onClose();
  }
}
