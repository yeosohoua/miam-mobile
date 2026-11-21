import 'package:flutter/material.dart';

/// Couleur de marque (identique en clair et en sombre).
class AppColors {
  const AppColors._();
  static const brandPink = Color(0xFFFF1160);
}

/// Palette dependante du theme (clair / sombre), releve sur les captures.
/// Enregistree comme ThemeExtension: le changement de theme s'anime tout seul.
@immutable
class MiamColors extends ThemeExtension<MiamColors> {
  const MiamColors({
    required this.background,
    required this.title,
    required this.subtitle,
    required this.field,
    required this.fieldFilled,
    required this.error,
    required this.primary,
    required this.onPrimary,
    required this.disabled,
    required this.onDisabled,
    required this.outline,
    required this.caret,
  });

  final Color background;
  final Color title;
  final Color subtitle;
  final Color field;
  final Color fieldFilled;
  final Color error;
  final Color primary;
  final Color onPrimary;
  final Color disabled;
  final Color onDisabled;
  final Color outline;
  final Color caret;

  static const dark = MiamColors(
    background: Color(0xFF000000),
    title: Color(0xFFFFFFFF),
    subtitle: Color(0xFFB4B4B4),
    field: Color(0xFF404040),
    fieldFilled: Color(0xFF333333),
    error: Color(0xFFE8705F),
    primary: Color(0xFFFFFFFF),
    onPrimary: Color(0xFF000000),
    disabled: Color(0xFF626262),
    onDisabled: Color(0xFF000000),
    outline: Color(0xFF555555),
    caret: Color(0xFF9A9A9A),
  );

  static const light = MiamColors(
    background: Color(0xFFFFFFFF),
    title: Color(0xFF000000),
    subtitle: Color(0xFF868686),
    field: Color(0xFFEFEFEF),
    fieldFilled: Color(0xFFE6E6E6),
    error: Color(0xFFE8705F),
    primary: Color(0xFF000000),
    onPrimary: Color(0xFFFFFFFF),
    disabled: Color(0xFF9D9D9D),
    onDisabled: Color(0xFFFFFFFF),
    outline: Color(0xFFDEDEDE),
    caret: Color(0xFF8A8A8A),
  );

  static MiamColors of(BuildContext context) =>
      Theme.of(context).extension<MiamColors>() ?? dark;

  @override
  MiamColors copyWith({
    Color? background,
    Color? title,
    Color? subtitle,
    Color? field,
    Color? fieldFilled,
    Color? error,
    Color? primary,
    Color? onPrimary,
    Color? disabled,
    Color? onDisabled,
    Color? outline,
    Color? caret,
  }) =>
      MiamColors(
        background: background ?? this.background,
        title: title ?? this.title,
        subtitle: subtitle ?? this.subtitle,
        field: field ?? this.field,
        fieldFilled: fieldFilled ?? this.fieldFilled,
        error: error ?? this.error,
        primary: primary ?? this.primary,
        onPrimary: onPrimary ?? this.onPrimary,
        disabled: disabled ?? this.disabled,
        onDisabled: onDisabled ?? this.onDisabled,
        outline: outline ?? this.outline,
        caret: caret ?? this.caret,
      );

  @override
  MiamColors lerp(ThemeExtension<MiamColors>? other, double t) {
    if (other is! MiamColors) return this;
    Color l(Color a, Color b) => Color.lerp(a, b, t)!;
    return MiamColors(
      background: l(background, other.background),
      title: l(title, other.title),
      subtitle: l(subtitle, other.subtitle),
      field: l(field, other.field),
      fieldFilled: l(fieldFilled, other.fieldFilled),
      error: l(error, other.error),
      primary: l(primary, other.primary),
      onPrimary: l(onPrimary, other.onPrimary),
      disabled: l(disabled, other.disabled),
      onDisabled: l(onDisabled, other.onDisabled),
      outline: l(outline, other.outline),
      caret: l(caret, other.caret),
    );
  }
}
