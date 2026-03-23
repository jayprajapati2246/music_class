import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'manage_users.dart';

class AdminDashboardPage extends StatelessWidget {
  const AdminDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF8F9FE),
      appBar: AppBar(
        title: const Text("Admin Dashboard", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF6A5AE0),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 15,
          mainAxisSpacing: 15,
          children: [
            GestureDetector(
              onTap: () => Get.to(() => ManageUsersPage()),
              child: _dashboardItem(Icons.people_rounded, "Users Student", Colors.blue),
            ),
            GestureDetector(
              onTap: () => Get.to(() => ManageUsersPage()),
              child: _dashboardItem(Icons.people_rounded, "Manage Users", Colors.orange),
            ),
            _dashboardItem(Icons.edit_note_rounded, "Edit Data", Colors.green),
            _dashboardItem(Icons.delete_sweep_rounded, "Delete Data", Colors.redAccent),
            _dashboardItem(Icons.settings_suggest_rounded, "System Settings", Colors.blueGrey),
            _dashboardItem(Icons.campaign_rounded, "Announcements", Colors.purple),
          ],
        ),
      ),
    );
  }

  Widget _dashboardItem(IconData icon, String label, Color color) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05), 
            blurRadius: 15, 
            offset: const Offset(0, 8)
          ),
        ],
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 32, color: color),
          ),
          const SizedBox(height: 12),
          Text(
            label, 
            textAlign: TextAlign.center, 
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF1A1D1E)),
          ),
        ],
      ),
    );
  }
}
