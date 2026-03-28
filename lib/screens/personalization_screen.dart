import 'package:flutter/material.dart';
import '../constants/route_names.dart';

class PersonalizationScreen extends StatelessWidget {
  const PersonalizationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Scaffold(
      body: SafeArea(
        child: SizedBox(
          width: double.infinity,
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(0, 0, 0, 10),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Stack(
                    clipBehavior: Clip.hardEdge,
                    children: [
                      SizedBox(height: 250, width: double.infinity),
                      Positioned(
                        left: -150,
                        right: -90,
                        top: -200,
                        child: Container(
                          width: 400,
                          height: 400,
                          decoration: BoxDecoration(
                            color: colors.primary,
                            borderRadius: BorderRadius.all(
                              Radius.elliptical(400, 175),
                            ),
                          ),
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 70),
                          Padding(
                            padding: EdgeInsetsGeometry.directional(start: 30),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Which user are you?',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontFamily: 'Inter',
                                    fontWeight: FontWeight.bold,
                                    fontSize: 32,
                                  ),
                                ),
                                Text(
                                  "We'll tailor the FSL curriculum to your specific needs.",
                                  style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.6),
                                    fontFamily: 'Inter',
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Padding(
                    padding: EdgeInsetsGeometry.symmetric(horizontal: 30),
                    child: Column(
                      spacing: 20,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        PersonalizationChoice(
                          imageDir: "assets/images/grad_cap.png",
                          title: "Self-Learning",
                          description:
                              "I want to learn FSL at my own pace through interactive lessons and feedback.",
                        ),
                        PersonalizationChoice(
                          imageDir: "assets/images/school.png",
                          title: "Teaching",
                          description:
                              "I am an educator looking for tools and resources to teach FSL to my students.",
                        ),
                        PersonalizationChoice(
                          imageDir: "assets/images/family.png",
                          title: "Parent Support",
                          description:
                              "I want to learn FSL to communicate better with my child and support their development.",
                        ),
                      ],
                    ),
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

class PersonalizationChoice extends StatelessWidget {
  final String imageDir;
  final String title;
  final String description;
  const PersonalizationChoice({
    super.key,
    required this.imageDir,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        // Vertical and Horizontal padding
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        // Background color
        backgroundColor: Color(0xffFFFFFF),
        // Text color
        foregroundColor: Color(0xff000000),
        // Border Radius (Rounded Corners)
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        side: const BorderSide(color: Colors.black, width: 0.1),
        elevation: 5, // Higher number = larger shadow
        shadowColor: Colors.black, // Make it darker
      ),
      onPressed: () {
        Navigator.pushReplacementNamed(context, RouteNames.main);
      },

      child: Row(
        spacing: 15,
        children: [
          SizedBox(height: 80, width: 80, child: Image.asset(imageDir)),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontFamily: "Inter",
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),

                Text(
                  description,
                  style: TextStyle(
                    fontFamily: "Inter",
                    fontSize: 12,
                    fontWeight: FontWeight.w300,
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
