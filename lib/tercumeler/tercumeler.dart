import 'package:dogum_gunu/tercumeler/tr.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class Tercumeler extends Translations {
  // Desteklenen dillerin listesi
  static Map<String, Locale> diller = {
    "Türkçe": const Locale("tr"),
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
      };

  static void menuDiliSec() {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0), // Köşe yuvarlama değeri
        ),
        content: Container(
          constraints: const BoxConstraints(maxHeight: 250),
          child: Scrollbar(
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: diller.entries.map((entry) {
                  var dilAdi = entry.key;
                  var locale = entry.value;
                  return Column(
                    children: [
                      ListTile(
                        title: Text(dilAdi),
                        onTap: () {
                          Get.find<DilSecimiController>().dilDegistir(locale.toString());
                          Get.back(); // Dialogu kapatır
                        },
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class DilSecimiController extends GetxController {
  // Dil seçimi yapıldığında Locale güncelleyen bir metot
  void dilDegistir(String dilKodu) {
    var locale = Locale(dilKodu.split('_').first, dilKodu.split('_').last);
    Get.updateLocale(locale);
  }
}
