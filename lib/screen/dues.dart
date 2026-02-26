import 'package:flutter/material.dart';

class Dues extends StatefulWidget {
  const Dues({super.key});

  @override
  State<Dues> createState() => _DuesState();
}

class _DuesState extends State<Dues> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          title: const Column(
            children: [
              Text("Due Payments",style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold,fontSize: 18),),
              SizedBox(height: 2,),
              Text("₹780,333 total pending",style: TextStyle(color: Colors.grey,fontSize: 15)),
            ],
          )
      ),
    );
  }
}
