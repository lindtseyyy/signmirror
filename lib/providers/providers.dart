// providers.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:signmirror_flutter/models/community_video.dart';
import 'package:signmirror_flutter/models/sign.dart';
import 'package:signmirror_flutter/state/lesson/lesson_state.dart';
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

  SignsNotifier(this._service) : super([]) {
    loadAll(); // Load initial data
  }

  Future<void> loadAll() async {
    state = await _service.getAllSigns();
  }

  Future<void> search(String query) async {
    state = await _service.searchSigns(query);
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

  Future<void> loadAll() async {
    state = state.copyWith(lessons: await _service.getAllLessons());
  }

  // The Master Filter Function
  Future<void> _applyFilters() async {
    final results = await _service.filterLessons(
      query: state.query,
      category: state.difficulty,
    );
    state = state.copyWith(lessons: results);
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
}
