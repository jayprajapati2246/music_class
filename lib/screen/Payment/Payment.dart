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
  Map<String, String> _studentNames = {};

  @override
  void initState() {
    super.initState();
    _loadStudentNames();
  }

  Future<void> _loadStudentNames() async {
    try {
      final snapshot = await FirebaseFirestore.instance.collection('students').get();
      final Map<String, String> names = {};
      for (var doc in snapshot.docs) {
        final data = doc.data();
        final profile = data['profile'] as Map<String, dynamic>? ?? {};
        names[doc.id] = profile['name'] ?? 'Unknown';
      }
      if (mounted) {
        setState(() {
          _studentNames = names;
        });
      }
    } catch (e) {
      print("Error loading student names: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: StreamBuilder<List<PaymentModel>>(
          stream: _paymentController.getAllPayments(),
          builder: (context, snapshot) {
            double todayTotal = 0;
            if (snapshot.hasData) {
              DateTime now = DateTime.now();
              todayTotal = snapshot.data!
                  .where(
                    (p) =>
                        p.date.day == now.day &&
                        p.date.month == now.month &&
                        p.date.year == now.year,
                  )
                  .fold(0.0, (sum, p) => sum + p.amount);
            }
            return Column(
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
            );
          },
        ),
      ),
      body: StreamBuilder<List<PaymentModel>>(
        stream: _paymentController.getAllPayments(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No payments recorded yet."));
          }

          final payments = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: payments.length,
            itemBuilder: (context, index) {
              final payment = payments[index];
              final studentName = _studentNames[payment.studentId] ?? "Loading...";
              
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
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Get.to(() => const AddPaymentPage());
          _loadStudentNames(); // Refresh names if a new student might have been added
        },
        backgroundColor: Colors.deepPurple,
        shape: const CircleBorder(),
        child: const Icon(Icons.add, color: Colors.white, size: 28),
      ),
    );
  }
}
