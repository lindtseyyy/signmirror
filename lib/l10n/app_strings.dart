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
  // Community strings
  // ---------------------------

  // Community main screen
  String get communityTitle => _t('communityTitle');
  String get communityUploadTooltip => _t('communityUploadTooltip');
  String get communitySearchHint => _t('communitySearchHint');

  // Tabs (tooltips/semantics)
  String get communityTabUnapprovedVideos => _t('communityTabUnapprovedVideos');
  String get communityTabApprovedVideos => _t('communityTabApprovedVideos');
  String get communityTabUserUploadedVideos =>
      _t('communityTabUserUploadedVideos');

  // Common actions/menus (community scope)
  String get communityMoreOptionsTooltip => _t('communityMoreOptionsTooltip');
  String get communityEditLabel => _t('communityEditLabel');
  String get communityDeleteLabel => _t('communityDeleteLabel');
  String get communityCancelLabel => _t('communityCancelLabel');
  String get communitySaveLabel => _t('communitySaveLabel');

  // Approvals / approving
  String get communityApproveLabel => _t('communityApproveLabel');
  String get communityApprovedLabel => _t('communityApprovedLabel');
  String get communityApprovedExclamationLabel =>
      _t('communityApprovedExclamationLabel');

  /// Builds a localized approvals count label.
  ///
  /// Examples (EN): "1 Approval", "12 Approvals".
  /// Example (FIL): "12 Pag-apruba".
  String communityApprovalCountLabel(num count) {
    final n = count is int ? count : count.round();
    final key = (langCode == _en && n == 1)
        ? 'communityApprovalCountLabelOne'
        : 'communityApprovalCountLabelOther';
    return _template(key, {'count': _formatNumber(n)});
  }

  /// Builds a localized "Top Approved" badge label.
  ///
  /// Example (EN): "Top Approved (3)".
  String communityTopApprovedLabel(num approves) {
    final n = approves is int ? approves : approves.round();
    return _template('communityTopApprovedLabel', {'count': _formatNumber(n)});
  }

  /// Builds a localized approvals progress label.
  ///
  /// Example (EN): "2/3 Approved".
  /// Example (FIL): "2/3 Naaprubahan".
  String communityApprovalProgressLabel(num approves, num threshold) {
    final a = approves is int ? approves : approves.round();
    final t = threshold is int ? threshold : threshold.round();
    return _template('communityApprovalProgressLabel', {
      'count': _formatNumber(a),
      'threshold': _formatNumber(t),
    });
  }

  // Comments

  /// Builds a localized comment count label.
  ///
  /// Examples (EN): "1 Comment", "12 Comments".
  /// Example (FIL): "12 Komento".
  String communityCommentCountLabel(num count) {
    final n = count is int ? count : count.round();
    final key = (langCode == _en && n == 1)
        ? 'communityCommentCountLabelOne'
        : 'communityCommentCountLabelOther';
    return _template(key, {'count': _formatNumber(n)});
  }

  /// Builds a localized comments sheet title with count.
  ///
  /// Example (EN): "Comments (2)".
  /// Example (FIL): "Mga komento (2)".
  String communityCommentsTitleWithCount(num count) {
    final n = count is int ? count : count.round();
    return _template('communityCommentsTitleWithCount', {
      'count': _formatNumber(n),
    });
  }

  String get communityNoCommentsYetMessage => _t('communityNoCommentsYetMessage');
  String get communityAddCommentHint => _t('communityAddCommentHint');
  String get communitySendTooltip => _t('communitySendTooltip');

  /// Builds a localized placeholder label for an unknown user.
  ///
  /// Example (EN): "User 12".
  /// Example (FIL): "Gumagamit 12".
  String communityUserWithId(num id) {
    return _template('communityUserWithId', {'id': _formatNumber(id)});
  }

  // User/system labels specific to community UI
  String get communityMockVideoBadge => _t('communityMockVideoBadge');

  String get communityMockFirstUploadTitle => _t('communityMockFirstUploadTitle');
  String get communityMockFirstUploadDescription =>
      _t('communityMockFirstUploadDescription');
  String get communityMockPracticeVideoTitle =>
      _t('communityMockPracticeVideoTitle');
  String get communityMockPracticeVideoDescription =>
      _t('communityMockPracticeVideoDescription');

  // Dialogs + snackbars
  String get communityEditDescriptionTitle => _t('communityEditDescriptionTitle');
  String get communityEditDescriptionHint => _t('communityEditDescriptionHint');

  String get communityDeletePostTitle => _t('communityDeletePostTitle');
  String get communityDeletePostBody => _t('communityDeletePostBody');

  String get communitySnackbarDescriptionUpdated =>
      _t('communitySnackbarDescriptionUpdated');
  String get communitySnackbarDescriptionUpdateFailed =>
      _t('communitySnackbarDescriptionUpdateFailed');
  String get communitySnackbarPostDeleted => _t('communitySnackbarPostDeleted');
  String get communitySnackbarPostDeleteFailed =>
      _t('communitySnackbarPostDeleteFailed');

  // Video dialog/player
  String get communityCloseTooltip => _t('communityCloseTooltip');
  String get communityVideoLoadError => _t('communityVideoLoadError');

  // Upload screen
  String get communityUploadScreenTitle => _t('communityUploadScreenTitle');
  String get communityUploadScreenInstructions =>
      _t('communityUploadScreenInstructions');

  String get communityUploadVideoSectionLabel =>
      _t('communityUploadVideoSectionLabel');
  String get communityUploadNoVideoSelectedLabel =>
      _t('communityUploadNoVideoSelectedLabel');

  // Semantics (upload picker)
  String get communityUploadSelectedVideoSemanticLabel =>
      _t('communityUploadSelectedVideoSemanticLabel');
  String get communityUploadChooseVideoSemanticLabel =>
      _t('communityUploadChooseVideoSemanticLabel');
  String get communityUploadInProgressSemanticHint =>
      _t('communityUploadInProgressSemanticHint');
  String get communityUploadTapToPickVideoSemanticHint =>
      _t('communityUploadTapToPickVideoSemanticHint');

  String get communityUploadVideoSelectedLabel =>
      _t('communityUploadVideoSelectedLabel');
  String get communityUploadPickVideoLabel => _t('communityUploadPickVideoLabel');
  String get communityUploadSupportedFormatsLabel =>
      _t('communityUploadSupportedFormatsLabel');

  String get communityUploadChangeSelectedVideoTooltip =>
      _t('communityUploadChangeSelectedVideoTooltip');
  String get communityUploadChooseVideoTooltip =>
      _t('communityUploadChooseVideoTooltip');
  String get communityUploadChangeButtonLabel =>
      _t('communityUploadChangeButtonLabel');
  String get communityUploadChooseButtonLabel =>
      _t('communityUploadChooseButtonLabel');

  String get communityUploadDescriptionSectionLabel =>
      _t('communityUploadDescriptionSectionLabel');
  String get communityUploadDescriptionOptionalLabel =>
      _t('communityUploadDescriptionOptionalLabel');
  String get communityUploadDescriptionHint =>
      _t('communityUploadDescriptionHint');

  // Semantics (upload action)
  String get communityUploadVideoButtonSemanticLabel =>
      _t('communityUploadVideoButtonSemanticLabel');
  String get communityUploadSelectedVideoSemanticHint =>
      _t('communityUploadSelectedVideoSemanticHint');
  String get communityUploadSelectVideoFirstSemanticHint =>
      _t('communityUploadSelectVideoFirstSemanticHint');

  String get communityUploadingLabel => _t('communityUploadingLabel');
  String get communityUploadButtonLabel => _t('communityUploadButtonLabel');

  // Upload snackbars/errors
  String get communityUploadFallbackPickerNoUsablePathError =>
      _t('communityUploadFallbackPickerNoUsablePathError');
  String get communityUploadNoPickerPluginError =>
      _t('communityUploadNoPickerPluginError');
  String get communityUploadFallbackPickerOpenError =>
      _t('communityUploadFallbackPickerOpenError');
  String get communityUploadVideoSelectionGenericError =>
      _t('communityUploadVideoSelectionGenericError');
  String get communityUploadPlatformNoPathError =>
      _t('communityUploadPlatformNoPathError');
  String get communityUploadFilePickerOpenError =>
      _t('communityUploadFilePickerOpenError');
  String get communityUploadChooseVideoFilePrompt =>
      _t('communityUploadChooseVideoFilePrompt');
  String get communityUploadSuccessSnackbar => _t('communityUploadSuccessSnackbar');
  String get communityUploadFailureSnackbar => _t('communityUploadFailureSnackbar');

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

      // Community
      'communityTitle': 'Community',
      'communityUploadTooltip': 'Upload',
      'communitySearchHint': 'Search by title or uploader',

      'communityTabUnapprovedVideos': 'Unapproved Videos',
      'communityTabApprovedVideos': 'Approved Videos',
      'communityTabUserUploadedVideos': 'User Uploaded Videos',

      'communityMoreOptionsTooltip': 'More options',
      'communityEditLabel': 'Edit',
      'communityDeleteLabel': 'Delete',
      'communityCancelLabel': 'Cancel',
      'communitySaveLabel': 'Save',

      'communityApproveLabel': 'Approve',
      'communityApprovedLabel': 'Approved',
      'communityApprovedExclamationLabel': 'Approved!',

      'communityApprovalCountLabelOne': '{count} Approval',
      'communityApprovalCountLabelOther': '{count} Approvals',
      'communityTopApprovedLabel': 'Top Approved ({count})',
      'communityApprovalProgressLabel': '{count}/{threshold} Approved',

      'communityCommentCountLabelOne': '{count} Comment',
      'communityCommentCountLabelOther': '{count} Comments',
      'communityCommentsTitleWithCount': 'Comments ({count})',
      'communityNoCommentsYetMessage': 'No comments yet. Be the first to comment!',
      'communityAddCommentHint': 'Add a comment...',
      'communitySendTooltip': 'Send',
      'communityUserWithId': 'User {id}',

      'communityMockVideoBadge': 'Mock Video',
      'communityMockFirstUploadTitle': 'My First Upload (Mock)',
      'communityMockFirstUploadDescription':
          'Example upload shown because you have no uploads yet.',
      'communityMockPracticeVideoTitle': 'Practice Video (Mock)',
      'communityMockPracticeVideoDescription':
          'Record and upload a video to replace this mock item.',

      'communityEditDescriptionTitle': 'Edit description',
      'communityEditDescriptionHint': 'Write a description...',

      'communityDeletePostTitle': 'Delete post?',
      'communityDeletePostBody': 'This action cannot be undone.',

      'communitySnackbarDescriptionUpdated': 'Description updated.',
      'communitySnackbarDescriptionUpdateFailed': 'Failed to update description.',
      'communitySnackbarPostDeleted': 'Post deleted.',
      'communitySnackbarPostDeleteFailed': 'Failed to delete post.',

      'communityCloseTooltip': 'Close',
      'communityVideoLoadError': 'Error loading video',

      'communityUploadScreenTitle': 'Upload',
      'communityUploadScreenInstructions':
          'Choose a video file, add an optional description, then upload it to the community.',

      'communityUploadVideoSectionLabel': 'Video',
      'communityUploadNoVideoSelectedLabel': 'No video selected',

      'communityUploadSelectedVideoSemanticLabel': 'Selected video',
      'communityUploadChooseVideoSemanticLabel': 'Choose a video to upload',
      'communityUploadInProgressSemanticHint': 'Upload in progress',
      'communityUploadTapToPickVideoSemanticHint': 'Tap to open the video picker',

      'communityUploadVideoSelectedLabel': 'Video selected',
      'communityUploadPickVideoLabel': 'Pick a video',
      'communityUploadSupportedFormatsLabel':
          'Supported: MP4, MOV, M4V, WebM, MKV, AVI',

      'communityUploadChangeSelectedVideoTooltip': 'Change selected video',
      'communityUploadChooseVideoTooltip': 'Choose video',
      'communityUploadChangeButtonLabel': 'Change',
      'communityUploadChooseButtonLabel': 'Choose',

      'communityUploadDescriptionSectionLabel': 'Description',
      'communityUploadDescriptionOptionalLabel': 'Description (optional)',
      'communityUploadDescriptionHint': 'Enter description',

      'communityUploadVideoButtonSemanticLabel': 'Upload video',
      'communityUploadSelectedVideoSemanticHint': 'Uploads the selected video',
      'communityUploadSelectVideoFirstSemanticHint': 'Select a video first',

      'communityUploadingLabel': 'Uploading…',
      'communityUploadButtonLabel': 'Upload',

      'communityUploadFallbackPickerNoUsablePathError':
          "Couldn't access a usable local file path from the fallback picker.",
      'communityUploadNoPickerPluginError':
          'No file picker plugin is available on this platform.',
      'communityUploadFallbackPickerOpenError':
          'Could not open the fallback file picker.',
      'communityUploadVideoSelectionGenericError':
          'Something went wrong selecting a video.',
      'communityUploadPlatformNoPathError':
          "This platform can't provide an accessible local file path.",
      'communityUploadFilePickerOpenError': 'Could not open the file picker.',
      'communityUploadChooseVideoFilePrompt': 'Please choose a video file.',
      'communityUploadSuccessSnackbar': 'Upload successful.',
      'communityUploadFailureSnackbar': 'Upload failed. Please try again.',
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

      // Community
      'communityTitle': 'Komunidad',
      'communityUploadTooltip': 'Mag-upload',
      'communitySearchHint': 'Maghanap ayon sa pamagat o nag-upload',

      'communityTabUnapprovedVideos': 'Mga Hindi Pa Naaprubahang Video',
      'communityTabApprovedVideos': 'Mga Naaprubahang Video',
      'communityTabUserUploadedVideos': 'Mga Video na In-upload Ko',

      'communityMoreOptionsTooltip': 'Iba pang opsyon',
      'communityEditLabel': 'I-edit',
      'communityDeleteLabel': 'Tanggalin',
      'communityCancelLabel': 'Kanselahin',
      'communitySaveLabel': 'I-save',

      'communityApproveLabel': 'Aprubahan',
      'communityApprovedLabel': 'Naaprubahan',
      'communityApprovedExclamationLabel': 'Naaprubahan!',

      'communityApprovalCountLabelOne': '{count} Pag-apruba',
      'communityApprovalCountLabelOther': '{count} Pag-apruba',
      'communityTopApprovedLabel': 'Pinaka-naaprubahan ({count})',
      'communityApprovalProgressLabel': '{count}/{threshold} Naaprubahan',

      'communityCommentCountLabelOne': '{count} Komento',
      'communityCommentCountLabelOther': '{count} Komento',
      'communityCommentsTitleWithCount': 'Mga komento ({count})',
      'communityNoCommentsYetMessage': 'Wala pang komento. Ikaw ang unang magkomento!',
      'communityAddCommentHint': 'Magdagdag ng komento...',
      'communitySendTooltip': 'Ipadala',
      'communityUserWithId': 'Gumagamit {id}',

      'communityMockVideoBadge': 'Halimbawang Video',
      'communityMockFirstUploadTitle': 'Una Kong Upload (Mock)',
      'communityMockFirstUploadDescription':
          'Halimbawang upload na ipinapakita dahil wala ka pang naiu-upload.',
      'communityMockPracticeVideoTitle': 'Pang-praktis na Video (Mock)',
      'communityMockPracticeVideoDescription':
          'Mag-record at mag-upload ng video para mapalitan ang mock na item na ito.',

      'communityEditDescriptionTitle': 'I-edit ang paglalarawan',
      'communityEditDescriptionHint': 'Sumulat ng paglalarawan...',

      'communityDeletePostTitle': 'Tanggalin ang post?',
      'communityDeletePostBody': 'Hindi na ito maibabalik.',

      'communitySnackbarDescriptionUpdated': 'Na-update ang paglalarawan.',
      'communitySnackbarDescriptionUpdateFailed': 'Hindi na-update ang paglalarawan.',
      'communitySnackbarPostDeleted': 'Natanggal ang post.',
      'communitySnackbarPostDeleteFailed': 'Hindi natanggal ang post.',

      'communityCloseTooltip': 'Isara',
      'communityVideoLoadError': 'Hindi ma-load ang video',

      'communityUploadScreenTitle': 'Mag-upload',
      'communityUploadScreenInstructions':
          'Pumili ng video file, magdagdag ng opsyonal na paglalarawan, at i-upload ito sa komunidad.',

      'communityUploadVideoSectionLabel': 'Video',
      'communityUploadNoVideoSelectedLabel': 'Walang napiling video',

      'communityUploadSelectedVideoSemanticLabel': 'Napiling video',
      'communityUploadChooseVideoSemanticLabel': 'Pumili ng video na i-upload',
      'communityUploadInProgressSemanticHint': 'Isinasagawa ang pag-upload',
      'communityUploadTapToPickVideoSemanticHint': 'I-tap para pumili ng video',

      'communityUploadVideoSelectedLabel': 'Napili na ang video',
      'communityUploadPickVideoLabel': 'Pumili ng video',
      'communityUploadSupportedFormatsLabel':
          'Sinusuportahan: MP4, MOV, M4V, WebM, MKV, AVI',

      'communityUploadChangeSelectedVideoTooltip': 'Palitan ang napiling video',
      'communityUploadChooseVideoTooltip': 'Pumili ng video',
      'communityUploadChangeButtonLabel': 'Palitan',
      'communityUploadChooseButtonLabel': 'Pumili',

      'communityUploadDescriptionSectionLabel': 'Paglalarawan',
      'communityUploadDescriptionOptionalLabel': 'Paglalarawan (opsyonal)',
      'communityUploadDescriptionHint': 'Ilagay ang paglalarawan',

      'communityUploadVideoButtonSemanticLabel': 'Mag-upload ng video',
      'communityUploadSelectedVideoSemanticHint': 'Iu-upload ang napiling video',
      'communityUploadSelectVideoFirstSemanticHint': 'Pumili muna ng video',

      'communityUploadingLabel': 'Nag-a-upload…',
      'communityUploadButtonLabel': 'I-upload',

      'communityUploadFallbackPickerNoUsablePathError':
          'Hindi ma-access ang magagamit na local file path mula sa fallback picker.',
      'communityUploadNoPickerPluginError':
          'Walang available na file picker plugin sa platform na ito.',
      'communityUploadFallbackPickerOpenError':
          'Hindi mabuksan ang fallback file picker.',
      'communityUploadVideoSelectionGenericError':
          'May nangyaring problema sa pagpili ng video.',
      'communityUploadPlatformNoPathError':
          'Hindi makapagbigay ang platform na ito ng accessible na local file path.',
      'communityUploadFilePickerOpenError': 'Hindi mabuksan ang file picker.',
      'communityUploadChooseVideoFilePrompt': 'Pumili ng video file.',
      'communityUploadSuccessSnackbar': 'Matagumpay ang pag-upload.',
      'communityUploadFailureSnackbar': 'Hindi natuloy ang pag-upload. Pakisubukan muli.',
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
