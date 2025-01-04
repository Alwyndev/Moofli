import 'package:flutter/material.dart';

class GradientButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;

  const GradientButton(
      {super.key, required this.text, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(4.0),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.red,
              Colors.orange,
              Colors.green,
              Colors.lightGreen,
              Colors.cyan,
            ],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(20.0),
          border: Border.all(
            color: Colors.white,
            width: 1.5,
          ),
        ),
        child: Center(
          child: Container(
            alignment: Alignment.center, // Center the white box
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white, // White background inside the button
              borderRadius: BorderRadius.circular(16.0),
            ),
            child: Text(
              text,
              style: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
                foreground: Paint()
                  ..shader = LinearGradient(
                    colors: [
                      Colors.orange,
                      Colors.green,
                      Colors.lightBlue,
                    ],
                  ).createShader(Rect.fromLTWH(0.0, 0.0, 200.0, 40.0)),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
