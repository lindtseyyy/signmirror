// providers.dart
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:signmirror_flutter/models/community_video.dart';
import 'package:signmirror_flutter/models/lesson.dart';
import 'package:signmirror_flutter/models/practice_stats.dart';
import 'package:signmirror_flutter/models/sign.dart';
import 'package:signmirror_flutter/state/lesson/lesson_state.dart';
import 'package:signmirror_flutter/services/practice_stats_service.dart';
import '../services/isar_service.dart';

// This provides the actual database logic class
final isarServiceProvider = Provider((ref) => IsarService());

// This provides a dynamic list of signs that updates when searched
final signsProvider = StateNotifierProvider<SignsNotifier, List<Sign>>((ref) {
  final service = ref.watch(isarServiceProvider);
  return SignsNotifier(service);
});

class SignsNotifier extends StateNotifier<List<Sign>> {
  final IsarService _service;
  String _lastQuery = '';

  SignsNotifier(this._service) : super([]) {
    loadAll(); // Load initial data
  }

  Future<void> loadAll() async {
    _lastQuery = '';
    state = await _service.getAllSigns();
  }

  Future<void> search(String query) async {
    _lastQuery = query;
    state = await _service.searchSigns(query);
  }

  Future<void> toggleBookmark(Sign sign) async {
    await _service.toggleSignBookmark(sign.id);

    if (_lastQuery.isEmpty) {
      await loadAll();
    } else {
      await search(_lastQuery);
    }
  }
}

// This provides a dynamic list of bookmarked signs
final bookmarkedSignsProvider =
    StateNotifierProvider<BookmarkedSignsNotifier, List<Sign>>((ref) {
      final service = ref.watch(isarServiceProvider);
      return BookmarkedSignsNotifier(service);
    });

class BookmarkedSignsNotifier extends StateNotifier<List<Sign>> {
  final IsarService _service;

  BookmarkedSignsNotifier(this._service) : super([]) {
    loadAll();
  }

  Future<void> loadAll() async {
    state = await _service.getBookmarkedSigns();
  }

  Future<void> toggleBookmark(Sign sign) async {
    await _service.toggleSignBookmark(sign.id);
    await loadAll();
  }
}

// This provides a dynamic list of signs that updates when searched
final lessonsProvider = StateNotifierProvider<LessonsNotifier, LessonsState>((
  ref,
) {
  final service = ref.watch(isarServiceProvider);
  return LessonsNotifier(service);
});

class LessonsNotifier extends StateNotifier<LessonsState> {
  final IsarService _service;

  LessonsNotifier(this._service) : super(LessonsState(lessons: [])) {
    loadAll(); // Load initial data
  }

  String _normalizeLessonTitleKey(String value) {
    return value.trim().toLowerCase();
  }

  Future<List<Lesson>> _withComputedCounts(List<Lesson> lessons) async {
    if (lessons.isEmpty) return lessons;

    final titles = lessons.map((l) => l.title);
    final countsByCategory = await _service.getSignCountsByCategories(titles);

    for (final lesson in lessons) {
      final key = _normalizeLessonTitleKey(lesson.title);
      lesson.count = countsByCategory[key] ?? 0;
    }

    return lessons;
  }

  Future<void> loadAll() async {
    final lessons = await _service.getAllLessons();
    state = state.copyWith(lessons: await _withComputedCounts(lessons));
  }

  // The Master Filter Function
  Future<void> _applyFilters() async {
    final results = await _service.filterLessons(
      query: state.query,
      category: state.difficulty,
    );
    state = state.copyWith(lessons: await _withComputedCounts(results));
  }

  void updateSearch(String newQuery) {
    state = state.copyWith(query: newQuery);
    _applyFilters();
  }

  void updateDifficulty(String newDiff) {
    state = state.copyWith(difficulty: newDiff);
    _applyFilters();
  }
}

// This provides a dynamic list of signs that updates when searched
final communityVideoProvider =
    StateNotifierProvider<CommunityVideoNotifier, List<CommunityVideo>>((ref) {
      final service = ref.watch(isarServiceProvider);
      return CommunityVideoNotifier(service);
    });

class CommunityVideoNotifier extends StateNotifier<List<CommunityVideo>> {
  final IsarService _service;

  CommunityVideoNotifier(this._service) : super([]) {
    loadAll(); // Load initial data
  }

  Future<void> loadAll() async {
    state = await _service.getAllCommunityVideos();
  }

  Future<void> addComment(int videoId, int userId, String text) async {
    final comment = Comment()
      ..userId = userId
      ..text = text;
    await _service.addCommentToVideo(videoId, comment);
    await loadAll(); // Refresh the state
  }

  Future<void> toggleApprove(int videoId) async {
    await _service.toggleApprove(videoId);
    await loadAll(); // Refresh the state
  }

  Future<void> uploadVideo({
    required File videoFile,
    required String description,
    required int uploaderId,
  }) async {
    await _service.uploadCommunityVideo(
      videoFile: videoFile,
      description: description,
      uploaderId: uploaderId,
    );
    await loadAll();
  }

  Future<void> editVideoDescription(int videoId, String description) async {
    await _service.editCommunityVideoDescription(videoId, description);
    await loadAll();
  }

  Future<void> ensureFallbackUnapprovedVideo({
    required int threshold,
    required int excludeUploaderId,
  }) {
    // If this is triggered from a widget build/lifecycle, mutating `state`
    // synchronously can throw. Scheduling avoids that class of errors.
    return Future(() async {
      try {
        await _service.ensureFallbackUnapprovedCommunityVideoExists(
          threshold: threshold,
          excludeUploaderId: excludeUploaderId,
        );
      } catch (_) {
        // Best-effort: don't crash the UI if seeding fails.
      }

      try {
        await loadAll();
      } catch (_) {
        // Ignore refresh failures for the same reason.
      }
    });
  }

  Future<void> deleteVideo(int videoId) async {
    await _service.deleteCommunityVideo(videoId);
    await loadAll();
  }
}

// Exposes uploader names for the currently loaded community video list.
final uploaderNamesProvider = FutureProvider<Map<int, String>>((ref) async {
  final videos = ref.watch(communityVideoProvider);
  final service = ref.watch(isarServiceProvider);

  final uploaderIds = videos
      .map((v) => v.uploaderId)
      .where((id) => id > 0)
      .toSet()
      .toList();
  if (uploaderIds.isEmpty) return {};

  // Missing users are omitted from the map.
  return service.getUploaderNamesByIds(uploaderIds);
});

final practiceStatsServiceProvider = Provider<PracticeStatsService>((ref) {
  return PracticeStatsService();
});

final practiceStatsProvider =
    StateNotifierProvider<PracticeStatsNotifier, AsyncValue<PracticeStats>>((
      ref,
    ) {
      return PracticeStatsNotifier(ref.watch(practiceStatsServiceProvider));
    });

class PracticeStatsNotifier extends StateNotifier<AsyncValue<PracticeStats>> {
  final PracticeStatsService _service;

  PracticeStatsNotifier(this._service) : super(const AsyncValue.loading()) {
    load();
  }

  Future<void> load() async {
    try {
      final stats = await _service.load();
      state = AsyncValue.data(stats);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> recordAttempt({
    required String signTitle,
    required double accuracyRate,
  }) {
    // If this gets triggered by a widget lifecycle (e.g. dispose), updating
    // `state` synchronously can throw: "Tried to modify a provider while the
    // widget tree was building".
    // Scheduling the mutation avoids that class of errors.
    return Future(() async {
      try {
        state = const AsyncValue.loading();
        final stats = await _service.recordAttempt(
          signTitle: signTitle,
          accuracyRate: accuracyRate,
        );
        state = AsyncValue.data(stats);
      } catch (e, st) {
        state = AsyncValue.error(e, st);
      }
    });
  }
}
