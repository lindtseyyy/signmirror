// providers.dart
import 'package:isar_community/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:signmirror_flutter/models/lesson.dart';
import 'package:signmirror_flutter/models/sign.dart';

class IsarService {
  late Future<Isar> db;

  IsarService() {
    db = openDB();
  }

  // Initialize the database
  Future<Isar> openDB() async {
    final dir = await getApplicationDocumentsDirectory();

    // Check if an instance is already open to avoid errors
    if (Isar.instanceNames.isEmpty) {
      final isar = await Isar.open([
        SignSchema,
        LessonSchema,
      ], directory: dir.path);

      // await resetDatabase();
      // OPTIONAL: Seed data if the database is brand new
      await _seedData(isar);
      return isar;
    }

    return Isar.getInstance()!;
  }

  // Seed initial data (for local testing)
  Future<void> _seedData(Isar isar) async {
    final lessonsCount = await isar.lessons.count();
    final signsCount = await isar.signs.count();

    // Only seed if the database is empty
    if (lessonsCount == 0 && signsCount == 0) {
      final List<Map<String, dynamic>> allLessons = [
        {
          'title': 'Alphabet',
          'count': 26,
          'level': 'Beginner',
          'progress': 0.75,
          'imagePath': 'assets/images/lessons/alphabet.png',
        },
        {
          'title': 'Numbers',
          'count': 10,
          'level': 'Beginner',
          'progress': 1.0,
          'imagePath': 'assets/images/lessons/numbers.png',
        },
        {
          'title': 'Basic Gestures',
          'count': 20,
          'level': 'Intermediate',
          'progress': 0.0,
          'imagePath': 'assets/images/lessons/basic_gestures.png',
        },
        {
          'title': 'Daily Conversations',
          'count': 18,
          'level': 'Intermediate',
          'progress': 0.1,
          'imagePath': 'assets/images/lessons/daily_conversation.png',
        },
      ];

      final List<Map<String, dynamic>> allSigns = [
        {
          'id': 1,
          'title': 'Letter A',
          'category': 'Alphabet',
          'imagePath': 'assets/images/lessons/daily_conversation.png',
        },
        {
          'id': 2,
          'title': 'Letter B',
          'category': 'Alphabet',
          'imagePath': 'assets/images/lessons/daily_conversation.png',
        },
        {
          'id': 3,
          'title': 'Number 1',
          'category': 'Numbers',
          'imagePath': 'assets/images/lessons/daily_conversation.png',
        },
        {
          'id': 4,
          'title': 'Hello',
          'category': 'Greetings',
          'imagePath': 'assets/images/lessons/daily_conversation.png',
        },
        {
          'id': 5,
          'title': 'Thank You',
          'category': 'Greetings',
          'imagePath': 'assets/images/lessons/daily_conversation.png',
        },
        {
          'id': 6,
          'title': 'Help',
          'category': 'Emergency',
          'imagePath': 'assets/images/lessons/daily_conversation.png',
        },
        {
          'id': 7,
          'title': 'Please',
          'category': 'Basic Gestures',
          'imagePath': 'assets/images/lessons/daily_conversation.png',
        },
      ];

      // Seed signs
      final initialSigns = allSigns.map((sign) {
        return Sign()
          ..title = sign['title']
          ..category = sign['category']
          ..imagePath = sign['imagePath'];
      }).toList();

      // Convert your List of Maps into a List of Sign objects
      final initialLessons = allLessons.map((lesson) {
        return Lesson()
          ..title = lesson['title']
          ..count = lesson['count']
          ..level = lesson['level']
          ..progress = lesson['progress']
          ..imagePath =
              lesson['imagePath']; // Using 'level' as the category for now
      }).toList();

      await isar.writeTxn(() async {
        await isar.lessons.putAll(initialLessons);
        await isar.signs.putAll(initialSigns);
      });

      print("Database seeded with ${initialLessons.length} lesson items.");
      print("Database seeded with ${initialSigns.length} sign items.");
    }
  }

  Future<void> resetDatabase() async {
    final isar = await db;

    // 1. Wipe all data from all collections
    await isar.writeTxn(() async {
      await isar.clear();
    });

    // 2. Re-run your seed function to put the initial lessons back
    await _seedData(isar);

    print("Database has been reset and re-seeded.");
  }

  // --- CRUD OPERATIONS ---

  // Get all signs
  Future<List<Sign>> getAllSigns() async {
    final isar = await db;
    return await isar.signs.where().findAll();
  }

  // Get all lessons
  Future<List<Lesson>> getAllLessons() async {
    final isar = await db;
    return await isar.lessons.where().findAll();
  }

  // Search signs by title (Case Insensitive)
  Future<List<Sign>> searchSigns(String query) async {
    final isar = await db;
    if (query.isEmpty) return getAllSigns();

    return await isar.signs
        .filter()
        .titleContains(query, caseSensitive: false)
        .or()
        .categoryContains(query, caseSensitive: false)
        .findAll();
  }

  Future<List<Lesson>> filterLessons({String? query, String? category}) async {
    final isar = await db;

    final results = await isar.lessons
        .filter()
        .optional(
          query != null && query.isNotEmpty,
          (q) => q.titleContains(query!, caseSensitive: false),
        )
        .optional(
          category != null && category != "Difficulty Level",
          (q) => q.levelEqualTo(category!, caseSensitive: false),
        )
        .build()
        .findAll();

    return results;
  }

  // Save or Update a single sign
  Future<void> saveSign(Sign sign) async {
    final isar = await db;
    await isar.writeTxn(() async {
      await isar.signs.put(sign);
    });
  }
}
