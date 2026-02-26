import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';

import 'add_payment.dart';

class Payment extends StatefulWidget {
  const Payment({super.key});

  @override
  State<Payment> createState() => _PaymentState();
}

class _PaymentState extends State<Payment> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          title: const Column(
            children: [
              Text("Payments",style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold,fontSize: 18),),
              SizedBox(height: 2,),
              Text("₹0 collected today",style: TextStyle(color: Colors.grey,fontSize: 15)),
              SizedBox(height: 2),
            ],
          )
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: ()  {
          Get.to(() => const AddPaymentPage());
        },
        backgroundColor: Colors.deepPurple,
        shape: const CircleBorder(),
        child: const Icon(Icons.add, color: Colors.white, size: 28),
      ),
    );
  }

}
