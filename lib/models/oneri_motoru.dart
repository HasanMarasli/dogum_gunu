import 'dart:math';

import 'package:dogum_gunu/models/dogum_gunu.dart';
import 'package:dogum_gunu/models/oneri_havuzu.dart';
import 'package:get_storage/get_storage.dart';

enum Butce { uygun, orta, ozel }

enum OneriTipi { hediye, surpriz }

class Oneri {
  const Oneri(
    this.anahtar,
    this.yasMin,
    this.yasMax, {
    required this.burclar,
    this.butce,
    this.cinsiyet,
    this.sadece = const {},
    this.samimi = false,
    this.uygun = const {},
    this.donum = const {},
  });

  final String anahtar;
  final int yasMin;
  final int yasMax;
  final Set<String> burclar;
  final Butce? butce;
  final Cinsiyet? cinsiyet;

  /// Doluysa yalnızca bu yakınlıklara önerilir (eş/sevgili, iş arkadaşı).
  final Set<Yakinlik> sadece;

  /// İş arkadaşına uygun olmayan kişisel öneriler.
  final bool samimi;

  /// Bu yakınlıklarda öne çıkar.
  final Set<Yakinlik> uygun;

  /// Doluysa yalnızca bu yaşlara girerken önerilir.
  final Set<int> donum;
}

class OneriMotoru {
  static const hediyeAdet = 4;
  static const surprizAdet = 3;

  static const _elementler = [
    ['aries', 'leo', 'sagittarius'],
    ['taurus', 'virgo', 'capricorn'],
    ['gemini', 'libra', 'aquarius'],
    ['cancer', 'scorpio', 'pisces'],
  ];

  static int adet(OneriTipi tip) =>
      tip == OneriTipi.hediye ? hediyeAdet : surprizAdet;

  /// Yaklaşan doğum gününde gireceği yaş.
  static int girecegiYas(DateTime dogum) =>
      DogumGunu.yasGetir(dogum) + (DogumGunu.kalanGun(dogum) == 0 ? 0 : 1);

  /// Burcun 10 günlük dönemi: aynı elementteki burçlardan biri o döneme eşlik
  /// eder, böylece aynı burcun farklı tarihleri farklı öneriler öne çıkarır.
  static String donemBurcu(DateTime dogum) {
    final burc = DogumGunu.burcIdGetir(dogum);
    // Yıl geçişi ve 29 Şubat hesabı bozmasın diye artık yıl kullanılır.
    var tarih = DateTime(2024, dogum.month, dogum.day);
    var gun = 0;
    while (DogumGunu.burcIdGetir(tarih.subtract(const Duration(days: 1))) ==
        burc) {
      tarih = tarih.subtract(const Duration(days: 1));
      gun++;
    }
    final grup = _elementler.firstWhere((e) => e.contains(burc));
    return grup[(grup.indexOf(burc) + min<int>(gun ~/ 10, 2)) % 3];
  }

  /// Kişiye uygun tüm öneriler, en uygundan başlayarak.
  static List<Oneri> sirala(DogumGunu kisi, OneriTipi tip, {Butce? butce}) {
    // Havuzun üst sınırı 99; daha büyük yaşlarda liste boş kalmasın.
    final yas = min<int>(girecegiYas(kisi.dogumTarihi), 99);
    final burc = DogumGunu.burcIdGetir(kisi.dogumTarihi);
    final donem = donemBurcu(kisi.dogumTarihi);
    final havuz = tip == OneriTipi.hediye ? hediyeHavuzu : surprizHavuzu;

    double puan(Oneri o) {
      var p = _karistir('${kisi.id}|${o.anahtar}') * 2.5;
      if (o.burclar.contains(burc)) p += 3;
      if (o.burclar.contains(donem)) p += 2;
      if (o.uygun.contains(kisi.yakinlik)) p += 3;
      if (o.sadece.isNotEmpty) p += 3;
      if (o.donum.isNotEmpty) p += 6;
      return p;
    }

    final uygunlar = havuz.where((o) {
      if (o.donum.isNotEmpty) {
        if (!o.donum.contains(yas)) return false;
      } else if (yas < o.yasMin || yas > o.yasMax) {
        return false;
      }
      if (o.cinsiyet != null && o.cinsiyet != kisi.cinsiyet) return false;
      if (o.sadece.isNotEmpty && !o.sadece.contains(kisi.yakinlik)) {
        return false;
      }
      if (o.samimi && kisi.yakinlik == Yakinlik.isArkadasi) return false;
      if (butce != null && o.butce != butce) return false;
      return true;
    }).toList();

    final puanlar = {for (final o in uygunlar) o: puan(o)};
    uygunlar.sort((a, b) => puanlar[b]!.compareTo(puanlar[a]!));
    return _cinsiyetiDagit(uygunlar, adet(tip));
  }

  /// Cinsiyete özel öneriler listeyi kaplamasın: her sayfada en fazla biri.
  static List<Oneri> _cinsiyetiDagit(List<Oneri> liste, int sayfa) {
    final ozel = liste.where((o) => o.cinsiyet != null).toList();
    final notr = liste.where((o) => o.cinsiyet == null).toList();
    final sonuc = <Oneri>[];
    var o = 0, n = 0;
    while (o < ozel.length && n < notr.length) {
      sonuc.add(ozel[o++]);
      for (var i = 1; i < sayfa && n < notr.length; i++) {
        sonuc.add(notr[n++]);
      }
    }
    return [...sonuc, ...notr.skip(n), ...ozel.skip(o)];
  }

  /// "Başka öner" turuna göre gösterilecek çeviri anahtarları.
  static List<String> sec(
    DogumGunu kisi,
    OneriTipi tip, {
    required int tur,
    Butce? butce,
  }) {
    final liste = sirala(kisi, tip, butce: butce);
    if (liste.isEmpty) return const [];
    final adetDeger = min(adet(tip), liste.length);
    final bas = (tur * adet(tip)) % liste.length;
    return [
      for (var i = 0; i < adetDeger; i++)
        liste[(bas + i) % liste.length].anahtar,
    ];
  }

  static int turGetir(String kisiId, OneriTipi tip) =>
      GetStorage().read<int>(_turAnahtari(kisiId, tip)) ?? 0;

  static void turArtir(String kisiId, OneriTipi tip) =>
      GetStorage().write(_turAnahtari(kisiId, tip), turGetir(kisiId, tip) + 1);

  static void turlariSil(String kisiId) {
    for (final tip in OneriTipi.values) {
      GetStorage().remove(_turAnahtari(kisiId, tip));
    }
  }

  static String _turAnahtari(String kisiId, OneriTipi tip) =>
      'oneri_tur.$kisiId.${tip.name}';

  /// Çalıştırmalar arasında sabit kalan FNV-1a; sonuç 0-1 arasıdır.
  static double _karistir(String metin) {
    var h = 0x811c9dc5;
    for (final c in metin.codeUnits) {
      h = ((h ^ c) * 0x01000193) & 0xffffffff;
    }
    return h / 0xffffffff;
  }
}
