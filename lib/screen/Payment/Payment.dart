import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../Logic/controller/user/Payments.dart';
import '../../Logic/model/payment.dart';
import 'add_payment.dart';

class Payment extends StatefulWidget {
  const Payment({super.key});

  @override
  State<Payment> createState() => _PaymentState();
}

class _PaymentState extends State<Payment> {
  final PaymentController _paymentController = PaymentController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  Map<String, String> _studentNames = {};
  List<PaymentModel> _allPayments = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) return;

      final studentSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('students')
          .get();

      final Map<String, String> names = {};
      List<PaymentModel> allPayments = [];

      for (var studentDoc in studentSnapshot.docs) {
        final data = studentDoc.data();
        // Updated to handle both nested 'profile' and flat structure
        String name = 'Unknown';
        if (data.containsKey('profile')) {
          name = data['profile']['name'] ?? 'Unknown';
        } else {
          name = data['name'] ?? 'Unknown';
        }
        names[studentDoc.id] = name;

        // Fetch payments for each student
        final paymentSnapshot = await studentDoc.reference.collection('payments').get();
        for (var paymentDoc in paymentSnapshot.docs) {
          allPayments.add(PaymentModel.fromMap(paymentDoc.data(), paymentDoc.id));
        }
      }

      // Sort payments by date descending
      allPayments.sort((a, b) => b.date.compareTo(a.date));

      if (mounted) {
        setState(() {
          _studentNames = names;
          _allPayments = allPayments;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Error loading data: $e");
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    double todayTotal = 0;
    DateTime now = DateTime.now();
    todayTotal = _allPayments
        .where(
          (p) =>
              p.date.day == now.day &&
              p.date.month == now.month &&
              p.date.year == now.year,
        )
        .fold(0.0, (sum, p) => sum + p.amount);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.appBarTheme.backgroundColor,
        elevation: 0,
        centerTitle: false,
        title: Column(
          children: [
            Text(
              "Payments",
              style: theme.appBarTheme.titleTextStyle,
            ),
            Text(
              "₹${todayTotal.toStringAsFixed(0)} collected today",
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
          : _allPayments.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.payment_rounded, size: 64, color: isDark ? Colors.white24 : Colors.grey.shade300),
                      const SizedBox(height: 16),
                      Text(
                        "No payments recorded yet.",
                        style: TextStyle(color: isDark ? Colors.white38 : Colors.grey),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadData,
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    itemCount: _allPayments.length,
                    itemBuilder: (context, index) {
                      final payment = _allPayments[index];
                      final studentName = _studentNames[payment.studentId] ?? "Unknown";
                      
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        color: theme.cardColor,
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          leading: CircleAvatar(
                            radius: 22,
                            backgroundColor: theme.primaryColor.withOpacity(0.1),
                            child: Icon(Icons.person, color: theme.primaryColor),
                          ),
                          title: Text(
                            studentName,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                          subtitle: Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              "${payment.month} • ${DateFormat('dd MMM yyyy').format(payment.date)}",
                              style: TextStyle(color: isDark ? Colors.white60 : Colors.black54),
                            ),
                          ),
                          trailing: Text(
                            "₹${payment.amount.toStringAsFixed(0)}",
                            style: const TextStyle(
                              fontWeight: FontWeight.w900,
                              color: Colors.green,
                              fontSize: 18,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Get.to(() => const AddPaymentPage());
          if (result == true) {
            _loadData();
          }
        },
        backgroundColor: theme.primaryColor,
        foregroundColor: Colors.white,
        shape: const CircleBorder(),
        child: const Icon(Icons.add, size: 28),
      ),
    );
  }
}
