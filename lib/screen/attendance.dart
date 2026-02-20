import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';

import '../Logic/controller/showstudent.dart';
import '../Logic/model/Student.dart';

class Attendance extends StatefulWidget {
  const Attendance({super.key});

  @override
  State<Attendance> createState() => _AttendanceState();
}

class _AttendanceState extends State<Attendance> {

  DateTime selectedDate = DateTime.now();

  int presentCount = 0;
  int absentCount = 0;
  int unmarkedCount = 1;

  void markPresent() {
    setState(() {
      presentCount = 1;
      absentCount = 0;
      unmarkedCount = 0;
    });
  }

  void markAbsent() {
    setState(() {
      presentCount = 0;
      absentCount = 1;
      unmarkedCount = 0;
    });
  }

  void previousDay() {
    setState(() {
      selectedDate = selectedDate.subtract(const Duration(days: 1));
    });
  }

  void nextDay() {
    setState(() {
      selectedDate = selectedDate.add(const Duration(days: 1));
    });
  }

  @override
  Widget build(BuildContext context) {

    String formattedDate =
        "${selectedDate.day}-${selectedDate.month}-${selectedDate.year}";

    String weekday =
    ["Monday","Tuesday","Wednesday","Thursday","Friday","Saturday","Sunday"]
    [selectedDate.weekday - 1];

    bool isToday =
        selectedDate.day == DateTime.now().day &&
            selectedDate.month == DateTime.now().month &&
            selectedDate.year == DateTime.now().year;

    final Showstudent showController = Get.put(Showstudent());

    return Scaffold(
      body:SingleChildScrollView(
        child:  Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [

              SizedBox(height: 10),
              /// ================= DATE HEADER =================
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Row(
                  mainAxisAlignment:
                  MainAxisAlignment.spaceBetween,
                  children: [

                    IconButton(
                      onPressed: previousDay,
                      icon: const Icon(Icons.chevron_left),
                    ),

                    Column(
                      children: [
                        Text(
                          weekday,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.calendar_today,
                                size: 14,
                                color: Colors.grey),
                            const SizedBox(width: 4),
                            Text(
                              formattedDate,
                              style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey),
                            ),
                            const SizedBox(width: 6),
                            if (isToday)
                              Container(
                                padding:
                                const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2),
                                decoration: BoxDecoration(
                                  color:
                                  Colors.blue.shade100,
                                  borderRadius:
                                  BorderRadius.circular(
                                      10),
                                ),
                                child: const Text(
                                  "Today",
                                  style: TextStyle(
                                      fontSize: 10,
                                      fontWeight:
                                      FontWeight.w600),
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),

                    IconButton(
                      onPressed: nextDay,
                      icon: const Icon(Icons.chevron_right),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              /// ================= COURSE + TIME =================
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: showController.students.length,
                itemBuilder: (context, index) {
                  final StudentModel student = showController.students[index];
                  return studentListItem(student);
                },
              ),

              const SizedBox(height: 20),

              /// ================= SUMMARY =================
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Today's Summary",
                      style: TextStyle(
                          fontWeight:
                          FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        summaryDot(
                            Colors.green,
                            "Present: $presentCount"),
                        const SizedBox(width: 15),
                        summaryDot(
                            Colors.red,
                            "Absent: $absentCount"),
                        const SizedBox(width: 15),
                        summaryDot(
                            Colors.grey,
                            "Unmarked: $unmarkedCount"),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      )
    );
  }

  Widget summaryDot(Color color, String text) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          text,
          style: const TextStyle(fontSize: 12),
        ),
      ],
    );
  }

  Widget studentListItem(StudentModel student) {
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

            /// ================= NAME + TIME =================
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    student.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    student.batchTime,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),

            /// ================= PRESENT BUTTON =================
            CircleAvatar(
              radius: 18,
              backgroundColor: Colors.green.withOpacity(0.15),
              child: IconButton(
                padding: EdgeInsets.zero,
                icon: const Icon(
                  Icons.check,
                  color: Colors.green,
                  size: 18,
                ),
                onPressed: () {
                  print("${student.name} marked Present");
                },
              ),
            ),

            const SizedBox(width: 10),

            /// ================= ABSENT BUTTON =================
            CircleAvatar(
              radius: 18,
              backgroundColor: Colors.red.withOpacity(0.15),
              child: IconButton(
                padding: EdgeInsets.zero,
                icon: const Icon(
                  Icons.close,
                  color: Colors.red,
                  size: 18,
                ),
                onPressed: () {
                  print("${student.name} marked Absent");
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

}
