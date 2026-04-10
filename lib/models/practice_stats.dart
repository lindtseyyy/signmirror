import 'dart:convert';

class PracticeStats {
  final int totalAttempts;
  final double totalAccuracySum;
  final int streak;
  final DateTime? lastPracticeAt;
  final Set<String> learnedSigns;

  const PracticeStats({
    required this.totalAttempts,
    required this.totalAccuracySum,
    required this.streak,
    required this.lastPracticeAt,
    required this.learnedSigns,
  });

  factory PracticeStats.empty() {
    return const PracticeStats(
      totalAttempts: 0,
      totalAccuracySum: 0,
      streak: 0,
      lastPracticeAt: null,
      learnedSigns: <String>{},
    );
  }

  double get averageAccuracyRate {
    if (totalAttempts <= 0) return 0;
    return totalAccuracySum / totalAttempts;
  }

  PracticeStats copyWith({
    int? totalAttempts,
    double? totalAccuracySum,
    int? streak,
    DateTime? lastPracticeAt,
    Set<String>? learnedSigns,
  }) {
    return PracticeStats(
      totalAttempts: totalAttempts ?? this.totalAttempts,
      totalAccuracySum: totalAccuracySum ?? this.totalAccuracySum,
      streak: streak ?? this.streak,
      lastPracticeAt: lastPracticeAt ?? this.lastPracticeAt,
      learnedSigns: learnedSigns ?? this.learnedSigns,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'totalAttempts': totalAttempts,
      'totalAccuracySum': totalAccuracySum,
      'streak': streak,
      'lastPracticeAtMillis': lastPracticeAt?.millisecondsSinceEpoch,
      'learnedSigns': learnedSigns.toList()..sort(),
    };
  }

  factory PracticeStats.fromMap(Map<String, dynamic> map) {
    final learned =
        (map['learnedSigns'] as List?)
            ?.whereType<String>()
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toSet() ??
        <String>{};

    final lastMillis = map['lastPracticeAtMillis'];
    DateTime? last;
    if (lastMillis is int) {
      last = DateTime.fromMillisecondsSinceEpoch(lastMillis);
    } else if (lastMillis is num) {
      last = DateTime.fromMillisecondsSinceEpoch(lastMillis.toInt());
    }

    return PracticeStats(
      totalAttempts: (map['totalAttempts'] as num?)?.toInt() ?? 0,
      totalAccuracySum: (map['totalAccuracySum'] as num?)?.toDouble() ?? 0,
      streak: (map['streak'] as num?)?.toInt() ?? 0,
      lastPracticeAt: last,
      learnedSigns: learned,
    );
  }

  String toJson() => jsonEncode(toMap());

  factory PracticeStats.fromJson(String json) {
    final decoded = jsonDecode(json);
    if (decoded is Map<String, dynamic>) {
      return PracticeStats.fromMap(decoded);
    }
    return PracticeStats.empty();
  }
}
