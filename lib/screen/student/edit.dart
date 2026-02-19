import 'package:flutter/material.dart';
import 'package:music_class/Logic/model/Student.dart';
import 'package:music_class/screen/attendance.dart';

class editdetail extends StatefulWidget {
  editdetail({super.key, required this.student});

  final StudentModel student;

  @override
  State<editdetail> createState() => _editdetailState();
}

class _editdetailState extends State<editdetail> {

  int selectedTab = 0;


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.white70,
        elevation: 0,
        title: Text(
          "Student Details",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsetsGeometry.all(10),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 25,
                    backgroundColor: Colors.lightBlueAccent.shade100,
                    child: const Icon(
                      Icons.person_outline,
                      color: Colors.black,
                    ),
                  ),

                  SizedBox(width: 20),

                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.student.name,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 3),
                      Text(
                        "Since Feb 5, 2026",
                        style: TextStyle(fontSize: 15, color: Colors.black87),
                      ),
                    ],
                  ),

                  SizedBox(width: 10),

                  IconButton(
                    onPressed: () {},
                    icon: Icon(Icons.edit, color: Colors.blueGrey),
                  ),

                  IconButton(
                    onPressed: () {},
                    icon: Icon(Icons.delete, color: Colors.red),
                  ),
                ],
              ),

              SizedBox(height: 10),

              Row(
                children: [
                  Expanded(
                    child: infoCard(
                      icon: Icons.music_note,
                      title: "Course",
                      value: "Tabla",
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: infoCard(
                      icon: Icons.access_time,
                      title: "Batch",
                      value: "5:00 PM - 6:00 PM",
                    ),
                  ),
                ],
              ),

              SizedBox(height: 10),

              Row(
                children: [
                  Expanded(
                    child: infoCard(
                      icon: Icons.credit_card,
                      title: "Monthly Fee",
                      value: "9000",
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: infoCard(
                      icon: Icons.credit_card,
                      title: "Balance",
                      value: "7000",
                    ),
                  ),
                ],
              ),

              SizedBox(height: 10),

              infoCard(icon: Icons.call, title: "Call", value: "8723451645"),

              SizedBox(height: 10),

              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () =>
                            setState(() => selectedTab = 0),
                        child: tabItem("Attendance", 0),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () =>
                            setState(() => selectedTab = 1),
                        child: tabItem("Payments", 1),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () =>
                            setState(() => selectedTab = 2),
                        child: tabItem("Add Payment", 2),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              /// ================= TAB CONTENT =================
              if (selectedTab == 0) attendanceSection(),
              if (selectedTab == 1) paymentSection(),
              if (selectedTab == 2) addPaymentSection(),

            ],
          ),
        ),
      ),
    );
  }

  Widget infoCard({
    required IconData icon,
    required String title,
    required String value,
    bool isBalance = false,
    bool fullWidth = false,
  }) {
    return Container(
      width: fullWidth ? double.infinity : null,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: isBalance ? Colors.red.withOpacity(0.12) : Colors.grey.shade200,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title.isNotEmpty)
            Row(
              children: [
                Icon(icon, size: 16, color: Colors.grey),
                const SizedBox(width: 6),
                Text(
                  title,
                  style: const TextStyle(fontSize: 13, color: Colors.grey),
                ),
              ],
            ),

          if (title.isNotEmpty) const SizedBox(height: 6),

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

  Widget tabItem(String title, int index) {
    final bool isSelected = selectedTab == index;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: isSelected ? Colors.white54 : Colors.transparent,
        borderRadius: BorderRadius.circular(25),
      ),
      child: Center(
        child: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.black : Colors.grey,
          ),
        ),
      ),
    );
  }


  Widget attendanceSection() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: attendanceCountCard(
                  4, "Present", Colors.green),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: attendanceCountCard(
                  0, "Absent", Colors.red),
            ),
          ],
        ),
        const SizedBox(height: 20),

        /// Simple Calendar
        GridView.builder(
          shrinkWrap: true,
          physics:
          const NeverScrollableScrollPhysics(),
          itemCount: 28,
          gridDelegate:
          const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
          ),
          itemBuilder: (context, index) {
            int day = index + 1;

            bool isPresent =
            [5, 6, 7, 10, 11].contains(day);
            bool isToday = day == 19;

            return Container(
              margin: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isPresent
                    ? Colors.green.shade200
                    : isToday
                    ? Colors.orange
                    : Colors.transparent,
              ),
              child: Center(
                child: Text(
                  "$day",
                  style: const TextStyle(
                      fontWeight: FontWeight.w600),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget attendanceCountCard(
      int count, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        children: [
          Text(
            "$count",
            style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: color),
          ),
          const SizedBox(height: 5),
          Text(label),
        ],
      ),
    );
  }

  /// ================= PAYMENTS =================
  Widget paymentSection() {
    return const Center(
      child: Text(
        "Payment History Coming Soon",
        style: TextStyle(fontWeight: FontWeight.w600),
      ),
    );
  }

  /// ================= ADD PAYMENT =================
  Widget addPaymentSection() {
    return Center(
      child: ElevatedButton(
        onPressed: () {},
        child: const Text("Add Payment"),
      ),
    );
  }

}
