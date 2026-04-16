/// Lightweight in-app strings for simple EN/FIL localization.
///
/// - No `intl` / ARB setup.
/// - Pass a language code (e.g. `'en'`, `'fil'`). Unknown values fall back
///   to English.
class AppStrings {
  /// Normalized language code: `'en'` or `'fil'`.
  final String langCode;

  const AppStrings._(this.langCode);

  /// Creates an [AppStrings] instance for [code].
  ///
  /// Accepts `'en'` or `'fil'` (case-insensitive). Any other value falls back
  /// to English.
  factory AppStrings(String? code) {
    final normalized = (code ?? '').trim().toLowerCase();
    if (normalized == 'fil' || normalized == 'tl') {
      return const AppStrings._('fil');
    }
    return const AppStrings._('en');
  }

  static const String _en = 'en';
  static const String _fil = 'fil';

  bool get isFilipino => langCode == _fil;

  // ---------------------------
  // Dashboard strings
  // ---------------------------

  String get dashboardTitle => _t('dashboardTitle');

  // Daily challenge
  String get dailyChallengeHeader => _t('dailyChallengeHeader');
  String get dailyChallengeTitle => _t('dailyChallengeTitle');
  String get dailyChallengeSubtitle => _t('dailyChallengeSubtitle');
  String get dailyChallengeButton => _t('dailyChallengeButton');

  /// Weekday labels ordered Monday → Sunday.
  List<String> get weekdayLabelsMonToSun =>
      isFilipino ? const ['Lun', 'Mar', 'Miy', 'Huw', 'Biy', 'Sab', 'Lin'] : const ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  // Weekly progress chart (DynamicBarChart)
  String get weeklyProgressTitle => _t('weeklyProgressTitle');
  String get lastWeekLabel => _t('lastWeekLabel');
  String get thisWeekLabel => _t('thisWeekLabel');
  String get lastTooltipTag => _t('lastTooltipTag');
  String get thisTooltipTag => _t('thisTooltipTag');

  // Struggled sign section
  String get struggledSignHeader => _t('struggledSignHeader');

  // Accuracy
  /// Standalone label. English spelling is intentionally "Accuracy".
  String get accuracyLabel => _t('accuracyLabel');

  /// Suffix used after a number in the dashboard struggled sign rows.
  ///
  /// Example (EN): "% Accuracy" (so you can build "45% Accuracy").
  String get accuracySuffix => _t('accuracySuffix');

  /// Builds a localized accuracy string with a percentage value.
  ///
  /// Example (EN): "45% Accuracy".
  String accuracyWithPercent(num percent) {
    return '${_formatNumber(percent)}$accuracySuffix';
  }

  // Progress
  String get progressHeader => _t('progressHeader');

  // Progress metric labels
  String get progressSignsLearnedLabel => _t('progressSignsLearnedLabel');
  String get progressAvgAccuracyLabel => _t('progressAvgAccuracyLabel');
  String get progressPracticeStreakLabel => _t('progressPracticeStreakLabel');
  String get progressTotalAttemptsLabel => _t('progressTotalAttemptsLabel');

  // Progress loading error
  String get unableToLoadProgressPrefix => _t('unableToLoadProgressPrefix');

  /// Builds the full progress loading failure message.
  ///
  /// Example (EN): "Unable to load progress: <message>".
  String unableToLoadProgress(String message) {
    return '$unableToLoadProgressPrefix$message';
  }

  // ---------------------------
  // Internals
  // ---------------------------

  String _t(String key) {
    final byLang = _strings[langCode] ?? _strings[_en]!;
    return byLang[key] ?? _strings[_en]![key] ?? key;
  }

  static const Map<String, Map<String, String>> _strings = {
    _en: {
      // Dashboard
      'dashboardTitle': 'Dashboard',

      // Daily challenge
      'dailyChallengeHeader': 'DAILY CHALLENGE',
      'dailyChallengeTitle': 'Master the basics',
      'dailyChallengeSubtitle': 'Complete 5 alphabet signs today',
      'dailyChallengeButton': 'PRACTICE NOW',

      // Struggled
      'struggledSignHeader': 'STRUGGLED SIGN THIS WEEK',

      // Accuracy
      'accuracyLabel': 'Accuracy',
      'accuracySuffix': '% Accuracy',

      // Progress
      'progressHeader': 'PROGRESS',

      // Weekly progress chart (DynamicBarChart)
      'weeklyProgressTitle': 'WEEKLY PROGRESS',
      'lastWeekLabel': 'Last Week',
      'thisWeekLabel': 'This Week',
      'lastTooltipTag': '(Last)',
      'thisTooltipTag': '(This)',

      'progressSignsLearnedLabel': 'Signs learned',
      'progressAvgAccuracyLabel': 'Avg accuracy',
      'progressPracticeStreakLabel': 'Practice streak',
      'progressTotalAttemptsLabel': 'Total attempts',

      // Error
      'unableToLoadProgressPrefix': 'Unable to load progress: ',
    },
    _fil: {
      // Dashboard
      'dashboardTitle': 'Dashboard',

      // Daily challenge
      'dailyChallengeHeader': 'ARAWANG HAMON',
      'dailyChallengeTitle': 'Maging bihasa sa mga batayan',
      'dailyChallengeSubtitle': 'Kumpletuhin ang 5 sign ng alpabeto ngayon',
      'dailyChallengeButton': 'MAGPRAKTIS NGAYON',

      // Struggled
      'struggledSignHeader': 'SIGN NA NAHIRAPAN NGAYONG LINGGO',

      // Accuracy
      'accuracyLabel': 'Katumpakan',
      'accuracySuffix': '% Katumpakan',

      // Progress
      'progressHeader': 'PROGRESO',

      // Weekly progress chart (DynamicBarChart)
      'weeklyProgressTitle': 'LINGGUHANG PROGRESO',
      'lastWeekLabel': 'Nakaraang Linggo',
      'thisWeekLabel': 'Ngayong Linggo',
      'lastTooltipTag': '(Nakaraan)',
      'thisTooltipTag': '(Ngayon)',

      'progressSignsLearnedLabel': 'Mga natutunang sign',
      'progressAvgAccuracyLabel': 'Karaniwang katumpakan',
      'progressPracticeStreakLabel': 'Streak ng praktis',
      'progressTotalAttemptsLabel': 'Kabuuang pagsubok',

      // Error
      'unableToLoadProgressPrefix': 'Hindi ma-load ang progreso: ',
    },
  };

  String _formatNumber(num value) {
    if (value is int) return value.toString();
    // Avoid trailing ".0" for whole values.
    final rounded = value.roundToDouble();
    if ((value - rounded).abs() < 1e-9) {
      return rounded.toInt().toString();
    }
    return value.toString();
  }
}
