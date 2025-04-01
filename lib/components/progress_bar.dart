import 'package:flutter/material.dart';

class ProgressBar extends StatelessWidget {
  final double progress;

  const ProgressBar({super.key, required this.progress});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        const Text(
          'Complete your',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w500,
            color: Colors.black,
          ),
        ),
        const Text(
          'Profile',
          style: TextStyle(
            fontSize: 48,
            fontWeight: FontWeight.w900,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 20),
        Stack(
          children: [
            Container(
              width: double.infinity,
              height: 12,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            Container(
              width: MediaQuery.of(context).size.width * progress,
              height: 12,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Colors.red,
                    Colors.yellow,
                    Colors.green,
                    Colors.blue,
                  ],
                ),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Center(
          child: RichText(
            text: TextSpan(
              text: 'You are ',
              style: const TextStyle(
                fontSize: 20,
                color: Color.fromARGB(255, 109, 108, 108),
              ),
              children: [
                TextSpan(
                  text: '${(progress * 100).toInt()}%',
                  style: const TextStyle(
                    color: Color.fromARGB(255, 90, 90, 90),
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const TextSpan(
                  text: ' there',
                  style: TextStyle(
                    fontSize: 20,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
