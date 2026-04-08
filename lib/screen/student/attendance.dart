import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../Logic/controller/user/attendance.dart';
import '../../Logic/controller/user/showstudent.dart';
import '../../Logic/model/Student.dart';

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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.appBarTheme.backgroundColor,
        elevation: 0,
        centerTitle: false,
        title: Column(
          children: [
            Text(
              "Attendance",
              style: theme.appBarTheme.titleTextStyle,
            ),
            const SizedBox(height: 2),
            Text(
              "Mark daily attendance",
              style: TextStyle(
                  color: isDark ? Colors.white70 : Colors.grey.shade400,
                  fontSize: 13
              ),
            ),
          ],
        ),
      ),
      body: Obx(() {
        DateTime selectedDate = controller.selectedDate.value;
        String formattedDate = "${selectedDate.day}-${selectedDate.month}-${selectedDate.year}";
        String weekday = [
          "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"
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
                    color: theme.cardColor,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        onPressed: controller.changeToPreviousDay,
                        icon: Icon(Icons.chevron_left, color: theme.primaryColor),
                      ),
                      Column(
                        children: [
                          Text(
                              weekday,
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: theme.colorScheme.onSurface
                              )
                          ),
                          const SizedBox(height: 4),
                          Text(
                              formattedDate,
                              style: TextStyle(fontSize: 12, color: isDark ? Colors.white60 : Colors.grey)
                          ),
                          if (isToday)
                            Text(
                                "Today",
                                style: TextStyle(fontSize: 10, color: theme.primaryColor, fontWeight: FontWeight.bold)
                            )
                        ],
                      ),
                      IconButton(
                        onPressed: controller.changeToNextDay,
                        icon: Icon(Icons.chevron_right, color: theme.primaryColor),
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
                    return studentListItem(student, theme, isDark);
                  },
                ),

                const SizedBox(height: 20),

                /// SUMMARY
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: theme.cardColor,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                          "Today's Summary",
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.onSurface
                          )
                      ),
                      const SizedBox(height: 15),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          summaryDot(Colors.green, "Present: ${controller.getPresentCount()}", isDark),
                          summaryDot(Colors.red, "Absent: ${controller.getAbsentCount()}", isDark),
                          summaryDot(Colors.grey, "Unmarked: ${controller.getUnmarkedCount(showController.students.length)}", isDark),
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

  Widget summaryDot(Color color, String text, bool isDark) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Text(
            text,
            style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: isDark ? Colors.white70 : Colors.black87
            )
        ),
      ],
    );
  }

  Widget studentListItem(StudentModel student, ThemeData theme, bool isDark) {
    final status = controller.attendanceStatus[student.id];

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
              color: status == 'present'
                  ? Colors.green.withOpacity(0.3)
                  : status == 'absent'
                  ? Colors.red.withOpacity(0.3)
                  : Colors.transparent
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                  student.name,
                  style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onSurface
                  )
              ),
            ),

            // Present Toggle
            GestureDetector(
              onTap: () async => await controller.markPresent(student.id!, student.name),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: status == 'present' ? Colors.green : Colors.green.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.check_rounded,
                  color: status == 'present' ? Colors.white : Colors.green,
                  size: 20,
                ),
              ),
            ),

            const SizedBox(width: 12),

            // Absent Toggle
            GestureDetector(
              onTap: () async => await controller.markAbsent(student.id!, student.name),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: status == 'absent' ? Colors.red : Colors.red.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.close_rounded,
                  color: status == 'absent' ? Colors.white : Colors.red,
                  size: 20,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}