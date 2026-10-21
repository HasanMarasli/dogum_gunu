import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import 'renkler.dart';

class TemaYoneticisi extends GetxController {
  TemaYoneticisi(this._box);

  final GetStorage _box;
  static const _key = 'theme_key';
  static const _koyuModKey = 'dark_mode';

  static const String baslikFontu = 'BricolageGrotesque';
  static const String metinFontu = 'Figtree';

  Map<String, Color> get palettes =>
      paletler.map((key, palet) => MapEntry(key, palet.seed));

  late String currentKey;
  late bool koyuMod;

  @override
  void onInit() {
    currentKey = _box.read<String>(_key) ?? 'purple';
    if (!paletler.containsKey(currentKey)) currentKey = 'purple';
    koyuMod = _box.read<bool>(_koyuModKey) ?? false;
    super.onInit();
  }

  Palet get _palet => paletler[currentKey]!;

  ThemeMode get themeMode => koyuMod ? ThemeMode.dark : ThemeMode.light;

  ThemeData get themeData => _tema(Brightness.light);

  ThemeData get darkThemeData => _tema(Brightness.dark);

  Color get gradientStart =>
      _palet.tonlar(koyuMod ? Brightness.dark : Brightness.light).g1;
  Color get gradientEnd =>
      _palet.tonlar(koyuMod ? Brightness.dark : Brightness.light).g2;

  ThemeData _tema(Brightness parlaklik) {
    final p = _palet.tonlar(parlaklik);
    final r = AppRenkler.olustur(p, parlaklik);
    final scheme = ColorScheme(
      brightness: parlaklik,
      primary: p.pr,
      onPrimary: p.onPr,
      primaryContainer: p.pc,
      onPrimaryContainer: p.onPc,
      secondary: p.pr,
      onSecondary: p.onPr,
      secondaryContainer: p.pc,
      onSecondaryContainer: p.onPc,
      tertiary: p.g2,
      onTertiary: Colors.white,
      error: r.err,
      onError: r.onErr,
      errorContainer: r.errc,
      onErrorContainer: r.onErrc,
      surface: r.bg,
      onSurface: r.tx,
      onSurfaceVariant: r.tx2,
      surfaceContainerLowest: r.s1,
      surfaceContainerLow: r.s1,
      surfaceContainer: r.s2,
      surfaceContainerHigh: r.s3,
      surfaceContainerHighest: r.raised,
      outline: r.bd2,
      outlineVariant: r.bd,
      scrim: r.scrim,
      shadow: Colors.black,
      inverseSurface: r.tx,
      onInverseSurface: r.bg,
      inversePrimary: p.pc,
    );

    final metin = _metinTemasi(r.tx);

    return ThemeData(
      useMaterial3: true,
      brightness: parlaklik,
      colorScheme: scheme,
      fontFamily: metinFontu,
      textTheme: metin,
      scaffoldBackgroundColor: r.bg,
      extensions: [r],
      appBarTheme: AppBarTheme(
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: r.bg,
        foregroundColor: r.tx,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: metin.titleLarge,
      ),
      cardTheme: CardThemeData(
        color: r.s1,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: r.raised,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: r.raised,
        surfaceTintColor: Colors.transparent,
        elevation: 6,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        textStyle: TextStyle(
          fontFamily: metinFontu,
          fontWeight: FontWeight.w500,
          fontSize: 15,
          color: r.tx,
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: r.raised,
        surfaceTintColor: Colors.transparent,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(64, 48),
          shape: const StadiumBorder(),
          textStyle: metin.labelLarge,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          minimumSize: const Size(48, 40),
          shape: const StadiumBorder(),
          textStyle: metin.labelLarge,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: r.s1,
        hintStyle: TextStyle(color: r.tx3),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: r.bd2, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: p.pr, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: r.err, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: r.err, width: 1.5),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: p.pr,
        foregroundColor: p.onPr,
        extendedTextStyle: metin.labelLarge,
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: p.pr,
        circularTrackColor: p.pc,
      ),
      dividerTheme: DividerThemeData(color: r.bd, thickness: 1, space: 1),
      switchTheme: SwitchThemeData(
        trackOutlineColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected) ? p.pr : r.bd2,
        ),
      ),
      checkboxTheme: CheckboxThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(7)),
        side: BorderSide(color: r.bd2, width: 2),
      ),
    );
  }

  TextTheme _metinTemasi(Color renk) {
    TextStyle b(double boyut, double yukseklik, double harf) => TextStyle(
          fontFamily: baslikFontu,
          fontWeight: FontWeight.w700,
          fontSize: boyut,
          height: yukseklik / boyut,
          letterSpacing: boyut * harf,
          color: renk,
        );
    TextStyle f(FontWeight agirlik, double boyut, double yukseklik,
            [double harf = 0]) =>
        TextStyle(
          fontFamily: metinFontu,
          fontWeight: agirlik,
          fontSize: boyut,
          height: yukseklik / boyut,
          letterSpacing: boyut * harf,
          color: renk,
        );
    return TextTheme(
      displayLarge: b(56, 60, -0.03),
      displayMedium: b(48, 52, -0.025),
      displaySmall: b(40, 44, -0.02),
      headlineLarge: b(32, 38, -0.01),
      headlineMedium: b(28, 34, -0.01),
      headlineSmall: b(24, 30, 0),
      titleLarge: b(22, 28, 0),
      titleMedium: f(FontWeight.w600, 17, 24),
      titleSmall: f(FontWeight.w600, 15, 20),
      bodyLarge: f(FontWeight.w400, 16, 24),
      bodyMedium: f(FontWeight.w400, 14, 20),
      bodySmall: f(FontWeight.w400, 12, 16, 0.01),
      labelLarge: f(FontWeight.w600, 15, 20, 0.01),
      labelMedium: f(FontWeight.w600, 12, 16, 0.02),
      labelSmall: f(FontWeight.w500, 11, 14, 0.02),
    );
  }

  void setTheme(String key) {
    if (!paletler.containsKey(key)) return;
    currentKey = key;
    _box.write(_key, key);
    update();
  }

  void setKoyuMod(bool deger) {
    koyuMod = deger;
    _box.write(_koyuModKey, deger);
    update();
  }
}
