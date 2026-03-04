import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../Logic/controller/Payments.dart';
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
        final profile = data['profile'] as Map<String, dynamic>? ?? {};
        names[studentDoc.id] = profile['name'] ?? 'Unknown';

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
      print("Error loading data: $e");
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
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
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Payments",
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            Text(
              "₹${todayTotal.toStringAsFixed(2)} collected today",
              style: const TextStyle(color: Colors.grey, fontSize: 13),
            ),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _allPayments.isEmpty
              ? const Center(child: Text("No payments recorded yet."))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _allPayments.length,
                  itemBuilder: (context, index) {
                    final payment = _allPayments[index];
                    final studentName = _studentNames[payment.studentId] ?? "Unknown";
                    
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        leading: const CircleAvatar(
                          backgroundColor: Color(0xFFE8EAF6),
                          child: Icon(Icons.person, color: Color(0xff6A5AE0)),
                        ),
                        title: Text(
                          studentName,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          "${payment.month} • ${DateFormat('dd MMM yyyy').format(payment.date)}",
                        ),
                        trailing: Text(
                          "₹${payment.amount.toStringAsFixed(2)}",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Get.to(() => const AddPaymentPage());
          if (result == true) {
            _loadData();
          }
        },
        backgroundColor: Colors.deepPurple,
        shape: const CircleBorder(),
        child: const Icon(Icons.add, color: Colors.white, size: 28),
      ),
    );
  }
}
