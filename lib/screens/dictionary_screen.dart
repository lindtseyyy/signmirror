import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:signmirror_flutter/constants/route_names.dart';
import 'package:signmirror_flutter/l10n/app_strings.dart';
import 'package:signmirror_flutter/models/sign.dart';
import 'package:signmirror_flutter/providers/providers.dart';
import 'package:signmirror_flutter/providers/settings_provider.dart';
import 'package:signmirror_flutter/screens/dictionary_sign_screen.dart';
import 'package:signmirror_flutter/theme/app_theme.dart';
import 'package:signmirror_flutter/widgets/bookmark_icon_button.dart';

class DictionaryScreen extends ConsumerStatefulWidget {
  const DictionaryScreen({super.key});

  @override
  ConsumerState<DictionaryScreen> createState() => _DictionaryScreenState();
}

class _DictionaryScreenState extends ConsumerState<DictionaryScreen> {
  String selectedDifficulty = "All categories";

  String searchQuery = "";

  final List<String> categories = [
    'All Categories',
    'Alphabet',
    'Numbers',
    'Greetings',
    'Emergency',
    'Basic Gestures',
  ];

  @override
  Widget build(BuildContext context) {
    final signs = ref.watch(signsProvider);
    final themeSettings = ref.watch(themeSettingsProvider);
    final strings = AppStrings(ref.watch(languageProvider));

    final effectiveHighContrast =
        themeSettings.highContrast || MediaQuery.of(context).highContrast;

    final resolvedTheme = AppTheme.resolve(
      mode: themeSettings.mode,
      highContrast: effectiveHighContrast,
    );

    return Theme(
      data: resolvedTheme,
      child: Builder(
        builder: (context) {
          final theme = Theme.of(context);
          final colorScheme = theme.colorScheme;

          final isDark = theme.brightness == Brightness.dark;
          final useLegacyLightColors = !isDark && !effectiveHighContrast;

          final appBarBackground = useLegacyLightColors
              ? const Color(0xff304166)
              : colorScheme.primary;
          final appBarForeground = useLegacyLightColors
              ? Colors.white
              : colorScheme.onPrimary;

          final searchBackground = useLegacyLightColors
              ? Colors.white
              : (isDark ? colorScheme.surfaceVariant : colorScheme.surface);
          final searchForeground = useLegacyLightColors
              ? Colors.black
              : (isDark ? colorScheme.onSurfaceVariant : colorScheme.onSurface);
          final searchBorderColor = useLegacyLightColors
              ? const Color(0xff304166)
              : (effectiveHighContrast
                    ? colorScheme.onSurface
                    : colorScheme.outline);
          final searchBorderWidth = useLegacyLightColors
              ? 0.5
              : (effectiveHighContrast ? 2.0 : 1.0);

          return Scaffold(
            appBar: PreferredSize(
              preferredSize: const Size.fromHeight(120.0),
              child: AppBar(
                automaticallyImplyLeading: false,
                backgroundColor: appBarBackground,
                foregroundColor: appBarForeground,
                elevation: 4,
                title: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      strings.dictionaryTitle,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 22,
                      ),
                    ),
                    Text(
                      strings.dictionarySubtitle,
                      style: TextStyle(
                        fontSize: 12,
                        color: useLegacyLightColors
                            ? Colors.white70
                            : appBarForeground.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
                bottom: PreferredSize(
                  preferredSize: const Size.fromHeight(50.0),
                  child: Padding(
                    padding: const EdgeInsetsGeometry.fromLTRB(15, 10, 15, 15),
                    child: SearchBar(
                      onChanged: (value) {
                        ref.read(signsProvider.notifier).search(value);
                      },
                      constraints: const BoxConstraints(
                        minHeight: 45.0,
                        maxHeight: 45.0,
                      ),
                      hintText: strings.dictionarySearchHint,
                      backgroundColor: WidgetStateProperty.all<Color>(
                        searchBackground,
                      ),
                      elevation: WidgetStateProperty.all<double>(0),
                      padding: WidgetStateProperty.all<EdgeInsetsGeometry>(
                        const EdgeInsets.symmetric(horizontal: 16),
                      ),
                      leading: Icon(Icons.search, color: searchForeground),
                      textStyle: WidgetStateProperty.all<TextStyle>(
                        TextStyle(color: searchForeground),
                      ),
                      hintStyle: WidgetStateProperty.all<TextStyle>(
                        TextStyle(
                          color: useLegacyLightColors
                              ? Colors.black.withValues(alpha: 0.5)
                              : searchForeground.withOpacity(0.6),
                        ),
                      ),
                      shape: WidgetStateProperty.all<OutlinedBorder>(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5),
                          side: BorderSide(
                            width: searchBorderWidth,
                            color: searchBorderColor,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                actions: [
                  IconButton(
                    iconSize: 30,
                    icon: Icon(Icons.bookmark, color: appBarForeground),
                    onPressed: () {
                      Navigator.pushNamed(context, RouteNames.bookmarkedSigns);
                    },
                  ),
                  const SizedBox(width: 5),
                ],
              ),
            ),
            body: Padding(
              padding: const EdgeInsetsGeometry.fromLTRB(15, 20, 15, 0),
              child: _buildListView(
                ref,
                signs,
                theme: theme,
                effectiveHighContrast: effectiveHighContrast,
                useLegacyLightColors: useLegacyLightColors,
              ),
            ),
          );
        },
      ),
    );
  }
}

Widget _buildListView(
  WidgetRef ref,
  List<Sign> signs, {
  required ThemeData theme,
  required bool effectiveHighContrast,
  required bool useLegacyLightColors,
}) {
  final strings = AppStrings(ref.watch(languageProvider));

  final colorScheme = theme.colorScheme;

  final tileBackground = useLegacyLightColors
      ? Colors.white
      : colorScheme.surface;
  final tileBorderColor = useLegacyLightColors
      ? null
      : (effectiveHighContrast ? colorScheme.onSurface : colorScheme.outline);
  final tileBorderWidth = useLegacyLightColors
      ? 0.0
      : (effectiveHighContrast ? 2.0 : 1.0);

  final titleColor = useLegacyLightColors ? null : colorScheme.onSurface;
  final subtitleColor = useLegacyLightColors
      ? Colors.black.withValues(alpha: 0.4)
      : colorScheme.onSurface.withOpacity(0.7);

  return ListView.builder(
    itemCount: signs.length,
    itemBuilder: (context, index) {
      final sign = signs[index];

      final titleFil = (sign.titleFil ?? '').trim();
      final displayTitle = strings.isFilipino && titleFil.isNotEmpty
          ? titleFil
          : sign.title;

      return Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: tileBackground,
          borderRadius: BorderRadius.circular(8),
          border: tileBorderColor == null
              ? null
              : Border.all(color: tileBorderColor, width: tileBorderWidth),
          boxShadow: useLegacyLightColors
              ? [BoxShadow(color: Colors.black.withValues(alpha: 0))]
              : const [],
        ),
        child: ListTile(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => DictionarySignScreen(sign: sign),
              ),
            );
          },
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 0,
          ),
          title: Text(
            displayTitle,
            style: TextStyle(fontWeight: FontWeight.w700, color: titleColor),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 5,
            children: [
              Row(
                children: [
                  Text(
                    strings.dictionaryCategorySubtitleForDisplay(sign.category),
                    style: TextStyle(color: subtitleColor),
                  ),
                ],
              ),
            ],
          ),
          trailing: BookmarkIconButton(
            isBookmarked: sign.isBookmarked,
            onPressed: () async {
              await ref.read(signsProvider.notifier).toggleBookmark(sign);
              await ref.read(bookmarkedSignsProvider.notifier).loadAll();
            },
          ),
        ),
      );
    },
  );
}
