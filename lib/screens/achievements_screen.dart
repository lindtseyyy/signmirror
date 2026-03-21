import 'package:flutter/material.dart';

class AchievementsScreen extends StatelessWidget {
  const AchievementsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Colors.white,
            size: 20,
          ),
          onPressed: () {
            Navigator.pop(context); // This performs the "Back" action
          },
        ),

        title: const Text(
          "Achievements",
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 24),
        ),
      ),
      body: SafeArea(
        child: SizedBox(
          width: double.infinity,
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),

                    child: Row(
                      children: [
                        SizedBox(
                          height: 120, // Increase this for a larger circle
                          width: 120, // Keep height and width the same
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              // 1. The Background Circle (the "track")
                              SizedBox(
                                height: 80,
                                width: 80,
                                child: CircularProgressIndicator(
                                  value: 1.0, // Full circle
                                  strokeWidth: 12, // Thicker line
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.grey.shade200,
                                  ),
                                ),
                              ),
                              // 2. The Actual Progress
                              SizedBox(
                                height: 80,
                                width: 80,
                                child: CircularProgressIndicator(
                                  value: 0.75, // 75% progress
                                  strokeWidth: 12,
                                  strokeCap: StrokeCap
                                      .round, // ✅ This makes the end rounded
                                  valueColor:
                                      const AlwaysStoppedAnimation<Color>(
                                        Color(0xff69B85E),
                                      ),
                                ),
                              ),
                              // 3. The Percentage Text
                              const Text(
                                "75%",
                                style: TextStyle(
                                  fontSize:
                                      20, // Larger font for a larger circle
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xff304166),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Text(
                            "Great job, Ping Pong! Complete your achievements to unlock more!",
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Column(
                    spacing: 10,
                    children: [
                      AchievementUnlocked(
                        title: "Studious",
                        description:
                            "You completed the 'Master the Basics' challenge.",
                        imagePath: "assets/images/achievements/trophy_icon.png",
                      ),
                      AchievementUnlocked(
                        title: "Quickie",
                        description:
                            "You completed the 'Master the Basics' challenge.",
                        imagePath: "assets/images/achievements/time_icon.png",
                      ),
                      AchievementUnlocked(
                        title: "Ambitious",
                        description:
                            "You completed the 'Master the Basics' challenge.",
                        imagePath: "assets/images/achievements/medal_icon.png",
                      ),
                      AchievementUnlocked(
                        title: "Perfectionist",
                        description:
                            "You completed the 'Master the Basics' challenge.",
                        imagePath: "assets/images/achievements/star_icon.png",
                      ),
                      AchievementLocked(
                        imagePath:
                            "assets/images/achievements/sunglasses_icon.png",
                      ),
                      AchievementLocked(
                        imagePath:
                            "assets/images/achievements/sunglasses_icon.png",
                      ),
                      AchievementLocked(
                        imagePath:
                            "assets/images/achievements/sunglasses_icon.png",
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

class AchievementUnlocked extends StatelessWidget {
  final String imagePath;
  final String title;
  final String description;
  const AchievementUnlocked({
    super.key,
    required this.imagePath,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            blurRadius: 1,
            offset: const Offset(1, 1),
            color: Colors.black.withValues(alpha: 0.1), // Very subtle color
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30, // Outer radius (Radius + Border Width)
            backgroundColor: const Color(0xffFF8504), // Border Color
            child: CircleAvatar(
              radius: 28, // Inner radius
              backgroundImage: AssetImage(imagePath),
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                ),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.black.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class AchievementLocked extends StatelessWidget {
  final String imagePath;
  const AchievementLocked({super.key, required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            blurRadius: 1,
            offset: const Offset(1, 1),
            color: Colors.black.withValues(alpha: 0.1), // Very subtle color
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30, // Outer radius (Radius + Border Width)
            backgroundColor: const Color(0xffFF8504), // Border Color
            child: CircleAvatar(
              radius: 28, // Inner radius
              backgroundImage: AssetImage(imagePath),
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Not yet unlocked",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.black.withValues(alpha: 0.4),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
