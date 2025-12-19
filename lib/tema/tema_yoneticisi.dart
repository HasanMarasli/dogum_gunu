import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class TemaYoneticisi extends GetxController {
  TemaYoneticisi(this._box);

  final GetStorage _box;
  static const _key = 'theme_key';

  final Map<String, Color> palettes = {
    'purple': const Color(0xFF5B55F6), // doygun mor
    'teal': const Color(0xFF11998E), // derin turkuaz
    'orange': const Color(0xFFFB8C00), // sıcak turuncu
    'blue': const Color(0xFF2962FF), // canlı mavi
    'coral': const Color(0xFFFF5C8D), // güçlü mercan
    'lime': const Color(0xFF6FBF73), // ferah yeşil
  };

  late String currentKey;

  @override
  void onInit() {
    currentKey = _box.read<String>(_key) ?? 'purple';
    super.onInit();
  }

  ThemeData get themeData {
    final seed = palettes[currentKey] ?? palettes['purple']!;
    final scheme = ColorScheme.fromSeed(
      seedColor: seed,
      brightness: Brightness.light,
    );
    return ThemeData(
      colorScheme: scheme,
      scaffoldBackgroundColor: const Color(0xFFF6F7FB),
      appBarTheme: AppBarTheme(
        centerTitle: false,
        elevation: 0,
        backgroundColor: gradientStart,
        foregroundColor: Colors.white,
        titleTextStyle: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w700,
          fontSize: 18,
        ),
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        shadowColor: Colors.black.withOpacity(0.06),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: scheme.primary,
        contentTextStyle: const TextStyle(color: Colors.white),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: scheme.primary,
        foregroundColor: Colors.white,
        extendedTextStyle: const TextStyle(fontWeight: FontWeight.w700),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: scheme.primary.withOpacity(0.08),
        labelStyle: TextStyle(color: scheme.primary),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      fontFamily: 'Kalam',
      useMaterial3: true,
    );
  }

  Color get gradientStart => _shade(palettes[currentKey] ?? palettes['purple']!, -0.08);
  Color get gradientEnd => _shade(palettes[currentKey] ?? palettes['purple']!, 0.14);

  Color _shade(Color color, double amount) {
    final hsl = HSLColor.fromColor(color);
    final lightness = (hsl.lightness + amount).clamp(0.0, 1.0);
    return hsl.withLightness(lightness).toColor();
  }

  void setTheme(String key) {
    if (!palettes.containsKey(key)) return;
    currentKey = key;
    _box.write(_key, key);
    update();
    Get.changeTheme(themeData);
  }
}
