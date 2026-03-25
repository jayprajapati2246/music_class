import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../Logic/controller/admin/admin_controller.dart';
import 'Userdetail.dart';

class ManageUsersPage extends StatelessWidget {
  final String appBarTitle;

  ManageUsersPage({
    super.key,
    required this.appBarTitle,
  });

  final AdminController controller = Get.put(AdminController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(appBarTitle),
        backgroundColor: const Color(0xFF6A5AE0),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Obx(() {
        if (controller.isLoadingUsers.value) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (controller.users.isEmpty) {
          return const Center(
            child: Text(
              "No users found",
              style: TextStyle(fontSize: 16),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: controller.users.length,
          itemBuilder: (context, index) {
            final user = controller.users[index];

            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                leading: CircleAvatar(
                  radius: 26,
                  backgroundColor: const Color(0xFF6A5AE0),
                  backgroundImage: user['profileImage'] != null &&
                      user['profileImage'].isNotEmpty
                      ? NetworkImage(user['profileImage'])
                      : null,
                  child: user['profileImage'] == null ||
                      user['profileImage'].isEmpty
                      ? const Icon(
                    Icons.person,
                    color: Colors.white,
                  )
                      : null,
                ),
                title: Text(
                  user['name'] ?? 'Unknown',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Text(user['email'] ?? ''),
                trailing: const Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 18,
                ),
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