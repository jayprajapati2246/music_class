import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:music_class/screen/student/student.dart';
import '../Logic/controller/attendance.dart';
import '../Logic/controller/showstudent.dart';
import '../Logic/model/Student.dart';

class Attendance extends StatefulWidget {
  const Attendance({super.key});

  @override
  State<Attendance> createState() => _AttendanceState();
}

class _AttendanceState extends State<Attendance> {
  late Showstudent showController;
  late AttendanceController controller;

  @override
  void initState() {
    super.initState();
    showController = Get.put(Showstudent());
    controller = Get.put(AttendanceController());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          title: const Column(
            children: [
              Text(
                "Attendance",
                style: TextStyle(
                    color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18),
              ),
              SizedBox(
                height: 2,
              ),
              Text("Mark daily attendance",
                  style: TextStyle(color: Colors.grey, fontSize: 15)),
            ],
          )),
      body: Obx(() {
        DateTime selectedDate = controller.selectedDate.value;

        String formattedDate =
            "${selectedDate.day}-${selectedDate.month}-${selectedDate.year}";

        String weekday = [
          "Monday",
          "Tuesday",
          "Wednesday",
          "Thursday",
          "Friday",
          "Saturday",
          "Sunday"
        ][selectedDate.weekday - 1];

        bool isToday = selectedDate.day == DateTime.now().day &&
            selectedDate.month == DateTime.now().month &&
            selectedDate.year == DateTime.now().year;

        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                /// DATE HEADER
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        onPressed: controller.changeToPreviousDay,
                        icon: const Icon(Icons.chevron_left),
                      ),
                      Column(
                        children: [
                          Text(weekday,
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 4),
                          Text(formattedDate,
                              style: const TextStyle(
                                  fontSize: 12, color: Colors.grey)),
                          if (isToday)
                            const Text("Today", style: TextStyle(fontSize: 10))
                        ],
                      ),
                      IconButton(
                        onPressed: controller.changeToNextDay,
                        icon: const Icon(Icons.chevron_right),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                /// STUDENT LIST
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: showController.students.length,
                  itemBuilder: (context, index) {
                    final student = showController.students[index];
                    return studentListItem(student);
                  },
                ),

                const SizedBox(height: 20),

                /// SUMMARY
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Today's Summary",
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          summaryDot(Colors.green,
                              "Present: ${controller.getPresentCount()}"),
                          const SizedBox(width: 15),
                          summaryDot(Colors.red,
                              "Absent: ${controller.getAbsentCount()}"),
                          const SizedBox(width: 15),
                          summaryDot(
                              Colors.grey,
                              "Unmarked: ${controller.getUnmarkedCount(showController.students.length)}"),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget summaryDot(Color color, String text) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(text, style: const TextStyle(fontSize: 12)),
      ],
    );
  }

  Widget studentListItem(StudentModel student) {
    final status = controller.attendanceStatus[student.id];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(student.name,
                  style: const TextStyle(fontWeight: FontWeight.w600)),
            ),
            CircleAvatar(
              radius: 18,
              backgroundColor:
                  status == 'present' ? Colors.green : Colors.green.withOpacity(0.15),
              child: IconButton(
                icon: Icon(Icons.check,
                    color: status == 'present' ? Colors.white : Colors.green,
                    size: 18),
                onPressed: () async {
                  await controller.markPresent(
                    student.id!,
                    student.name,
                  );
                },
              ),
            ),
            const SizedBox(width: 10),
            CircleAvatar(
              radius: 18,
              backgroundColor:
                  status == 'absent' ? Colors.red : Colors.red.withOpacity(0.15),
              child: IconButton(
                icon: Icon(Icons.close,
                    color: status == 'absent' ? Colors.white : Colors.red, size: 18),
                onPressed: () async {
                  await controller.markAbsent(
                    student.id!,
                    student.name,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
