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
  double _todayTotal = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: StreamBuilder<List<PaymentModel>>(
          stream: _paymentController.getAllPayments(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              DateTime now = DateTime.now();
              _todayTotal = snapshot.data!
                  .where(
                    (p) =>
                        p.date.day == now.day &&
                        p.date.month == now.month &&
                        p.date.year == now.year,
                  )
                  .fold(0, (sum, p) => sum + p.amount);
            }
            return Column(
              children: [
                const Text(
                  "Payments",
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  "₹${_todayTotal.toStringAsFixed(2)} collected today",
                  style: const TextStyle(color: Colors.grey, fontSize: 15),
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
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Colors.greenAccent,
                    child: Icon(Icons.currency_rupee, color: Colors.green),
                  ),
                  title: FutureBuilder<String>(
                    future: _getStudentName(payment.studentId),
                    builder: (context, nameSnapshot) {
                      return Text(
                        nameSnapshot.data ?? "Loading...",
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      );
                    },
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
        onPressed: () {
          Get.to(() => const AddPaymentPage())?.then((_) => setState(() {}));
        },
        backgroundColor: Colors.deepPurple,
        shape: const CircleBorder(),
        child: const Icon(Icons.add, color: Colors.white, size: 28),
      ),
    );
  }

  Future<String> _getStudentName(String studentId) async {
    final doc = await FirebaseFirestore.instance
        .collection('students')
        .doc(studentId)
        .get();
    return doc.data()?['name'] ?? "Unknown";
  }
}
