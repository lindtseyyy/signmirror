/// Lightweight in-app strings for simple EN/FIL localization.
///
/// - No `intl` / ARB setup.
/// - Pass a language code (e.g. `'en'`, `'fil'`). Unknown values fall back
///   to English.
class AppStrings {
  /// Backing field for the language code.
  ///
  /// This is intentionally nullable to be defensive against unsound/legacy calls
  /// that might pass `null` into the private constructor at runtime.
  final String? _langCode;

  /// Normalized language code: `'en'` or `'fil'`.
  ///
  /// Always returns a non-null, supported value.
  String get langCode => normalizeLangCode(_langCode);

  const AppStrings._(this._langCode);

  /// Creates an [AppStrings] instance for [code].
  ///
  /// Accepts `'en'` or `'fil'` (case-insensitive). Any other value falls back
  /// to English.
  factory AppStrings(String? code) {
    final normalized = normalizeLangCode(code);
    if (normalized == _fil) {
      return const AppStrings._(_fil);
    }
    return const AppStrings._(_en);
  }

  static const String _en = 'en';
  static const String _fil = 'fil';

  /// Normalizes any input into a supported language code.
  ///
  /// Mapping rules:
  /// - `null` / empty / whitespace → `'en'`
  /// - case-insensitive `'fil'` or `'tl'` → `'fil'`
  /// - string literals `'null'` / `'undefined'` → `'en'`
  /// - anything else → `'en'`
  static String normalizeLangCode(String? code) {
    final normalized = (code ?? '').trim().toLowerCase();

    if (normalized.isEmpty) return _en;
    if (normalized == 'null' || normalized == 'undefined') return _en;
    if (normalized == _fil || normalized == 'tl') return _fil;

    return _en;
  }

  bool get isFilipino => langCode == _fil;

  // ---------------------------
  // Sign in strings
  // ---------------------------

  String get signinWelcomeTitle => _t('signinWelcomeTitle');
  String get signinWelcomeSubtitle => _t('signinWelcomeSubtitle');

  String get signinEmailLabel => _t('signinEmailLabel');
  String get signinEmailHint => _t('signinEmailHint');

  String get signinPasswordLabel => _t('signinPasswordLabel');
  String get signinPasswordHint => _t('signinPasswordHint');

  String get signinLoginButtonLabel => _t('signinLoginButtonLabel');
  String get signinDividerLabel => _t('signinDividerLabel');

  String get signinFooterNoAccountLabel => _t('signinFooterNoAccountLabel');
  String get signinFooterSignUpLabel => _t('signinFooterSignUpLabel');

  String get signinLoadingLoggingInLabel => _t('signinLoadingLoggingInLabel');
  String get signinLoadingPreparingDashboardLabel =>
      _t('signinLoadingPreparingDashboardLabel');

  String get signinErrorEmailRequired => _t('signinErrorEmailRequired');
  String get signinErrorEmailInvalid => _t('signinErrorEmailInvalid');
  String get signinErrorPasswordRequired => _t('signinErrorPasswordRequired');
  String get signinErrorInvalidCredentials =>
      _t('signinErrorInvalidCredentials');

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

  // ---------------------------
  // Practice Mirror strings
  // ---------------------------

  // App bar
  String get practiceMirrorTitle => _t('practiceMirrorTitle');

  // Reference panel
  String get practiceMirrorReferenceHeader =>
      _t('practiceMirrorReferenceHeader');

  /// Builds the reference panel subtitle.
  ///
  /// Example (EN): "Target: Hello".
  String practiceMirrorReferenceTargetSubtitle(String targetGestureName) {
    return _template('practiceMirrorReferenceTargetSubtitle', {
      'targetGestureName': targetGestureName,
    });
  }

  // Camera message states
  String get practiceMirrorCameraPermissionTitle =>
      _t('practiceMirrorCameraPermissionTitle');
  String get practiceMirrorCameraPermissionSubtitle =>
      _t('practiceMirrorCameraPermissionSubtitle');

  String get practiceMirrorCameraUnavailableTitle =>
      _t('practiceMirrorCameraUnavailableTitle');

  String get practiceMirrorStartingCameraTitle =>
      _t('practiceMirrorStartingCameraTitle');
  String get practiceMirrorStartingCameraSubtitle =>
      _t('practiceMirrorStartingCameraSubtitle');

  /// Builds the FPS badge label.
  ///
  /// Example (EN): "15 FPS".
  String practiceMirrorFpsBadge(num fps) {
    return _template('practiceMirrorFpsBadge', {'fps': _formatNumber(fps)});
  }

  /// Builds the HUD label for the currently detected gesture.
  ///
  /// Example (EN): "Detected: A".
  String practiceMirrorDetectedLabel(String detectedGestureLabel) {
    return _template('practiceMirrorDetectedLabel', {
      'detectedGestureLabel': detectedGestureLabel,
    });
  }

  // Processing pill labels
  String get practiceMirrorPausedLabel => _t('practiceMirrorPausedLabel');
  String get practiceMirrorProcessingLabel =>
      _t('practiceMirrorProcessingLabel');

  // Low light banner messages
  String get practiceMirrorLowLightPausedMessage =>
      _t('practiceMirrorLowLightPausedMessage');
  String get practiceMirrorLowLightImproveMessage =>
      _t('practiceMirrorLowLightImproveMessage');

  // Performance labels
  String get practiceMirrorPerformanceCorrect =>
      _t('practiceMirrorPerformanceCorrect');
  String get practiceMirrorPerformanceAlmost =>
      _t('practiceMirrorPerformanceAlmost');
  String get practiceMirrorPerformanceIncorrect =>
      _t('practiceMirrorPerformanceIncorrect');

  // Errors
  String get practiceMirrorNoCamerasAvailableError =>
      _t('practiceMirrorNoCamerasAvailableError');

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

  String get communityNoCommentsYetMessage =>
      _t('communityNoCommentsYetMessage');
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

  String get communityMockFirstUploadTitle =>
      _t('communityMockFirstUploadTitle');
  String get communityMockFirstUploadDescription =>
      _t('communityMockFirstUploadDescription');
  String get communityMockPracticeVideoTitle =>
      _t('communityMockPracticeVideoTitle');
  String get communityMockPracticeVideoDescription =>
      _t('communityMockPracticeVideoDescription');

  // Dialogs + snackbars
  String get communityEditDescriptionTitle =>
      _t('communityEditDescriptionTitle');
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
  String get communityUploadPickVideoLabel =>
      _t('communityUploadPickVideoLabel');
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
  String get communityUploadSuccessSnackbar =>
      _t('communityUploadSuccessSnackbar');
  String get communityUploadFailureSnackbar =>
      _t('communityUploadFailureSnackbar');

  // ---------------------------
  // Profile strings
  // ---------------------------

  String get profileTitle => _t('profileTitle');
  String get profileAchievementsHeader => _t('profileAchievementsHeader');
  String get profileAchievementStudious => _t('profileAchievementStudious');
  String get profileAchievementQuickie => _t('profileAchievementQuickie');
  String get profileAchievementAmbitious => _t('profileAchievementAmbitious');
  String get profileAchievementPerfectionist =>
      _t('profileAchievementPerfectionist');

  String get profileDarkModeLabel => _t('profileDarkModeLabel');
  String get profileOfflineDownloadingLabel =>
      _t('profileOfflineDownloadingLabel');
  String get profileHighContrastLabel => _t('profileHighContrastLabel');

  String get profileLanguageLabel => _t('profileLanguageLabel');
  String get profileSelectLanguageTitle => _t('profileSelectLanguageTitle');
  String get languageEnglishLabel => _t('languageEnglishLabel');
  String get languageFilipinoLabel => _t('languageFilipinoLabel');

  String get profileDailyPracticeReminderLabel =>
      _t('profileDailyPracticeReminderLabel');
  String get profileLogoutLabel => _t('profileLogoutLabel');

  String get profileDefaultUserLabel => _t('profileDefaultUserLabel');
  String get profileNotSetLabel => _t('profileNotSetLabel');

  String get profileSelectTimeTitle => _t('profileSelectTimeTitle');
  String get commonDoneLabel => _t('commonDoneLabel');
  String get commonNoneLabel => _t('commonNoneLabel');

  // ---------------------------
  // Edit Profile strings
  // ---------------------------

  // App bar
  String get editProfileTitle => _t('editProfileTitle');

  // Section titles / descriptions
  String get editProfileSectionProfileTitle =>
      _t('editProfileSectionProfileTitle');
  String get editProfileSectionProfileDescription =>
      _t('editProfileSectionProfileDescription');

  String get editProfileSectionEmailTitle => _t('editProfileSectionEmailTitle');
  String get editProfileSectionEmailDescription =>
      _t('editProfileSectionEmailDescription');

  String get editProfileSectionPasswordTitle =>
      _t('editProfileSectionPasswordTitle');
  String get editProfileSectionPasswordDescription =>
      _t('editProfileSectionPasswordDescription');

  // Labels / hints / buttons
  String get editProfileUserNameLabel => _t('editProfileUserNameLabel');
  String get editProfileUserNameHint => _t('editProfileUserNameHint');

  String get editProfilePersonalizationLabel =>
      _t('editProfilePersonalizationLabel');
  String get editProfilePersonalizationHint =>
      _t('editProfilePersonalizationHint');

  String get editProfileSaveProfileButton => _t('editProfileSaveProfileButton');

  // Email
  String get editProfileCurrentEmailPrefix =>
      _t('editProfileCurrentEmailPrefix');
  String get editProfileNewEmailLabel => _t('editProfileNewEmailLabel');
  String get editProfileNewEmailHint => _t('editProfileNewEmailHint');
  String get editProfileUpdateEmailButton => _t('editProfileUpdateEmailButton');

  // Password
  String get editProfileCurrentPasswordLabel =>
      _t('editProfileCurrentPasswordLabel');
  String get editProfileCurrentPasswordHint =>
      _t('editProfileCurrentPasswordHint');
  String get editProfileNewPasswordLabel => _t('editProfileNewPasswordLabel');
  String get editProfileNewPasswordHint => _t('editProfileNewPasswordHint');
  String get editProfileConfirmNewPasswordLabel =>
      _t('editProfileConfirmNewPasswordLabel');
  String get editProfileConfirmNewPasswordHint =>
      _t('editProfileConfirmNewPasswordHint');
  String get editProfileChangePasswordButton =>
      _t('editProfileChangePasswordButton');

  // Tooltips
  String get editProfileShowPasswordTooltip =>
      _t('editProfileShowPasswordTooltip');
  String get editProfileHidePasswordTooltip =>
      _t('editProfileHidePasswordTooltip');

  // Snackbars
  String get editProfileSnackbarProfileUpdated =>
      _t('editProfileSnackbarProfileUpdated');
  String get editProfileSnackbarEmailUpdated =>
      _t('editProfileSnackbarEmailUpdated');
  String get editProfileSnackbarPasswordNotConnected =>
      _t('editProfileSnackbarPasswordNotConnected');

  // Validation errors
  String get editProfileErrorEmailEmpty => _t('editProfileErrorEmailEmpty');
  String get editProfileErrorEmailInvalid => _t('editProfileErrorEmailInvalid');
  String get editProfileErrorNewPasswordEmpty =>
      _t('editProfileErrorNewPasswordEmpty');
  String get editProfileErrorConfirmPasswordEmpty =>
      _t('editProfileErrorConfirmPasswordEmpty');
  String get editProfileErrorPasswordsDoNotMatch =>
      _t('editProfileErrorPasswordsDoNotMatch');

  // Personalization option labels (display-only)
  String get personalizationSelfLearningLabel =>
      _t('personalizationSelfLearningLabel');
  String get personalizationTeachingLabel => _t('personalizationTeachingLabel');
  String get personalizationParentSupportLabel =>
      _t('personalizationParentSupportLabel');

  /// Maps persisted personalization keys to localized labels for display.
  ///
  /// Persisted values must remain stable and language-agnostic:
  /// '', 'Self-Learning', 'Teaching', 'Parent Support'.
  ///
  /// Fallback behavior:
  /// - empty/whitespace → [commonNoneLabel]
  /// - unknown keys → trimmed key
  String personalizationLabelForKey(String key) {
    final normalized = key.trim();
    if (normalized.isEmpty) return commonNoneLabel;

    switch (normalized.toLowerCase()) {
      case 'self-learning':
        return personalizationSelfLearningLabel;
      case 'teaching':
        return personalizationTeachingLabel;
      case 'parent support':
        return personalizationParentSupportLabel;
      default:
        return normalized;
    }
  }

  // ---------------------------
  // Achievements strings
  // ---------------------------

  String get achievementsTitle => _t('achievementsTitle');

  String achievementsHeaderMessage(String name) {
    return _template('achievementsHeaderMessage', {'name': name});
  }

  String get achievementsLockedLabel => _t('achievementsLockedLabel');

  String achievementsCompletedChallenge(String challenge) {
    return _template('achievementsCompletedChallenge', {
      'challenge': challenge,
    });
  }

  String get achievementsChallengeStayConsistent7Days =>
      _t('achievementsChallengeStayConsistent7Days');
  String get achievementsChallengeLearn5SignsOneWeek =>
      _t('achievementsChallengeLearn5SignsOneWeek');
  String get achievementsChallengeLearnBasicSigns =>
      _t('achievementsChallengeLearnBasicSigns');
  String get achievementsChallengeGet100Accuracy =>
      _t('achievementsChallengeGet100Accuracy');

  // ---------------------------
  // Internals
  // ---------------------------

  String _t(String key) {
    final byLang = _strings[langCode] ?? _strings[_en]!;
    return byLang[key] ?? _strings[_en]![key] ?? key;
  }

  static const Map<String, Map<String, String>> _strings = {
    _en: {
      // Sign in
      'signinWelcomeTitle': 'Welcome Back!',
      'signinWelcomeSubtitle': 'Good to see you again!',
      'signinEmailLabel': 'Email Address',
      'signinEmailHint': 'Enter email',
      'signinPasswordLabel': 'Password',
      'signinPasswordHint': 'Enter password',
      'signinLoginButtonLabel': 'Login',
      'signinDividerLabel': 'or sign up with',
      'signinFooterNoAccountLabel': "Don't have an account?",
      'signinFooterSignUpLabel': 'Sign up',
      'signinLoadingLoggingInLabel': 'Logging in',
      'signinLoadingPreparingDashboardLabel': 'Preparing your Dashboard',
      'signinErrorEmailRequired': 'Email is required',
      'signinErrorEmailInvalid': 'Enter a valid email address',
      'signinErrorPasswordRequired': 'Password is required',
      'signinErrorInvalidCredentials': 'Invalid credentials. Please try again.',

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

      // Practice Mirror
      'practiceMirrorTitle': 'Practice & Feedback',
      'practiceMirrorReferenceHeader': 'Reference Tutorial',
      'practiceMirrorReferenceTargetSubtitle': 'Target: {targetGestureName}',

      'practiceMirrorCameraPermissionTitle': 'Camera permission needed',
      'practiceMirrorCameraPermissionSubtitle':
          'Enable camera access to show live practice feed.',
      'practiceMirrorCameraUnavailableTitle': 'Camera unavailable',
      'practiceMirrorStartingCameraTitle': 'Starting camera…',
      'practiceMirrorStartingCameraSubtitle': 'Preparing live preview.',

      'practiceMirrorFpsBadge': '{fps} FPS',
      'practiceMirrorDetectedLabel': 'Detected: {detectedGestureLabel}',
      'practiceMirrorPausedLabel': 'Paused',
      'practiceMirrorProcessingLabel': 'Processing',

      'practiceMirrorLowLightPausedMessage':
          'Low light detected. Scoring paused.',
      'practiceMirrorLowLightImproveMessage':
          'Low light detected. Improve lighting for better scoring.',

      'practiceMirrorPerformanceCorrect': 'Correct',
      'practiceMirrorPerformanceAlmost': 'Almost',
      'practiceMirrorPerformanceIncorrect': 'Incorrect',

      'practiceMirrorNoCamerasAvailableError':
          'No cameras available on this device.',

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
      'communityNoCommentsYetMessage':
          'No comments yet. Be the first to comment!',
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
      'communitySnackbarDescriptionUpdateFailed':
          'Failed to update description.',
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
      'communityUploadTapToPickVideoSemanticHint':
          'Tap to open the video picker',

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

      // Profile
      'profileTitle': 'Profile',
      'profileAchievementsHeader': 'ACHIEVEMENTS',
      'profileAchievementStudious': 'Studious',
      'profileAchievementQuickie': 'Quickie',
      'profileAchievementAmbitious': 'Ambitious',
      'profileAchievementPerfectionist': 'Perfectionist',
      'profileDarkModeLabel': 'Dark Mode',
      'profileOfflineDownloadingLabel': 'Offline Downloading',
      'profileHighContrastLabel': 'High Contrast',
      'profileLanguageLabel': 'Language',
      'profileSelectLanguageTitle': 'Select Language',
      'languageEnglishLabel': 'English',
      'languageFilipinoLabel': 'Filipino',
      'profileDailyPracticeReminderLabel': 'Daily Practice Reminder',
      'profileLogoutLabel': 'Logout',
      'profileDefaultUserLabel': 'User',
      'profileNotSetLabel': 'Not set',
      'profileSelectTimeTitle': 'Select Time',
      'commonDoneLabel': 'Done',
      'commonNoneLabel': 'None',

      // Edit Profile
      'editProfileTitle': 'Edit Profile',

      'editProfileSectionProfileTitle': 'Profile',
      'editProfileSectionProfileDescription':
          'Update your name and personalization settings.',

      'editProfileSectionEmailTitle': 'Email',
      'editProfileSectionEmailDescription': 'Update your email address.',

      'editProfileSectionPasswordTitle': 'Password',
      'editProfileSectionPasswordDescription': 'Change your password.',

      'editProfileUserNameLabel': 'User name',
      'editProfileUserNameHint': 'Enter your name',

      'editProfilePersonalizationLabel': 'Personalization',
      'editProfilePersonalizationHint': 'Select an option',

      'editProfileSaveProfileButton': 'Save profile',

      'editProfileCurrentEmailPrefix': 'Current: ',
      'editProfileNewEmailLabel': 'New email',
      'editProfileNewEmailHint': 'Enter new email address',
      'editProfileUpdateEmailButton': 'Update email',

      'editProfileCurrentPasswordLabel': 'Current password',
      'editProfileCurrentPasswordHint': 'Enter current password',
      'editProfileNewPasswordLabel': 'New password',
      'editProfileNewPasswordHint': 'Enter a new password',
      'editProfileConfirmNewPasswordLabel': 'Confirm new password',
      'editProfileConfirmNewPasswordHint': 'Re-enter the new password',
      'editProfileChangePasswordButton': 'Change password',

      'editProfileShowPasswordTooltip': 'Show password',
      'editProfileHidePasswordTooltip': 'Hide password',

      'editProfileSnackbarProfileUpdated': 'Profile updated.',
      'editProfileSnackbarEmailUpdated': 'Email updated.',
      'editProfileSnackbarPasswordNotConnected':
          'Password change is not connected to the backend yet.',

      'editProfileErrorEmailEmpty': 'Email cannot be empty.',
      'editProfileErrorEmailInvalid': 'Enter a valid email address.',
      'editProfileErrorNewPasswordEmpty': 'New password cannot be empty.',
      'editProfileErrorConfirmPasswordEmpty':
          'Please confirm the new password.',
      'editProfileErrorPasswordsDoNotMatch': 'Passwords do not match.',

      'personalizationSelfLearningLabel': 'Self-Learning',
      'personalizationTeachingLabel': 'Teaching',
      'personalizationParentSupportLabel': 'Parent Support',

      // Achievements screen
      'achievementsTitle': 'Achievements',
      'achievementsHeaderMessage':
          'Great job, {name}! Complete your achievements to unlock more!',
      'achievementsLockedLabel': 'Not yet unlocked',
      'achievementsCompletedChallenge':
          'You completed the "{challenge}" challenge.',
      'achievementsChallengeStayConsistent7Days': 'Stay Consistent for 7 Days',
      'achievementsChallengeLearn5SignsOneWeek': 'Learn 5 Signs in One Week',
      'achievementsChallengeLearnBasicSigns': 'Learn the Basic Signs',
      'achievementsChallengeGet100Accuracy': 'Get 100% Accuracy',
    },
    _fil: {
      // Sign in
      'signinWelcomeTitle': 'Maligayang pagbabalik!',
      'signinWelcomeSubtitle': 'Masayang makita ka ulit!',
      'signinEmailLabel': 'Email Address',
      'signinEmailHint': 'Ilagay ang email',
      'signinPasswordLabel': 'Password',
      'signinPasswordHint': 'Ilagay ang password',
      'signinLoginButtonLabel': 'Mag-login',
      'signinDividerLabel': 'o mag-sign up sa',
      'signinFooterNoAccountLabel': 'Wala ka pang account?',
      'signinFooterSignUpLabel': 'Mag-sign up',
      'signinLoadingLoggingInLabel': 'Nagla-log in',
      'signinLoadingPreparingDashboardLabel': 'Inihahanda ang iyong Dashboard',
      'signinErrorEmailRequired': 'Kailangan ang email',
      'signinErrorEmailInvalid': 'Maglagay ng wastong email address',
      'signinErrorPasswordRequired': 'Kailangan ang password',
      'signinErrorInvalidCredentials':
          'Maling email o password. Pakisubukan muli.',

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
      'dictionarySubtitle':
          'Matuto ng mga bagong senyas at paghusayin ang iyong kasanayan',
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

      // Practice Mirror
      'practiceMirrorTitle': 'Praktis at Feedback',
      'practiceMirrorReferenceHeader': 'Sanggunian na Tutorial',
      'practiceMirrorReferenceTargetSubtitle': 'Target: {targetGestureName}',

      'practiceMirrorCameraPermissionTitle':
          'Kailangan ng pahintulot sa camera',
      'practiceMirrorCameraPermissionSubtitle':
          'I-enable ang access sa camera para maipakita ang live na feed ng praktis.',
      'practiceMirrorCameraUnavailableTitle': 'Hindi available ang camera',
      'practiceMirrorStartingCameraTitle': 'Sinisimulan ang camera…',
      'practiceMirrorStartingCameraSubtitle': 'Inihahanda ang live na preview.',

      'practiceMirrorFpsBadge': '{fps} FPS',
      'practiceMirrorDetectedLabel': 'Nadetect: {detectedGestureLabel}',
      'practiceMirrorPausedLabel': 'Naka-pause',
      'practiceMirrorProcessingLabel': 'Pinoproseso',

      'practiceMirrorLowLightPausedMessage':
          'Nadetect ang mababang liwanag. Naka-pause ang pag-iskor.',
      'practiceMirrorLowLightImproveMessage':
          'Nadetect ang mababang liwanag. Pagandahin ang ilaw para mas maayos ang pag-iskor.',

      'practiceMirrorPerformanceCorrect': 'Tama',
      'practiceMirrorPerformanceAlmost': 'Halos Tama',
      'practiceMirrorPerformanceIncorrect': 'Mali',

      'practiceMirrorNoCamerasAvailableError':
          'Walang available na camera sa device na ito.',

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
      'communityNoCommentsYetMessage':
          'Wala pang komento. Ikaw ang unang magkomento!',
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
      'communitySnackbarDescriptionUpdateFailed':
          'Hindi na-update ang paglalarawan.',
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
      'communityUploadSelectedVideoSemanticHint':
          'Iu-upload ang napiling video',
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
      'communityUploadFailureSnackbar':
          'Hindi natuloy ang pag-upload. Pakisubukan muli.',

      // Profile
      'profileTitle': 'Profile',
      'profileAchievementsHeader': 'MGA TAGUMPAY',
      'profileAchievementStudious': 'Masipag',
      'profileAchievementQuickie': 'Mabilis',
      'profileAchievementAmbitious': 'Mapaglayon',
      'profileAchievementPerfectionist': 'Perpeksiyonista',
      'profileDarkModeLabel': 'Madilim na Mode',
      'profileOfflineDownloadingLabel': 'Pag-download offline',
      'profileHighContrastLabel': 'Mataas na Kontrast',
      'profileLanguageLabel': 'Wika',
      'profileSelectLanguageTitle': 'Pumili ng Wika',
      'languageEnglishLabel': 'Ingles',
      'languageFilipinoLabel': 'Filipino',
      'profileDailyPracticeReminderLabel': 'Paalala sa Araw-araw na Praktis',
      'profileLogoutLabel': 'Mag-logout',
      'profileDefaultUserLabel': 'Gumagamit',
      'profileNotSetLabel': 'Hindi nakatakda',
      'profileSelectTimeTitle': 'Pumili ng Oras',
      'commonDoneLabel': 'Tapos',
      'commonNoneLabel': 'Wala',

      // Edit Profile
      'editProfileTitle': 'I-edit ang Profile',

      'editProfileSectionProfileTitle': 'Profile',
      'editProfileSectionProfileDescription':
          'I-update ang iyong pangalan at mga setting ng personalisasyon.',

      'editProfileSectionEmailTitle': 'Email',
      'editProfileSectionEmailDescription': 'I-update ang iyong email address.',

      'editProfileSectionPasswordTitle': 'Password',
      'editProfileSectionPasswordDescription': 'Palitan ang iyong password.',

      'editProfileUserNameLabel': 'Pangalan ng gumagamit',
      'editProfileUserNameHint': 'Ilagay ang iyong pangalan',

      'editProfilePersonalizationLabel': 'Personalisasyon',
      'editProfilePersonalizationHint': 'Pumili ng opsyon',

      'editProfileSaveProfileButton': 'I-save ang profile',

      'editProfileCurrentEmailPrefix': 'Kasalukuyan: ',
      'editProfileNewEmailLabel': 'Bagong email',
      'editProfileNewEmailHint': 'Ilagay ang bagong email address',
      'editProfileUpdateEmailButton': 'I-update ang email',

      'editProfileCurrentPasswordLabel': 'Kasalukuyang password',
      'editProfileCurrentPasswordHint': 'Ilagay ang kasalukuyang password',
      'editProfileNewPasswordLabel': 'Bagong password',
      'editProfileNewPasswordHint': 'Ilagay ang bagong password',
      'editProfileConfirmNewPasswordLabel': 'Kumpirmahin ang bagong password',
      'editProfileConfirmNewPasswordHint': 'Ilagay muli ang bagong password',
      'editProfileChangePasswordButton': 'Palitan ang password',

      'editProfileShowPasswordTooltip': 'Ipakita ang password',
      'editProfileHidePasswordTooltip': 'Itago ang password',

      'editProfileSnackbarProfileUpdated': 'Na-update ang profile.',
      'editProfileSnackbarEmailUpdated': 'Na-update ang email.',
      'editProfileSnackbarPasswordNotConnected':
          'Hindi pa nakakonekta sa backend ang pagpapalit ng password.',

      'editProfileErrorEmailEmpty': 'Hindi maaaring walang laman ang email.',
      'editProfileErrorEmailInvalid': 'Maglagay ng wastong email address.',
      'editProfileErrorNewPasswordEmpty':
          'Hindi maaaring walang laman ang bagong password.',
      'editProfileErrorConfirmPasswordEmpty':
          'Pakikumpirma ang bagong password.',
      'editProfileErrorPasswordsDoNotMatch':
          'Hindi magkapareho ang mga password.',

      'personalizationSelfLearningLabel': 'Sariling Pagkatuto',
      'personalizationTeachingLabel': 'Pagtuturo',
      'personalizationParentSupportLabel': 'Suporta ng Magulang',

      // Achievements screen
      'achievementsTitle': 'Mga Tagumpay',
      'achievementsHeaderMessage':
          'Magaling, {name}! Kumpletuhin ang iyong mga tagumpay para makapag-unlock pa!',
      'achievementsLockedLabel': 'Hindi pa nabubuksan',
      'achievementsCompletedChallenge':
          'Nakumpleto mo ang hamong "{challenge}".',
      'achievementsChallengeStayConsistent7Days':
          'Manatiling Konsistent sa loob ng 7 Araw',
      'achievementsChallengeLearn5SignsOneWeek':
          'Matuto ng 5 Senyas sa loob ng Isang Linggo',
      'achievementsChallengeLearnBasicSigns':
          'Matutunan ang Mga Batayang Senyas',
      'achievementsChallengeGet100Accuracy': 'Makakuha ng 100% Katumpakan',
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
