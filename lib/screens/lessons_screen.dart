import 'package:flutter/material.dart';

class LessonsScreen extends StatefulWidget {
  const LessonsScreen({super.key});

  @override
  State<LessonsScreen> createState() => _LessonsScreenState();
}

class _LessonsScreenState extends State<LessonsScreen> {
  String selectedCategory = "All Categories";
  bool isListView = true;

  String searchQuery = "";

  final List<String> categories = [
    'All Categories',
    'Beginner',
    'Intermediate',
    'Difficult',
  ];

  final List<Map<String, dynamic>> allLessons = [
    {
      'title': 'Alphabet',
      'count': 26,
      'level': 'Beginner',
      'progress': 0.75, // 75% completed
    },
    {
      'title': 'Numbers',
      'count': 10,
      'level': 'Beginner',
      'progress': 1.0, // 100% completed
    },
    {
      'title': 'Greetings',
      'count': 15,
      'level': 'Beginner',
      'progress': 0.4, // 40% completed
    },
    {
      'title': 'Basic Gestures',
      'count': 20,
      'level': 'Intermediate',
      'progress': 0.0, // 0% completed
    },
    {
      'title': 'Daily Conversations',
      'count': 18,
      'level': 'Intermediate',
      'progress': 0.1, // 10% completed
    },
    {
      'title': 'Emergency Signs',
      'count': 26,
      'level': 'Difficult',
      'progress': 0.0, // 0% completed
    },
  ];

  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> filteredLessons = allLessons.where((lesson) {
      // 1. Filter by Category Dropdown
      bool matchesCategory =
          selectedCategory == 'All Categories' ||
          lesson['level'] == selectedCategory;

      // 2. Filter by Search Bar (assuming you have a 'searchQuery' variable)
      bool matchesSearch = lesson['title'].toLowerCase().contains(
        searchQuery.toLowerCase(),
      );

      return matchesCategory && matchesSearch;
    }).toList();
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "FSL Lessons",
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 24),
        ),
        backgroundColor: Color(0xff304166),
        foregroundColor: Colors.white, // Sets color for icons and text
        elevation: 4,
      ),
      backgroundColor: Color(0xffF4F4F8),
      body: SafeArea(
        child: SizedBox(
          child: Container(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
            child: Column(
              children: [
                SearchBar(
                  onChanged: (value) => {
                    setState(() {
                      searchQuery = value;
                    }),
                  },
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
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(width: 0.5, color: Color(0xff304166)),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // --- LEFT: DROPDOWN FILTER ---
                    DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: selectedCategory,
                        dropdownColor: Colors.white, // Background of the list
                        icon: const Icon(
                          Icons.arrow_drop_down,
                          color: Color(0xff304166),
                        ),
                        style: const TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                        onChanged: (String? newValue) {
                          setState(() {
                            selectedCategory = newValue!;
                          });
                        },
                        items: categories.map<DropdownMenuItem<String>>((
                          String value,
                        ) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                      ),
                    ),

                    // --- RIGHT: VIEW TOGGLE ICON ---
                    Container(
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: const Color(0xff304166).withValues(alpha: 0.1),
                        ),
                      ),
                      child: IconButton(
                        icon: Icon(
                          isListView
                              ? Icons.grid_view_rounded
                              : Icons.format_list_bulleted_rounded,
                          color: const Color(0xff304166),
                        ),
                        onPressed: () {
                          setState(() {
                            isListView = !isListView; // Toggles the view mode
                          });
                        },
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
                        ? _buildListView(filteredLessons)
                        : _buildGridView(filteredLessons),
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

Widget _buildListView(List lessons) {
  return ListView.builder(
    itemCount: lessons.length, // Replace with your data.length
    itemBuilder: (context, index) {
      return Card(
        margin: const EdgeInsets.only(bottom: 12),
        elevation: 1,
        color: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 10,
          ),
          leading: Container(
            width: 50,
            height: 50,

            decoration: BoxDecoration(
              color: Colors.greenAccent,
              borderRadius: BorderRadius.circular(10),
            ),
          ), // Lesson Image
          title: Text(
            lessons[index]['title'],
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 5,
            children: [
              Row(
                children: [
                  Text(
                    "${lessons[index]['count']} Lessons",
                    style: TextStyle(
                      color: Colors.black.withValues(alpha: 0.4),
                    ),
                  ),
                ],
              ),
              DifficultyBadge(level: lessons[index]['level']),
              const SizedBox(height: 1),
              ProgressBar(percentage: lessons[index]['progress']),
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
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 3,
              offset: const Offset(1, 1), // Bottom-right shadow
            ),
          ],
        ),
        clipBehavior: Clip.hardEdge,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: double.infinity,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.greenAccent,
                borderRadius: BorderRadius.circular(10),
              ),
            ), // Lesson Icon
            const SizedBox(height: 10),
            Text(
              lesson['title'],
              style: TextStyle(fontWeight: FontWeight.w700),
              overflow: TextOverflow.ellipsis, // Adds the "..."
              maxLines: 1, // Limits to a single line
              softWrap: false,
            ),

            Text(
              "${lesson['count']} Lessons",
              style: TextStyle(color: Colors.black.withValues(alpha: 0.4)),
              overflow: TextOverflow.ellipsis, // Adds the "..."
              maxLines: 1, // Limits to a single line
              softWrap: false,
            ),
            const SizedBox(height: 7),
            DifficultyBadge(level: lessons[index]['level']),
            const SizedBox(height: 10),
            ProgressBar(percentage: lessons[index]['progress']),
          ],
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
