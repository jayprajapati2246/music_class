import 'package:flutter/material.dart';
import 'package:music_class/screen/Payment.dart';
import 'package:music_class/screen/attendance.dart';
import 'package:music_class/screen/dues.dart';
import 'package:music_class/screen/home.dart';
import 'package:music_class/screen/student/student.dart';

class Mainscreen extends StatefulWidget {
  const Mainscreen({super.key});

  @override
  State<Mainscreen> createState() => _MainscreenState();
}

class _MainscreenState extends State<Mainscreen> {
  int selectedIndex = 0;

  final List<Widget> _pages = const [
    HomePage(),
    Student(),
    Attendance(),
    Payment(),
    Dues(),
  ];

  final List<String> titles = [
    "Home",
    "Student",
   "Attendance",
    "Payment",
    "Dues",
  ];

  final List<String> subtitles = [
    "Music Class Dashboard",
    "0 enrolled",
     "Mark daily attendance",
    "₹0 collected today",
    "All payments cleared",
  ];

  void onItemTapped(int index) {
    setState(() {
      selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: selectedIndex == 0
          ? null
          : AppBar(
              backgroundColor: Colors.white70,
              elevation: 0,
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    titles[selectedIndex],
                    style: const TextStyle(
                      fontSize: 18,
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitles[selectedIndex],
                    style: const TextStyle(fontSize: 12, color: Colors.black),
                  ),
                ],
              ),
            ),

      body: _pages[selectedIndex],

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
