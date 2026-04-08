import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../Logic/controller/admin/admin_controller.dart';
import 'Userdetail.dart';
import 'user_services_page.dart';

class ManageUsersPage extends StatefulWidget {
  final String appBarTitle;
  final bool isServiceFlow;

  const ManageUsersPage({
    super.key,
    required this.appBarTitle,
    this.isServiceFlow = false,
  });

  @override
  State<ManageUsersPage> createState() => _ManageUsersPageState();
}

class _ManageUsersPageState extends State<ManageUsersPage> {
  final AdminController controller = Get.put(AdminController());
  final TextEditingController searchController = TextEditingController();
  final RxString searchQuery = "".obs;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryColor = widget.isServiceFlow ? Colors.blue : Colors.orange;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(widget.appBarTitle, style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: theme.appBarTheme.backgroundColor,
        foregroundColor: theme.appBarTheme.foregroundColor,
        elevation: 0,
        centerTitle: false,
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
        ),
      ),
      body: Column(
        children: [
          // Search Bar Section
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(isDark ? 0.2 : 0.05),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: TextField(
                controller: searchController,
                onChanged: (value) => searchQuery.value = value,
                style: TextStyle(color: theme.colorScheme.onSurface),
                decoration: InputDecoration(
                  hintText: "Search by name or email...",
                  hintStyle: TextStyle(color: isDark ? Colors.white30 : Colors.grey.shade400),
                  prefixIcon: Icon(Icons.search, color: primaryColor),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 15),
                ),
              ),
            ),
          ),

          Expanded(
            child: Obx(() {
              if (controller.isLoadingUsers.value) {
                return Center(
                  child: CircularProgressIndicator(color: primaryColor),
                );
              }

              final filteredUsers = controller.users.where((user) {
                final name = (user['name'] ?? '').toString().toLowerCase();
                final email = (user['email'] ?? '').toString().toLowerCase();
                final query = searchQuery.value.toLowerCase();
                return name.contains(query) || email.contains(query);
              }).toList();

              if (filteredUsers.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.person_off_rounded, size: 80, color: isDark ? Colors.white12 : Colors.grey.shade200),
                      const SizedBox(height: 16),
                      Text(
                        "No users found",
                        style: TextStyle(fontSize: 16, color: isDark ? Colors.white38 : Colors.grey),
                      ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                itemCount: filteredUsers.length,
                itemBuilder: (context, index) {
                  final user = filteredUsers[index];

                  return Container(
                    margin: const EdgeInsets.only(bottom: 15),
                    decoration: BoxDecoration(
                      color: theme.cardColor,
                      borderRadius: BorderRadius.circular(22),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(isDark ? 0.2 : 0.04),
                          blurRadius: 12,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(22),
                        onTap: () {
                          if (widget.isServiceFlow) {
                            Get.to(
                                  () => UserServicesPage(user: user),
                              transition: Transition.cupertino,
                            );
                          } else {
                            Get.to(
                                  () => UserDetailsPage(user: user),
                              transition: Transition.cupertino,
                            );
                          }
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(color: primaryColor.withOpacity(0.2), width: 2),
                                ),
                                child: CircleAvatar(
                                  radius: 28,
                                  backgroundColor: primaryColor.withOpacity(0.1),
                                  backgroundImage: user['profileImage'] != null &&
                                      user['profileImage'].isNotEmpty
                                      ? NetworkImage(user['profileImage'])
                                      : null,
                                  child: user['profileImage'] == null ||
                                      user['profileImage'].isEmpty
                                      ? Icon(Icons.person, color: primaryColor)
                                      : null,
                                ),
                              ),
                              const SizedBox(width: 15),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      user['name'] ?? 'Unknown',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                        color: theme.colorScheme.onSurface,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      user['email'] ?? '',
                                      style: TextStyle(
                                        color: isDark ? Colors.white60 : Colors.black54,
                                        fontSize: 13,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                              // Conditional Action Icon
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: primaryColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  widget.isServiceFlow ? Icons.layers_rounded : Icons.manage_accounts_rounded,
                                  size: 20,
                                  color: primaryColor,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Icon(
                                Icons.arrow_forward_ios_rounded,
                                size: 14,
                                color: isDark ? Colors.white24 : Colors.grey.shade400,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }
}