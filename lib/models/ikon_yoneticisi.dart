import 'dart:io';

import 'package:dogum_gunu/models/dogum_gunu.dart';
import 'package:dogum_gunu/veriTabani/dogum_gunu_veri_tabani.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

/// iOS'ta bugün birinin doğum günüyse uygulama ikonunu kutlama ikonuna çevirir.
///
/// Android'de bu iş native tarafta gece yarısı alarmıyla yapılır; iOS ikon
/// değişimine yalnızca uygulama ön plandayken izin verdiği için burada
/// açılışta ve uygulamaya her dönüşte kontrol edilir.
class IkonYoneticisi with WidgetsBindingObserver {
  IkonYoneticisi._();

  static const _kanal = MethodChannel('dogum_gunu/ikon');

  static void baslat() {
    if (!Platform.isIOS) return;
    final yonetici = IkonYoneticisi._();
    WidgetsBinding.instance.addObserver(yonetici);
    yonetici._guncelle();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _guncelle();
  }

  Future<void> _guncelle() async {
    try {
      final liste = await DogumGunuVeriTabani.tumVerileriGetir();
      final dogumGunuVar = liste.any(
        (kisi) => DogumGunu.kalanGun(kisi.dogumTarihi) == 0,
      );
      await _kanal.invokeMethod('ikonAyarla', dogumGunuVar);
    } on PlatformException {
      // İkon değişmezse uygulama normal çalışmaya devam eder.
    } on MissingPluginException {
      // Native taraf kanalı kaydetmediyse ikon varsayılan kalır.
    } catch (hata, yigin) {
      FlutterError.reportError(
        FlutterErrorDetails(
          exception: hata,
          stack: yigin,
          library: 'ikon',
          context: ErrorDescription('uygulama ikonu güncellenemedi'),
        ),
      );
    }
  }
}
