import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:get/get_navigation/src/snackbar/snackbar.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';

import '../Servisses/student.dart';
import '../model/Student.dart';

class Showstudent extends GetxController {

  final AddStudentService _service = AddStudentService();

  RxList<StudentModel> students = <StudentModel>[].obs;
  RxBool isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    fetchStudents();
  }

  Future<void> fetchStudents() async {
    try {
      isLoading.value = true;
      students.value = await _service.getStudents();
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
