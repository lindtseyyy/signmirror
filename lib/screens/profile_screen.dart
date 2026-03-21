import 'package:flutter/material.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(70.0),
        child: AppBar(
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                "Profile",
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 22),
              ),
              Text(
                "Learn new signs and improve your skills",
                style: TextStyle(fontSize: 12, color: Colors.white70),
              ),
            ],
          ),
        ),
      ),
      body: SafeArea(
        child: SizedBox(
          width: double.infinity,
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsetsGeometry.all(30),
              child: Column(
                children: [
                  Column(
                    children: [
                      const CircleAvatar(
                        radius: 50,
                        backgroundImage: AssetImage(
                          'assets/images/profile_picture.jpeg',
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        "Ping Pong Dantes",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 3),
                      const Text(
                        "Self-Learning",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                      const Divider(
                        color: Colors.grey, // Line color
                        thickness: 1, // The actual thickness of the line
                        // indent: 20,
                        // endIndent: 20,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,

                        children: [
                          const Text(
                            "ACHIEVEMENTS",
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          IconButton(
                            iconSize: 18,
                            icon: Icon(
                              Icons.double_arrow,
                              color: Colors.black.withValues(
                                alpha: 0.6,
                              ), // Changed to white to see it against the dark blue
                            ),
                            onPressed: () => {},
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,

                        children: [
                          Achievement(
                            imagePath:
                                "assets/images/achievements/trophy_icon.png",
                            title: "Studious",
                          ),
                          Achievement(
                            imagePath:
                                "assets/images/achievements/time_icon.png",
                            title: "Quickie",
                          ),
                          Achievement(
                            imagePath:
                                "assets/images/achievements/star_icon.png",
                            title: "Ambitious",
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Column(
                        children: [
                          Row(
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "High Contrast Mode",
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  Text(
                                    "VISUAL ACCESSIBILITY",
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w300,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class Achievement extends StatelessWidget {
  final String imagePath;
  final String title;
  const Achievement({super.key, required this.imagePath, required this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: Color(0xffE2E8F0),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 27, // Outer radius (Radius + Border Width)
            backgroundColor: const Color(0xffFF8504), // Border Color
            child: CircleAvatar(
              radius: 25, // Inner radius
              backgroundImage: AssetImage(imagePath),
            ),
          ),
          SizedBox(height: 3),
          Text(
            title,
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}
