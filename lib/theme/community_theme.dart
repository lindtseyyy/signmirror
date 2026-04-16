import 'package:flutter/material.dart';

@immutable
class CommunityTheme extends ThemeExtension<CommunityTheme> {
  /// Scaffold/page background used by Community screens.
  final Color pageBackgroundColor;

  /// Default card surface used for community posts and related panels.
  final Color cardBackgroundColor;

  /// Sub-surface used inside cards (e.g. description bubble / neutral chips).
  final Color cardSubsurfaceColor;

  /// Background for modal sheets (e.g. comments sheet).
  final Color sheetBackgroundColor;

  /// Background for dialogs (e.g. video dialog container).
  final Color dialogBackgroundColor;

  /// Fill color for the search field in Community.
  final Color searchFieldFillColor;

  /// Fill color for the comment input field.
  final Color commentFieldFillColor;

  /// Generic outline color (borders, separators) used by Community UI.
  final Color outlineColor;

  /// Divider/separator color used by Community sheets.
  final Color dividerColor;

  /// Drag handle color for modal sheets.
  final Color sheetHandleColor;

  /// Neutral badge/chip background (e.g. approvals count chip).
  final Color badgeNeutralBackgroundColor;

  /// Approved badge background.
  final Color badgeApprovedBackgroundColor;

  /// Approved badge border color.
  final Color badgeApprovedBorderColor;

  /// Approved badge text/icon color.
  final Color badgeApprovedContentColor;

  /// Pending/unapproved badge border color.
  final Color badgePendingBorderColor;

  /// Primary action color for Community interactions (e.g. send icon).
  final Color primaryActionColor;

  const CommunityTheme({
    required this.pageBackgroundColor,
    required this.cardBackgroundColor,
    required this.cardSubsurfaceColor,
    required this.sheetBackgroundColor,
    required this.dialogBackgroundColor,
    required this.searchFieldFillColor,
    required this.commentFieldFillColor,
    required this.outlineColor,
    required this.dividerColor,
    required this.sheetHandleColor,
    required this.badgeNeutralBackgroundColor,
    required this.badgeApprovedBackgroundColor,
    required this.badgeApprovedBorderColor,
    required this.badgeApprovedContentColor,
    required this.badgePendingBorderColor,
    required this.primaryActionColor,
  });

  @override
  CommunityTheme copyWith({
    Color? pageBackgroundColor,
    Color? cardBackgroundColor,
    Color? cardSubsurfaceColor,
    Color? sheetBackgroundColor,
    Color? dialogBackgroundColor,
    Color? searchFieldFillColor,
    Color? commentFieldFillColor,
    Color? outlineColor,
    Color? dividerColor,
    Color? sheetHandleColor,
    Color? badgeNeutralBackgroundColor,
    Color? badgeApprovedBackgroundColor,
    Color? badgeApprovedBorderColor,
    Color? badgeApprovedContentColor,
    Color? badgePendingBorderColor,
    Color? primaryActionColor,
  }) {
    return CommunityTheme(
      pageBackgroundColor: pageBackgroundColor ?? this.pageBackgroundColor,
      cardBackgroundColor: cardBackgroundColor ?? this.cardBackgroundColor,
      cardSubsurfaceColor: cardSubsurfaceColor ?? this.cardSubsurfaceColor,
      sheetBackgroundColor: sheetBackgroundColor ?? this.sheetBackgroundColor,
      dialogBackgroundColor:
          dialogBackgroundColor ?? this.dialogBackgroundColor,
      searchFieldFillColor: searchFieldFillColor ?? this.searchFieldFillColor,
      commentFieldFillColor:
          commentFieldFillColor ?? this.commentFieldFillColor,
      outlineColor: outlineColor ?? this.outlineColor,
      dividerColor: dividerColor ?? this.dividerColor,
      sheetHandleColor: sheetHandleColor ?? this.sheetHandleColor,
      badgeNeutralBackgroundColor:
          badgeNeutralBackgroundColor ?? this.badgeNeutralBackgroundColor,
      badgeApprovedBackgroundColor:
          badgeApprovedBackgroundColor ?? this.badgeApprovedBackgroundColor,
      badgeApprovedBorderColor:
          badgeApprovedBorderColor ?? this.badgeApprovedBorderColor,
      badgeApprovedContentColor:
          badgeApprovedContentColor ?? this.badgeApprovedContentColor,
      badgePendingBorderColor:
          badgePendingBorderColor ?? this.badgePendingBorderColor,
      primaryActionColor: primaryActionColor ?? this.primaryActionColor,
    );
  }

  @override
  CommunityTheme lerp(ThemeExtension<CommunityTheme>? other, double t) {
    if (other is! CommunityTheme) return this;

    return CommunityTheme(
      pageBackgroundColor: Color.lerp(
        pageBackgroundColor,
        other.pageBackgroundColor,
        t,
      )!,
      cardBackgroundColor: Color.lerp(
        cardBackgroundColor,
        other.cardBackgroundColor,
        t,
      )!,
      cardSubsurfaceColor: Color.lerp(
        cardSubsurfaceColor,
        other.cardSubsurfaceColor,
        t,
      )!,
      sheetBackgroundColor: Color.lerp(
        sheetBackgroundColor,
        other.sheetBackgroundColor,
        t,
      )!,
      dialogBackgroundColor: Color.lerp(
        dialogBackgroundColor,
        other.dialogBackgroundColor,
        t,
      )!,
      searchFieldFillColor: Color.lerp(
        searchFieldFillColor,
        other.searchFieldFillColor,
        t,
      )!,
      commentFieldFillColor: Color.lerp(
        commentFieldFillColor,
        other.commentFieldFillColor,
        t,
      )!,
      outlineColor: Color.lerp(outlineColor, other.outlineColor, t)!,
      dividerColor: Color.lerp(dividerColor, other.dividerColor, t)!,
      sheetHandleColor: Color.lerp(
        sheetHandleColor,
        other.sheetHandleColor,
        t,
      )!,
      badgeNeutralBackgroundColor: Color.lerp(
        badgeNeutralBackgroundColor,
        other.badgeNeutralBackgroundColor,
        t,
      )!,
      badgeApprovedBackgroundColor: Color.lerp(
        badgeApprovedBackgroundColor,
        other.badgeApprovedBackgroundColor,
        t,
      )!,
      badgeApprovedBorderColor: Color.lerp(
        badgeApprovedBorderColor,
        other.badgeApprovedBorderColor,
        t,
      )!,
      badgeApprovedContentColor: Color.lerp(
        badgeApprovedContentColor,
        other.badgeApprovedContentColor,
        t,
      )!,
      badgePendingBorderColor: Color.lerp(
        badgePendingBorderColor,
        other.badgePendingBorderColor,
        t,
      )!,
      primaryActionColor: Color.lerp(
        primaryActionColor,
        other.primaryActionColor,
        t,
      )!,
    );
  }
}
