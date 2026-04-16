import 'package:signmirror_flutter/models/lesson.dart';

class LessonsState {
  final List<Lesson> lessons;
  final String query;
  final String difficulty;

  LessonsState({
    required this.lessons,
    this.query = '',
    // Language-agnostic sentinel for "no difficulty filter".
    this.difficulty = '',
  });

  // Helper to update only one piece of state at a time
  LessonsState copyWith({
    List<Lesson>? lessons,
    String? query,
    String? difficulty,
  }) {
    return LessonsState(
      lessons: lessons ?? this.lessons,
      query: query ?? this.query,
      difficulty: difficulty ?? this.difficulty,
    );
  }
}
