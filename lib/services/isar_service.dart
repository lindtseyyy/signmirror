// providers.dart
import 'package:isar_community/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:signmirror_flutter/models/user.dart';
import 'package:signmirror_flutter/models/community_video.dart';
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
        CommunityVideoSchema,
        UserSchema,
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

      final sampleVideos = [
        CommunityVideo()
          ..id = 1
          ..title = "Sunset Timelapse"
          ..description = "A relaxing sunset view at the beach."
          ..videoUrl = "assets/videos/sample_portrait_video.mp4"
          ..comments = [
            Comment()
              ..userId = 101
              ..text = "Ang ganda ng view!",
            Comment()
              ..userId = 102
              ..text = "So relaxing 😌",
          ]
          ..approves = 15
          ..uploaderId = 1
          ..isApprovedByCurrentUser = true, // Default value for new videos

        CommunityVideo()
          ..id = 2
          ..title = "Street Food Adventure"
          ..description = "Trying different street foods in Manila."
          ..videoUrl = "assets/videos/sample_landscape_video.mp4"
          ..comments = [
            Comment()
              ..userId = 103
              ..text = "Sarap nito!",
            Comment()
              ..userId = 104
              ..text = "Where is this located?",
            Comment()
              ..userId = 105
              ..text = "Gutom tuloy ako 🤤",
          ]
          ..approves = 32
          ..uploaderId = 2
          ..isApprovedByCurrentUser = false, // Default value for new videos

        CommunityVideo()
          ..id = 3
          ..title = "Basketball Highlights"
          ..description = "Top plays from our barangay league."
          ..videoUrl = "assets/videos/sample_portrait_video.mp4"
          ..comments = [
            Comment()
              ..userId = 106
              ..text = "Nice shot!",
            Comment()
              ..userId = 107
              ..text = "Solid defense 🔥",
          ]
          ..approves = 21
          ..uploaderId = 3
          ..isApprovedByCurrentUser = true, // Default value for new videos

        CommunityVideo()
          ..id = 4
          ..title = "Coding Setup Tour"
          ..description = "My simple programming workspace."
          ..videoUrl = "assets/videos/sample_landscape_video.mp4"
          ..comments = [
            Comment()
              ..userId = 108
              ..text = "Clean setup!",
            Comment()
              ..userId = 109
              ..text = "What monitor is that?",
          ]
          ..approves = 12
          ..uploaderId = 1
          ..isApprovedByCurrentUser = false, // Default value for new videos
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

      final initialCommunityVideos = sampleVideos;

      // Seed mock users for comments
      final initialUsers = [
        User()
          ..id = 101
          ..name = 'Alice'
          ..email = 'alice@example.com'
          ..password = 'password123',
        User()
          ..id = 102
          ..name = 'Bob'
          ..email = 'bob@example.com'
          ..password = 'password123',
        User()
          ..id = 103
          ..name = 'Charlie'
          ..email = 'charlie@example.com'
          ..password = 'password123',
        User()
          ..id = 104
          ..name = 'David'
          ..email = 'david@example.com'
          ..password = 'password123',
        User()
          ..id = 105
          ..name = 'Eve'
          ..email = 'eve@example.com'
          ..password = 'password123',
        User()
          ..id = 106
          ..name = 'Frank'
          ..email = 'frank@example.com'
          ..password = 'password123',
        User()
          ..id = 107
          ..name = 'Grace'
          ..email = 'grace@example.com'
          ..password = 'password123',
        User()
          ..id = 108
          ..name = 'Heidi'
          ..email = 'heidi@example.com'
          ..password = 'password123',
        User()
          ..id = 109
          ..name = 'Ivan'
          ..email = 'ivan@example.com'
          ..password = 'password123',
        // Current user
        User()
          ..id = 1
          ..name = 'Current User'
          ..email = 'user@example.com'
          ..password = 'password123',
      ];

      await isar.writeTxn(() async {
        await isar.lessons.putAll(initialLessons);
        await isar.signs.putAll(initialSigns);
        await isar.communityVideos.putAll(initialCommunityVideos);
        await isar.users.putAll(initialUsers);
      });

      print("Database seeded with ${initialLessons.length} lesson items.");
      print("Database seeded with ${initialSigns.length} sign items.");
      print(
        "Database seeded with ${initialCommunityVideos.length} community video items.",
      );
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

  // Get all lessons
  Future<List<CommunityVideo>> getAllCommunityVideos() async {
    final isar = await db;
    return await isar.communityVideos.where().findAll();
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
          (q) => q.group((q) => q.titleContains(query!, caseSensitive: false)),
        )
        .optional(
          category != null &&
              category != "Difficulty Level" &&
              category != "All" &&
              category.isNotEmpty,
          (q) => q.levelEqualTo(category!, caseSensitive: false),
        )
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

  // Add a comment to a community video
  Future<void> addCommentToVideo(int videoId, Comment comment) async {
    final isar = await db;

    await isar.writeTxn(() async {
      final video = await isar.communityVideos.get(videoId);
      if (video != null) {
        video.comments = [...video.comments, comment];
        await isar.communityVideos.put(video);
      }
    });
  }

  // Get a user by ID
  Future<User?> getUserById(int userId) async {
    final isar = await db;
    return await isar.users.get(userId);
  }
}
