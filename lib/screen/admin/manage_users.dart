import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../Logic/controller/admin/admin_controller.dart';
import 'Userdetail.dart';


class ManageUsersPage extends StatelessWidget {
  ManageUsersPage({super.key});

  final AdminController controller = Get.put(AdminController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Users Student"),
        backgroundColor: const Color(0xFF6A5AE0),
        foregroundColor: Colors.white,
      ),
      body: Obx(() {
        if (controller.isLoadingUsers.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.users.isEmpty) {
          return const Center(child: Text("No users found"));
        }

        return ListView.builder(
          itemCount: controller.users.length,
          itemBuilder: (context, index) {
            final user = controller.users[index];

            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundImage: user['profileImage'] != null &&
                      user['profileImage'].isNotEmpty
                      ? NetworkImage(user['profileImage'])
                      : null,
                  child: user['profileImage'] == null ||
                      user['profileImage'].isEmpty
                      ? const Icon(Icons.person)
                      : null,
                ),
                title: Text(user['name'] ?? 'Unknown'),
                subtitle: Text(user['email'] ?? ''),
                trailing: const Icon(Icons.arrow_forward_ios_rounded),
                onTap: () {
                  Get.to(() => UserDetailsPage(user: user));
                },
              ),
            );
          },
        );
      }),
    );
  }
}