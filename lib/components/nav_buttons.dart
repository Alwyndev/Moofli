import 'package:flutter/material.dart';

class NavButtons extends StatelessWidget {
  final String prev;
  final Future<void> Function() next;

  const NavButtons({
    required this.prev,
    required this.next,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 5.0),
        child: Row(
          mainAxisAlignment:
              MainAxisAlignment.spaceBetween, // Spreads the buttons apart
          children: [
            // Back Button (Circular)
            InkWell(
              onTap: () {
                Navigator.pushNamed(context, prev);
              },
              child: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.black, width: 1.5),
                ),
                child:
                    const Icon(Icons.arrow_back, size: 24, color: Colors.black),
              ),
            ),

            // Next Button (Rounded Rectangle)
            InkWell(
              onTap: () async {
                await next();
              },
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black, width: 1.5),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Text(
                      "NEXT",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(width: 8), // Space between text and icon
                    Icon(Icons.arrow_forward, size: 24, color: Colors.black),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
