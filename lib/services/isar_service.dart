// providers.dart
import 'dart:io';

import 'package:isar_community/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:signmirror_flutter/models/user.dart';
import 'package:signmirror_flutter/models/community_video.dart';
import 'package:signmirror_flutter/models/lesson.dart';
import 'package:signmirror_flutter/models/sign.dart';
import 'package:signmirror_flutter/utils/profile_placeholder.dart';

/// Thrown when attempting to register with an email that already exists.
class EmailAlreadyExistsException implements Exception {
  final String email;

  EmailAlreadyExistsException(this.email);

  @override
  String toString() =>
      'EmailAlreadyExistsException: A user with this email already exists ($email)';
}

class IsarService {
  late Future<Isar> db;

  static const String _legacyProfilePictureUrl =
      'assets/images/profile_picture.jpeg';

  IsarService() {
    db = openDB();
  }

  // Initialize the database
  Future<Isar> openDB() async {
    final dir = await getApplicationDocumentsDirectory();

    late final Isar isar;

    // Check if an instance is already open to avoid errors
    if (Isar.instanceNames.isEmpty) {
      isar = await Isar.open([
        SignSchema,
        LessonSchema,
        CommunityVideoSchema,
        UserSchema,
      ], directory: dir.path);

      // await resetDatabase();
      // OPTIONAL: Seed data if the database is brand new
      await _seedData(isar);
    } else {
      isar = Isar.getInstance()!;
    }

    // Idempotent migration/backfill: populate Filipino titles for known seeded signs.
    await _backfillSignFilipinoTitles(isar);

    // Idempotent migration/backfill: populate profile picture placeholders for users
    // that still have legacy/missing values.
    await _backfillUserProfilePictureUrls(isar);

    return isar;
  }

  bool _needsProfilePictureBackfill(User user) {
    final current = user.profilePictureUrl.trim();
    if (current.isEmpty) return true;
    if (current == _legacyProfilePictureUrl) return true;
    return false;
  }

  Future<void> _backfillUserProfilePictureUrls(Isar isar) async {
    final all = await isar.users.where().findAll();
    if (all.isEmpty) return;

    final toUpdate = <User>[];
    for (final user in all) {
      if (!_needsProfilePictureBackfill(user)) continue;

      final stableKey = user.email.trim().isNotEmpty
          ? user.email.trim().toLowerCase()
          : 'user:${user.id}';

      final placeholder = await pickRandomProfilePlaceholderAssetPath(
        stableKey: stableKey,
      );

      // Avoid an endless loop if we can only resolve to the legacy path.
      if (placeholder.trim().isEmpty) continue;
      if (placeholder == _legacyProfilePictureUrl) {
        continue;
      }

      user.profilePictureUrl = placeholder;
      toUpdate.add(user);
    }

    if (toUpdate.isEmpty) return;

    await isar.writeTxn(() async {
      await isar.users.putAll(toUpdate);
    });
  }

  // --- Sign title translations (seed + migration/backfill) ---

  /// Known seeded English titles -> Filipino titles.
  ///
  /// `Sign.title` remains the stable English identifier.
  static const Map<String, String> _seededTitleEnToFil = {
    'Letter A': 'Letrang A',
    'Letter B': 'Letrang B',
    'Number 1': 'Numero 1',
    'Hello': 'Kumusta',
    'Thank You': 'Salamat',
    'Help': 'Tulong',
    'Please': 'Pakiusap',
  };

  String? _filipinoTitleForEnglish(String englishTitle) {
    return _seededTitleEnToFil[englishTitle];
  }

  /// Backfills `Sign.titleFil` for existing databases without wiping/overwriting user data.
  ///
  /// Idempotent: only fills when `titleFil` is null/blank and a known mapping exists.
  Future<void> _backfillSignFilipinoTitles(Isar isar) async {
    final all = await isar.signs.where().findAll();
    if (all.isEmpty) return;

    final toUpdate = <Sign>[];
    for (final sign in all) {
      final current = sign.titleFil;
      if (current != null && current.trim().isNotEmpty) continue;

      final mapped = _filipinoTitleForEnglish(sign.title);
      if (mapped == null) continue;

      sign.titleFil = mapped;
      toUpdate.add(sign);
    }

    if (toUpdate.isEmpty) return;

    await isar.writeTxn(() async {
      await isar.signs.putAll(toUpdate);
    });
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
          'titleFil': 'Letrang A',
          'category': 'Alphabet',
          'imagePath': 'assets/images/lessons/daily_conversation.png',
          'videoUrl': 'assets/videos/signs/alphabet/a.mp4',
        },
        {
          'id': 2,
          'title': 'Letter B',
          'titleFil': 'Letrang B',
          'category': 'Alphabet',
          'imagePath': 'assets/images/lessons/daily_conversation.png',
          'videoUrl': 'assets/videos/signs/alphabet/b.mp4',
        },
        {
          'id': 21,
          'title': 'Letter C',
          'titleFil': 'Letrang C',
          'category': 'Alphabet',
          'imagePath': 'assets/images/lessons/daily_conversation.png',
          'videoUrl': 'assets/videos/signs/alphabet/c.mp4',
        },
        {
          'id': 22,
          'title': 'Letter D',
          'titleFil': 'Letrang D',
          'category': 'Alphabet',
          'imagePath': 'assets/images/lessons/daily_conversation.png',
          'videoUrl': 'assets/videos/signs/alphabet/d.mp4',
        },
        {
          'id': 23,
          'title': 'Letter E',
          'titleFil': 'Letrang E',
          'category': 'Alphabet',
          'imagePath': 'assets/images/lessons/daily_conversation.png',
          'videoUrl': 'assets/videos/signs/alphabet/e.mp4',
        },
        {
          'id': 3,
          'title': 'One',
          'titleFil': 'Isa',
          'category': 'Numbers',
          'imagePath': 'assets/images/lessons/daily_conversation.png',
          'videoUrl': 'assets/videos/signs/numbers/one.mp4',
        },
        {
          'id': 4,
          'title': 'Two',
          'titleFil': 'Dalawa',
          'category': 'Numbers',
          'imagePath': 'assets/images/lessons/daily_conversation.png',
          'videoUrl': 'assets/videos/signs/numbers/two.mp4',
        },
        {
          'id': 5,
          'title': 'Three',
          'titleFil': 'Tatlo',
          'category': 'Numbers',
          'imagePath': 'assets/images/lessons/daily_conversation.png',
          'videoUrl': 'assets/videos/signs/numbers/three.mp4',
        },
        {
          'id': 6,
          'title': 'Four',
          'titleFil': 'Apat',
          'category': 'Numbers',
          'imagePath': 'assets/images/lessons/daily_conversation.png',
          'videoUrl': 'assets/videos/signs/numbers/four.mp4',
        },
        {
          'id': 7,
          'title': 'Five',
          'titleFil': 'Lima',
          'category': 'Numbers',
          'imagePath': 'assets/images/lessons/daily_conversation.png',
          'videoUrl': 'assets/videos/signs/numbers/five.mp4',
        },
        {
          'id': 8,
          'title': 'Six',
          'titleFil': 'Anim',
          'category': 'Numbers',
          'imagePath': 'assets/images/lessons/daily_conversation.png',
          'videoUrl': 'assets/videos/signs/numbers/six.mp4',
        },

        {
          'id': 8,
          'title': 'Hello',
          'titleFil': 'Kumusta',
          'category': 'Basic Gestures',
          'imagePath': 'assets/images/lessons/daily_conversation.png',
          'videoUrl': 'assets/videos/signs/basics/hello.mp4',
        },
        {
          'id': 9,
          'title': 'How are you?',
          'titleFil': 'Kumusta ka?',
          'category': 'Daily Conversations',
          'imagePath': 'assets/images/lessons/daily_conversation.png',
          'videoUrl': 'assets/videos/signs/basics/howareyou.mp4',
        },
        {
          'id': 10,
          'title': 'Nice to meet you',
          'titleFil': 'Ikinagagalak kitang makilala?',
          'category': 'Daily Conversations',
          'imagePath': 'assets/images/lessons/daily_conversation.png',
          'videoUrl': 'assets/videos/signs/basics/nicetomeetyou.mp4',
        },
        {
          'id': 11,
          'title': 'No',
          'titleFil': 'Hindi',
          'category': 'Basic Gestures',
          'imagePath': 'assets/images/lessons/daily_conversation.png',
          'videoUrl': 'assets/videos/signs/basics/no.mp4',
        },
        {
          'id': 12,
          'title': 'Yes',
          'titleFil': 'Oo',
          'category': 'Basic Gestures',
          'imagePath': 'assets/images/lessons/daily_conversation.png',
          'videoUrl': 'assets/videos/signs/basics/yes.mp4',
        },
        {
          'id': 12,
          'title': 'What is your name?',
          'titleFil': 'Ano ang pangalan mo?',
          'category': 'Daily Conversations',
          'imagePath': 'assets/images/lessons/daily_conversation.png',
          'videoUrl': 'assets/videos/signs/basics/whatisyourname.mp4',
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
          ..titleFil = sign['titleFil']
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
          ..password = 'password123'
          ..profilePictureUrl = 'assets/images/profile/profile_picture.jpg',
        User()
          ..id = 3
          ..name = 'Uploader Three'
          ..email = 'uploader3@example.com'
          ..password = 'password123'
          ..profilePictureUrl = 'assets/images/profile/profile_picture.jpg',
        User()
          ..id = 101
          ..name = 'Alice'
          ..email = 'alice@example.com'
          ..password = 'password123'
          ..profilePictureUrl = 'assets/images/profile/profile_picture.jpg',
        User()
          ..id = 102
          ..name = 'Bob'
          ..email = 'bob@example.com'
          ..password = 'password123'
          ..profilePictureUrl = 'assets/images/profile/profile_picture.jpg',
        User()
          ..id = 103
          ..name = 'Charlie'
          ..email = 'charlie@example.com'
          ..password = 'password123'
          ..profilePictureUrl = 'assets/images/profile/profile_picture.jpg',
        User()
          ..id = 104
          ..name = 'David'
          ..email = 'david@example.com'
          ..password = 'password123'
          ..profilePictureUrl = 'assets/images/profile/profile_picture.jpg',
        User()
          ..id = 105
          ..name = 'Eve'
          ..email = 'eve@example.com'
          ..password = 'password123'
          ..profilePictureUrl = 'assets/images/profile/profile_picture.jpg',
        User()
          ..id = 106
          ..name = 'Frank'
          ..email = 'frank@example.com'
          ..password = 'password123'
          ..profilePictureUrl = 'assets/images/profile/profile_picture.jpg',
        User()
          ..id = 107
          ..name = 'Grace'
          ..email = 'grace@example.com'
          ..password = 'password123'
          ..profilePictureUrl = 'assets/images/profile/profile_picture.jpg',
        User()
          ..id = 108
          ..name = 'Heidi'
          ..email = 'heidi@example.com'
          ..password = 'password123'
          ..profilePictureUrl = 'assets/images/profile/profile_picture.jpg',
        User()
          ..id = 109
          ..name = 'Ivan'
          ..email = 'ivan@example.com'
          ..password = 'password123'
          ..profilePictureUrl = 'assets/images/profile/profile_picture.jpg',
        // Current user
        User()
          ..id = 1
          ..name = 'Current User'
          ..email = 'user@example.com'
          ..password = 'password123'
          ..profilePictureUrl = 'assets/images/profile/profile_picture.jpg',
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

  // Search signs by title/category (Case Insensitive)
  Future<List<Sign>> searchSigns(String query) async {
    final isar = await db;
    if (query.isEmpty) return getAllSigns();

    return await isar.signs
        .filter()
        .titleContains(query, caseSensitive: false)
        .or()
        .titleFilContains(query, caseSensitive: false)
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

  String _normalizeCategoryKey(String value) {
    return value.trim().toLowerCase();
  }

  /// Returns sign counts keyed by *normalized* category.
  ///
  /// Normalization: `trim().toLowerCase()`.
  ///
  /// Notes:
  /// - Counts are case-insensitive and whitespace-tolerant for both the input
  ///   categories and the stored `Sign.category` values.
  /// - Empty/blank category strings in [categories] are ignored.
  /// - This method returns an entry for every non-empty requested category,
  ///   defaulting to `0` when there are no matching signs.
  Future<Map<String, int>> getSignCountsByCategories(
    Iterable<String> categories,
  ) async {
    final normalizedRequested = <String>[];
    final seen = <String>{};

    for (final category in categories) {
      final key = _normalizeCategoryKey(category);
      if (key.isEmpty) continue;
      if (seen.add(key)) {
        normalizedRequested.add(key);
      }
    }

    final counts = <String, int>{for (final key in normalizedRequested) key: 0};
    if (counts.isEmpty) return counts;

    final isar = await db;
    final signs = await isar.signs.where().findAll();

    for (final sign in signs) {
      final key = _normalizeCategoryKey(sign.category);
      final current = counts[key];
      if (current == null) continue;
      counts[key] = current + 1;
    }

    return counts;
  }

  Future<List<Lesson>> filterLessons({String? query, String? category}) async {
    final isar = await db;

    final normalizedQuery = query?.trim() ?? '';
    final normalizedCategory = category?.trim();

    final hasQuery = normalizedQuery.isNotEmpty;
    final hasCategory =
        normalizedCategory != null &&
        normalizedCategory.isNotEmpty &&
        normalizedCategory.toLowerCase() != 'all';

    final results = await isar.lessons
        .filter()
        .optional(
          hasQuery,
          (q) => q.group(
            (q) => q.titleContains(normalizedQuery, caseSensitive: false),
          ),
        )
        .optional(
          hasCategory,
          (q) => q.levelEqualTo(normalizedCategory!, caseSensitive: false),
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

  // --- Authentication / registration (Isar-backed) ---

  String _normalizeEmail(String email) => email.trim().toLowerCase();

  /// Finds a user by email (trimmed + lowercased).
  ///
  /// Returns null when email is blank or no user is found.
  Future<User?> getUserByEmail(String email) async {
    final normalizedEmail = _normalizeEmail(email);
    if (normalizedEmail.isEmpty) return null;

    final isar = await db;
    return await isar.users
        .filter()
        .emailEqualTo(normalizedEmail, caseSensitive: false)
        .findFirst();
  }

  /// Registers a new user and persists it.
  ///
  /// - Email is normalized (trim/lowercase).
  /// - Throws [EmailAlreadyExistsException] if email already exists.
  Future<User> registerUser(String name, String email, String password) async {
    final normalizedEmail = _normalizeEmail(email);
    final normalizedName = name.trim();

    if (normalizedEmail.isEmpty) {
      throw ArgumentError.value(email, 'email', 'Email must not be empty');
    }
    if (normalizedName.isEmpty) {
      throw ArgumentError.value(name, 'name', 'Name must not be empty');
    }

    final isar = await db;

    return await isar.writeTxn<User>(() async {
      final existing = await isar.users
          .filter()
          .emailEqualTo(normalizedEmail, caseSensitive: false)
          .findFirst();
      if (existing != null) {
        throw EmailAlreadyExistsException(normalizedEmail);
      }

      final user = User()
        ..name = normalizedName
        ..email = normalizedEmail
        ..password = password
        ..profilePictureUrl = await pickRandomProfilePlaceholderAssetPath(
          stableKey: normalizedEmail,
        );

      await isar.users.put(user);
      return user;
    });
  }

  /// Authenticates a user by email + password.
  ///
  /// Returns the matching [User] when valid, otherwise null.
  Future<User?> authenticateUser(String email, String password) async {
    final normalizedEmail = _normalizeEmail(email);
    if (normalizedEmail.isEmpty) return null;

    final isar = await db;
    final user = await isar.users
        .filter()
        .emailEqualTo(normalizedEmail, caseSensitive: false)
        .findFirst();

    if (user == null) return null;
    if (user.password != password) return null;
    return user;
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
