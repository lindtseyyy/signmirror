import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../constants/route_names.dart';
import '../providers/settings_provider.dart';

class PersonalizationScreen extends ConsumerWidget {
  const PersonalizationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).colorScheme;
    final highContrast = MediaQuery.of(context).highContrast;

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
                                    color: colors.onPrimary,
                                    fontFamily: 'Inter',
                                    fontWeight: FontWeight.bold,
                                    fontSize: 32,
                                  ),
                                ),
                                Text(
                                  "We'll tailor the FSL curriculum to your specific needs.",
                                  style: TextStyle(
                                    color: highContrast
                                        ? colors.onPrimary
                                        : colors.onPrimary.withOpacity(0.75),
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
                          onPressed: () {
                            ref
                                .read(personalizationProvider.notifier)
                                .setPersonalization("Self-Learning");
                            Navigator.pushReplacementNamed(
                              context,
                              RouteNames.main,
                            );
                          },
                        ),
                        PersonalizationChoice(
                          imageDir: "assets/images/school.png",
                          title: "Teaching",
                          description:
                              "I am an educator looking for tools and resources to teach FSL to my students.",
                          onPressed: () {
                            ref
                                .read(personalizationProvider.notifier)
                                .setPersonalization("Teaching");
                            Navigator.pushReplacementNamed(
                              context,
                              RouteNames.main,
                            );
                          },
                        ),
                        PersonalizationChoice(
                          imageDir: "assets/images/family.png",
                          title: "Parent Support",
                          description:
                              "I want to learn FSL to communicate better with my child and support their development.",
                          onPressed: () {
                            ref
                                .read(personalizationProvider.notifier)
                                .setPersonalization("Parent Support");
                            Navigator.pushReplacementNamed(
                              context,
                              RouteNames.main,
                            );
                          },
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
  final VoidCallback onPressed;
  const PersonalizationChoice({
    super.key,
    required this.imageDir,
    required this.title,
    required this.description,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final highContrast = MediaQuery.of(context).highContrast;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        // Vertical and Horizontal padding
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        // Background color
        backgroundColor: colors.surface,
        // Text color
        foregroundColor: colors.onSurface,
        // Border Radius (Rounded Corners)
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        side: highContrast
            ? BorderSide(color: colors.onSurface, width: 2.0)
            : (isDarkMode
                  ? BorderSide(color: colors.outline, width: 1.0)
                  : BorderSide.none),
        elevation: 5, // Higher number = larger shadow
        shadowColor: colors.shadow,
      ),
      onPressed: onPressed,

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
                    color: colors.onSurface,
                  ),
                ),

                Text(
                  description,
                  style: TextStyle(
                    fontFamily: "Inter",
                    fontSize: 12,
                    fontWeight: highContrast
                        ? FontWeight.w400
                        : FontWeight.w300,
                    color: highContrast
                        ? colors.onSurface
                        : colors.onSurfaceVariant,
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
