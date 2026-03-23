import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:music_class/screen/Payment/Payment.dart';
import 'package:music_class/screen/attendance.dart';
import 'package:music_class/screen/dues.dart';
import 'package:music_class/screen/home.dart';
import 'package:music_class/screen/student/student.dart';

import 'Logic/controller/user/home_controller.dart';

class Mainscreen extends StatefulWidget {
  const Mainscreen({super.key});

  @override
  State<Mainscreen> createState() => _MainscreenState();
}

class _MainscreenState extends State<Mainscreen> {
  int selectedIndex = 0;

  void onItemTapped(int index) {
    setState(() {
      selectedIndex = index;
    });
    
    // Refresh Home data if Home tab is selected
    if (index == 0) {
      try {
        if (Get.isRegistered<HomeController>()) {
          Get.find<HomeController>().refreshData();
        }
      } catch (e) {
        // Controller might not be initialized yet, which is fine
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      HomePage(
        onNavigateToStudent: () => onItemTapped(1),
        onNavigateToAttendance: () => onItemTapped(2),
        onNavigateToPayments: () => onItemTapped(3),
        onNavigateToDues: () => onItemTapped(4),
      ),
      const Student(),
      const Attendance(),
      const Payment(),
      const Dues(),
    ];

    return Scaffold(
      body: pages[selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: selectedIndex,
        selectedItemColor: Colors.deepPurple,
        unselectedItemColor: Colors.black87,
        type: BottomNavigationBarType.fixed,
        onTap: onItemTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people_alt_outlined),
            label: "Student",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today_outlined),
            label: "Attendance",
          ),
          BottomNavigationBarItem(icon: Icon(Icons.payment), label: "Payment"),
          BottomNavigationBarItem(
            icon: Icon(Icons.error_outline),
            label: "Dues",
          ),
        ],
      ),
    );
  }
}
