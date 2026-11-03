import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:dogum_gunu/tercumeler/tr.dart';
import 'package:dogum_gunu/tercumeler/en.dart';

/// Sayı 1 ise tekil (`.one`) anahtarı kullanır; "1 days" gibi hataları önler.
String trSayi(String anahtar, int sayi, Map<String, String> degerler) =>
    (sayi == 1 ? '$anahtar.one' : anahtar).trParams(degerler);

class Tercumeler extends Translations {
  // Desteklenen dillerin listesi
  static Map<String, Locale> diller = {
    "Türkçe": const Locale("tr"),
    "English": const Locale("en"),
  };

  // Locale'den dil adını döner
  static String? dilAdVer(Locale value) {
    for (var entry in diller.entries) {
      if (entry.value == value) {
        return entry.key;
      }
    }
    return null; // Değer bulunamazsa null döner
  }

  @override
  Map<String, Map<String, String>> get keys => {
        'tr': tr,
        'en': en,
      };
}

class DilSecimiController extends GetxController {
  DilSecimiController(this._box);
  final GetStorage _box;

  static const _localeKey = 'selected_locale';

  Locale? readStoredLocale() {
    final saved = _box.read<String>(_localeKey);
    if (saved == null || saved.isEmpty) return null;
    final parts = saved.split('_');
    return Locale(parts.first, parts.length > 1 ? parts.last : null);
  }

  // Dil seçimi yapıldığında Locale güncelleyen bir metot
  void dilDegistir(String dilKodu) {
    var parcalar = dilKodu.split('_');
    var locale =
        Locale(parcalar.first, parcalar.length > 1 ? parcalar.last : null);
    _box.write(_localeKey, dilKodu);
    Get.updateLocale(locale);
  }
}
