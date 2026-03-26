import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:music_class/Logic/model/Student.dart';

import '../../Logic/controller/user/AddStudent.dart';

class Addnstudent extends StatefulWidget {
  final StudentModel? student;
  final String? userId; 

  const Addnstudent({super.key, this.student, this.userId});

  @override
  State<Addnstudent> createState() => _AddnstudentState();
}

class _AddnstudentState extends State<Addnstudent> {
  late final Addstudentcontroller controller;

  @override
  void initState() {
    super.initState();
    controller = Get.put(Addstudentcontroller());
    controller.targetUserId = widget.userId;
    
    if (widget.student != null) {
      controller.nameController.text = widget.student!.name;
      controller.phoneController.text = widget.student!.phone;
      controller.selectedCourse = widget.student!.course;
      controller.selectedBatchTime = widget.student!.batchTime;
      controller.selectedBatchType = widget.student!.batchType;
      controller.selectedPaymentType = widget.student!.paymentType;
      controller.joinDate = widget.student!.joinDate;
      controller.joinDateController.text =
          DateFormat('dd/MM/yyyy').format(widget.student!.joinDate);
      controller.amountController.text = widget.student!.monthlyFee.toString();
      controller.sourceController.text = widget.student!.source;
      controller.selectedStatus = widget.student!.status;
    }
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        centerTitle: false,
        backgroundColor: theme.appBarTheme.backgroundColor,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: Icon(Icons.arrow_back_ios, color: theme.iconTheme.color),
        ),
        title: Column(
          children: [
            Text(
              widget.student == null ? "Add New Service" : "Edit Service",
              style: theme.appBarTheme.titleTextStyle?.copyWith(
                color: theme.colorScheme.onSurface
              ),
            ),
            const SizedBox(height: 2),
            Text(
              "Enter service details",
              style: TextStyle(
                fontSize: 12, 
                color: isDark ? Colors.white60 : Colors.black54
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 17),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            _label(context, "Student Name"),
            commonTextField(
              context: context,
              hintText: "Enter student name",
              controller: controller.nameController,
            ),
            SizedBox(height: height * 0.02),
            _label(context, "Phone Number"),
            commonTextField(
              context: context,
              hintText: "Enter phone number",
              controller: controller.phoneController,
              keyboardType: TextInputType.phone,
            ),
            SizedBox(height: height * 0.02),
            _label(context, "Course"),
            Obx(() => commonDropdown<String>(
              context: context,
              hintText: "Select course",
              items: controller.courses,
              value: controller.selectedCourse,
              itemLabel: (e) => e,
              onChanged: (value) {
                setState(() => controller.selectedCourse = value);
              },
            )),
            SizedBox(height: height * 0.02),
            _label(context, "Batch Time"),
            Obx(() => commonDropdown<String>(
              context: context,
              hintText: "Select batch time",
              items: controller.batchTime,
              value: controller.selectedBatchTime,
              itemLabel: (e) => e,
              onChanged: (value) {
                setState(() => controller.selectedBatchTime = value);
              },
            )),
            SizedBox(height: height * 0.02),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _label(context, "Batch Type"),
                      commonDropdown<String>(
                        context: context,
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
                      _label(context, "Status"),
                      commonDropdown<String>(
                        context: context,
                        hintText: "Active",
                        items: controller.statuses,
                        value: controller.selectedStatus,
                        itemLabel: (e) => e,
                        onChanged: (value) {
                          setState(() => controller.selectedStatus = value ?? 'Active');
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: height * 0.02),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _label(context, "Payment Type"),
                      commonDropdown<String>(
                        context: context,
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
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _label(context, "Monthly Fee"),
                      commonTextField(
                        context: context,
                        hintText: "Enter amount",
                        controller: controller.amountController,
                        keyboardType: TextInputType.number,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: height * 0.02),
            commonDateField(
              context: context,
              label: "Join Date",
              dateController: controller.joinDateController,
              onDateSelected: (date) {
                setState(() => controller.joinDate = date);
              },
            ),
            SizedBox(height: height * 0.02),
            _label(context, "Source"),
            commonTextField(
              context: context,
              hintText: "e.g. Google, Friend, Instagram",
              controller: controller.sourceController,
            ),
            SizedBox(height: height * 0.04),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.primaryColor,
                minimumSize: const Size(double.infinity, 55),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                elevation: 4,
              ),
              onPressed: () {
                if (widget.student == null) {
                  controller.addStudent();
                } else {
                  controller.updateStudent(widget.student!.id!);
                }
              },
              child: Text(
                widget.student == null ? "Add Service" : "Update Service",
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
            SizedBox(height: height * 0.05),
          ],
        ),
      ),
    );
  }

  Widget _label(BuildContext context, String text) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 6, left: 4),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: theme.colorScheme.onSurface.withOpacity(0.8),
        ),
      ),
    );
  }

  Widget commonTextField({
    required BuildContext context,
    required String hintText,
    TextEditingController? controller,
    TextInputType keyboardType = TextInputType.text,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      style: TextStyle(color: theme.colorScheme.onSurface),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(color: isDark ? Colors.white30 : Colors.grey),
        filled: true,
        fillColor: theme.cardColor,
        contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: isDark ? Colors.white12 : Colors.black12),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: theme.primaryColor, width: 2),
        ),
      ),
    );
  }

  Widget commonDropdown<T>({
    required BuildContext context,
    required String hintText,
    required List<T> items,
    required T? value,
    required String Function(T) itemLabel,
    required ValueChanged<T?> onChanged,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final safeValue = items.contains(value) ? value : null;

    return DropdownButtonFormField<T>(
      isExpanded: true,
      value: safeValue,
      onChanged: onChanged,
      dropdownColor: theme.cardColor,
      style: TextStyle(color: theme.colorScheme.onSurface),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(color: isDark ? Colors.white30 : Colors.grey),
        filled: true,
        fillColor: theme.cardColor,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: isDark ? Colors.white12 : Colors.black12),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: theme.primaryColor, width: 2),
        ),
      ),
      items: items
          .map(
            (item) => DropdownMenuItem<T>(
          value: item,
          child: Text(itemLabel(item), style: TextStyle(color: theme.colorScheme.onSurface)),
        ),
      )
          .toList(),
    );
  }

  Widget commonDateField({
    required BuildContext context,
    required String label,
    required TextEditingController dateController,
    required Function(DateTime) onDateSelected,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label(context, label),
        const SizedBox(height: 2),
        GestureDetector(
          onTap: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: controller.joinDate ?? DateTime.now(),
              firstDate: DateTime(2000),
              lastDate: DateTime(2100),
              builder: (context, child) {
                return Theme(
                  data: isDark ? ThemeData.dark().copyWith(
                    colorScheme: ColorScheme.dark(
                      primary: theme.primaryColor,
                      onPrimary: Colors.white,
                      surface: theme.cardColor,
                      onSurface: Colors.white,
                    ),
                    dialogBackgroundColor: theme.cardColor,
                  ) : theme,
                  child: child!,
                );
              },
            );

            if (picked != null) {
              dateController.text =
                  "${picked.day.toString().padLeft(2, '0')}/"
                  "${picked.month.toString().padLeft(2, '0')}/"
                  "${picked.year}";
              onDateSelected(picked);
            }
          },
          child: AbsorbPointer(
            child: TextField(
              controller: dateController,
              readOnly: true,
              style: TextStyle(color: theme.colorScheme.onSurface),
              decoration: InputDecoration(
                hintText: "Select date",
                hintStyle: TextStyle(color: isDark ? Colors.white30 : Colors.grey),
                filled: true,
                fillColor: theme.cardColor,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
                suffixIcon: Padding(
                  padding: const EdgeInsets.only(right: 14),
                  child: Icon(
                    Icons.calendar_today_outlined,
                    size: 20,
                    color: isDark ? Colors.white38 : Colors.grey,
                  ),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                  borderSide: BorderSide(color: isDark ? Colors.white12 : Colors.black12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                  borderSide: BorderSide(color: theme.primaryColor, width: 2),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
