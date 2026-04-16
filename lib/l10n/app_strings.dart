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
  List<String> get weekdayLabelsMonToSun => isFilipino
      ? const ['Lun', 'Mar', 'Miy', 'Huw', 'Biy', 'Sab', 'Lin']
      : const ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

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
  // Lessons strings
  // ---------------------------

  // Lessons list
  String get lessonsTitle => _t('lessonsTitle');
  String get lessonsSubtitle => _t('lessonsSubtitle');
  String get lessonsSearchHint => _t('lessonsSearchHint');

  // Difficulty filter
  /// Placeholder/label used when no difficulty is selected.
  ///
  /// In the Lessons list UI this is shown as the dropdown's first item.
  String get difficultyFilterLabel => _t('difficultyFilterLabel');
  String get difficultyAllLabel => _t('difficultyAllLabel');
  String get difficultyBeginnerLabel => _t('difficultyBeginnerLabel');
  String get difficultyIntermediateLabel => _t('difficultyIntermediateLabel');
  String get difficultyDifficultLabel => _t('difficultyDifficultLabel');

  /// Maps internal difficulty keys to localized labels for display.
  ///
  /// Internal keys should be language-agnostic and stable:
  /// '' (no filter), 'Beginner', 'Intermediate', 'Difficult'.
  String difficultyLabelForKey(String key) {
    final normalized = key.trim();
    if (normalized.isEmpty) return difficultyFilterLabel;

    switch (normalized.toLowerCase()) {
      case 'all':
        return difficultyAllLabel;
      case 'beginner':
        return difficultyBeginnerLabel;
      case 'intermediate':
        return difficultyIntermediateLabel;
      case 'difficult':
        return difficultyDifficultLabel;
      default:
        return normalized;
    }
  }

  /// Builds a localized lesson count label.
  ///
  /// Examples (EN): "1 lesson", "12 lessons".
  /// Example (FIL): "12 aralin".
  String lessonCountLabel(num count) {
    final n = count is int ? count : count.round();
    final key = (langCode == _en && n == 1)
        ? 'lessonCountLabelOne'
        : 'lessonCountLabelOther';
    return _template(key, {'count': _formatNumber(n)});
  }

  // Lesson details / signs
  String get lessonFallbackTitle => _t('lessonFallbackTitle');
  String get lessonNoSignsMessage => _t('lessonNoSignsMessage');
  String get lessonDefaultInstructions => _t('lessonDefaultInstructions');

  /// Display-only lesson title.
  ///
  /// Keep `Lesson.title` / sign `category` in English as the stable key for lookups.
  /// This helper optionally maps known seeded lesson titles for Filipino UI.
  String lessonTitleForDisplay(String? englishTitle) {
    final title = (englishTitle ?? '').trim();
    if (title.isEmpty) return lessonFallbackTitle;
    if (!isFilipino) return title;

    return _knownLessonTitlesEnToFil[title] ?? title;
  }

  static const Map<String, String> _knownLessonTitlesEnToFil = {
    'Alphabet': 'Alpabeto',
    'Numbers': 'Mga Numero',
    'Basic Gestures': 'Pangunahing Galaw',
    'Daily Conversations': 'Araw-araw na Usapan',
  };

  // ---------------------------
  // Dictionary strings
  // ---------------------------

  // Dictionary header
  String get dictionaryTitle => _t('dictionaryTitle');
  String get dictionarySubtitle => _t('dictionarySubtitle');
  String get dictionarySearchHint => _t('dictionarySearchHint');

  /// Display-only category label.
  ///
  /// Keep dictionary `category` keys stored in English as the stable key for
  /// lookups / filtering.
  ///
  /// Fallback behavior:
  /// - `null`/empty → ''
  /// - Unknown keys → original (trimmed)
  ///
  /// When Filipino is active, known categories are translated for display.
  /// If a category matches a seeded lesson title, the same lesson translations
  /// are reused.
  String categoryLabelForDisplay(String? categoryKey) {
    final key = (categoryKey ?? '').trim();
    if (key.isEmpty) return '';
    if (!isFilipino) return key;

    // Reuse lesson title translations when applicable.
    final fromLesson = lessonTitleForDisplay(key);
    if (fromLesson != key) return fromLesson;

    // Dictionary-only category translations.
    return _knownDictionaryCategoriesEnToFil[key] ?? key;
  }

  /// Display-only subtitle for Dictionary/Bookmarks category sections.
  ///
  /// - EN: "<Category> Sign".
  /// - FIL: "Senyas ng <Category>".
  ///
  /// Filipino grammar note: if the display label starts with "Mga ", the
  /// prefix is dropped for this phrase (e.g. "Mga Numero" → "Senyas ng Numero").
  ///
  /// Safe fallbacks:
  /// - `null`/empty keys → ''
  /// - Unknown keys → uses the trimmed key as the category label.
  String dictionaryCategorySubtitleForDisplay(String? categoryKey) {
    final label = categoryLabelForDisplay(categoryKey).trim();
    if (label.isEmpty) return '';

    if (!isFilipino) {
      return '$label Sign';
    }

    var filipinoLabel = label;
    if (filipinoLabel.startsWith('Mga ')) {
      filipinoLabel = filipinoLabel.substring('Mga '.length).trimLeft();
    }

    if (filipinoLabel.isEmpty) return '';
    return 'Senyas ng $filipinoLabel';
  }

  static const Map<String, String> _knownDictionaryCategoriesEnToFil = {
    // Dictionary-only (minimum required)
    'Greetings': 'Pagbati',
    'Emergency': 'Emerhensiya',
  };

  // Navigation / actions
  String get prevLabel => _t('prevLabel');
  String get nextLabel => _t('nextLabel');
  String get practiceLabel => _t('practiceLabel');

  /// Builds a localized progress label for lesson signs.
  ///
  /// Example (EN): "Sign 2 of 10".
  /// Example (FIL): "Sign 2 sa 10".
  String lessonSignProgressLabel(num current, num total) {
    return _template('lessonSignProgressLabel', {
      'current': _formatNumber(current),
      'total': _formatNumber(total),
    });
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

      // Lessons
      'lessonsTitle': 'Lessons',
      'lessonsSubtitle': 'Learn new signs and improve your skills',
      'lessonsSearchHint': 'Search Lessons',

      // Dictionary
      'dictionaryTitle': 'Dictionary',
      'dictionarySubtitle': 'Learn new signs and improve your skills',
      'dictionarySearchHint': 'Search Signs',

      'difficultyFilterLabel': 'Difficulty Level',
      'difficultyAllLabel': 'All',
      'difficultyBeginnerLabel': 'Beginner',
      'difficultyIntermediateLabel': 'Intermediate',
      'difficultyDifficultLabel': 'Difficult',

      // Lesson count (used by lessonCountLabel(count))
      'lessonCountLabelOne': '{count} Lesson',
      'lessonCountLabelOther': '{count} Lessons',

      'lessonFallbackTitle': 'Lesson',
      'lessonNoSignsMessage': 'No signs available for this lesson.',
      'lessonDefaultInstructions':
          'Follow the hand gesture shown in the visual above. Make sure your hand gestures are clear and recognizable.',

      'prevLabel': 'Prev',
      'nextLabel': 'Next',
      'practiceLabel': 'Practice',

      // Progress (used by lessonSignProgressLabel(current,total))
      'lessonSignProgressLabel': 'Sign {current} of {total}',
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

      'progressSignsLearnedLabel': 'Natutunang Sign',
      'progressAvgAccuracyLabel': 'Avg. katumpakan',
      'progressPracticeStreakLabel': 'Streak ng praktis',
      'progressTotalAttemptsLabel': 'Kabuuang pagsubok',

      // Error
      'unableToLoadProgressPrefix': 'Hindi ma-load ang progreso: ',

      // Lessons
      'lessonsTitle': 'Mga Aralin',
      'lessonsSubtitle': 'Matuto at paghusayin ang kasanayan sa mga senyas',
      'lessonsSearchHint': 'Maghanap ng mga Aralin',

      // Dictionary
      'dictionaryTitle': 'Diksiyonaryo',
      'dictionarySubtitle': 'Matuto ng mga bagong senyas at paghusayin ang iyong kasanayan',
      'dictionarySearchHint': 'Maghanap ng mga Senyas',

      'difficultyFilterLabel': 'Antas ng Kahirapan',
      'difficultyAllLabel': 'Lahat',
      'difficultyBeginnerLabel': 'Baguhan',
      'difficultyIntermediateLabel': 'Katamtaman',
      'difficultyDifficultLabel': 'Mahirap',

      // Lesson count (used by lessonCountLabel(count))
      'lessonCountLabelOne': '{count} Aralin',
      'lessonCountLabelOther': '{count} Aralin',

      'lessonFallbackTitle': 'Aralin',
      'lessonNoSignsMessage':
          'Walang available na mga sign para sa araling ito.',
      'lessonDefaultInstructions':
          'Sundan at magpraktis ng bawat sign sa araling ito.',

      'prevLabel': 'Nakaraan',
      'nextLabel': 'Susunod',
      'practiceLabel': 'Magpraktis',

      // Progress (used by lessonSignProgressLabel(current,total))
      'lessonSignProgressLabel': 'Sign {current} sa {total}',
    },
  };

  String _template(String key, Map<String, String> values) {
    var text = _t(key);
    values.forEach((k, v) {
      text = text.replaceAll('{$k}', v);
    });
    return text;
  }

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
