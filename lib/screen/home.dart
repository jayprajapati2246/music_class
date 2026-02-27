import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:music_class/Logic/controller/home_controller.dart';

class HomePage extends StatefulWidget {
  final VoidCallback onNavigateToPayments;
  final VoidCallback onNavigateToDues;
  final VoidCallback onNavigateToStudent;
  final VoidCallback onNavigateToAttendance;

  const HomePage({
    super.key,
    required this.onNavigateToPayments,
    required this.onNavigateToDues,
    required this.onNavigateToStudent,
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
    return Scaffold(
      backgroundColor: const Color(0xfff5f5f7),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(20, 50, 20, 30),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xff6A5AE0), Color(0xff8E54E9)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const CircleAvatar(
                        backgroundColor: Colors.white24,
                        child: Icon(Icons.music_note, color: Colors.white),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Music Class",
                            style: TextStyle(
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
                  ),
                  const SizedBox(height: 25),

                  Obx(
                    () => Row(
                      children: [
                        Expanded(
                          child: topCard(
                            controller.totalStudents.toString(),
                            "Total Students",
                            Icons.people,
                            onTap: widget.onNavigateToStudent,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: topCard(
                            "${controller.todaysPresent}/${controller.totalStudents}",
                            "Today's Attendance",
                            Icons.calendar_today,
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

            /// Payment Section
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
                        widget.onNavigateToPayments,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: paymentCard(
                        "₹${controller.totalDues.value.toStringAsFixed(0)}",
                        "Pending Dues",
                        Colors.redAccent,
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
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Quick Actions",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 15),
                    Row(
                      children: [
                        Expanded(
                          child: actionButton(
                            "Add Student",
                            Icons.people,
                            Colors.deepPurple,
                            widget.onNavigateToStudent,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: actionButton(
                            "Mark Attendance",
                            Icons.event,
                            Colors.orange,
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

            /// ================= DUE SUMMARY BOX =================
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Obx(() {
                if (controller.totalDues.value <= 0) {
                  return const SizedBox(); // hide if no dues
                }

                return InkWell(
                  onTap: widget.onNavigateToDues,
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xffffebee),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.red.shade200),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        /// Title Row
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
                          style: const TextStyle(
                            fontSize: 13,
                            color: Colors.black87,
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
          ],
        ),
      ),
    );
  }

  Widget topCard(
    String value,
    String title,
    IconData icon, {
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
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          children: [
            Icon(Icons.account_balance_wallet, color: iconColor),
            const SizedBox(height: 10),
            Text(
              amount,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
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
