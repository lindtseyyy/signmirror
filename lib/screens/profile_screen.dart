import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:signmirror_flutter/constants/route_names.dart';
import 'package:signmirror_flutter/providers/settings_provider.dart';
import 'package:flutter/cupertino.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    final isDarkMode = ref.watch(themeProvider);
    final isOfflineDownloading = ref.watch(offlineDownloadProvider);
    final isHighContrast = ref.watch(highContrastProvider);
    final time = ref.watch(practiceTimeProvider);
    // 2. GET the pretty version from your Notifier
    final displayTime = ref
        .read(practiceTimeProvider.notifier)
        .getDisplayTime();
    final language = ref.watch(languageProvider);

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(50.0),
        child: AppBar(
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                "Profile",
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 22),
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
              padding: const EdgeInsetsGeometry.fromLTRB(15, 15, 15, 15),
              child: Column(
                children: [
                  Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: const Color(0xffffffff),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Column(
                          children: [
                            CircleAvatar(
                              radius: 51,
                              backgroundColor: Colors.black,
                              child: const CircleAvatar(
                                radius: 50,
                                backgroundImage: AssetImage(
                                  'assets/images/profile_picture.jpeg',
                                ),
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
                            const SizedBox(height: 10),
                            const Divider(
                              color: Colors.grey, // Line color
                              thickness: 1, // The actual thickness of the line
                              // indent: 20,
                              // endIndent: 20,
                            ),
                            const SizedBox(height: 10),
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
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                  style: const ButtonStyle(
                                    tapTargetSize:
                                        MaterialTapTargetSize.shrinkWrap, //
                                  ),
                                  icon: Icon(
                                    Icons.double_arrow,
                                    color: Colors.black.withValues(alpha: 0.6),
                                  ),
                                  onPressed: () {
                                    Navigator.pushNamed(
                                      context,
                                      RouteNames.achievements,
                                    );
                                  },
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
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
                          ],
                        ),
                      ),

                      const SizedBox(height: 10),

                      Container(
                        padding: const EdgeInsetsGeometry.all(20),
                        decoration: BoxDecoration(
                          color: const Color(0xffffffff),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Column(
                          children: [
                            SwitchListTile(
                              contentPadding: EdgeInsets
                                  .zero, // 1. Removes the outer 16px gap
                              visualDensity: const VisualDensity(
                                horizontal: -4,
                                vertical: -4,
                              ), // 2. Squeezes the internal space
                              title: const Text("Dark Mode"),
                              secondary: Icon(
                                isDarkMode ? Icons.dark_mode : Icons.light_mode,
                              ),
                              value: isDarkMode,

                              // 1. Change the shape/size of the track
                              trackOutlineColor: WidgetStateProperty.all(
                                isDarkMode ? Colors.transparent : Colors.black,
                              ),

                              // 2. Put an icon INSIDE the moving circle
                              thumbIcon: WidgetStateProperty.resolveWith<Icon?>(
                                (states) {
                                  if (states.contains(WidgetState.selected)) {
                                    return const Icon(
                                      Icons.check,
                                      color: Color(0xff2D68FF),
                                    );
                                  }
                                  return const Icon(
                                    Icons.close,
                                    color: Colors.white,
                                  );
                                },
                              ),

                              onChanged: (value) => ref
                                  .read(themeProvider.notifier)
                                  .toggleTheme(),
                            ),
                            const SizedBox(height: 10),
                            SwitchListTile(
                              contentPadding: EdgeInsets
                                  .zero, // 1. Removes the outer 16px gap
                              visualDensity: const VisualDensity(
                                horizontal: -4,
                                vertical: -4,
                              ), // 2. Squeezes the internal space
                              title: const Text("Offline Downloading"),
                              secondary: Icon(
                                isOfflineDownloading
                                    ? Icons.download_for_offline
                                    : Icons.download_for_offline_outlined,
                              ),
                              value: isOfflineDownloading,

                              // 1. Change the shape/size of the track
                              trackOutlineColor: WidgetStateProperty.all(
                                isOfflineDownloading
                                    ? Colors.transparent
                                    : Colors.black,
                              ),

                              // 2. Put an icon INSIDE the moving circle
                              thumbIcon: WidgetStateProperty.resolveWith<Icon?>(
                                (states) {
                                  if (states.contains(WidgetState.selected)) {
                                    return const Icon(
                                      Icons.download,
                                      color: Color(0xff2D68FF),
                                    );
                                  }
                                  return const Icon(
                                    Icons.close,
                                    color: Colors.white,
                                  );
                                },
                              ),

                              onChanged: (value) => ref
                                  .read(offlineDownloadProvider.notifier)
                                  .toggle(),
                            ),
                            const SizedBox(height: 10),
                            SwitchListTile(
                              contentPadding: EdgeInsets
                                  .zero, // 1. Removes the outer 16px gap
                              visualDensity: const VisualDensity(
                                horizontal: -4,
                                vertical: -4,
                              ), // 2. Squeezes the internal space
                              title: const Text("High Contrast"),
                              secondary: Icon(
                                isHighContrast
                                    ? Icons.contrast
                                    : Icons.contrast_outlined,
                              ),
                              value: isHighContrast,

                              // 1. Change the shape/size of the track
                              trackOutlineColor: WidgetStateProperty.all(
                                isHighContrast
                                    ? Colors.transparent
                                    : Colors.black,
                              ),

                              // 2. Put an icon INSIDE the moving circle
                              thumbIcon: WidgetStateProperty.resolveWith<Icon?>(
                                (states) {
                                  if (states.contains(WidgetState.selected)) {
                                    return const Icon(
                                      Icons.contrast,
                                      color: Color(0xff2D68FF),
                                    );
                                  }
                                  return const Icon(
                                    Icons.close,
                                    color: Colors.white,
                                  );
                                },
                              ),

                              onChanged: (value) => ref
                                  .read(highContrastProvider.notifier)
                                  .toggle(),
                            ),
                            ListTile(
                              contentPadding: EdgeInsets.zero,
                              horizontalTitleGap:
                                  8, // Removes the gap between icon and text
                              visualDensity: const VisualDensity(vertical: -4),
                              minLeadingWidth: 0,
                              leading: const Icon(Icons.language),
                              title: const Text("Language"),
                              subtitle: Text(
                                language == 'en' ? "English" : "Filipino",
                              ),
                              trailing: const Icon(
                                Icons.arrow_forward_ios,
                                size: 16,
                                color: Colors.grey,
                              ),
                              onTap: () {
                                showDialog(
                                  context: context,
                                  builder: (context) => SimpleDialog(
                                    title: const Text(
                                      "Select Language",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    children: [
                                      SimpleDialogOption(
                                        onPressed: () {
                                          ref
                                              .read(languageProvider.notifier)
                                              .setLanguage('en');
                                          Navigator.pop(context);
                                        },
                                        child: const Text(
                                          "English",
                                          style: TextStyle(fontSize: 16),
                                        ),
                                      ),
                                      SimpleDialogOption(
                                        onPressed: () {
                                          ref
                                              .read(languageProvider.notifier)
                                              .setLanguage('fil');
                                          Navigator.pop(context);
                                        },
                                        child: const Text(
                                          "Filipino",
                                          style: TextStyle(fontSize: 16),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                            ListTile(
                              contentPadding: EdgeInsets.zero,
                              visualDensity: const VisualDensity(vertical: -4),

                              horizontalTitleGap:
                                  8, // Removes the gap between icon and text
                              minLeadingWidth: 0,
                              leading: const Icon(Icons.alarm),
                              title: const Text("Daily Practice Reminder"),
                              subtitle: Text(displayTime), // e.g., "08:30 PM"
                              trailing: Icon(
                                Icons.arrow_forward_ios,
                                color: Colors.grey,
                                size: 15,
                              ),
                              onTap: () => _showTimePicker(context, ref),
                            ),
                            const SizedBox(height: 10),
                            FilledButton(
                              onPressed: () {},

                              style: FilledButton.styleFrom(
                                shape: const RoundedRectangleBorder(
                                  borderRadius: BorderRadiusGeometry.all(
                                    Radius.circular(10),
                                  ),
                                ),
                                backgroundColor: const Color(0xffFF4646),
                                minimumSize: const Size(double.infinity, 50),
                              ),
                              child: const Text(
                                "Logout",
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 1.0,
                                ),
                              ),
                            ),
                          ],
                        ),
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
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
      decoration: BoxDecoration(
        color: Color(0xffE2E8F0),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 30, // Outer radius (Radius + Border Width)
            backgroundColor: const Color(0xffFF8504), // Border Color
            child: CircleAvatar(
              radius: 28, // Inner radius
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

void _showTimePicker(BuildContext context, WidgetRef ref) {
  // 1. Get current saved time and convert to DateTime for the wheel
  final savedTime = ref.read(practiceTimeProvider); // e.g. "20:00"
  final parts = savedTime.split(':');
  final now = DateTime.now();
  DateTime tempDateTime = DateTime(
    now.year,
    now.month,
    now.day,
    int.parse(parts[0]),
    int.parse(parts[1]),
  );

  showCupertinoModalPopup(
    context: context,
    builder: (BuildContext context) => Container(
      height: 300,
      color: CupertinoColors.systemBackground.resolveFrom(context),
      child: SafeArea(
        top: false,
        child: Column(
          children: [
            // Using your helper header but adding the logic to the Done button
            _buildPickerHeader(context, ref, () {
              final pickedTime = TimeOfDay.fromDateTime(tempDateTime);
              ref.read(practiceTimeProvider.notifier).setTime(pickedTime);
              Navigator.pop(context);
            }),
            Expanded(
              child: CupertinoDatePicker(
                mode: CupertinoDatePickerMode.time,
                use24hFormat: false,
                initialDateTime: tempDateTime,
                onDateTimeChanged: (DateTime newDateTime) {
                  tempDateTime = newDateTime;
                },
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

// Updated Header to accept the Done action
Widget _buildPickerHeader(
  BuildContext context,
  WidgetRef ref,
  VoidCallback onDone,
) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
    decoration: const BoxDecoration(
      border: Border(
        bottom: BorderSide(color: CupertinoColors.separator, width: 0.5),
      ),
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          "Select Time",
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
        ),
        CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: onDone,
          child: const Text(
            "Done",
            style: TextStyle(
              color: Color(0xff2D68FF),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    ),
  );
}
