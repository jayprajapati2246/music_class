import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:music_class/Logic/Servisses/student.dart';

import '../../model/Student.dart';

class StudentController extends GetxController {

  RxList<StudentModel> students = <StudentModel>[].obs;
  RxList<StudentModel> students_search = <StudentModel>[].obs;

  RxBool isLoading = true.obs;


  final AddStudentService _addStudentService = AddStudentService();

  Future<void> deleteStudent(String studentId) async {
    try {
      await _addStudentService.deleteStudent(studentId);
    } catch (e) {
      Get.snackbar(
        "Error",
        "Failed to delete student: ${e.toString()}",
        snackPosition: SnackPosition.TOP,
      );
    }
  }
  Future<void> fetchStudents() async {
    try {
      isLoading.value = true;

      final data = await _addStudentService.getStudents();

      students_search.assignAll(data);
      students.assignAll(data);


    } catch (e) {
      Get.snackbar(
        "Error",
        "Failed to fetch students",
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }
}