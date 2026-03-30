import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../Logic/controller/user/services_controller.dart';

class UserServicesPage extends StatelessWidget {
  UserServicesPage({super.key});

  final UserServicesController controller = Get.put(UserServicesController());

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: CustomScrollView(
        slivers: [
          // Attractive Header with SliverAppBar
          SliverAppBar(
            expandedHeight: 180,
            floating: false,
            pinned: true,
            elevation: 0,
            backgroundColor: theme.appBarTheme.backgroundColor,
            flexibleSpace: FlexibleSpaceBar(
              centerTitle: true,
              title: Text(
                "My Services",
                style: theme.appBarTheme.titleTextStyle?.copyWith(color: Colors.white),
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isDark 
                      ? [const Color(0xFF1A1A2E), const Color(0xFF16213E)]
                      : [const Color(0xff6A5AE0), const Color(0xff8E54E9)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Center(
                  child: Icon(
                    Icons.dashboard_customize_rounded,
                    size: 80,
                    color: Colors.white.withOpacity(0.15),
                  ),
                ),
              ),
            ),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
              onPressed: () => Get.back(),
            ),
          ),

          SliverToBoxAdapter(
            child: Obx(() {
              if (controller.isLoading.value) {
                return SizedBox(
                  height: 400,
                  child: Center(child: CircularProgressIndicator(color: theme.primaryColor)),
                );
              }
              return Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    // Courses Section Card
                    _buildFeatureCard(
                      context: context,
                      title: "Courses Offered",
                      icon: Icons.auto_stories_rounded,
                      color: Colors.blueAccent,
                      textController: controller.courseController,
                      hint: "e.g. Guitar, Piano, Vocal",
                      onAdd: controller.addCourse,
                      items: controller.courses,
                      onRemove: controller.removeCourse,
                    ),

                    const SizedBox(height: 20),

                    // Batch Times Section Card
                    _buildFeatureCard(
                      context: context,
                      title: "Batch Timings",
                      icon: Icons.access_time_filled_rounded,
                      color: Colors.green.shade600,
                      textController: controller.batchController,
                      hint: "e.g. 10AM - 11AM",
                      onAdd: controller.addBatch,
                      items: controller.batchTimes,
                      onRemove: controller.removeBatch,
                    ),

                    const SizedBox(height: 30),

                   
                    Row(
                      children: [
                        Expanded(
                          child: _buildMiniClearButton(
                            context: context,
                            label: "Clear Courses",
                            icon: Icons.layers_clear_rounded,
                            color: Colors.blueAccent,
                            onPressed: () => _showSectionClearConfirmation(
                              context, 
                              "Courses", 
                              controller.clearCourses
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildMiniClearButton(
                            context: context,
                            label: "Clear Batches",
                            icon: Icons.history_toggle_off_rounded,
                            color: Colors.green.shade600,
                            onPressed: () => _showSectionClearConfirmation(
                              context, 
                              "Batches", 
                              controller.clearBatches
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 40),

                    // Action Buttons
                    Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: _buildActionButton(
                            context: context,
                            label: "Save & Finish",
                            icon: Icons.check_circle_rounded,
                            isOutlined: false,
                            onPressed: () {
                              Get.back();
                              Get.snackbar(
                                "Success",
                                "All changes saved successfully!",
                                backgroundColor: Colors.green.shade600,
                                colorText: Colors.white,
                                snackPosition: SnackPosition.TOP,
                                margin: const EdgeInsets.all(15),
                                borderRadius: 15,
                                icon: const Icon(Icons.done_all_rounded, color: Colors.white),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),
                  ],
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildMiniClearButton({
    required BuildContext context,
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(15),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
        decoration: BoxDecoration(
          color: color.withOpacity(isDark ? 0.12 : 0.08),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 4),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: color,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureCard({
    required BuildContext context,
    required String title,
    required IconData icon,
    required Color color,
    required TextEditingController textController,
    required String hint,
    required VoidCallback onAdd,
    required RxList<String> items,
    required Function(int) onRemove,
    TextInputType keyboardType = TextInputType.text,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.2 : 0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(25),
        child: Column(
          children: [
            // Header for card
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              decoration: BoxDecoration(
                color: color.withOpacity(0.05),
                border: Border(bottom: BorderSide(color: isDark ? Colors.white10 : Colors.black.withOpacity(0.05))),
              ),
              child: Row(
                children: [
                  Icon(icon, color: color, size: 22),
                  const SizedBox(width: 12),
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Input Area
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: textController,
                          keyboardType: keyboardType,
                          style: TextStyle(color: theme.colorScheme.onSurface),
                          decoration: InputDecoration(
                            hintText: hint,
                            hintStyle: TextStyle(color: isDark ? Colors.white30 : Colors.grey.shade400, fontSize: 14),
                            fillColor: isDark ? Colors.white.withOpacity(0.05) : Colors.grey.shade50,
                            filled: true,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                              borderSide: BorderSide(color: isDark ? Colors.white12 : Colors.grey.shade200),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                              borderSide: BorderSide(color: isDark ? Colors.white12 : Colors.grey.shade200),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                              borderSide: BorderSide(color: color, width: 1.5),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Material(
                        color: color,
                        borderRadius: BorderRadius.circular(15),
                        child: InkWell(
                          onTap: onAdd,
                          borderRadius: BorderRadius.circular(15),
                          child: Container(
                            height: 50,
                            width: 50,
                            alignment: Alignment.center,
                            child: const Icon(Icons.add_rounded, color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),

                  if (items.isNotEmpty) ...[
                    const SizedBox(height: 20),
                    // Chips Area
                    Wrap(
                      spacing: 8,
                      runSpacing: 10,
                      children: List.generate(items.length, (index) {
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: color.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: color.withOpacity(0.2)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                items[index],
                                style: TextStyle(
                                  color: color,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                ),
                              ),
                              const SizedBox(width: 6),
                              GestureDetector(
                                onTap: () => onRemove(index),
                                child: Icon(Icons.cancel_rounded, size: 18, color: color.withOpacity(0.6)),
                              ),
                            ],
                          ),
                        );
                      }),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required BuildContext context,
    required String label,
    required IconData icon,
    required bool isOutlined,
    required VoidCallback onPressed,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      height: 58,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        boxShadow: isOutlined
            ? null
            : [
                BoxShadow(
                  color: theme.primaryColor.withOpacity(isDark ? 0.2 : 0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
              ],
      ),
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 20),
        label: Text(
          label,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: isOutlined 
              ? theme.cardColor 
              : theme.primaryColor,
          foregroundColor: isOutlined ? Colors.red : Colors.white,
          elevation: 0,
          side: isOutlined ? BorderSide(color: Colors.red.withOpacity(0.5), width: 1.5) : null,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        ),
      ),
    );
  }

  void _showSectionClearConfirmation(BuildContext context, String section, VoidCallback onConfirm) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: theme.cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
        title: Text("Clear All $section?", style: TextStyle(color: theme.colorScheme.onSurface)),
        content: Text("Are you sure you want to delete all entries in $section?", style: TextStyle(color: isDark ? Colors.white70 : Colors.black54)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel", style: TextStyle(color: isDark ? Colors.white38 : Colors.grey.shade600)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              onConfirm();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text("Delete"),
          ),
        ],
      ),
    );
  }
}
