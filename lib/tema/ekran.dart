import 'dart:math' as math;

import 'package:flutter/widgets.dart';

/// Pencere genişliğine göre düzen sınıfı (Material pencere sınıflarıyla aynı
/// eşikler): telefon < 600 ≤ küçük tablet < 840 ≤ büyük tablet.
enum EkranSinifi { telefon, kucukTablet, buyukTablet }

/// Responsive düzenin ortak ölçüleri. Sayfalar sabit genişlik yerine
/// buradaki eşik ve azami genişlikleri kullanır.
abstract final class Ekran {
  static const double kucukTabletEsik = 600;
  static const double buyukTabletEsik = 840;

  /// Bu yüksekliğin altındaki yatay pencere "alçak" sayılır (yatay telefon);
  /// sayfalar dikey yığın yerine yan yana düzene geçer.
  static const double alcakEsik = 500;

  /// Metin ağırlıklı içerik (ayarlar, tek sütun liste) için okunur genişlik.
  static const double okunurGenislik = 640;

  /// Form ekranları (kişi ekle/düzenle) için azami genişlik.
  static const double formGenislik = 600;

  /// Çok sütunlu ızgara ve iki sütunlu sayfalar için azami genişlik.
  static const double genisIcerik = 1200;

  /// Diyalog ve alt sayfa azami genişlikleri.
  static const double diyalogGenislik = 480;
  static const double altSayfaGenislik = 560;

  /// Üstten kayan mesaj kartının azami genişliği.
  static const double mesajGenislik = 560;

  /// Ana sayfa kartının sütuna bölünmeden önceki en küçük genişliği.
  static const double kartMinGenislik = 340;
  static const double sutunAraligi = 12;

  static EkranSinifi sinif(double genislik) {
    if (genislik >= buyukTabletEsik) return EkranSinifi.buyukTablet;
    if (genislik >= kucukTabletEsik) return EkranSinifi.kucukTablet;
    return EkranSinifi.telefon;
  }

  /// Ekran kenarından içeriğe en az bırakılacak boşluk.
  static double kenarBoslugu(double genislik) => switch (sinif(genislik)) {
    EkranSinifi.telefon => 20,
    EkranSinifi.kucukTablet => 32,
    EkranSinifi.buyukTablet => 40,
  };

  /// İçeriği [azami] genişlikte ortalamak için gereken yatay dolgu. Kaydırma
  /// alanı ekranın tamamında kalsın diye kısıtlama yerine dolgu olarak verilir.
  static double yatayDolgu(double genislik, {double azami = okunurGenislik}) =>
      math.max(kenarBoslugu(genislik), (genislik - azami) / 2);

  /// [icerikGenisligi] içine en az [kartMinGenislik] genişlikte kaç kart sığar.
  static int sutunSayisi(double icerikGenisligi, {int azami = 3}) =>
      ((icerikGenisligi + sutunAraligi) / (kartMinGenislik + sutunAraligi))
          .floor()
          .clamp(1, azami);
}

extension EkranBaglami on BuildContext {
  Size get _pencere => MediaQuery.sizeOf(this);

  EkranSinifi get ekranSinifi => Ekran.sinif(_pencere.width);

  /// Cihaz tablet boyutunda mı (yönden bağımsız, kısa kenara göre).
  bool get tabletMi => _pencere.shortestSide >= Ekran.kucukTabletEsik;

  /// Yatay ve kısa pencere (yatay telefon): yan yana düzen kullanılır.
  bool alcakMi([double esik = Ekran.alcakEsik]) =>
      _pencere.height < esik && _pencere.width > _pencere.height;
}

/// Çocuğunu [azami] genişlikle sınırlayıp yatayda ortalar.
class OkunurGenislik extends StatelessWidget {
  const OkunurGenislik({
    super.key,
    this.azami = Ekran.okunurGenislik,
    this.hizalama = Alignment.topCenter,
    required this.child,
  });

  final double azami;
  final AlignmentGeometry hizalama;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: hizalama,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: azami),
        child: child,
      ),
    );
  }
}
