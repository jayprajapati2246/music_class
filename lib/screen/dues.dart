import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../Logic/controller/due.dart';
import '../Logic/controller/Payments.dart';
import '../Logic/model/Student.dart';
import '../Logic/model/payment.dart';

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

  @override
  void initState() {
    super.initState();
    _fetchDues();
  }

  Future<void> _fetchDues() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
    });

    try {
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
    } catch (e) {
      print("Error fetching dues: $e");
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Column(
          children: [
            const Text(
              "Due Payments",
              style: TextStyle(
                  color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 2),
            Text(
              "₹${_totalDues.toStringAsFixed(2)} total pending",
              style: const TextStyle(color: Colors.grey, fontSize: 15),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.black),
            onPressed: _fetchDues,
          )
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _fetchDues,
              child: _dues.isEmpty
                  ? const Center(child: Text("No pending dues!"))
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _dues.length,
                      itemBuilder: (context, index) {
                        final item = _dues[index];
                        final StudentModel student = item['student'];
                        final double dueAmount = item['dueAmount'];
                        final int monthsPending = item['monthsPending'];

                        return Card(
                          elevation: 2,
                          margin: const EdgeInsets.only(bottom: 16),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          child: ListTile(
                            contentPadding: const EdgeInsets.all(16),
                            title: Text(
                              student.name,
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("${student.course} | ${student.batchTime}"),
                                const SizedBox(height: 4),
                                // Text(
                                //   "Pending for $monthsPending month(s)",
                                //   style: const TextStyle(color: Colors.red),
                                // ),
                              ],
                            ),
                            trailing: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  "₹${dueAmount.toStringAsFixed(2)}",
                                  style: const TextStyle(
                                      color: Colors.red,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16),
                                ),
                                const SizedBox(height: 4),
                                ElevatedButton(
                                  onPressed: () {
                                    _showPaymentDialog(context, student, dueAmount);
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blue,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 0),
                                  ),
                                  child: const Text("Pay Now"),
                                )
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
    );
  }

  void _showPaymentDialog(
      BuildContext context, StudentModel student, double recommendedAmount) {
    final TextEditingController amountController =
        TextEditingController(text: recommendedAmount.toString());
    final TextEditingController noteController = TextEditingController();
    String selectedMonth = DateFormat('MMMM yyyy').format(DateTime.now());

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Add Payment for ${student.name}"),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: amountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: "Amount (₹)"),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: noteController,
                decoration: const InputDecoration(labelText: "Note (Optional)"),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: selectedMonth,
                decoration: const InputDecoration(labelText: "For Month"),
                items: _getMonthsList().map((month) {
                  return DropdownMenuItem(value: month, child: Text(month));
                }).toList(),
                onChanged: (val) {
                  if (val != null) selectedMonth = val;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () async {
              final double amount = double.tryParse(amountController.text) ?? 0;
              if (amount <= 0) return;

              final payment = PaymentModel(
                studentId: student.id!,
                amount: amount,
                date: DateTime.now(),
                month: selectedMonth,
                note: noteController.text,
              );

              try {
                await _paymentController.addPayment(payment);
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Payment recorded successfully")),
                  );
                  _fetchDues();
                }
              } catch (e) {
                print("Error saving payment: $e");
              }
            },
            child: const Text("Submit"),
          ),
        ],
      ),
    );
  }

  List<String> _getMonthsList() {
    List<String> months = [];
    DateTime now = DateTime.now();
    for (int i = 0; i < 6; i++) {
      DateTime monthDate = DateTime(now.year, now.month - i, 1);
      months.add(DateFormat('MMMM yyyy').format(monthDate));
    }
    return months;
  }
}
