import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:music_class/screen/User%20Profile/user%20profile.dart';

import '../Logic/controller/user/auth_controller.dart';
import '../Logic/controller/user/home_controller.dart';

class HomePage extends StatefulWidget {
  final VoidCallback onNavigateToPayments;
  final VoidCallback onNavigateToDues;
  final VoidCallback onNavigateToAddStudents;
  final VoidCallback onNavigateToAttendance;

  const HomePage({
    super.key,
    required this.onNavigateToPayments,
    required this.onNavigateToDues,
    required this.onNavigateToAddStudents,
    required this.onNavigateToAttendance,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late HomeController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.put(HomeController());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: RefreshIndicator(
        onRefresh: () async {
          await controller.refreshData();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.fromLTRB(20, 50, 20, 30),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isDark
                        ? [const Color(0xff1E1E1E), const Color(0xff2C2C2C)]
                        : [const Color(0xff6A5AE0), const Color(0xff8E54E9)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Obx(() {
                      final userData = AuthController.instance.userData.value;
                      final profileImage = userData['profileImage'] as String?;
                      final userName = userData['name'] as String? ?? "Music Class";

                      return Row(
                        children: [
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => userprofile(),
                                ),
                              );
                            },
                            child: CircleAvatar(
                              backgroundColor: Colors.white24,
                              backgroundImage: (profileImage != null && profileImage.isNotEmpty)
                                  ? NetworkImage(profileImage)
                                  : null,
                              child: (profileImage == null || profileImage.isEmpty)
                                  ? const Icon(
                                Icons.person,
                                color: Colors.white,
                              )
                                  : null,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                userName,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                DateFormat('EEEE, MMM d').format(DateTime.now()),
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ],
                      );
                    }),
                    const SizedBox(height: 25),
                    Obx(
                          () => Row(
                        children: [
                          Expanded(
                            child: topCard(
                              controller.totalStudents.toString(),
                              "Total Students",
                              Icons.people,
                              context,
                              onTap: widget.onNavigateToAddStudents,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: topCard(
                              "${controller.todaysPresent}/${controller.totalStudents}",
                              "Today's Attendance",
                              Icons.calendar_today,
                              context,
                              onTap: widget.onNavigateToAttendance,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Obx(
                      () => Row(
                    children: [
                      Expanded(
                        child: paymentCard(
                          "₹${controller.paymentsToday.value.toStringAsFixed(0)}",
                          "Payments Today",
                          Colors.green,
                          context,
                          widget.onNavigateToPayments,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: paymentCard(
                          "₹${controller.totalDues.value.toStringAsFixed(0)}",
                          "Pending Dues",
                          Colors.redAccent,
                          context,
                          widget.onNavigateToDues,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
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
                        "Quick Actions",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 15),
                      Row(
                        children: [
                          Expanded(
                            child: actionButton(
                              "Add Student",
                              Icons.people,
                              const Color(0xff6A5AE0),
                              context,
                              widget.onNavigateToAddStudents,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: actionButton(
                              "Mark Attendance",
                              Icons.event,
                              Colors.orange,
                              context,
                              widget.onNavigateToAttendance,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 30),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Obx(() {
                  if (controller.totalDues.value <= 0) {
                    return const SizedBox();
                  }

                  return InkWell(
                    onTap: widget.onNavigateToDues,
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isDark ? Colors.red.withOpacity(0.1) : const Color(0xffffebee),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.red.withOpacity(0.3)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: const [
                              Icon(
                                Icons.error_outline,
                                color: Colors.red,
                                size: 18,
                              ),
                              SizedBox(width: 6),
                              Text(
                                "Due Payments",
                                style: TextStyle(
                                  color: Colors.red,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "${controller.studentsWithDues.value} students have pending payments totaling ₹${controller.totalDues.value.toStringAsFixed(0)}",
                            style: TextStyle(
                              fontSize: 13,
                              color: isDark ? Colors.white70 : Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 10),
                          const Text(
                            "View all dues →",
                            style: TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget topCard(
      String value,
      String title,
      IconData icon,
      BuildContext context, {
        VoidCallback? onTap,
      }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          children: [
            Icon(icon, color: Colors.white),
            const SizedBox(height: 10),
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white70, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget paymentCard(
      String amount,
      String title,
      Color iconColor,
      BuildContext context,
      VoidCallback onTap,
      ) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
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
          children: [
            Icon(Icons.account_balance_wallet, color: iconColor),
            const SizedBox(height: 10),
            Text(
              amount,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                color: isDark ? Colors.white60 : Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget actionButton(
      String title,
      IconData icon,
      Color color,
      BuildContext context,
      VoidCallback onTap,
      ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          children: [
            Icon(icon, color: color),
            const SizedBox(height: 6),
            Text(
              title,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}