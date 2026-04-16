import 'package:flutter/material.dart';

/// Reusable `InputDecoration` builder that matches the Signin/Signup text field
/// styling (radius 10, always-floating label, grey enabled border, primary
/// focused border, red error borders) while maintaining good contrast in dark
/// mode.
InputDecoration signMirrorInputDecoration({
  required String label,
  required String hint,
  required ColorScheme colors,
  String? errorText,
  Widget? suffixIcon,
}) {
  final bool isDark = colors.brightness == Brightness.dark;

  // In light mode, keep the exact hint color used by the Login fields.
  // In dark mode, derive from the theme to preserve contrast.
  final Color hintColor = isDark
      ? colors.onSurfaceVariant.withOpacity(0.75)
      : const Color(0xffB3B3B3);

  // Keep the enabled border "grey" in light mode (to match Login); in dark
  // mode use the theme's outline color so borders remain visible.
  final Color enabledBorderColor = isDark
      ? colors.outline.withOpacity(0.75)
      : Colors.grey;

  // In dark mode, the app's `primary` can be quite deep, which reads as a dark
  // border even when focused. Boost the lightness so focus is clearly visible.
  final hslPrimary = HSLColor.fromColor(colors.primary);
  final Color focusBorderColor = isDark
      ? hslPrimary
            .withLightness((hslPrimary.lightness + 0.25).clamp(0.6, 1.0))
            .toColor()
      : colors.primary;

  OutlineInputBorder border(Color color, double width) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: BorderSide(color: color, width: width),
    );
  }

  return InputDecoration(
    labelText: label,
    hintText: hint,
    errorText: errorText,
    floatingLabelBehavior: FloatingLabelBehavior.always,
    hintStyle: TextStyle(color: hintColor),

    // Label color ("field name"). Keep it readable in dark mode, and highlight
    // it on focus to match the focused border.
    labelStyle: TextStyle(color: colors.onSurfaceVariant),
    floatingLabelStyle: TextStyle(
      color: errorText != null ? colors.error : focusBorderColor,
    ),

    enabledBorder: border(enabledBorderColor, 1.0),
    focusedBorder: border(focusBorderColor, 1.5),
    errorBorder: border(Colors.red, 1.0),
    focusedErrorBorder: border(Colors.red, 1.5),
    suffixIcon: suffixIcon,
  );
}
