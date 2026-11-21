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

  /// Liste bunun altına düşmemeli; tarafsız (yakınlık bilinmeyen) kişilerde
  /// kişisel öneri elemesi bu sınırı bozuyorsa geri alınır.
  static const enAz = 8;

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
    // Artık olmayan referans yılı kullanılır; 29 Şubat, 28 Şubat'a eşlenir.
    final gunNo = dogum.month == 2 && dogum.day == 29 ? 28 : dogum.day;
    var tarih = DateTime(2023, dogum.month, gunNo);
    var gun = 0;
    while (DogumGunu.burcIdGetir(DateTime(2023, tarih.month, tarih.day - 1)) ==
        burc) {
      tarih = DateTime(2023, tarih.month, tarih.day - 1);
      gun++;
    }
    final grup = _elementler.firstWhere((e) => e.contains(burc));
    return grup[(grup.indexOf(burc) + min<int>(gun ~/ 10, 2)) % 3];
  }

  /// Kişiye uygun tüm öneriler; sayfa sayfa dizilmiştir (bkz. [sec]).
  static List<Oneri> sirala(DogumGunu kisi, OneriTipi tip, {Butce? butce}) {
    final gercekYas = girecegiYas(kisi.dogumTarihi);
    // Bugün doğana da 1 yaş önerileri çıkar; 99 da havuzun üst sınırı.
    final yas = gercekYas.clamp(1, 99);
    // Dönüm noktası öğeleri 100. yaşa (üst sınır 110) kadar eşleşir.
    final donumYasi = gercekYas.clamp(1, 110);
    final burc = DogumGunu.burcIdGetir(kisi.dogumTarihi);
    final donem = donemBurcu(kisi.dogumTarihi);
    final havuz = tip == OneriTipi.hediye ? hediyeHavuzu : surprizHavuzu;
    final yakinlik = kisi.yakinlik;
    final tarafsiz = yakinlik == null || yakinlik == Yakinlik.diger;

    double puan(Oneri o) {
      var p = _karistir('${kisi.id}|${o.anahtar}') * 2.5;
      if (o.burclar.contains(burc)) p += 3;
      if (o.burclar.contains(donem)) p += 2;
      if (o.uygun.contains(yakinlik)) p += 3;
      if (o.sadece.isNotEmpty) p += 3;
      if (o.donum.isNotEmpty) p += 6;
      // Yakınlığı belirsizse kimseye özel olmayan öneriler öne çıkar.
      if (tarafsiz && o.uygun.isEmpty && !o.samimi) p += 1.5;
      return p;
    }

    List<Oneri> suz({required bool samimiEle}) => havuz.where((o) {
      if (o.donum.isNotEmpty) {
        if (!o.donum.contains(donumYasi)) return false;
      } else if (yas < o.yasMin || yas > o.yasMax) {
        return false;
      }
      if (o.cinsiyet != null && o.cinsiyet != kisi.cinsiyet) return false;
      if (o.sadece.isNotEmpty && !o.sadece.contains(yakinlik)) {
        return false;
      }
      if (samimiEle && o.samimi) return false;
      if (butce != null && o.butce != butce) return false;
      return true;
    }).toList();

    // İş arkadaşına kişisel öneri çıkmaz; yakınlık bilinmiyorsa da kişisel
    // öneriler elenir, ancak liste çok kısalırsa geri alınır.
    var uygunlar = suz(samimiEle: yakinlik == Yakinlik.isArkadasi || tarafsiz);
    if (tarafsiz && uygunlar.length < enAz) uygunlar = suz(samimiEle: false);

    final puanlar = {for (final o in uygunlar) o: puan(o)};
    uygunlar.sort((a, b) => puanlar[b]!.compareTo(puanlar[a]!));
    return _sayfala(uygunlar, adet(tip));
  }

  static int _sayfaSayisi(int uzunluk, int sayfa) =>
      uzunluk > sayfa ? max(2, uzunluk ~/ sayfa) : 1;

  /// Listeyi tekrarsız sayfalara böler: artan öğeler sayfalara dağıtılır,
  /// bir sayfada aynı temadan birden fazla öğe ve cinsiyete özel birden fazla
  /// öğe bulunmaz (başka seçenek kalmadıysa kural gevşetilir).
  static List<Oneri> _sayfala(List<Oneri> sirali, int sayfaBoyu) {
    final n = sirali.length;
    final sayfaAdedi = _sayfaSayisi(n, sayfaBoyu);
    final kalan = [...sirali];
    final sonuc = <Oneri>[];
    for (var p = 0; p < sayfaAdedi; p++) {
      final boy = (p + 1) * n ~/ sayfaAdedi - p * n ~/ sayfaAdedi;
      final temalar = <String>{};
      var cinsiyetli = false;
      for (var i = 0; i < boy; i++) {
        bool temaTamam(Oneri o) => !temalar.contains(_tema(o.anahtar));
        final cinsiyetliAra = i == 0;
        var ix = kalan.indexWhere(
          (o) =>
              (cinsiyetliAra ? o.cinsiyet != null : o.cinsiyet == null) &&
              temaTamam(o),
        );
        if (ix < 0) {
          ix = kalan.indexWhere(
            (o) => (cinsiyetli ? o.cinsiyet == null : true) && temaTamam(o),
          );
        }
        if (ix < 0) {
          ix = kalan.indexWhere((o) => cinsiyetli ? o.cinsiyet == null : true);
        }
        if (ix < 0) ix = 0;
        final secilen = kalan.removeAt(ix);
        temalar.add(_tema(secilen.anahtar));
        if (secilen.cinsiyet != null) cinsiyetli = true;
        sonuc.add(secilen);
      }
    }
    return sonuc;
  }

  /// Aynı sayfada birlikte çıkmaması gereken öneri grupları.
  static const _temalar = {
    'gift.bezKitap': 'kitap',
    'gift.masalKitabi': 'kitap',
    'gift.romanSerisi': 'kitap',
    'gift.kitapMacera': 'kitap',
    'gift.gencKitap': 'kitap',
    'gift.kitap': 'kitap',
    'gift.kitap18': 'kitap',
    'gift.eKitap': 'kitap',
    'gift.bulmaca': 'kitap',
    'gift.kahveCekirdek': 'kahve',
    'gift.kahveMakinesi': 'kahve',
    'gift.kahveCihazi': 'kahve',
    'gift.kupaSeti': 'kahve',
    'surprise.ofisKahve': 'kahve',
    'surprise.sevdigiKafe': 'kahve',
    'gift.cerceve': 'foto',
    'gift.fotoKitabi': 'foto',
    'gift.dijitalCerceve': 'foto',
    'gift.polaroid': 'foto',
    'gift.anilar50': 'foto',
    'gift.anilar60': 'foto',
    'gift.yuzYilFoto': 'foto',
    'surprise.bebekAlbum': 'foto',
    'surprise.gencFotoDuvar': 'foto',
    'surprise.eskiFotograf': 'foto',
    'gift.parfumK': 'parfum',
    'gift.parfumE': 'parfum',
    'gift.gencParfumK': 'parfum',
    'gift.gencParfumE': 'parfum',
    'gift.bluetoothKulaklik': 'kulaklik',
    'gift.kulaklikPro': 'kulaklik',
    'gift.klavye': 'kulaklik',
    'gift.kolyeK': 'taki',
    'gift.altinTakiK': 'taki',
    'gift.sadeTaki': 'taki',
    'gift.saat': 'saat',
    'gift.saatDuvar': 'saat',
    'gift.akilliBileklik': 'saat',
    'gift.hafSonuKacamak': 'seyahat',
    'gift.ciftKacamak': 'seyahat',
    'gift.seyahat50': 'seyahat',
    'gift.deneyim30': 'seyahat',
    'gift.bavul18': 'seyahat',
    'gift.kutuOyunu': 'masaOyunu',
    'gift.masaOyunu': 'masaOyunu',
    'gift.kutuStrateji': 'masaOyunu',
    'gift.hafizaOyunu': 'masaOyunu',
    'gift.buyukBlok': 'blok',
    'gift.ahsapBlok': 'blok',
    'gift.manyetikSeti': 'blok',
    'gift.boyamaSeti': 'boya',
    'gift.sulBoya': 'boya',
    'gift.cizimSeti': 'boya',
    'gift.cizimTahtasi': 'boya',
    'gift.bakimSeti': 'bakim',
    'gift.ciltBakimK': 'bakim',
    'gift.spa': 'bakim',
    'gift.masajAleti': 'bakim',
    'gift.sporCanta': 'canta',
    'gift.sirtCantasi': 'canta',
    'gift.cocukCanta': 'canta',
    'gift.elCantasiK': 'canta',
    'gift.cantaAksesuar': 'canta',
    'gift.bisiklet': 'tekerlek',
    'gift.paten': 'tekerlek',
    'gift.kaykay': 'tekerlek',
    'gift.scooter': 'tekerlek',
    'gift.dengeBisikleti': 'tekerlek',
    'gift.itmeliYurutec': 'tekerlek',
    'surprise.kisiselMektup': 'mektup',
    'surprise.askMektup': 'mektup',
    'surprise.bebekMektup': 'mektup',
    'surprise.mektup18': 'mektup',
    'surprise.yuzYilMektup': 'mektup',
    'surprise.kahvalti': 'yemek',
    'surprise.sevdigiYemek': 'yemek',
    'surprise.aileYemek': 'yemek',
    'surprise.isOgle': 'yemek',
    'surprise.romantikOda': 'yemek',
    'surprise.pastaYapmak': 'pasta',
    'surprise.bebekPasta': 'pasta',
    'surprise.ofisPasta': 'pasta',
    'surprise.favoriTatli': 'pasta',
    'surprise.miniParti': 'parti',
    'surprise.gencParti': 'parti',
    'surprise.kostumParti': 'parti',
    'surprise.konsept': 'parti',
    'surprise.yarimAsir': 'parti',
    'surprise.yuzYil': 'parti',
    'surprise.ofisKart': 'kart',
    'surprise.imzaKart': 'kart',
    'surprise.isTesekkur': 'kart',
    'surprise.notSeti': 'kart',
    'surprise.sinemaEv': 'film',
    'surprise.gencFilm': 'film',
    'surprise.gencGezi': 'gezi',
    'surprise.anlikPlan': 'gezi',
    'surprise.sehirTuru': 'gezi',
    'surprise.dogaYuruyus': 'gezi',
    'surprise.parkPiknik': 'gezi',
    'surprise.bebekPiknik': 'gezi',
    'surprise.anilar30': 'anilar',
    'surprise.anilar40': 'anilar',
    'surprise.altmis': 'anilar',
    'surprise.videoAile': 'anilar',
    'surprise.gencVideo': 'anilar',
    'surprise.mesajKoleksiyon': 'anilar',
  };

  static String _tema(String anahtar) => _temalar[anahtar] ?? anahtar;

  /// "Başka öner" turuna göre gösterilecek çeviri anahtarları. Her tur ayrı
  /// bir sayfadır; son sayfadan sonra başa dönülür, sayfalar arasında tekrar yok.
  static List<String> sec(
    DogumGunu kisi,
    OneriTipi tip, {
    required int tur,
    Butce? butce,
  }) {
    final liste = sirala(kisi, tip, butce: butce);
    if (liste.isEmpty) return const [];
    final n = liste.length;
    final sayfaAdedi = _sayfaSayisi(n, adet(tip));
    final p = tur % sayfaAdedi;
    return [
      for (final o in liste.sublist(
        p * n ~/ sayfaAdedi,
        (p + 1) * n ~/ sayfaAdedi,
      ))
        o.anahtar,
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
