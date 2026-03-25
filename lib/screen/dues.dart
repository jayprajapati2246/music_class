import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:music_class/Logic/ads/banner_ads.dart';
import 'package:music_class/screen/student/edit.dart';

import '../Logic/controller/user/Payments.dart';
import '../Logic/controller/user/due.dart';
import '../Logic/model/Student.dart';

class Dues extends StatefulWidget {
  const Dues({super.key});

  @override
  State<Dues> createState() => _DuesState();
}

class _DuesState extends State<Dues> {
  final DueController _dueController = DueController();
  final PaymentController _paymentController = PaymentController();

  List<Map<String, dynamic>> _dues = [];
  bool _isLoading = true;
  double _totalDues = 0;

  final BannerAds bannerAds = Get.put(BannerAds());

  @override
  void initState() {
    super.initState();
    _fetchDues();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      bannerAds.loadAd(MediaQuery.of(context).size.width);
    });
  }

  Future<void> _fetchDues() async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    final duesList = await _dueController.calculateDues();
    double total = 0;
    for (var item in duesList) {
      total += item['dueAmount'];
    }

    if (mounted) {
      setState(() {
        _dues = duesList;
        _totalDues = total;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.appBarTheme.backgroundColor,
        elevation: 0,
        centerTitle: false,
        title: Column(
          children: [
            Text(
              "Due Payments",
              style: theme.appBarTheme.titleTextStyle,
            ),
            const SizedBox(height: 2),
            Text(
              "₹${_totalDues.toStringAsFixed(0)} total pending",
              style: TextStyle(
                color: isDark ? Colors.white60 : Colors.grey.shade400,
                fontSize: 13
              ),
            ),
          ],
        ),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: theme.primaryColor))
          : RefreshIndicator(
              onRefresh: _fetchDues,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // Summary Banner
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: isDark ? Colors.red.withOpacity(0.1) : const Color(0xffffebee),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: Colors.red.withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          height: 50,
                          width: 50,
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.warning_amber_rounded,
                            color: Colors.red,
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "₹${_totalDues.toStringAsFixed(0)}",
                                style: const TextStyle(
                                  color: Colors.red,
                                  fontSize: 26,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              Text(
                                "Pending from ${_dues.length} students",
                                style: TextStyle(
                                  color: isDark ? Colors.white70 : Colors.black87,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  ..._dues.map((item) {
                    final StudentModel student = item['student'];
                    final double dueAmount = item['dueAmount'];

                    return Container(
                      margin: const EdgeInsets.only(bottom: 14),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: theme.cardColor,
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(isDark ? 0.2 : 0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 25,
                            backgroundColor: Colors.red.withOpacity(0.1),
                            child: const Icon(Icons.person, color: Colors.red),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  student.name,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 17,
                                    color: theme.colorScheme.onSurface,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Icon(Icons.music_note, size: 14, color: isDark ? Colors.white38 : Colors.grey),
                                    const SizedBox(width: 4),
                                    Text(
                                      student.course,
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: isDark ? Colors.white60 : Colors.grey.shade600,
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    Icon(Icons.access_time, size: 14, color: isDark ? Colors.white38 : Colors.grey),
                                    const SizedBox(width: 4),
                                    Text(
                                      student.batchTime,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: isDark ? Colors.white60 : Colors.grey.shade600,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Colors.red.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  "₹${dueAmount.toStringAsFixed(0)}",
                                  style: const TextStyle(
                                    color: Colors.red,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 4),
                              IconButton(
                                onPressed: () => Get.to(() => EditDetail(student: student)),
                                icon: Icon(
                                  Icons.chevron_right_rounded,
                                  color: isDark ? Colors.white38 : Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ],
              ),
            ),
      bottomNavigationBar: GetBuilder<BannerAds>(
        builder: (controller) {
          if (controller.bannerAd == null || !controller.isLoaded) {
            return const SizedBox();
          }

          return Container(
            color: theme.cardColor,
            width: controller.bannerAd!.size.width.toDouble(),
            height: controller.bannerAd!.size.height.toDouble(),
            child: AdWidget(ad: controller.bannerAd!),
          );
        },
      ),
    );
  }
}
