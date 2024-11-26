import 'package:flutter/material.dart';
class CircleButton extends StatelessWidget {
  final IconData icon;
  final String label;
  const CircleButton({super.key, required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    final w= MediaQuery.of(context).size.width;
    final h=MediaQuery.of(context).size.height;
    return Column(
      children: [
        CircleAvatar(
          radius: w*.06,
          backgroundColor: Colors.orange,
            child: Center(
              child: Icon(icon, color: Colors.white,),
            ),
        ),
        SizedBox(height: h*.005,),
    Text(
    label,
    // style: const TextStyle(
    // fontSize: 12, // Adjust font size as needed
    // color: Colors.black, // Set text color
    // ),
    ),

      ],
    );
  }
}

