import 'package:flutter/material.dart';

class SetupProfileUploadPhoto extends StatelessWidget {
  const SetupProfileUploadPhoto({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Image.asset(
          'assets/images/logo.png',
          height: 80,
        ),
        centerTitle: true,
      ),
      backgroundColor: Colors.white,
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        children: [
          const SizedBox(height: 100),

          // Subtitle
          const Text(
            'Complete your',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w500,
              color: Colors.black,
            ),
          ),

          // Title
          const Text(
            'Profile',
            style: TextStyle(
              fontSize: 48,
              fontWeight: FontWeight.w900,
              color: Colors.black,
            ),
          ),

          // Decorative Line
          const SizedBox(height: 8),
          Row(
            children: [
              Container(
                height: 8,
                width: 325,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Colors.red,
                      Colors.yellow,
                      Colors.green,
                      Colors.blue
                    ],
                  ),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              Expanded(
                child: Container(
                  height: 8,
                  decoration: const BoxDecoration(
                    borderRadius:
                        BorderRadius.only(topRight: Radius.circular(4)),
                    color: Color.fromRGBO(224, 217, 217, 1),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Center(
            child: RichText(
              text: const TextSpan(
                text: 'You are ',
                style: TextStyle(
                  fontSize: 20,
                  color: Color.fromARGB(255, 109, 108, 108),
                ),
                children: [
                  TextSpan(
                    text: '80%',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextSpan(
                    text: ' there',
                  ),
                ],
              ),
            ),
          ),

          // Cover and Profile Photo Section
          const SizedBox(height: 20),
          SizedBox(height: 20),
          Text(
            'Cover Photo',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: () {
              // Handle cover photo upload
            },
            child: Container(
              height: 150,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8),
                color: Colors.grey[200],
              ),
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.upload, size: 32, color: Colors.black),
                    Text('UPLOAD'),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 20),
          SizedBox(height: 20),
          Text(
            'Profile Photo',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: () {
              // Handle profile photo upload
            },
            child: Container(
              height: 100,
              width: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.grey),
                color: Colors.grey[200],
              ),
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.upload, size: 32, color: Colors.black),
                    Text('UPLOAD'),
                  ],
                ),
              ),
            ),
          ),

          // Back and Next Buttons
          const SizedBox(height: 40),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              InkWell(
                onTap: () {
                  Navigator.pushNamed(
                      context, '/setup_profile_professional_info');
                },
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.black, width: 1.5),
                  ),
                  child: const Icon(Icons.arrow_back,
                      size: 24, color: Colors.black),
                ),
              ),
              InkWell(
                onTap: () {
                  Navigator.pushNamed(context, '/setup_profile_socials');
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
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(width: 8),
                      Icon(Icons.arrow_forward, size: 24, color: Colors.black),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
