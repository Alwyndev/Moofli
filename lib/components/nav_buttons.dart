import 'package:flutter/material.dart';

class NavButtons extends StatelessWidget {
  final String prev;
  final VoidCallback next;

  const NavButtons({
    Key? key,
    required this.prev,
    required this.next,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Previous Button on the left
        ElevatedButton(
          onPressed: () => Navigator.pushNamed(context, prev),
          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            foregroundColor: Colors.black, // Icon color
            backgroundColor: Colors.white, // Button color
            side: const BorderSide(color: Colors.black),
          ),
          child: Row(
            children: [
              // Text("Previous", style: TextStyle(color: Colors.black)),
              const SizedBox(width: 1),
              const Icon(Icons.arrow_left, size: 45, color: Colors.black),
            ],
          ),
        ),
        // Next/Skip Button on the right
        ElevatedButton(
          onPressed: next,
          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            foregroundColor: Colors.black, // Text/Icon color
            backgroundColor: Colors.white, // Button color
            side: const BorderSide(color: Colors.black),
          ),
          child: Row(
            children: const [
              // Text("Next/Skip", style: TextStyle(color: Colors.black)),
              SizedBox(width: 1),
              Icon(Icons.arrow_right, size: 45, color: Colors.black),
            ],
          ),
        ),
      ],
    );
  }
}
