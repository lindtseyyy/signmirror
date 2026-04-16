import 'package:signmirror_flutter/widgets/adaptive_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:signmirror_flutter/models/lesson.dart';
import 'package:signmirror_flutter/providers/providers.dart';
import 'package:signmirror_flutter/providers/settings_provider.dart';
import 'package:signmirror_flutter/screens/lesson_signs_screen.dart';
import 'package:signmirror_flutter/theme/app_theme.dart';

class LessonsScreen extends ConsumerStatefulWidget {
  const LessonsScreen({super.key});

  @override
  ConsumerState<LessonsScreen> createState() => _LessonsScreenState();
}

class _LessonsScreenState extends ConsumerState<LessonsScreen> {
  String selectedDifficulty = "Difficulty Level";
  bool isListView = true;

  String searchQuery = "";

  final List<String> categories = [
    'Difficulty Level',
    'Beginner',
    'Intermediate',
    'Difficult',
  ];

  @override
  Widget build(BuildContext context) {
    final lessonState = ref.watch(lessonsProvider);
    final themeSettings = ref.watch(themeSettingsProvider);
    final resolvedTheme = AppTheme.resolve(
      mode: themeSettings.mode,
      highContrast: themeSettings.highContrast,
    );

    return Theme(
      data: resolvedTheme,
      child: Builder(
        builder: (context) {
          final theme = Theme.of(context);
          final colorScheme = theme.colorScheme;

          final isHighContrast = themeSettings.highContrast;
          final isDark = theme.brightness == Brightness.dark;
          final useLegacyLightColors = !isDark && !isHighContrast;

          final searchBackground = useLegacyLightColors
              ? Colors.white
              : (isDark ? colorScheme.surfaceVariant : colorScheme.surface);
          final searchForeground = useLegacyLightColors
              ? Colors.black
              : (isDark ? colorScheme.onSurfaceVariant : colorScheme.onSurface);

          final dropdownBackground = useLegacyLightColors
              ? const Color(0xff776483)
              : (isDark ? colorScheme.surfaceVariant : colorScheme.surface);
          final dropdownForeground = useLegacyLightColors
              ? Colors.white
              : (isDark ? colorScheme.onSurfaceVariant : colorScheme.onSurface);

          final dropdownSelectedTextStyle = useLegacyLightColors
              ? const TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                )
              : TextStyle(
                  color: dropdownForeground,
                  fontWeight: FontWeight.bold,
                );
          final dropdownItemTextColor = useLegacyLightColors
              ? Colors.white
              : dropdownForeground;

          final appBarBackground = useLegacyLightColors
              ? const Color(0xff304166)
              : colorScheme.primary;
          final appBarForeground = useLegacyLightColors
              ? Colors.white
              : colorScheme.onPrimary;

          return Scaffold(
            appBar: PreferredSize(
              preferredSize: Size.fromHeight(120.0),
              child: AppBar(
                automaticallyImplyLeading: false,
                title: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Lessons",
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 22,
                      ),
                    ),
                    Text(
                      "Learn new signs and improve your skills",
                      style: TextStyle(
                        fontSize: 12,
                        color: useLegacyLightColors
                            ? Colors.white70
                            : colorScheme.onPrimary.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
                actions: [
                  IconButton(
                    iconSize: 30,
                    icon: Icon(
                      isListView
                          ? Icons.grid_view_rounded
                          : Icons.format_list_bulleted_rounded,
                      color: useLegacyLightColors
                          ? Colors.white
                          : appBarForeground,
                    ),
                    onPressed: () => setState(() => isListView = !isListView),
                  ),
                  const SizedBox(width: 5),
                ],
                bottom: PreferredSize(
                  preferredSize: Size.fromHeight(50.0),
                  child: Padding(
                    padding: const EdgeInsetsGeometry.fromLTRB(15, 10, 15, 15),
                    child: SearchBar(
                      onChanged: (value) => {
                        ref.read(lessonsProvider.notifier).updateSearch(value),
                      },
                      constraints: const BoxConstraints(
                        minHeight: 45.0,
                        maxHeight: 45.0,
                      ),
                      hintText: "Search Lessons",
                      backgroundColor: MaterialStateProperty.all(
                        searchBackground,
                      ),
                      elevation: MaterialStateProperty.all(0),
                      padding: MaterialStateProperty.all(
                        const EdgeInsets.symmetric(horizontal: 16),
                      ),
                      leading: Icon(Icons.search, color: searchForeground),
                      textStyle: MaterialStateProperty.all(
                        TextStyle(color: searchForeground),
                      ),
                      hintStyle: MaterialStateProperty.all(
                        TextStyle(
                          color: useLegacyLightColors
                              ? Colors.black.withOpacity(0.5)
                              : searchForeground.withOpacity(0.6),
                        ),
                      ),
                      shape: MaterialStateProperty.resolveWith((states) {
                        if (useLegacyLightColors) {
                          return RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5),
                            side: const BorderSide(
                              width: 0.5,
                              color: Color(0xff304166),
                            ),
                          );
                        }

                        final isFocused = states.contains(
                          MaterialState.focused,
                        );
                        final borderWidth = isHighContrast ? 1.2 : 0.8;
                        final borderColor = isFocused
                            ? colorScheme.primary
                            : (isHighContrast
                                  ? colorScheme.onSurface.withOpacity(0.8)
                                  : colorScheme.outline);

                        return RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5),
                          side: BorderSide(
                            width: borderWidth,
                            color: borderColor,
                          ),
                        );
                      }),
                    ),
                  ),
                ),
                backgroundColor: appBarBackground,
                foregroundColor: appBarForeground,
                elevation: 4,
              ),
            ),
            backgroundColor: useLegacyLightColors
                ? const Color(0xffF4F4F8)
                : theme.scaffoldBackgroundColor,
            body: SafeArea(
              child: SizedBox(
                child: Container(
                  padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Container(
                            padding: const EdgeInsets.fromLTRB(15, 10, 5, 10),
                            decoration: BoxDecoration(
                              color: dropdownBackground,
                              borderRadius: BorderRadius.circular(5),
                              border: Border.all(
                                color: useLegacyLightColors
                                    ? const Color(0xff304166)
                                    : (isHighContrast
                                          ? colorScheme.onSurface.withOpacity(
                                              0.8,
                                            )
                                          : colorScheme.outline),
                                width: useLegacyLightColors
                                    ? 0.1
                                    : (isHighContrast ? 1.2 : 0.8),
                              ),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                isDense: true,
                                value: selectedDifficulty,
                                dropdownColor: dropdownBackground,
                                icon: Icon(
                                  Icons.arrow_drop_down,
                                  color: useLegacyLightColors
                                      ? Colors.white
                                      : dropdownForeground,
                                ),
                                style: dropdownSelectedTextStyle,
                                onChanged: (String? newValue) {
                                  setState(() {
                                    selectedDifficulty = newValue!;
                                  });
                                  ref
                                      .read(lessonsProvider.notifier)
                                      .updateDifficulty(newValue!);
                                },
                                items: categories.map<DropdownMenuItem<String>>(
                                  (String value) {
                                    return DropdownMenuItem<String>(
                                      value: value,
                                      child: Text(
                                        value,
                                        style: TextStyle(
                                          color: dropdownItemTextColor,
                                        ),
                                      ),
                                    );
                                  },
                                ).toList(),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Expanded(
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 300),
                          transitionBuilder:
                              (Widget child, Animation<double> animation) {
                                return FadeTransition(
                                  opacity: animation,
                                  child: child,
                                );
                              },
                          child: isListView
                              ? _buildListView(
                                  lessonState.lessons,
                                  useLegacyLightColors: useLegacyLightColors,
                                  isHighContrast: isHighContrast,
                                )
                              : _buildGridView(
                                  lessonState.lessons,
                                  useLegacyLightColors: useLegacyLightColors,
                                  isHighContrast: isHighContrast,
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

Widget _buildListView(
  List<Lesson> lessons, {
  required bool useLegacyLightColors,
  required bool isHighContrast,
}) {
  return ListView.builder(
    itemCount: lessons.length, // Replace with your data.length
    itemBuilder: (context, index) {
      final lesson = lessons[index];
      final theme = Theme.of(context);
      final colorScheme = theme.colorScheme;
      final isDark = theme.brightness == Brightness.dark;

      final cardBackground = useLegacyLightColors
          ? Colors.white
          : (isDark ? colorScheme.surfaceVariant : colorScheme.surface);

      final BoxBorder? cardBorder = isHighContrast
          ? Border.all(
              color: colorScheme.onSurface.withOpacity(isDark ? 0.9 : 0.7),
              width: 1.4,
            )
          : null;

      final List<BoxShadow> cardShadows = useLegacyLightColors
          ? <BoxShadow>[
              BoxShadow(
                blurRadius: 1,
                offset: const Offset(1, 1),
                color: Colors.black.withOpacity(0.1),
              ),
            ]
          : (isDark
                ? <BoxShadow>[]
                : <BoxShadow>[
                    BoxShadow(
                      blurRadius: 1,
                      offset: const Offset(1, 1),
                      color: theme.shadowColor.withOpacity(0.12),
                    ),
                  ]);

      final countColor = useLegacyLightColors
          ? Colors.black.withOpacity(0.4)
          : colorScheme.onSurfaceVariant.withOpacity(0.7);

      final trailingColor = useLegacyLightColors
          ? const Color(0xff304166)
          : colorScheme.primary;

      return Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: cardBackground,
          borderRadius: BorderRadius.circular(15),
          border: cardBorder,
          boxShadow: cardShadows,
        ),
        child: ListTile(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => LessonSignsScreen(lesson: lesson),
              ),
            );
          },
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 10,
          ),
          leading: SizedBox(
            width: 50,
            height: 50,
            child: AdaptiveImage(lesson.imagePath, fit: BoxFit.cover),
          ), // Lesson Image
          title: Text(
            lesson.title,
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    "${lesson.count} Lessons",
                    style: TextStyle(color: countColor),
                  ),
                ],
              ),
              const SizedBox(height: 5),
              DifficultyBadge(level: lesson.level),
              const SizedBox(height: 5),
              ProgressBar(
                percentage: lesson.progress,
                useLegacyLightColors: useLegacyLightColors,
                isHighContrast: isHighContrast,
              ),
            ],
          ),
          trailing: Icon(
            Icons.arrow_forward_ios,
            size: 14,
            color: trailingColor,
          ),
        ),
      );
    },
  );
}

class ProgressBar extends StatelessWidget {
  final double percentage;
  final bool useLegacyLightColors;
  final bool isHighContrast;

  const ProgressBar({
    super.key,
    required this.percentage,
    required this.useLegacyLightColors,
    required this.isHighContrast,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final trackColor = useLegacyLightColors
        ? Colors.black.withOpacity(0.15)
        : colorScheme.outline.withOpacity(
            isHighContrast ? (isDark ? 0.7 : 0.35) : (isDark ? 0.45 : 0.25),
          );

    final fillColor = useLegacyLightColors
        ? Colors.lightGreen.shade400
        : colorScheme.primary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(10), // Makes it rounded
          child: LinearProgressIndicator(
            value: percentage, // 0.0 to 1.0
            minHeight: 5, // Makes it thicker and easier to see
            backgroundColor: trackColor, // The "empty" part
            valueColor: AlwaysStoppedAnimation<Color>(
              fillColor,
            ), // The "filled" part
          ),
        ),
      ],
    );
  }
}

Widget _buildGridView(
  List<Lesson> lessons, {
  required bool useLegacyLightColors,
  required bool isHighContrast,
}) {
  return GridView.builder(
    itemCount: lessons.length,
    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: 2, // 2 items per row
      crossAxisSpacing: 20, // Horizontal gap
      mainAxisSpacing: 20, // Vertical gap
      childAspectRatio: 0.85, // Adjust this to make boxes taller or shorter
    ),
    itemBuilder: (context, index) {
      final lesson = lessons[index];
      final theme = Theme.of(context);
      final colorScheme = theme.colorScheme;
      final isDark = theme.brightness == Brightness.dark;

      final cardBackground = useLegacyLightColors
          ? Colors.white
          : (isDark ? colorScheme.surfaceVariant : colorScheme.surface);

      final BoxBorder? cardBorder = isHighContrast
          ? Border.all(
              color: colorScheme.onSurface.withOpacity(isDark ? 0.9 : 0.7),
              width: 1.4,
            )
          : null;

      final List<BoxShadow> cardShadows = useLegacyLightColors
          ? <BoxShadow>[
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 1,
                offset: const Offset(1, 1), // Bottom-right shadow
              ),
            ]
          : (isDark
                ? <BoxShadow>[]
                : <BoxShadow>[
                    BoxShadow(
                      color: theme.shadowColor.withOpacity(0.12),
                      blurRadius: 1,
                      offset: const Offset(1, 1), // Bottom-right shadow
                    ),
                  ]);

      final countColor = useLegacyLightColors
          ? Colors.black.withOpacity(0.4)
          : colorScheme.onSurfaceVariant.withOpacity(0.7);

      return Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
        decoration: BoxDecoration(
          color: cardBackground,
          borderRadius: BorderRadius.circular(15),
          border: cardBorder,
          boxShadow: cardShadows,
        ),
        clipBehavior: Clip.hardEdge,
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => LessonSignsScreen(lesson: lesson),
              ),
            );
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: double.infinity,
                height: 60,
                child: AdaptiveImage(lesson.imagePath, fit: BoxFit.contain),
              ), // Lesson Icon
              const SizedBox(height: 10),
              Text(
                lesson.title,
                style: const TextStyle(fontWeight: FontWeight.w700),
                overflow: TextOverflow.ellipsis, // Adds the "..."
                maxLines: 1, // Limits to a single line
                softWrap: false,
              ),
              Text(
                "${lesson.count} Lessons",
                style: TextStyle(color: countColor),
                overflow: TextOverflow.ellipsis, // Adds the "..."
                maxLines: 1, // Limits to a single line
                softWrap: false,
              ),
              const SizedBox(height: 7),
              DifficultyBadge(level: lesson.level),
              const SizedBox(height: 10),
              ProgressBar(
                percentage: lesson.progress,
                useLegacyLightColors: useLegacyLightColors,
                isHighContrast: isHighContrast,
              ),
            ],
          ),
        ),
      );
    },
  );
}

class DifficultyBadge extends StatelessWidget {
  const DifficultyBadge({super.key, required this.level});

  final String level;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 5),
      decoration: BoxDecoration(
        color: getLevelColor(level),
        borderRadius: BorderRadius.circular(5),
      ),
      child: Text(
        level,
        style: TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
        overflow: TextOverflow.ellipsis, // Adds the "..."
        maxLines: 1, // Limits to a single line
        softWrap: false,
      ),
    );
  }
}

Color getLevelColor(String level) {
  switch (level) {
    case 'Beginner':
      return Colors.green;
    case 'Intermediate':
      return Colors.orange;
    case 'Difficult':
      return Colors.red;
    default:
      return Colors.grey;
  }
}
