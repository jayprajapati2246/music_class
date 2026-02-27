import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../Logic/controller/Payments.dart';
import '../../Logic/model/Student.dart';
import '../../Logic/model/payment.dart';

class AddPaymentPage extends StatefulWidget {
  const AddPaymentPage({super.key});

  @override
  State<AddPaymentPage> createState() => _AddPaymentPageState();
}

class _AddPaymentPageState extends State<AddPaymentPage> {
  StudentModel? selectedStudent;
  final TextEditingController amountController = TextEditingController();
  final TextEditingController noteController = TextEditingController();
  final PaymentController _paymentController = PaymentController();
  
  List<StudentModel> _students = [];
  bool _isLoadingStudents = true;
  String selectedMonth = DateFormat('MMMM yyyy').format(DateTime.now());

  @override
  void initState() {
    super.initState();
    _loadStudents();
  }

  Future<void> _loadStudents() async {
    try {
      final snapshot = await FirebaseFirestore.instance.collection('students').get();
      setState(() {
        _students = snapshot.docs
            .map((doc) => StudentModel.fromMap(doc.data(), doc.id))
            .toList();
        _isLoadingStudents = false;
      });
    } catch (e) {
      print("Error loading students: $e");
      setState(() {
        _isLoadingStudents = false;
      });
    }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff5f5f7),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          "Add Payments",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      body: _isLoadingStudents 
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// SELECT STUDENT
              const Text(
                "Select Student",
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),

              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.deepPurple.withOpacity(0.5)),
                  color: Colors.white,
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<StudentModel>(
                    value: selectedStudent,
                    isExpanded: true,
                    hint: const Text("Choose a student"),
                    icon: const Icon(Icons.keyboard_arrow_down),
                    items: _students.map((student) {
                      return DropdownMenuItem(
                        value: student,
                        child: Text(student.name),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedStudent = value;
                        if (value != null) {
                          amountController.text = value.monthlyFee.toString();
                        }
                      });
                    },
                  ),
                ),
              ),

              const SizedBox(height: 20),

              /// FOR MONTH
              const Text(
                "For Month",
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.deepPurple.withOpacity(0.5)),
                  color: Colors.white,
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: selectedMonth,
                    isExpanded: true,
                    items: _getMonthsList().map((month) {
                      return DropdownMenuItem(value: month, child: Text(month));
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => selectedMonth = val);
                    },
                  ),
                ),
              ),

              const SizedBox(height: 20),

              /// AMOUNT
              const Text(
                "Amount",
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),

              TextField(
                controller: amountController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: "Enter amount",
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(color: Colors.deepPurple.withOpacity(0.5)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(color: Colors.deepPurple.withOpacity(0.5)),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              /// NOTE
              const Text(
                "Note (optional)",
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),

              TextField(
                controller: noteController,
                decoration: InputDecoration(
                  hintText: "e.g., Monthly fee for January",
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(color: Colors.deepPurple.withOpacity(0.5)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(color: Colors.deepPurple.withOpacity(0.5)),
                  ),
                ),
              ),

              const SizedBox(height: 40),

              /// BUTTON
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () async {
                    if (selectedStudent == null) {
                      Get.snackbar("Error", "Please select a student");
                      return;
                    }
                    final double amount = double.tryParse(amountController.text) ?? 0;
                    if (amount <= 0) {
                      Get.snackbar("Error", "Please enter a valid amount");
                      return;
                    }

                    final payment = PaymentModel(
                      studentId: selectedStudent!.id!,
                      amount: amount,
                      date: DateTime.now(),
                      month: selectedMonth,
                      note: noteController.text,
                    );

                    try {
                      await _paymentController.addPayment(payment);
                      Get.back();
                      Get.snackbar("Success", "Payment recorded successfully");
                    } catch (e) {
                      Get.snackbar("Error", "Failed to record payment");
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    padding: EdgeInsets.zero,
                    elevation: 0,
                    backgroundColor: Colors.transparent,
                  ),
                  child: Ink(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xff6A5AE0), Color(0xff8E54E9)],
                      ),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Center(
                      child: Text(
                        "Record Payment",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
