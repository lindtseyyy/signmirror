import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:signmirror_flutter/l10n/app_strings.dart';
import 'package:signmirror_flutter/models/sign.dart';
import 'package:signmirror_flutter/providers/providers.dart';
import 'package:signmirror_flutter/providers/settings_provider.dart';
import 'package:signmirror_flutter/screens/dictionary_sign_screen.dart';
import 'package:signmirror_flutter/theme/app_theme.dart';
import 'package:signmirror_flutter/widgets/bookmark_icon_button.dart';

class BookmarkedSignsScreen extends ConsumerWidget {
  const BookmarkedSignsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookmarkedSigns = ref.watch(bookmarkedSignsProvider);
    final settings = ref.watch(themeSettingsProvider);

    final effectiveHighContrast =
        settings.highContrast || MediaQuery.of(context).highContrast;

    final resolvedTheme = AppTheme.resolve(
      mode: settings.mode,
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

          final emptyTextStyle = useLegacyLightColors
              ? null
              : theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onBackground,
                  fontWeight: effectiveHighContrast ? FontWeight.w600 : null,
                );

          return Scaffold(
            appBar: AppBar(
              title: const Text(
                'Bookmarked Signs',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
              ),
              backgroundColor: appBarBackground,
              foregroundColor: appBarForeground,
              elevation: 4,
            ),
            body: Padding(
              padding: const EdgeInsetsGeometry.fromLTRB(15, 20, 15, 0),
              child: bookmarkedSigns.isEmpty
                  ? Center(
                      child: Text(
                        'No bookmarked signs.',
                        style: emptyTextStyle,
                        textAlign: TextAlign.center,
                      ),
                    )
                  : _BookmarkedSignsList(
                      signs: bookmarkedSigns,
                      useLegacyLightColors: useLegacyLightColors,
                      effectiveHighContrast: effectiveHighContrast,
                    ),
            ),
          );
        },
      ),
    );
  }
}

class _BookmarkedSignsList extends ConsumerWidget {
  final List<Sign> signs;
  final bool useLegacyLightColors;
  final bool effectiveHighContrast;

  const _BookmarkedSignsList({
    required this.signs,
    required this.useLegacyLightColors,
    required this.effectiveHighContrast,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final strings = AppStrings(ref.watch(languageProvider));

    final cardColor = useLegacyLightColors ? Colors.white : colorScheme.surface;

    final titleColor = useLegacyLightColors ? null : colorScheme.onSurface;

    final subtitleColor = useLegacyLightColors
        ? Colors.black.withValues(alpha: 0.4)
        : (effectiveHighContrast
              ? colorScheme.onSurface
              : colorScheme.onSurface.withOpacity(0.7));

    final borderSide = useLegacyLightColors
        ? null
        : BorderSide(
            color: effectiveHighContrast
                ? colorScheme.onSurface
                : colorScheme.outline,
            width: effectiveHighContrast ? 2 : 1,
          );

    String displayTitleFor(Sign sign) {
      return (strings.isFilipino && (sign.titleFil?.trim().isNotEmpty ?? false))
          ? sign.titleFil!.trim()
          : sign.title;
    }

    String sortKeyFor(Sign sign) => displayTitleFor(sign).trim().toLowerCase();

    final sortedSigns = List<Sign>.of(signs)
      ..sort((a, b) {
        final titleCompare = sortKeyFor(a).compareTo(sortKeyFor(b));
        if (titleCompare != 0) return titleCompare;
        return a.id.compareTo(b.id);
      });

    return ListView.builder(
      itemCount: sortedSigns.length,
      itemBuilder: (context, index) {
        final sign = sortedSigns[index];

        final displayTitle = displayTitleFor(sign);

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(8),
            border: borderSide == null
                ? null
                : Border.fromBorderSide(borderSide),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0))],
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
                      strings.dictionaryCategorySubtitleForDisplay(
                        sign.category,
                      ),
                      style: TextStyle(color: subtitleColor),
                    ),
                  ],
                ),
              ],
            ),
            trailing: BookmarkIconButton(
              isBookmarked: true,
              onPressed: () async {
                await ref.read(signsProvider.notifier).toggleBookmark(sign);
                await ref.read(bookmarkedSignsProvider.notifier).loadAll();
              },
              tooltip: 'Remove bookmark',
            ),
          ),
        );
      },
    );
  }
}
