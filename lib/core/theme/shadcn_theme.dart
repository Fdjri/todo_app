import 'package:shadcn_flutter/shadcn_flutter.dart' as shadcn;

/// Maps the Coquette palette to shadcn_flutter ThemeData.
class ShadcnCoquetteTheme {
  ShadcnCoquetteTheme._();

  /// Light Coquette shadcn theme
  static shadcn.ThemeData light({shadcn.ColorScheme? colorSchemeOverride}) {
    final scheme = colorSchemeOverride ??
        shadcn.ColorSchemes.lightZinc; // neutral base, we override primary

    return shadcn.ThemeData(
      colorScheme: scheme,
      radius: 0.5, // medium border radius
    );
  }

  /// Dark Coquette shadcn theme
  static shadcn.ThemeData dark({shadcn.ColorScheme? colorSchemeOverride}) {
    final scheme = colorSchemeOverride ??
        shadcn.ColorSchemes.darkZinc;

    return shadcn.ThemeData(
      colorScheme: scheme,
      radius: 0.5,
    );
  }
}
