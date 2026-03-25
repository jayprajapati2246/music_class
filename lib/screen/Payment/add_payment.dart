import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../Logic/controller/user/Payments.dart';
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
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
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
      final userId = _auth.currentUser?.uid;
      if (userId == null) return;

      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('students')
          .get();
          
      setState(() {
        _students = snapshot.docs
            .map((doc) => StudentModel.fromMap(doc.data(), doc.id))
            .toList();
        _isLoadingStudents = false;
      });
    } catch (e) {
      debugPrint("Error loading students: $e");
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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.appBarTheme.backgroundColor,
        elevation: 0,
        centerTitle: false,
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: Icon(Icons.arrow_back_ios, color: theme.iconTheme.color),
        ),
        title: Text(
          "Add Payment",
          style: theme.appBarTheme.titleTextStyle?.copyWith(
            color: theme.colorScheme.onSurface,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: _isLoadingStudents 
          ? Center(child: CircularProgressIndicator(color: theme.primaryColor))
          : SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// SELECT STUDENT
              _label(context, "Select Student"),
              const SizedBox(height: 8),

              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: theme.primaryColor.withOpacity(0.3)),
                  color: theme.cardColor,
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<StudentModel>(
                    value: selectedStudent,
                    isExpanded: true,
                    hint: Text("Choose a student", style: TextStyle(color: isDark ? Colors.white38 : Colors.grey)),
                    icon: Icon(Icons.keyboard_arrow_down, color: theme.primaryColor),
                    dropdownColor: theme.cardColor,
                    items: _students.map((student) {
                      return DropdownMenuItem(
                        value: student,
                        child: Text(student.name, style: TextStyle(color: theme.colorScheme.onSurface)),
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
              _label(context, "For Month"),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: theme.primaryColor.withOpacity(0.3)),
                  color: theme.cardColor,
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: selectedMonth,
                    isExpanded: true,
                    dropdownColor: theme.cardColor,
                    icon: Icon(Icons.calendar_month, color: theme.primaryColor),
                    items: _getMonthsList().map((month) {
                      return DropdownMenuItem(
                        value: month, 
                        child: Text(month, style: TextStyle(color: theme.colorScheme.onSurface))
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => selectedMonth = val);
                    },
                  ),
                ),
              ),

              const SizedBox(height: 20),

              /// AMOUNT
              _label(context, "Amount"),
              const SizedBox(height: 8),

              TextField(
                controller: amountController,
                keyboardType: TextInputType.number,
                style: TextStyle(color: theme.colorScheme.onSurface),
                decoration: InputDecoration(
                  hintText: "Enter amount",
                  hintStyle: TextStyle(color: isDark ? Colors.white30 : Colors.grey),
                  filled: true,
                  fillColor: theme.cardColor,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(color: theme.primaryColor.withOpacity(0.3)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(color: theme.primaryColor.withOpacity(0.3)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(color: theme.primaryColor, width: 2),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              /// NOTE
              _label(context, "Note (optional)"),
              const SizedBox(height: 8),

              TextField(
                controller: noteController,
                style: TextStyle(color: theme.colorScheme.onSurface),
                decoration: InputDecoration(
                  hintText: "e.g., Monthly fee for January",
                  hintStyle: TextStyle(color: isDark ? Colors.white30 : Colors.grey),
                  filled: true,
                  fillColor: theme.cardColor,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(color: theme.primaryColor.withOpacity(0.3)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(color: theme.primaryColor.withOpacity(0.3)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(color: theme.primaryColor, width: 2),
                  ),
                ),
              ),

              const SizedBox(height: 40),

              /// BUTTON
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: () async {
                    if (selectedStudent == null) {
                      Get.snackbar("Error", "Please select a student", backgroundColor: Colors.red, colorText: Colors.white);
                      return;
                    }
                    final double amount = double.tryParse(amountController.text) ?? 0;
                    if (amount <= 0) {
                      Get.snackbar("Error", "Please enter a valid amount", backgroundColor: Colors.red, colorText: Colors.white);
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
                      Get.back(result: true);
                      Get.snackbar("Success", "Payment recorded successfully", backgroundColor: Colors.green, colorText: Colors.white);
                    } catch (e) {
                      Get.snackbar("Error", "Failed to record payment", backgroundColor: Colors.red, colorText: Colors.white);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    padding: EdgeInsets.zero,
                    elevation: 4,
                    backgroundColor: Colors.transparent,
                    shadowColor: theme.primaryColor.withOpacity(0.3),
                  ),
                  child: Ink(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [theme.primaryColor, theme.primaryColor.withOpacity(0.8)],
                      ),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Center(
                      child: Text(
                        "Record Payment",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
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

  Widget _label(BuildContext context, String text) {
    return Text(
      text,
      style: TextStyle(
        fontWeight: FontWeight.w600,
        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8),
      ),
    );
  }
}
