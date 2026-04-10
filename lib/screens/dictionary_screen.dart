import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:signmirror_flutter/models/sign.dart';
import 'package:signmirror_flutter/constants/route_names.dart';
import 'package:signmirror_flutter/providers/providers.dart';
import 'package:signmirror_flutter/screens/dictionary_sign_screen.dart';

class DictionaryScreen extends ConsumerStatefulWidget {
  const DictionaryScreen({super.key});

  @override
  ConsumerState<DictionaryScreen> createState() => _DictionaryScreenState();
}

class _DictionaryScreenState extends ConsumerState<DictionaryScreen> {
  String selectedDifficulty = "All categories";

  String searchQuery = "";

  final List<String> categories = [
    'All Categories',
    'Alphabet',
    'Numbers',
    'Greetings',
    'Emergency',
    'Basic Gestures',
  ];

  @override
  Widget build(BuildContext context) {
    final signs = ref.watch(signsProvider);

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(120.0),
        child: AppBar(
          automaticallyImplyLeading: false,
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                "Dictionary",
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 22),
              ),
              Text(
                "Learn new signs and improve your skills",
                style: TextStyle(fontSize: 12, color: Colors.white70),
              ),
            ],
          ),

          bottom: PreferredSize(
            preferredSize: Size.fromHeight(50.0),
            child: Padding(
              padding: const EdgeInsetsGeometry.fromLTRB(15, 10, 15, 15),
              child: SearchBar(
                onChanged: (value) => {
                  ref.read(signsProvider.notifier).search(value),
                },
                constraints: const BoxConstraints(
                  minHeight: 45.0, // Minimum height
                  maxHeight: 45.0, // Maximum height
                ),
                hintText: "Search Signs",

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
          // Move the IconButton HERE
          actions: [
            IconButton(
              iconSize: 30,
              icon: Icon(
                Icons.bookmark,

                color: Colors
                    .white, // Changed to white to see it against the dark blue
              ),
              onPressed: () {
                Navigator.pushNamed(context, RouteNames.bookmarkedSigns);
              },
            ),
            SizedBox(width: 5), // Add some spacing to the right of the icon
          ],
        ),
      ),

      body: Padding(
        padding: const EdgeInsetsGeometry.fromLTRB(15, 20, 15, 0),
        child: _buildListView(ref, signs),
      ),
    );
  }
}

Widget _buildListView(WidgetRef ref, List<Sign> signs) {
  return ListView.builder(
    itemCount: signs.length,
    itemBuilder: (context, index) {
      final sign = signs[index];
      return Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0), // Very subtle color
            ),
          ],
        ),
        child: ListTile(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => DictionarySignScreen(sign: sign),
              ),
            );
          },
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 0,
          ),

          title: Text(
            sign.title,
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 5,
            children: [
              Row(
                children: [
                  Text(
                    "${sign.category} Sign",
                    style: TextStyle(
                      color: Colors.black.withValues(alpha: 0.4),
                    ),
                  ),
                ],
              ),
            ],
          ),
          trailing: IconButton(
            onPressed: () async {
              await ref.read(signsProvider.notifier).toggleBookmark(sign);
              await ref.read(bookmarkedSignsProvider.notifier).loadAll();
            },
            icon: Icon(
              sign.isBookmarked ? Icons.bookmark : Icons.bookmark_border,
              size: 20,
              color: const Color(0xff304166),
            ),
          ),
        ),
      );
    },
  );
}
