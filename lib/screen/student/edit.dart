import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:music_class/Logic/controller/edit.dart';
import 'package:music_class/Logic/model/Student.dart';
import 'package:music_class/Logic/model/attundance.dart';
import 'package:music_class/Logic/model/payment.dart';
import 'package:music_class/screen/student/addnewstudent.dart';
import 'package:table_calendar/table_calendar.dart';

class EditDetail extends StatelessWidget {
  final StudentModel student;
  final StudentDetailController controller;

  EditDetail({super.key, required this.student})
      : controller = Get.put(StudentDetailController(student), tag: student.id);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
        ),
        title: const Text(
          "Student Details",
          style: TextStyle(fontWeight: FontWeight.bold),
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
            icon: const Icon(Icons.edit, color: Colors.blueGrey),
          ),
          IconButton(
            onPressed: () {
              Get.defaultDialog(
                title: "Delete Student",
                middleText:
                    "Are you sure you want to delete ${controller.student.value.name}?",
                textConfirm: "Delete",
                textCancel: "Cancel",
                confirmTextColor: Colors.white,
                onConfirm: controller.deleteStudent,
              );
            },
            icon: const Icon(Icons.delete, color: Colors.red),
          ),
        ],
      ),
      body: Obx(() {
        final student = controller.student.value;

        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              children: [
                _buildHeader(student),
                const SizedBox(height: 10),
                _buildInfoCards(student),
                const SizedBox(height: 10),
                _buildCallCard(student),
                const SizedBox(height: 10),
                _buildTabBar(),
                const SizedBox(height: 20),
                _buildTabContent(),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildHeader(StudentModel student) {
    return Row(
      children: [
        CircleAvatar(
          radius: 25,
          backgroundColor: Colors.lightBlueAccent.shade100,
          child: const Icon(Icons.person_outline, color: Colors.black),
        ),
        const SizedBox(width: 20),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              student.name,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 3),
            Text(
              "Joined on ${DateFormat('MMM d, yyyy').format(student.joinDate)}",
              style: const TextStyle(fontSize: 15, color: Colors.black87),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildInfoCards(StudentModel student) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _infoCard(Icons.music_note, "Course", student.course),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _infoCard(Icons.access_time, "Batch", student.batchTime),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _infoCard(
                Icons.credit_card,
                "Monthly Fee",
                "₹${student.monthlyFee.toStringAsFixed(0)}",
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _infoCard(
                Icons.account_balance_wallet,
                "Balance",
                "₹${controller.balance.value.toStringAsFixed(0)}",
                isBalance: true,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCallCard(StudentModel student) {
    return _infoCard(Icons.call, "Call", student.phone, fullWidth: true);
  }

  Widget _buildTabBar() {
    return Obx(() => Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: Colors.grey.shade300,
            borderRadius: BorderRadius.circular(30),
          ),
          child: Row(
            children: [
              _tabItem("Attendance", 0),
              _tabItem("Payments", 1),
              _tabItem("Add Payment", 2),
            ],
          ),
        ));
  }

  Widget _tabItem(String title, int index) {
    final isSelected = controller.selectedTab.value == index;

    return Expanded(
      child: GestureDetector(
        onTap: () => controller.changeTab(index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(25),
          ),
          child: Center(
            child: Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.deepPurple : Colors.grey,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTabContent() {
    return Obx(() {
      switch (controller.selectedTab.value) {
        case 0:
          return _attendanceSection();
        case 1:
          return _paymentSection();
        case 2:
          return _addPaymentSection();
        default:
          return const SizedBox.shrink();
      }
    });
  }

  Widget _attendanceSection() {
    return StreamBuilder<List<AttendanceRecordModel>>(
      stream: controller.attendanceStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final allRecords = snapshot.data ?? [];
        
        // Filter records for the currently focused month
        final focusedMonthRecords = allRecords.where((r) => 
          r.date.month == controller.focusedDay.value.month && 
          r.date.year == controller.focusedDay.value.year
        ).toList();

        final presentCount = focusedMonthRecords.where((e) => e.status == 'present').length;
        final absentCount = focusedMonthRecords.where((e) => e.status == 'absent').length;

        return Column(
          children: [
            Row(
              children: [
                Expanded(child: _attendanceCard(presentCount, "Present", Colors.green)),
                const SizedBox(width: 10),
                Expanded(child: _attendanceCard(absentCount, "Absent", Colors.red)),
              ],
            ),
            const SizedBox(height: 20),
            TableCalendar(
              firstDay: DateTime.utc(2020, 1, 1),
              lastDay: DateTime.utc(2030, 12, 31),
              focusedDay: controller.focusedDay.value,
              headerStyle: const HeaderStyle(
                formatButtonVisible: false,
                titleCentered: true,
              ),
              onPageChanged: (focusedDay) {
                controller.focusedDay.value = focusedDay;
              },
              calendarBuilders: CalendarBuilders(
                defaultBuilder: (context, day, focusedDay) {
                  final record = allRecords.firstWhereOrNull((r) =>
                    isSameDay(r.date, day));

                  if (record != null) {
                    return Container(
                      margin: const EdgeInsets.all(4),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: record.status == 'present' ? Colors.green.shade400 : Colors.red.shade400,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        '${day.day}',
                        style: const TextStyle(color: Colors.white),
                      ),
                    );
                  }
                  return null;
                },
                todayBuilder: (context, day, focusedDay) {
                   final record = allRecords.firstWhereOrNull((r) =>
                    isSameDay(r.date, day));

                   return Container(
                      margin: const EdgeInsets.all(4),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: record != null
                          ? (record.status == 'present' ? Colors.green.shade400 : Colors.red.shade400)
                          : Colors.blue.withOpacity(0.3),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.blue, width: 2)
                      ),
                      child: Text(
                        '${day.day}',
                        style: TextStyle(color: record != null ? Colors.white : Colors.blue.shade900, fontWeight: FontWeight.bold),
                      ),
                    );
                }
              ),
              onDaySelected: (selectedDay, focusedDay) {
                controller.focusedDay.value = focusedDay;
                _showMarkAttendanceDialog(selectedDay);
              },
            ),
          ],
        );
      },
    );
  }

  void _showMarkAttendanceDialog(DateTime date) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Mark Attendance for ${DateFormat('dd MMM yyyy').format(date)}",
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      controller.markAttendance(date, 'present');
                      Get.back();
                    },
                    icon: const Icon(Icons.check_circle, color: Colors.white),
                    label: const Text("Present", style: TextStyle(color: Colors.white)),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      controller.markAttendance(date, 'absent');
                      Get.back();
                    },
                    icon: const Icon(Icons.cancel, color: Colors.white),
                    label: const Text("Absent", style: TextStyle(color: Colors.white)),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Widget _paymentSection() {
    return StreamBuilder<List<PaymentModel>>(
      stream: controller.paymentStream,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final payments = snapshot.data!;
        if (payments.isEmpty) {
          return const Text("No payments found.");
        }

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: payments.length,
          itemBuilder: (context, index) {
            final p = payments[index];
            return Card(
              child: ListTile(
                title: Text("₹${p.amount.toStringAsFixed(0)}"),
                subtitle: Text(DateFormat('MMM d, yyyy').format(p.date)),
                trailing: const Icon(Icons.check_circle, color: Colors.green),
              ),
            );
          },
        );
      },
    );
  }

  Widget _addPaymentSection() {
    return Column(
      children: [
        TextField(
          controller: controller.paymentAmountController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: "Enter Amount",
            prefixText: "₹",
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: controller.recordPayment,
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(double.infinity, 50),
            backgroundColor: Colors.deepPurple,
          ),
          child: const Text(
            "Record Payment",
            style: TextStyle(color: Colors.white),
          ),
        ),
      ],
    );
  }

  Widget _infoCard(IconData icon, String title, String value,
      {bool isBalance = false, bool fullWidth = false}) {
    return Container(
      width: fullWidth ? double.infinity : null,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: isBalance
            ? Colors.red.withOpacity(0.12)
            : Colors.grey.shade200,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: Colors.grey),
              const SizedBox(width: 6),
              Text(title, style: const TextStyle(fontSize: 13, color: Colors.grey)),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: isBalance ? Colors.red : Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget _attendanceCard(int count, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(
            "$count",
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: color),
          ),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(fontSize: 12, color: color)),
        ],
      ),
    );
  }
}
