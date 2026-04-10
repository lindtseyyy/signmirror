import 'package:shared_preferences/shared_preferences.dart';
import 'package:signmirror_flutter/models/practice_stats.dart';

class PracticeStatsService {
  static const _prefsKey = 'practice_stats_v1';

  Future<PracticeStats> load() async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString(_prefsKey);
    if (json == null || json.trim().isEmpty) {
      return PracticeStats.empty();
    }

    try {
      final stats = PracticeStats.fromJson(json);
      final last = stats.lastPracticeAt;
      if (last != null &&
          DateTime.now().difference(last) > const Duration(hours: 24) &&
          stats.streak != 0) {
        final normalized = stats.copyWith(streak: 0);
        await prefs.setString(_prefsKey, normalized.toJson());
        return normalized;
      }
      return stats;
    } catch (_) {
      return PracticeStats.empty();
    }
  }

  Future<PracticeStats> recordAttempt({
    required String signTitle,
    required double accuracyRate,
  }) async {
    final prev = await load();
    final now = DateTime.now();

    final sanitizedAccuracy = accuracyRate.clamp(0, 100).toDouble();

    var nextStreak = prev.streak;
    final last = prev.lastPracticeAt;

    if (last == null) {
      nextStreak = 1;
    } else {
      final inactiveTooLong = now.difference(last) > const Duration(hours: 24);
      if (inactiveTooLong) {
        nextStreak = 1;
      } else {
        final dayChanged = !_isSameLocalDay(last, now);
        if (dayChanged) {
          nextStreak = (nextStreak <= 0) ? 1 : nextStreak + 1;
        }
      }
    }

    final learned = {...prev.learnedSigns};
    if (sanitizedAccuracy >= 80) {
      final normalized = signTitle.trim();
      if (normalized.isNotEmpty) {
        learned.add(normalized);
      }
    }

    final next = prev.copyWith(
      totalAttempts: prev.totalAttempts + 1,
      totalAccuracySum: prev.totalAccuracySum + sanitizedAccuracy,
      streak: nextStreak,
      lastPracticeAt: now,
      learnedSigns: learned,
    );

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKey, next.toJson());
    return next;
  }

  bool _isSameLocalDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}
