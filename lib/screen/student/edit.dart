import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:music_class/Logic/model/Student.dart';
import 'package:music_class/Logic/model/attundance.dart';
import 'package:music_class/Logic/model/payment.dart';
import 'package:music_class/screen/student/addnewstudent.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../Logic/controller/user/edit.dart';

class EditDetail extends StatelessWidget {
  final StudentModel student;
  final StudentDetailController controller;

  EditDetail({super.key, required this.student})
      : controller = Get.put(StudentDetailController(student), tag: student.id);

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
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: Icon(Icons.arrow_back_ios, color: theme.iconTheme.color),
        ),
        title: Text(
          "Student Details",
          style: theme.appBarTheme.titleTextStyle?.copyWith(
            color: theme.colorScheme.onSurface,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () async {
              final result = await Get.to(
                    () => Addnstudent(student: controller.student.value),
              );

              if (result == true) {
                controller.refreshStudent();
              }
            },
            icon: Icon(Icons.edit, color: theme.primaryColor),
          ),
          IconButton(
            onPressed: () {
              Get.defaultDialog(
                backgroundColor: theme.cardColor,
                title: "Delete Student",
                titleStyle: TextStyle(color: theme.colorScheme.onSurface, fontWeight: FontWeight.bold),
                middleText: "Are you sure you want to delete ${controller.student.value.name}?",
                middleTextStyle: TextStyle(color: isDark ? Colors.white70 : Colors.black87),
                textConfirm: "Delete",
                textCancel: "Cancel",
                confirmTextColor: Colors.white,
                cancelTextColor: theme.primaryColor,
                buttonColor: Colors.red,
                radius: 15,
                contentPadding: const EdgeInsets.all(20),
                onConfirm: controller.deleteStudent,
              );
            },
            icon: const Icon(Icons.delete_outline, color: Colors.red),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Column(
            children: [
              Obx(() => _buildHeader(context, controller.student.value)),
              const SizedBox(height: 15),
              Obx(() => _buildInfoCards(context, controller.student.value)),
              const SizedBox(height: 15),
              Obx(() => _buildCallCard(context, controller.student.value)),
              const SizedBox(height: 20),
              _buildTabBar(context),
              const SizedBox(height: 20),
              _buildTabContent(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, StudentModel student) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(18),
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
            radius: 30,
            backgroundColor: theme.primaryColor.withOpacity(0.1),
            child: Icon(Icons.person, color: theme.primaryColor, size: 30),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  student.name,
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "Joined on ${DateFormat('MMM d, yyyy').format(student.joinDate)}",
                  style: TextStyle(
                      fontSize: 14,
                      color: isDark ? Colors.white60 : Colors.black54
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCards(BuildContext context, StudentModel student) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _infoCard(context, Icons.music_note_rounded, "Course", student.course),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _infoCard(context, Icons.access_time_filled_rounded, "Batch", student.batchTime),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _infoCard(
                context,
                Icons.payments_rounded,
                "Monthly Fee",
                "₹${student.monthlyFee.toStringAsFixed(0)}",
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _infoCard(
                context,
                Icons.account_balance_wallet_rounded,
                "Balance Due",
                "₹${controller.balance.value.toStringAsFixed(0)}",
                isBalance: true,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCallCard(BuildContext context, StudentModel student) {
    return _infoCard(context, Icons.phone_android_rounded, "Contact Number", student.phone, fullWidth: true);
  }

  Widget _buildTabBar(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Obx(() => Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.2 : 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          _tabItem(context, "Attendance", 0),
          _tabItem(context, "Payments", 1),
          _tabItem(context, "Add Pay", 2),
        ],
      ),
    ));
  }

  Widget _tabItem(BuildContext context, String title, int index) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isSelected = controller.selectedTab.value == index;

    return Expanded(
      child: GestureDetector(
        onTap: () => controller.changeTab(index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected
                ? theme.primaryColor
                : Colors.transparent,
            borderRadius: BorderRadius.circular(25),
          ),
          child: Center(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: isSelected
                    ? Colors.white
                    : (isDark ? Colors.white38 : Colors.grey.shade600),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTabContent(BuildContext context) {
    return Obx(() {
      switch (controller.selectedTab.value) {
        case 0:
          return _attendanceSection(context);
        case 1:
          return _paymentSection(context);
        case 2:
          return _addPaymentSection(context);
        default:
          return const SizedBox.shrink();
      }
    });
  }

  Widget _attendanceSection(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return StreamBuilder<List<AttendanceRecordModel>>(
      stream: controller.attendanceStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final allRecords = snapshot.data ?? [];

        return Obx(() {
          final focusedMonth = controller.focusedDay.value;
          final focusedMonthRecords = allRecords.where((r) =>
          r.date.month == focusedMonth.month &&
              r.date.year == focusedMonth.year
          ).toList();

          final presentCount = focusedMonthRecords.where((e) => e.status == 'present').length;
          final absentCount = focusedMonthRecords.where((e) => e.status == 'absent').length;

          return Column(
            children: [
              Row(
                children: [
                  Expanded(child: _attendanceCard(presentCount, "Present", Colors.green)),
                  const SizedBox(width: 12),
                  Expanded(child: _attendanceCard(absentCount, "Absent", Colors.red)),
                ],
              ),
              const SizedBox(height: 20),
              Container(
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(isDark ? 0.2 : 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(8),
                child: TableCalendar(
                  firstDay: DateTime.utc(2020, 1, 1),
                  lastDay: DateTime.utc(2030, 12, 31),
                  focusedDay: focusedMonth,
                  headerStyle: HeaderStyle(
                    formatButtonVisible: false,
                    titleCentered: true,
                    titleTextStyle: TextStyle(color: theme.colorScheme.onSurface, fontWeight: FontWeight.bold, fontSize: 16),
                    leftChevronIcon: Icon(Icons.chevron_left, color: theme.primaryColor),
                    rightChevronIcon: Icon(Icons.chevron_right, color: theme.primaryColor),
                  ),
                  daysOfWeekStyle: DaysOfWeekStyle(
                    weekdayStyle: TextStyle(color: isDark ? Colors.white70 : Colors.black87, fontWeight: FontWeight.w600),
                    weekendStyle: TextStyle(color: theme.primaryColor, fontWeight: FontWeight.w600),
                  ),
                  calendarStyle: CalendarStyle(
                    defaultTextStyle: TextStyle(color: theme.colorScheme.onSurface),
                    weekendTextStyle: TextStyle(color: theme.primaryColor),
                    outsideTextStyle: TextStyle(color: isDark ? Colors.white24 : Colors.grey.shade400),
                    todayDecoration: BoxDecoration(color: theme.primaryColor.withOpacity(0.2), shape: BoxShape.circle),
                    todayTextStyle: TextStyle(color: theme.primaryColor, fontWeight: FontWeight.bold),
                  ),
                  onPageChanged: (focusedDay) {
                    controller.focusedDay.value = focusedDay;
                  },
                  calendarBuilders: CalendarBuilders(
                    defaultBuilder: (context, day, focusedDay) {
                      final record = allRecords.firstWhereOrNull((r) => isSameDay(r.date, day));
                      if (record != null) {
                        return Container(
                          margin: const EdgeInsets.all(6),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: record.status == 'present' ? Colors.green.withOpacity(0.8) : Colors.red.withOpacity(0.8),
                            shape: BoxShape.circle,
                          ),
                          child: Text('${day.day}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        );
                      }
                      return null;
                    },
                  ),
                  onDaySelected: (selectedDay, focusedDay) {
                    controller.focusedDay.value = focusedDay;
                    _showMarkAttendanceDialog(context, selectedDay);
                  },
                ),
              ),
            ],
          );
        });
      },
    );
  }

  void _showMarkAttendanceDialog(BuildContext context, DateTime date) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 40, height: 4, decoration: BoxDecoration(color: isDark ? Colors.white12 : Colors.grey.shade300, borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 20),
            Text(
              "Mark Attendance",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface),
            ),
            const SizedBox(height: 8),
            Text(DateFormat('EEEE, dd MMMM yyyy').format(date), style: TextStyle(color: isDark ? Colors.white60 : Colors.black54)),
            const SizedBox(height: 30),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () { controller.markAttendance(date, 'present'); Get.back(); },
                    icon: const Icon(Icons.check_circle_rounded, color: Colors.white),
                    label: const Text("Present", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () { controller.markAttendance(date, 'absent'); Get.back(); },
                    icon: const Icon(Icons.cancel_rounded, color: Colors.white),
                    label: const Text("Absent", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.red, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _paymentSection(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return StreamBuilder<List<PaymentModel>>(
      stream: controller.paymentStream,
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        final payments = snapshot.data!;
        if (payments.isEmpty) return Center(child: Text("No payment history found.", style: TextStyle(color: isDark ? Colors.white38 : Colors.grey)));

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: payments.length,
          itemBuilder: (context, index) {
            final p = payments[index];
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(isDark ? 0.2 : 0.05), blurRadius: 8, offset: const Offset(0, 3))],
              ),
              child: Row(
                children: [
                  Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: Colors.green.withOpacity(0.1), shape: BoxShape.circle), child: const Icon(Icons.check_rounded, color: Colors.green, size: 20)),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Fees Paid", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: theme.colorScheme.onSurface)),
                        Text(DateFormat('dd MMM yyyy').format(p.date), style: TextStyle(fontSize: 13, color: isDark ? Colors.white60 : Colors.black54)),
                      ],
                    ),
                  ),
                  Text("₹${p.amount.toStringAsFixed(0)}", style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: Colors.green)),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _addPaymentSection(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Column(
      children: [
        TextField(
          controller: controller.paymentAmountController,
          keyboardType: TextInputType.number,
          style: TextStyle(color: theme.colorScheme.onSurface, fontWeight: FontWeight.bold, fontSize: 18),
          decoration: InputDecoration(
            labelText: "Payment Amount",
            labelStyle: TextStyle(color: theme.primaryColor, fontWeight: FontWeight.w600),
            prefixIcon: Icon(Icons.currency_rupee_rounded, color: theme.primaryColor),
            filled: true,
            fillColor: theme.cardColor,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: BorderSide.none),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: BorderSide(color: isDark ? Colors.white12 : Colors.black12)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: BorderSide(color: theme.primaryColor, width: 2)),
          ),
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: controller.recordPayment,
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(double.infinity, 55),
            backgroundColor: theme.primaryColor,
            foregroundColor: Colors.white,
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          ),
          child: const Text("SAVE PAYMENT", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, letterSpacing: 1.2)),
        ),
      ],
    );
  }

  Widget _infoCard(BuildContext context, IconData icon, String title, String value, {bool isBalance = false, bool fullWidth = false}) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      width: fullWidth ? double.infinity : null,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isBalance ? Colors.red.withOpacity(0.08) : theme.cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: isBalance ? Colors.red.withOpacity(0.2) : Colors.transparent),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(isDark ? 0.2 : 0.05), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: isBalance ? Colors.red : theme.primaryColor),
              const SizedBox(width: 8),
              Text(title, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: isDark ? Colors.white38 : Colors.grey.shade600)),
            ],
          ),
          const SizedBox(height: 8),
          Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: isBalance ? Colors.red : theme.colorScheme.onSurface)),
        ],
      ),
    );
  }

  Widget _attendanceCard(int count, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Text("$count", style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: color)),
          Text(label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }
}