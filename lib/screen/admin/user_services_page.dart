import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../Logic/controller/admin/admin_controller.dart';
import '../../Logic/model/Student.dart';
import '../student/addnewstudent.dart';

class UserServicesPage extends StatelessWidget {
  final Map<String, dynamic> user;

  UserServicesPage({super.key, required this.user});

  final AdminController controller = Get.find();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          "User Services Enroll",
          style: TextStyle(
            color: theme.colorScheme.onSurface,
            fontWeight: FontWeight.bold,
          ),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: theme.colorScheme.onSurface,
        centerTitle: true,
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: theme.colorScheme.onSurface),
        ),
      ),
      body: Column(
        children: [
          // User Info Section
          _buildUserHeader(context, isDark),
          
          const SizedBox(height: 10),
          
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Row(
              children: [
                Icon(Icons.category_rounded, color: theme.primaryColor, size: 20),
                const SizedBox(width: 8),
                Text(
                  "Assigned Services",
                  style: TextStyle(
                    fontSize: 18, 
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: StreamBuilder<List<StudentModel>>(
              stream: controller.getStudentsForUser(user['uid']),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator(color: theme.primaryColor));
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return _buildEmptyState(context, isDark);
                }

                final students = snapshot.data!;

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemCount: students.length,
                  itemBuilder: (context, index) {
                    return _buildServiceCard(context, students[index], isDark);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserHeader(BuildContext context, bool isDark) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark 
            ? [const Color(0xFF2C2C44), const Color(0xFF1A1A2E)]
            : [const Color(0xFF6A5AE0).withOpacity(0.9), const Color(0xFF8E54E9).withOpacity(0.9)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: theme.primaryColor.withOpacity(0.2),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 35,
            backgroundColor: Colors.white.withOpacity(0.2),
            backgroundImage: user['profileImage'] != null && user['profileImage'].isNotEmpty
                ? NetworkImage(user['profileImage'])
                : null,
            child: user['profileImage'] == null || user['profileImage'].isEmpty
                ? const Icon(Icons.person, size: 35, color: Colors.white)
                : null,
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user['name'] ?? 'Unknown User',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.email_outlined, color: Colors.white70, size: 14),
                    const SizedBox(width: 5),
                    Expanded(
                      child: Text(
                        user['email'] ?? 'No Email',
                        style: const TextStyle(color: Colors.white70, fontSize: 13),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    const Icon(Icons.phone_outlined, color: Colors.white70, size: 14),
                    const SizedBox(width: 5),
                    Text(
                      user['phone'] ?? 'No Phone',
                      style: const TextStyle(color: Colors.white70, fontSize: 13),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceCard(BuildContext context, StudentModel student, bool isDark) {
    final theme = Theme.of(context);
    final dateFormat = DateFormat('dd MMM yyyy');

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isDark ? Colors.white12 : Colors.black12.withOpacity(0.05)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header of the card
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: theme.primaryColor.withOpacity(0.05),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.auto_stories_rounded, color: theme.primaryColor, size: 22),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        student.name,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      Text(
                        student.course,
                        style: TextStyle(
                          fontSize: 12,
                          color: theme.primaryColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: (student.status == 'Active' ? Colors.green : Colors.red).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    student.status,
                    style: TextStyle(
                      color: student.status == 'Active' ? Colors.green : Colors.red,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                _buildActionMenu(context, student),
              ],
            ),
          ),
          
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(child: _buildInfoItem(Icons.access_time_rounded, "Batch Time", student.batchTime, theme, isDark)),
                    Expanded(child: _buildInfoItem(Icons.payments_outlined, "Fees", "₹${student.monthlyFee}", theme, isDark)),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(child: _buildInfoItem(Icons.calendar_month_rounded, "Joining Date", dateFormat.format(student.joinDate), theme, isDark)),
                    Expanded(child: _buildInfoItem(Icons.share_location_rounded, "Source", student.source, theme, isDark)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String label, String value, ThemeData theme, bool isDark) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isDark ? Colors.white.withOpacity(0.05) : Colors.grey.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 18, color: theme.primaryColor),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  color: isDark ? Colors.white38 : Colors.grey,
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionMenu(BuildContext context, StudentModel student) {
    final theme = Theme.of(context);
    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert_rounded, size: 20),
      onSelected: (value) async {
        if (value == "edit") {
          await Get.to(
            () => Addnstudent(
              student: student,
              userId: user['uid'],
            ),
            transition: Transition.rightToLeftWithFade,
          );
        } else if (value == "delete") {
          _showDeleteConfirmation(context, student);
        }
      },
      itemBuilder: (context) => [
        const PopupMenuItem(
          value: "edit",
          child: Row(
            children: [
              Icon(Icons.edit_rounded, color: Colors.blue, size: 18),
              SizedBox(width: 10),
              Text("Edit Service"),
            ],
          ),
        ),
        const PopupMenuItem(
          value: "delete",
          child: Row(
            children: [
              Icon(Icons.delete_outline_rounded, color: Colors.red, size: 18),
              SizedBox(width: 10),
              Text("Remove Service"),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context, bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.layers_clear_outlined, 
            size: 80, 
            color: isDark ? Colors.white12 : Colors.grey.shade300
          ),
          const SizedBox(height: 16),
          Text(
            "No services assigned yet",
            style: TextStyle(
              fontSize: 18, 
              fontWeight: FontWeight.w500,
              color: isDark ? Colors.white38 : Colors.grey
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Add services to see them here",
            style: TextStyle(
              fontSize: 14, 
              color: isDark ? Colors.white24 : Colors.grey.shade400
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, StudentModel student) {
    final theme = Theme.of(context);
    Get.dialog(
      AlertDialog(
        backgroundColor: theme.cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Remove Service?"),
        content: Text("Are you sure you want to remove ${student.course} service for ${student.name}?"),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              controller.deleteStudent(user['uid'], student.id!);
              Get.back();
            },
            child: const Text("Remove", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
