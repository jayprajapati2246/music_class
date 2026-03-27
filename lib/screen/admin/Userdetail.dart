import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../Logic/controller/admin/admin_controller.dart';
import '../../Logic/model/Student.dart';
import 'user_services_page.dart';

class UserDetailsPage extends StatelessWidget {
  final Map<String, dynamic> user;

  UserDetailsPage({super.key, required this.user});

  final AdminController controller = Get.find();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryColor = theme.primaryColor;
    final onSurface = theme.colorScheme.onSurface;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // Elegant SliverAppBar
          SliverAppBar(
            expandedHeight: 260,
            pinned: true,
            stretch: true,
            backgroundColor: theme.scaffoldBackgroundColor,
            elevation: 0,
            flexibleSpace: FlexibleSpaceBar(
              stretchModes: const [
                StretchMode.zoomBackground,
                StretchMode.blurBackground
              ],
              background: Stack(
                fit: StackFit.expand,
                children: [
                  // Decorative Background Gradient
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          primaryColor.withValues(alpha: isDark ? 0.6 : 0.8),
                          primaryColor.withValues(alpha: 0.2),
                          theme.scaffoldBackgroundColor,
                        ],
                      ),
                    ),
                  ),
                  // User Profile Image & Name
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 50),
                        Hero(
                          tag: 'user-avatar-${user['uid']}',
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(
                                      alpha: isDark ? 0.4 : 0.15),
                                  blurRadius: 30,
                                  spreadRadius: 2,
                                )
                              ],
                              border: Border.all(
                                color: isDark ? theme.cardColor : Colors.white,
                                width: 4,
                              ),
                            ),
                            child: CircleAvatar(
                              radius: 55,
                              backgroundColor: isDark ? theme.cardColor : Colors
                                  .white,
                              backgroundImage: user['profileImage'] != null &&
                                  user['profileImage'].isNotEmpty
                                  ? NetworkImage(user['profileImage'])
                                  : null,
                              child: user['profileImage'] == null ||
                                  user['profileImage'].isEmpty
                                  ? Icon(
                                  Icons.person, size: 55, color: primaryColor)
                                  : null,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          user['name'] ?? 'Unknown',
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: onSurface,
                            letterSpacing: -0.5,
                            shadows: [
                              Shadow(
                                blurRadius: 10,
                                color: Colors.black.withValues(
                                    alpha: isDark ? 0.3 : 0.1),
                                offset: const Offset(0, 2),
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            leading: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: theme.cardColor.withValues(alpha: 0.5),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                    Icons.arrow_back_ios_new, size: 18, color: onSurface),
              ),
              onPressed: () => Get.back(),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: 20.0, vertical: 10),
              child: Column(
                children: [
                  // Quick Stats Summary
                  StreamBuilder<List<StudentModel>>(
                    stream: controller.getStudentsForUser(user['uid']),
                    builder: (context, snapshot) {
                      final studentCount = snapshot.data?.length ?? 0;
                      return Row(
                        children: [
                          _buildStatCard(
                            context,
                            "Total Students",
                            studentCount.toString(),
                            Icons.group_rounded,
                            Colors.blueAccent,
                          ),
                          const SizedBox(width: 15),
                          _buildStatCard(
                            context,
                            "Status",
                            "Active",
                            Icons.verified_rounded,
                            Colors.green,
                          ),
                        ],
                      );
                    },
                  ),

                  const SizedBox(height: 32),

                  // Contact Info Section
                  _buildSectionHeader(
                      "Contact Info", Icons.alternate_email_rounded, theme),
                  _buildInfoCard(
                    context,
                    items: [
                      _infoItem(Icons.mail_outline_rounded, "Email Address",
                          user['email'] ?? 'N/A', theme),
                      _infoItem(Icons.phone_iphone_rounded, "Phone Number",
                          user['phone'] ?? 'N/A', theme),
                    ],
                  ),

                  const SizedBox(height: 28),

                  // Configured Services Section
                  StreamBuilder<DocumentSnapshot>(
                    stream: controller.getUserStream(user['uid']),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Padding(
                          padding: EdgeInsets.symmetric(vertical: 20),
                          child: LinearProgressIndicator(),
                        );
                      }

                      final userData = snapshot.data?.data() as Map<
                          String,
                          dynamic>? ?? {};
                      final services = userData['services'] as Map<
                          String,
                          dynamic>? ?? {};
                      final addedCourses = List<String>.from(
                          services['courses'] ?? []);
                      final addedBatches = List<String>.from(
                          services['batchTimes'] ?? []);
                      final addedFees = List<String>.from(
                          services['fees'] ?? []);

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _buildSectionHeader("Configured Services",
                                  Icons.auto_awesome_mosaic_rounded, theme),
                              TextButton.icon(
                                onPressed: () =>
                                    Get.to(() => UserServicesPage(user: user)),
                                label: const Text("View All"),
                                style: TextButton.styleFrom(
                                  foregroundColor: primaryColor,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12),
                                ),
                              ),
                            ],
                          ),
                          _buildInfoCard(
                            context,
                            items: [
                              _buildServiceTags(
                                  context,
                                  "Courses",
                                  addedCourses,
                                  Icons.auto_stories_rounded,
                                  Colors.indigoAccent
                              ),
                              const Padding(
                                padding: EdgeInsets.symmetric(vertical: 12),
                                child: Divider(height: 1, thickness: 0.5),
                              ),
                              _buildServiceTags(
                                  context,
                                  "Batch Times",
                                  addedBatches,
                                  Icons.alarm_rounded,
                                  Colors.orangeAccent
                              ),
                              if (addedFees.isNotEmpty) ...[
                                const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 12),
                                  child: Divider(height: 1, thickness: 0.5),
                                ),
                                _buildServiceTags(
                                    context,
                                    "Fee Plans",
                                    addedFees.map((f) => "₹$f").toList(),
                                    Icons.account_balance_wallet_rounded,
                                    Colors.tealAccent
                                ),
                              ],
                            ],
                          ),
                        ],
                      );
                    },
                  ),

                  const SizedBox(height: 28),

                  // Active Usage Section
                  StreamBuilder<List<StudentModel>>(
                    stream: controller.getStudentsForUser(user['uid']),
                    builder: (context, snapshot) {
                      final students = snapshot.data ?? [];
                      if (students.isEmpty) return const SizedBox();

                      final activeCourses = students
                          .map((e) => e.course)
                          .where((c) => c.isNotEmpty)
                          .toSet()
                          .toList();
                      final activeBatches = students
                          .map((e) => e.batchTime)
                          .where((b) => b.isNotEmpty)
                          .toSet()
                          .toList();

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSectionHeader("Usage Insight", Icons
                              .analytics_rounded, theme),
                          _buildInfoCard(
                            context,
                            items: [
                              _infoItem(
                                  Icons.layers_outlined,
                                  "Active Courses",
                                  activeCourses.join(", "),
                                  theme
                              ),
                              _infoItem(
                                  Icons.timelapse_rounded,
                                  "Active Batches",
                                  activeBatches.join(", "),
                                  theme
                              ),
                            ],
                          ),
                        ],
                      );
                    },
                  ),

                  const SizedBox(height: 28),

                  _buildSectionHeader(
                      "System ID", Icons.info_outline_rounded, theme),
                  _buildInfoCard(
                    context,
                    items: [
                      _infoItem(Icons.fingerprint_rounded, "Identifier (UID)",
                          user['uid'] ?? 'N/A', theme),
                    ],
                  ),

                  const SizedBox(height: 48),


                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.red.withValues(alpha: isDark ? 0.1 : 0.05),
                      borderRadius: BorderRadius.circular(28),
                      border: Border.all(color: Colors.red.withValues(
                          alpha: isDark ? 0.3 : 0.2)),
                    ),
                    child: Column(
                      children: [
                        const Icon(Icons.report_gmailerrorred_rounded,
                            color: Colors.red, size: 40),
                        const SizedBox(height: 16),
                        const Text(
                          "Sensitive Actions",
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight
                              .bold, color: Colors.red),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Removing this user will immediately disconnect all linked students and services. This cannot be undone.",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 13,
                              color: isDark ? Colors.red[200] : Colors.red[700],
                              height: 1.5
                          ),
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () => _showDeleteDialog(context),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16)),
                              elevation: 0,
                            ),
                            child: const Text("DELETE ACCOUNT",
                                style: TextStyle(fontWeight: FontWeight.bold,
                                    letterSpacing: 1)),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 60),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 12),
      child: Row(
        children: [
          Icon(
              icon, size: 18, color: theme.primaryColor.withValues(alpha: 0.8)),
          const SizedBox(width: 10),
          Text(
            title.toUpperCase(),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.5,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(BuildContext context, String label, String value,
      IconData icon, Color color) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isDark ? color.withValues(alpha: 0.15) : color.withValues(
              alpha: 0.1),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: color.withValues(alpha: 0.25), width: 1.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(height: 18),
            Text(
              value,
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w900,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(BuildContext context, {required List<Widget> items}) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.04),
            blurRadius: 25,
            offset: const Offset(0, 10),
          ),
        ],
        border: Border.all(
            color: theme.dividerColor.withValues(alpha: isDark ? 0.1 : 0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: items,
      ),
    );
  }

  Widget _buildServiceTags(BuildContext context, String title,
      List<String> tags, IconData icon, Color color) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: color.withValues(alpha: 0.9)),
            const SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        tags.isEmpty
            ? Text(
          "No $title configured",
          style: TextStyle(
            fontSize: 13,
            fontStyle: FontStyle.italic,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
          ),
        )
            : Wrap(
          spacing: 10,
          runSpacing: 10,
          children: tags.map((tag) =>
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: isDark ? color.withValues(alpha: 0.15) : color
                      .withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                      color: color.withValues(alpha: isDark ? 0.3 : 0.2)),
                ),
                child: Text(
                  tag,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: isDark ? color : color.withValues(alpha: 0.9),
                  ),
                ),
              )).toList(),
        ),
      ],
    );
  }

  Widget _infoItem(IconData icon, String label, String value, ThemeData theme) {
    final onSurface = theme.colorScheme.onSurface;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: theme.primaryColor, size: 20),
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    color: onSurface.withValues(alpha: 0.45),
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: onSurface,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    Get.dialog(
      AlertDialog(
        backgroundColor: theme.cardColor,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                  Icons.warning_amber_rounded, color: Colors.red, size: 24),
            ),
            const SizedBox(width: 12),
            const Text(
                "Final Warning", style: TextStyle(fontWeight: FontWeight.w900)),
          ],
        ),
        content: Text(
          "This will permanently delete the account for ${user['name']}. This action is irreversible. Do you wish to continue?",
          style: TextStyle(
              fontSize: 15,
              height: 1.6,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.8)
          ),
        ),
        actionsPadding: const EdgeInsets.only(right: 20, bottom: 20, left: 20),
        actions: [
          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: () => Get.back(),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                  child: Text("CANCEL", style: TextStyle(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                      fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    controller.deleteUser(user['uid']);
                    Get.back();
                    Get.back();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                  child: const Text(
                      "DELETE", style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
