import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../Servisses/student.dart';
import '../../model/Student.dart';
import 'due.dart';

class Showstudent extends GetxController {
  final AddStudentService _service = AddStudentService();
  final DueController _dueController = DueController();

  RxList<StudentModel> students = <StudentModel>[].obs;
  RxList<StudentModel> students_search = <StudentModel>[].obs;
  RxMap<String, double> duesMap = <String, double>{}.obs;

  RxBool isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    fetchStudents();
  }

  Future<void> fetchStudents() async {
    try {
      isLoading.value = true;

      final data = await _service.getStudents();
      students_search.assignAll(data);
      students.assignAll(data);

      // Fetch and calculate dues
      final duesList = await _dueController.calculateDues();
      Map<String, double> tempDues = {};
      for (var item in duesList) {
        final student = item['student'] as StudentModel;
        if (student.id != null) {
          tempDues[student.id!] = item['dueAmount'];
        }
      }
      duesMap.assignAll(tempDues);

    } catch (e) {
      Get.snackbar(
        "Error",
        "Failed to fetch students: $e",
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  void searchStudents(String query) {
    if (query.isEmpty) {
      students.assignAll(students_search);
      return;
    } else {
      final result = students_search.where((student) {
        final name = student.name.toLowerCase();
        final course = student.course.toLowerCase();
        final search = query.toLowerCase();

        return name.contains(search) || course.contains(search);
      }).toList();

      students.assignAll(result);
    }
  }

  double getDueAmount(String? studentId) {
    if (studentId == null) return 0.0;
    return duesMap[studentId] ?? 0.0;
  }
}
