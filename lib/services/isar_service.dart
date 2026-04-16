// providers.dart
import 'dart:io';

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
          'videoUrl': 'https://youtu.be/iYpTJ5cEl9Y?si=B1WP_YUBMsjEdRMr',
          'videoId': 'iYpTJ5cEl9Y',
        },
        {
          'id': 2,
          'title': 'Letter B',
          'category': 'Alphabet',
          'imagePath': 'assets/images/lessons/daily_conversation.png',
          'videoUrl': 'https://youtu.be/e6MYgcbUKqQ?si=PUcl1r4duqdTzSA8',
          'videoId': 'e6MYgcbUKqQ',
        },
        {
          'id': 3,
          'title': 'Number 1',
          'category': 'Numbers',
          'imagePath': 'assets/images/lessons/daily_conversation.png',
          'videoId': 'iYpTJ5cEl9Y',
        },
        {
          'id': 4,
          'title': 'Hello',
          'category': 'Greetings',
          'imagePath': 'assets/images/lessons/daily_conversation.png',
          'videoId': 'iYpTJ5cEl9Y',
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
          ..title = "Greetings in FSL"
          ..description =
              "Learn basic greetings in Filipino Sign Language, demonstrated step by step."
          ..videoUrl = "assets/videos/sample_portrait_video.mp4"
          ..comments = [
            Comment()
              ..userId = 101
              ..text = "Very clear demonstration, thank you!",
            Comment()
              ..userId = 102
              ..text = "I can follow along easily 😃",
          ]
          ..approves = 2
          ..uploaderId = 1
          ..isApprovedByCurrentUser = true,

        CommunityVideo()
          ..id = 2
          ..title = "FSL: Common Everyday Phrases"
          ..description =
              "A quick guide to commonly used Filipino Sign Language phrases in daily conversation."
          ..videoUrl = "assets/videos/sample_landscape_video.mp4"
          ..comments = [
            Comment()
              ..userId = 103
              ..text = "This helps a lot for practicing with friends!",
            Comment()
              ..userId = 104
              ..text = "Can you make a video for questions too?",
            Comment()
              ..userId = 105
              ..text = "Super helpful! Thank you 👐",
          ]
          ..approves = 2
          ..uploaderId = 2
          ..isApprovedByCurrentUser = false,

        CommunityVideo()
          ..id = 3
          ..title = "FSL Alphabet Practice"
          ..description =
              "Master the FSL alphabet with this step-by-step demonstration and practice guide."
          ..videoUrl = "assets/videos/sample_portrait_video.mp4"
          ..comments = [
            Comment()
              ..userId = 106
              ..text = "Perfect for daily practice!",
            Comment()
              ..userId = 107
              ..text = "Love the slow motion for tricky letters 🔥",
          ]
          ..approves = 21
          ..uploaderId = 3
          ..isApprovedByCurrentUser = true,

        CommunityVideo()
          ..id = 4
          ..title = "Community FSL Storytelling"
          ..description =
              "Watch members of our FSL community share short stories using Filipino Sign Language."
          ..videoUrl = "assets/videos/sample_landscape_video.mp4"
          ..comments = [
            Comment()
              ..userId = 108
              ..text = "Amazing storytelling! Learned new expressions.",
            Comment()
              ..userId = 109
              ..text = "Great job everyone, so inspiring! 👏",
          ]
          ..approves = 12
          ..uploaderId = 1
          ..isApprovedByCurrentUser = false,
      ];

      // Seed signs
      final initialSigns = allSigns.map((sign) {
        return Sign()
          ..title = sign['title']
          ..category = sign['category']
          ..imagePath = sign['imagePath']
          ..videoUrl =
              sign['videoUrl'] ?? 'assets/videos/sample_landscape_video.mp4'
          ..videoId = sign['videoId'];
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
        // Uploaders used by seeded community videos
        User()
          ..id = 2
          ..name = 'Uploader Two'
          ..email = 'uploader2@example.com'
          ..password = 'password123',
        User()
          ..id = 3
          ..name = 'Uploader Three'
          ..email = 'uploader3@example.com'
          ..password = 'password123',
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

  /// Community videos that are still pending approval.
  ///
  /// Predicate: `approves < threshold` AND `uploaderId != excludeUploaderId`.
  Future<List<CommunityVideo>> getUnapprovedCommunityVideos({
    required int threshold,
    required int excludeUploaderId,
  }) async {
    final isar = await db;

    final lower = await isar.communityVideos
        .filter()
        .approvesLessThan(threshold)
        .uploaderIdLessThan(excludeUploaderId)
        .findAll();

    final higher = await isar.communityVideos
        .filter()
        .approvesLessThan(threshold)
        .uploaderIdGreaterThan(excludeUploaderId)
        .findAll();

    return [...lower, ...higher];
  }

  /// Ensures there is at least one pending-approval community video available
  /// for the Unapproved tab to show.
  ///
  /// If none exist (using the same predicate as `getUnapprovedCommunityVideos`),
  /// inserts a single stable sample record into Isar.
  Future<void> ensureFallbackUnapprovedCommunityVideoExists({
    required int threshold,
    required int excludeUploaderId,
  }) async {
    final isar = await db;

    // Fast existence check using the same predicate.
    final anyLower = await isar.communityVideos
        .filter()
        .approvesLessThan(threshold)
        .uploaderIdLessThan(excludeUploaderId)
        .limit(1)
        .findAll();

    if (anyLower.isNotEmpty) return;

    final anyHigher = await isar.communityVideos
        .filter()
        .approvesLessThan(threshold)
        .uploaderIdGreaterThan(excludeUploaderId)
        .limit(1)
        .findAll();

    if (anyHigher.isNotEmpty) return;

    // Stable signature: title + uploaderId.
    const fallbackTitle = '[Sample] Pending approval';
    const fallbackVideoUrl = 'assets/videos/sample_portrait_video.mp4';
    const fallbackDescription =
        'Sample community video inserted locally so the Unapproved tab is not empty.';

    // Ensure the fallback uploader is never the excluded uploader.
    final fallbackUploaderId = excludeUploaderId == 9999 ? 9998 : 9999;
    final desiredApproves = threshold > 0 ? threshold - 1 : 0;

    final existingFallback = await isar.communityVideos
        .filter()
        .titleEqualTo(fallbackTitle)
        .uploaderIdEqualTo(fallbackUploaderId)
        .limit(1)
        .findFirst();

    await isar.writeTxn(() async {
      if (existingFallback == null) {
        final fallback = CommunityVideo()
          ..title = fallbackTitle
          ..description = fallbackDescription
          ..videoUrl = fallbackVideoUrl
          ..comments = <Comment>[]
          ..approves = desiredApproves
          ..uploaderId = fallbackUploaderId
          ..isApprovedByCurrentUser = false;

        await isar.communityVideos.put(fallback);
        return;
      }

      // If the fallback exists but was modified (e.g., user approved it),
      // normalize it back to a "pending" state.
      var needsUpdate = false;

      if (existingFallback.videoUrl != fallbackVideoUrl) {
        existingFallback.videoUrl = fallbackVideoUrl;
        needsUpdate = true;
      }
      if (existingFallback.description != fallbackDescription) {
        existingFallback.description = fallbackDescription;
        needsUpdate = true;
      }
      if (existingFallback.comments.isNotEmpty) {
        existingFallback.comments = <Comment>[];
        needsUpdate = true;
      }
      if (existingFallback.approves != desiredApproves) {
        existingFallback.approves = desiredApproves;
        needsUpdate = true;
      }
      if (existingFallback.isApprovedByCurrentUser != false) {
        existingFallback.isApprovedByCurrentUser = false;
        needsUpdate = true;
      }

      if (needsUpdate) {
        await isar.communityVideos.put(existingFallback);
      }
    });
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

  // Get bookmarked signs
  Future<List<Sign>> getBookmarkedSigns() async {
    final isar = await db;
    return await isar.signs.filter().isBookmarkedEqualTo(true).findAll();
  }

  // Toggle bookmark status for a sign
  Future<Sign?> toggleSignBookmark(Id signId) async {
    final isar = await db;
    Sign? updated;

    await isar.writeTxn(() async {
      final sign = await isar.signs.get(signId);
      if (sign == null) return;
      sign.isBookmarked = !sign.isBookmarked;
      await isar.signs.put(sign);
      updated = sign;
    });

    return updated;
  }

  // Get signs by category
  Future<List<Sign>> getSignsByCategory(String category) async {
    final isar = await db;
    return await isar.signs
        .filter()
        .categoryEqualTo(category, caseSensitive: false)
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

  // Toggle approve status for a video
  Future<void> toggleApprove(int videoId) async {
    final isar = await db;

    await isar.writeTxn(() async {
      final video = await isar.communityVideos.get(videoId);
      if (video != null) {
        if (!video.isApprovedByCurrentUser) {
          // If NOT approved, user clicks approve -> toggle to true and decrease approvals
          video.isApprovedByCurrentUser = true;
          video.approves = video.approves + 1;
        } else {
          // If already approved, user clicks un-approve -> toggle to false and increase approvals
          video.isApprovedByCurrentUser = false;
          video.approves = video.approves - 1;
        }
        await isar.communityVideos.put(video);
      }
    });
  }

  Future<void> uploadCommunityVideo({
    required File videoFile,
    required String description,
    required int uploaderId,
  }) async {
    final isar = await db;
    final docsDir = await getApplicationDocumentsDirectory();

    final uploadsDir = Directory('${docsDir.path}/uploads');
    if (!await uploadsDir.exists()) {
      await uploadsDir.create(recursive: true);
    }

    final normalizedDescription = description
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
    final derivedTitle = normalizedDescription.isEmpty
        ? 'User upload'
        : (normalizedDescription.length <= 40
              ? normalizedDescription
              : normalizedDescription.substring(0, 40));

    final originalPath = videoFile.path;
    final lastSeparator = originalPath.lastIndexOf(Platform.pathSeparator);
    final lastDot = originalPath.lastIndexOf('.');
    final extension = (lastDot > lastSeparator)
        ? originalPath.substring(lastDot)
        : '.mp4';
    final filename =
        'community_${DateTime.now().millisecondsSinceEpoch}$extension';
    final destinationPath = '${uploadsDir.path}/$filename';

    final copiedFile = await videoFile.copy(destinationPath);

    final newVideo = CommunityVideo()
      ..title = derivedTitle
      ..description = description
      ..videoUrl = copiedFile.path
      ..comments = <Comment>[]
      ..approves = 0
      ..uploaderId = uploaderId
      ..isApprovedByCurrentUser = false;

    await isar.writeTxn(() async {
      await isar.communityVideos.put(newVideo);
    });
  }

  Future<void> editCommunityVideoDescription(
    int videoId,
    String description,
  ) async {
    final isar = await db;

    final normalizedDescription = description
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
    final derivedTitle = normalizedDescription.isEmpty
        ? 'User upload'
        : (normalizedDescription.length <= 40
              ? normalizedDescription
              : normalizedDescription.substring(0, 40));

    await isar.writeTxn(() async {
      final video = await isar.communityVideos.get(videoId);
      if (video == null) return;

      video.description = normalizedDescription;
      video.title = derivedTitle;
      await isar.communityVideos.put(video);
    });
  }

  Future<void> deleteCommunityVideo(int videoId) async {
    final isar = await db;

    final video = await isar.communityVideos.get(videoId);
    if (video == null) return;

    final videoUrl = video.videoUrl;

    await isar.writeTxn(() async {
      await isar.communityVideos.delete(videoId);
    });

    await _tryDeleteUploadedCommunityVideoFile(videoUrl);
  }

  Future<void> _tryDeleteUploadedCommunityVideoFile(String videoUrl) async {
    try {
      if (videoUrl.isEmpty) return;

      final docsDir = await getApplicationDocumentsDirectory();
      final uploadsDir = Directory('${docsDir.path}/uploads');

      final uploadsPath = uploadsDir.absolute.path;
      final file = File(videoUrl);
      final filePath = file.absolute.path;

      final isInsideUploads = filePath.startsWith(
        '$uploadsPath${Platform.pathSeparator}',
      );
      if (!isInsideUploads) return;

      if (await file.exists()) {
        await file.delete();
      }
    } catch (_) {
      // Ignore failures (missing perms, already deleted, etc.)
    }
  }

  // Get a user by ID
  Future<User?> getUserById(int userId) async {
    final isar = await db;
    return await isar.users.get(userId);
  }

  // Batch fetch uploader names for the given ids.
  // Missing users are omitted from the returned map.
  Future<Map<int, String>> getUploaderNamesByIds(List<int> uploaderIds) async {
    final ids = uploaderIds.where((id) => id > 0).toList();
    if (ids.isEmpty) return {};

    final isar = await db;
    final uniqueIds = ids.toSet().toList();
    final users = await isar.users.getAll(uniqueIds);

    final Map<int, String> result = {};
    for (var i = 0; i < uniqueIds.length; i++) {
      final user = users[i];
      if (user == null) continue;
      result[uniqueIds[i]] = user.name;
    }
    return result;
  }
}
