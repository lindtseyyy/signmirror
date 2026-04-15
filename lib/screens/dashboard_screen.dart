import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:signmirror_flutter/models/practice_stats.dart';
import 'package:signmirror_flutter/models/sign.dart';
import 'package:signmirror_flutter/providers/providers.dart';
import 'package:signmirror_flutter/providers/settings_provider.dart';
import 'package:signmirror_flutter/screens/dictionary_sign_screen.dart';
import 'package:signmirror_flutter/constants/route_names.dart';
import 'package:signmirror_flutter/theme/app_theme.dart';
import '../widgets//dynamic_bar_chart.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  Sign? _resolveSignByTitle(List<Sign> signs, String title) {
    final normalized = title.trim().toLowerCase();
    for (final sign in signs) {
      if (sign.title.trim().toLowerCase() == normalized) {
        return sign;
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final signs = ref.watch(signsProvider);
    final progress = ref.watch(practiceStatsProvider);
    final themeSettings = ref.watch(themeSettingsProvider);

    final resolvedTheme = AppTheme.resolve(
      mode: themeSettings.mode,
      highContrast: themeSettings.highContrast,
    );

    final letterASign = _resolveSignByTitle(signs, 'Letter A');
    final letterBSign = _resolveSignByTitle(signs, 'Letter B');

    final VoidCallback? onTapLetterA = (letterASign == null)
        ? null
        : () {
            final sign = letterASign;
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => DictionarySignScreen(sign: sign),
              ),
            );
          };

    final VoidCallback? onTapLetterB = (letterBSign == null)
        ? null
        : () {
            final sign = letterBSign;
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => DictionarySignScreen(sign: sign),
              ),
            );
          };

    return Theme(
      data: resolvedTheme,
      child: Builder(
        builder: (context) {
          final theme = Theme.of(context);
          final colorScheme = theme.colorScheme;
          final textTheme = theme.textTheme;

          return Scaffold(
            appBar: PreferredSize(
              preferredSize: const Size.fromHeight(50.0),
              child: AppBar(
                automaticallyImplyLeading: false,
                title: const Text(
                  "Dashboard",
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 22),
                ),
              ),
            ),
            body: SafeArea(
              child: SizedBox(
                width: double.infinity,
                child: SingleChildScrollView(
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          height: 175,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: colorScheme.primary,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Padding(
                            padding: const EdgeInsetsGeometry.symmetric(
                              horizontal: 25,
                              vertical: 15,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "DAILY CHALLENGE",
                                  style: TextStyle(
                                    color: colorScheme.onPrimary.withOpacity(
                                      0.8,
                                    ),
                                    fontWeight: FontWeight.w700,
                                    fontSize: 12,
                                  ),
                                ),
                                const SizedBox(height: 20),
                                Text(
                                  "Master the basics",
                                  style: TextStyle(
                                    color: colorScheme.onPrimary,
                                    fontSize: 20,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                Text(
                                  "Complete 5 alphabet signs today",
                                  style: TextStyle(
                                    color: colorScheme.onPrimary.withOpacity(
                                      0.6,
                                    ),
                                    fontSize: 12,
                                  ),
                                ),
                                const SizedBox(height: 20),
                                FilledButton(
                                  onPressed: () {
                                    Navigator.of(
                                      context,
                                    ).pushNamed(RouteNames.practiceMirror);
                                  },
                                  style: FilledButton.styleFrom(
                                    shape: const RoundedRectangleBorder(
                                      borderRadius: BorderRadiusGeometry.all(
                                        Radius.circular(10),
                                      ),
                                    ),
                                    minimumSize: const Size(
                                      double.infinity,
                                      40,
                                    ),
                                  ),
                                  child: const Text(
                                    "PRACTICE NOW",
                                    style: TextStyle(
                                      fontFamily: 'Inter',
                                      fontWeight: FontWeight.w700,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        progress.when(
                          data: (stats) => _ProgressSummaryCard(stats: stats),
                          loading: () => const _ProgressSummaryLoading(),
                          error: (e, _) => _ProgressSummaryError(message: '$e'),
                        ),
                        const SizedBox(height: 20),
                        DynamicBarChart(
                          labels: [
                            'Mon',
                            'Tue',
                            'Wed',
                            'Thu',
                            'Fri',
                            'Sat',
                            'Sun',
                          ],
                          data: [
                            [12, 18],
                            [10, 14],
                            [15, 9],
                            [11, 15],
                            [8, 12],
                            [20, 18],
                            [14, 16],
                          ],
                        ),
                        const SizedBox(height: 25),
                        Text(
                          "STRUGGLED SIGN THIS WEEK",
                          style: textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurface.withOpacity(0.6),
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 7),
                        SizedBox(
                          width: double.infinity,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              StruggledSign(
                                signTitle: 'Letter A',
                                percentage: 45,
                                onTap: onTapLetterA,
                              ),
                              const SizedBox(height: 10),
                              StruggledSign(
                                signTitle: 'Letter B',
                                percentage: 52,
                                onTap: onTapLetterB,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class StruggledSign extends StatelessWidget {
  final String signTitle;
  final int percentage;
  final VoidCallback? onTap;

  const StruggledSign({
    super.key,
    required this.signTitle,
    required this.percentage,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      height: 50,
      decoration: BoxDecoration(
        color: isDark ? colorScheme.surfaceVariant : colorScheme.surface,
        border: Border.all(
          color: colorScheme.outline.withOpacity(isDark ? 0.10 : 0.14),
          width: 1,
        ),
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withOpacity(0.2),
            blurRadius: 3,
            offset: const Offset(1, 1),
          ),
        ],
      ),
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  signTitle,
                  style: textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: colorScheme.onSurface,
                  ),
                ),
                Text(
                  percentage.toString() + ("% Accurracy"),
                  style: textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w300,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ProgressSummaryCard extends StatelessWidget {
  final PracticeStats stats;

  const _ProgressSummaryCard({required this.stats});

  String _formatPercent(double value) {
    if (value.isNaN || value.isInfinite) return '0%';
    final rounded = value.round();
    return '$rounded%';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final showMock = stats.totalAttempts == 0;

    final signsLearnedValue = showMock
        ? '8'
        : stats.learnedSigns.length.toString();
    final avgAccuracy = showMock
        ? '76%'
        : _formatPercent(stats.averageAccuracyRate);
    final streakValue = showMock ? '3d' : '${stats.streak}d';
    final attemptsValue = showMock ? '18' : stats.totalAttempts.toString();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? colorScheme.surfaceVariant : colorScheme.surface,
        border: Border.all(
          color: colorScheme.outline.withOpacity(isDark ? 0.10 : 0.12),
          width: 1,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withOpacity(0.12),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'PROGRESS',
            style: TextStyle(
              color: colorScheme.onSurface.withOpacity(0.6),
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _ProgressMetricTile(
                  label: 'Signs learned',
                  value: signsLearnedValue,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _ProgressMetricTile(
                  label: 'Avg accuracy',
                  value: avgAccuracy,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _ProgressMetricTile(
                  label: 'Practice streak',
                  value: streakValue,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _ProgressMetricTile(
                  label: 'Total attempts',
                  value: attemptsValue,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ProgressMetricTile extends StatelessWidget {
  final String label;
  final String value;

  const _ProgressMetricTile({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? colorScheme.surface : colorScheme.surfaceVariant,
        border: Border.all(
          color: colorScheme.outline.withOpacity(isDark ? 0.10 : 0.14),
          width: 1,
        ),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: colorScheme.onSurfaceVariant.withOpacity(0.8),
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _ProgressSummaryLoading extends StatelessWidget {
  const _ProgressSummaryLoading();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? colorScheme.surfaceVariant : colorScheme.surface,
        border: Border.all(
          color: colorScheme.outline.withOpacity(isDark ? 0.10 : 0.12),
          width: 1,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Center(
        child: SizedBox(
          height: 24,
          width: 24,
          child: CircularProgressIndicator(strokeWidth: 3),
        ),
      ),
    );
  }
}

class _ProgressSummaryError extends StatelessWidget {
  final String message;

  const _ProgressSummaryError({required this.message});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? colorScheme.surfaceVariant : colorScheme.surface,
        border: Border.all(
          color: colorScheme.outline.withOpacity(isDark ? 0.10 : 0.12),
          width: 1,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        'Unable to load progress: $message',
        style: TextStyle(color: colorScheme.error),
      ),
    );
  }
}
