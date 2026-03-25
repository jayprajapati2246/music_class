import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../Logic/controller/user/showstudent.dart';
import '../../Logic/model/Student.dart';
import 'addnewstudent.dart';
import 'edit.dart';

class Student extends StatefulWidget {
  const Student({super.key});

  @override
  State<Student> createState() => _StudentState();
}

class _StudentState extends State<Student> {
  final Showstudent showController = Get.put(Showstudent());

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
        title: Obx(() => Column(
          children: [
            Text(
              "Students",
              style: theme.appBarTheme.titleTextStyle,
            ),
            const SizedBox(height: 2),
            Text(
              "${showController.students.length} enrolled",
              style: TextStyle(
                color: isDark ? Colors.white70: Colors.grey.shade400,
                fontSize: 13
              ),
            ),
          ],
        )),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await showController.fetchStudents();
        },
        child: Column(
          children: [
            // Search Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: TextField(
                onChanged: (value) => showController.searchStudents(value),
                style: TextStyle(color: theme.colorScheme.onSurface),
                decoration: InputDecoration(
                  hintText: "Search students...",
                  hintStyle: TextStyle(color: isDark ? Colors.white38 : Colors.grey),
                  prefixIcon: Icon(Icons.search, color: isDark ? Colors.white38 : Colors.grey),
                  filled: true,
                  fillColor: theme.cardColor,
                  contentPadding: const EdgeInsets.symmetric(vertical: 14),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(32),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(32),
                    borderSide: BorderSide(color: isDark ? Colors.white12 : Colors.black12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(32),
                    borderSide: BorderSide(color: theme.primaryColor, width: 2),
                  ),
                ),
              ),
            ),
            
            Expanded(
              child: Obx(() {
                if (showController.isLoading.value) {
                  return Center(child: CircularProgressIndicator(color: theme.primaryColor));
                }

                if (showController.students.isEmpty) {
                  return SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: SizedBox(
                      height: MediaQuery.of(context).size.height * 0.6,
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                color: isDark ? Colors.white.withOpacity(0.05) : Colors.grey.shade200,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.group_outlined,
                                size: 36,
                                color: isDark ? Colors.white38 : Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 20),
                            Text(
                              "No Students Yet",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.onSurface,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 32),
                              child: Text(
                                "Add your first student to get started with managing your music classes",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: isDark ? Colors.white60 : Colors.grey, 
                                  fontSize: 14
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                            ElevatedButton(
                              onPressed: () async {
                                await Get.to(() => const Addnstudent());
                                showController.fetchStudents();
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: theme.primaryColor,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 28,
                                  vertical: 12,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(24),
                                ),
                              ),
                              child: const Text(
                                "Add Student",
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }

                return ListView.builder(
                  physics: const AlwaysScrollableScrollPhysics(),
                  itemCount: showController.students.length,
                  padding: const EdgeInsets.fromLTRB(10, 0, 10, 80),
                  itemBuilder: (context, index) {
                    final StudentModel student = showController.students[index];
                    return studentListItem(student, theme, isDark);
                  },
                );
              }),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Get.to(() => const Addnstudent());
          showController.fetchStudents();
        },
        backgroundColor: theme.primaryColor,
        foregroundColor: Colors.white,
        shape: const CircleBorder(),
        child: const Icon(Icons.add, size: 28),
      ),
    );
  }

  Widget studentListItem(StudentModel student, ThemeData theme, bool isDark) {
    final double dueAmount = showController.getDueAmount(student.id);
    final bool hasDue = dueAmount > 0;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () async {
            await Get.to(() => EditDetail(student: student));
            showController.fetchStudents();
          },
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(isDark ? 0.2 : 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 22,
                  backgroundColor: theme.primaryColor.withOpacity(0.1),
                  child: Icon(Icons.person_outline, color: theme.primaryColor),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        student.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Wrap(
                        spacing: 8,
                        runSpacing: 4,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Icon(
                            Icons.music_note,
                            size: 14,
                            color: isDark ? Colors.white60 : Colors.grey,
                          ),
                          Text(
                            student.course,
                            style: TextStyle(
                              color: isDark ? Colors.white60 : Colors.grey,
                              fontSize: 13,
                            ),
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.access_time,
                                size: 14,
                                color: isDark ? Colors.white60 : Colors.grey,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                student.batchTime,
                                style: TextStyle(
                                  color: isDark ? Colors.white60 : Colors.grey,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: hasDue 
                            ? Colors.redAccent.withOpacity(0.1)
                            : Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        hasDue ? "₹${dueAmount.toStringAsFixed(0)} due" : "Paid",
                        style: TextStyle(
                          color: hasDue ? Colors.red : Colors.green,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Icon(
                      Icons.chevron_right, 
                      color: isDark ? Colors.white38 : Colors.grey, 
                      size: 20
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
