import 'package:signmirror_flutter/widgets/adaptive_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:signmirror_flutter/models/lesson.dart';
import 'package:signmirror_flutter/providers/providers.dart';
import 'package:signmirror_flutter/screens/lesson_signs_screen.dart';

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

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(120.0),
        child: AppBar(
          automaticallyImplyLeading: false,
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                "Lessons",
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 22),
              ),
              Text(
                "Learn new signs and improve your skills",
                style: TextStyle(fontSize: 12, color: Colors.white70),
              ),
            ],
          ),
          // Move the IconButton HERE
          actions: [
            IconButton(
              iconSize: 30,
              icon: Icon(
                isListView
                    ? Icons.grid_view_rounded
                    : Icons.format_list_bulleted_rounded,
                color: Colors
                    .white, // Changed to white to see it against the dark blue
              ),
              onPressed: () => setState(() => isListView = !isListView),
            ),
            SizedBox(width: 5), // Add some spacing to the right of the icon
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
                  minHeight: 45.0, // Minimum height
                  maxHeight: 45.0, // Maximum height
                ),
                hintText: "Search Lessons",

                backgroundColor: WidgetStateProperty.all(Colors.white),

                elevation: WidgetStateProperty.all(0),

                padding: WidgetStateProperty.all(
                  const EdgeInsets.symmetric(horizontal: 16),
                ),

                leading: const Icon(Icons.search, color: Colors.black),

                textStyle: WidgetStateProperty.all(
                  const TextStyle(color: Colors.black),
                ),

                hintStyle: WidgetStateProperty.all(
                  TextStyle(color: Colors.black.withValues(alpha: 0.5)),
                ),

                shape: WidgetStateProperty.all(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5),

                    side: BorderSide(width: 0.5, color: Color(0xff304166)),
                  ),
                ),
              ),
            ),
          ),
          backgroundColor: Color(0xff304166),
          foregroundColor: Colors.white, // Sets color for icons and text
          elevation: 4,
        ),
      ),
      backgroundColor: Color(0xffF4F4F8),
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
                        color: Color(0xff776483),
                        borderRadius: BorderRadius.circular(5),
                        border: Border.all(
                          color: Color(0xff304166),
                          width: 0.1,
                        ),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          isDense: true,
                          value: selectedDifficulty,
                          dropdownColor: Color(
                            0xff776483,
                          ), // Background of the list
                          icon: const Icon(
                            Icons.arrow_drop_down,
                            color: Colors.white,
                          ),
                          style: const TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                          onChanged: (String? newValue) {
                            setState(() {
                              selectedDifficulty = newValue!;
                            });
                            ref
                                .read(lessonsProvider.notifier)
                                .updateDifficulty(
                                  newValue!,
                                ); // Update the provider with the new category
                          },
                          items: categories.map<DropdownMenuItem<String>>((
                            String value,
                          ) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(
                                value,
                                style: TextStyle(color: Colors.white),
                              ),
                            );
                          }).toList(),
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
                        ? _buildListView(lessonState.lessons)
                        : _buildGridView(lessonState.lessons),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

Widget _buildListView(List<Lesson> lessons) {
  return ListView.builder(
    itemCount: lessons.length, // Replace with your data.length
    itemBuilder: (context, index) {
      final lesson = lessons[index];
      return Container(
        margin: const EdgeInsets.only(bottom: 12),

        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              blurRadius: 1,
              offset: const Offset(1, 1),
              color: Colors.black.withValues(alpha: 0.1), // Very subtle color
            ),
          ],
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
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 5,
            children: [
              Row(
                children: [
                  Text(
                    "${lesson.count} Lessons",
                    style: TextStyle(
                      color: Colors.black.withValues(alpha: 0.4),
                    ),
                  ),
                ],
              ),
              DifficultyBadge(level: lesson.level),
              const SizedBox(height: 1),
              ProgressBar(percentage: lesson.progress),
            ],
          ),
          trailing: const Icon(
            Icons.arrow_forward_ios,
            size: 14,
            color: Color(0xff304166),
          ),
        ),
      );
    },
  );
}

class ProgressBar extends StatelessWidget {
  final double percentage;
  const ProgressBar({super.key, required this.percentage});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(10), // Makes it rounded
          child: LinearProgressIndicator(
            value: percentage, // 0.0 to 1.0 (75%)
            minHeight: 5, // Makes it thicker and easier to see
            backgroundColor: Colors.black.withValues(
              alpha: 0.15,
            ), // The "empty" part
            valueColor: AlwaysStoppedAnimation<Color>(
              Colors.lightGreen.shade400,
            ), // The "filled" part
          ),
        ),
      ],
    );
  }
}

Widget _buildGridView(List lessons) {
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

      return Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 1,
              offset: const Offset(1, 1), // Bottom-right shadow
            ),
          ],
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
                style: TextStyle(fontWeight: FontWeight.w700),
                overflow: TextOverflow.ellipsis, // Adds the "..."
                maxLines: 1, // Limits to a single line
                softWrap: false,
              ),

              Text(
                "${lesson.count} Lessons",
                style: TextStyle(color: Colors.black.withValues(alpha: 0.4)),
                overflow: TextOverflow.ellipsis, // Adds the "..."
                maxLines: 1, // Limits to a single line
                softWrap: false,
              ),
              const SizedBox(height: 7),
              DifficultyBadge(level: lesson.level),
              const SizedBox(height: 10),
              ProgressBar(percentage: lesson.progress),
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
