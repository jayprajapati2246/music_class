import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:music_class/screen/Payment/Payment.dart';
import 'package:music_class/screen/attendance.dart';
import 'package:music_class/screen/Payment/dues.dart';
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
        onNavigateToAddStudents: () => onItemTapped(1),
        onNavigateToAttendance: () => onItemTapped(2),
        onNavigateToPayments: () => onItemTapped(3),
        onNavigateToDues: () => onItemTapped(4),
      ),
      const Student(),
      const Attendance(),
      const Payment(),
      const Dues(),
    ];

    // Access current theme colors
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: pages[selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: selectedIndex,
        selectedItemColor: theme.primaryColor,
        unselectedItemColor: isDark ? Colors.white70 : Colors.black54,
        backgroundColor: theme.bottomNavigationBarTheme.backgroundColor ?? theme.cardColor,
        type: BottomNavigationBarType.fixed,
        onTap: onItemTapped,
        elevation: 10,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home_rounded),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people_alt_outlined),
            activeIcon: Icon(Icons.people_alt_rounded),
            label: "Student",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today_outlined),
            activeIcon: Icon(Icons.calendar_today_rounded),
            label: "Attendance",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.payment_outlined), 
            activeIcon: Icon(Icons.payment_rounded),
            label: "Payment",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.error_outline_rounded),
            activeIcon: Icon(Icons.error_rounded),
            label: "Dues",
          ),
        ],
      ),
    );
  }
}
