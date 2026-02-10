import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../Logic/controller/AddStudent.dart';

class Addnstudent extends StatefulWidget {
  const Addnstudent({super.key});

  @override
  State<Addnstudent> createState() => _AddnstudentState();
}

class _AddnstudentState extends State<Addnstudent> {
  final Addstudentcontroller controller =
  Get.put(Addstudentcontroller());

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.white70,
        elevation: 0,
        title: Column(
          children: const [
            Text(
              "Add New Student",
              style: TextStyle(
                fontSize: 18,
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 2),
            Text(
              "Enter student details",
              style: TextStyle(fontSize: 12, color: Colors.black),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 17),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _label("Student Name"),
            commonTextField(
              hintText: "Enter student name",
              controller: controller.nameController,
            ),

            SizedBox(height: height * 0.02),

            _label("Phone Number"),
            commonTextField(
              hintText: "Enter phone number",
              controller: controller.phoneController,
              keyboardType: TextInputType.phone,
            ),

            SizedBox(height: height * 0.02),

            _label("Course"),
            commonDropdown<String>(
              hintText: "Select course",
              items: controller.courses,
              value: controller.selectedCourse,
              itemLabel: (e) => e,
              onChanged: (value) {
                setState(() => controller.selectedCourse = value);
              },
            ),

            SizedBox(height: height * 0.02),

            _label("Batch Time"),
            commonDropdown<String>(
              hintText: "Select batch time",
              items: controller.batchTime,
              value: controller.selectedBatchTime,
              itemLabel: (e) => e,
              onChanged: (value) {
                setState(() => controller.selectedBatchTime = value);
              },
            ),

            SizedBox(height: height * 0.02),

            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _label("Batch Type"),
                      commonDropdown<String>(
                        hintText: "Everyday",
                        items: controller.batchTypes,
                        value: controller.selectedBatchType,
                        itemLabel: (e) => e,
                        onChanged: (value) {
                          setState(() => controller.selectedBatchType = value);
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _label("Payment Type"),
                      commonDropdown<String>(
                        hintText: "Per Class",
                        items: controller.paymentTypes,
                        value: controller.selectedPaymentType,
                        itemLabel: (e) => e,
                        onChanged: (value) {
                          setState(() => controller.selectedPaymentType = value);
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),

            SizedBox(height: height * 0.02),

            _label("Monthly Fee"),
            commonTextField(
              hintText: "Enter amount",
              controller: controller.amountController,
              keyboardType: TextInputType.number,
            ),

            SizedBox(height: height * 0.02),

            commonDateField(
              label: "Join Date",
              controller: controller.joinDateController,
              onDateSelected: (date) {
                setState(() => controller.joinDate = date);
              },
            ),

            SizedBox(height: height * 0.03),

            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                minimumSize: const Size(double.infinity, 48),
              ),
              onPressed: controller.addStudent,
              child: const Text(
                "Add Student",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),

            SizedBox(height: height * 0.03),
          ],
        ),
      ),
    );
  }

  Widget _label(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 5),
    child: Text(
      text,
      style: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w500,
      ),
    ),
  );

  Widget commonTextField({
    required String hintText,
    TextEditingController? controller,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        hintText: hintText,
        contentPadding:
        const EdgeInsets.symmetric(vertical: 14, horizontal: 14),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(color: Colors.black),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide:
          const BorderSide(color: Colors.deepPurple, width: 2.5),
        ),
      ),
    );
  }

  Widget commonDropdown<T>({
    required String hintText,
    required List<T> items,
    required T? value,
    required String Function(T) itemLabel,
    required ValueChanged<T?> onChanged,
  }) {
    return DropdownButtonFormField<T>(
      isExpanded: true,
      value: value,
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: hintText,
        contentPadding:
        const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(color: Colors.black),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide:
          const BorderSide(color: Colors.deepPurple, width: 2.5),
        ),
      ),
      items: items
          .map(
            (item) => DropdownMenuItem<T>(
          value: item,
          child: Text(itemLabel(item)),
        ),
      )
          .toList(),
    );
  }
  Widget commonDateField({
    required String label,
    required TextEditingController controller,
    required Function(DateTime) onDateSelected,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label(label),
        const SizedBox(height: 6),
        GestureDetector(
          onTap: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: DateTime.now(),
              firstDate: DateTime(2000),
              lastDate: DateTime(2100),
            );

            if (picked != null) {
              controller.text =
              "${picked.day.toString().padLeft(2, '0')}/"
                  "${picked.month.toString().padLeft(2, '0')}/"
                  "${picked.year}";
              onDateSelected(picked);
            }
          },
          child: AbsorbPointer(
            child: TextField(
              controller: controller,
              readOnly: true,
              decoration: InputDecoration(
                hintText: "Select date",
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                suffixIcon: Padding(
                  padding: const EdgeInsets.only(right: 14),
                  child: const Icon(
                    Icons.calendar_today_outlined,
                    size: 20,
                    color: Colors.grey,
                  ),
                ),
                suffixIconConstraints: const BoxConstraints(
                  minWidth: 48,
                  minHeight: 48,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: const BorderSide(color: Colors.black12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: const BorderSide(
                    color: Colors.deepPurple,
                    width: 2,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

}
