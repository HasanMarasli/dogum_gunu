import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:dogum_gunu/veriTabani/dogum_gunu_veri_tabani.dart';

class DogumGunu {
  String id;
  String isim;
  DateTime dogumTarihi;

  DogumGunu({
    required this.id,
    required this.dogumTarihi,
    required this.isim,
  });

  /// 29 Şubat doğumlular artık olmayan yıllarda 28 Şubat'ta kutlanır.
  static DateTime yildakiDogumGunu(DateTime dogum, int yil) {
    if (dogum.month == 2 && dogum.day == 29) {
      final artik = (yil % 4 == 0 && yil % 100 != 0) || yil % 400 == 0;
      return DateTime(yil, 2, artik ? 29 : 28);
    }
    return DateTime(yil, dogum.month, dogum.day);
  }

  /// Bir sonraki doğum gününe kalan gün; bugünse 0.
  static int kalanGun(DateTime dogum) {
    final simdi = DateTime.now();
    final bugun = DateTime(simdi.year, simdi.month, simdi.day);
    var sonraki = yildakiDogumGunu(dogum, bugun.year);
    if (sonraki.isBefore(bugun)) {
      sonraki = yildakiDogumGunu(dogum, bugun.year + 1);
    }
    // Yaz saati geçişlerinde saat farkı gün hesabını bozmasın.
    return (sonraki.difference(bugun).inHours / 24).round();
  }

  /// Kişinin bugünkü yaşı; bu yılki doğum günü gelmediyse bir eksik.
  static int yasGetir(DateTime dogum) {
    final simdi = DateTime.now();
    final bugun = DateTime(simdi.year, simdi.month, simdi.day);
    final yas = bugun.year - dogum.year;
    return bugun.isBefore(yildakiDogumGunu(dogum, bugun.year)) ? yas - 1 : yas;
  }

  static String burcIdGetir(DateTime tarih) {
    final gun = tarih.day;
    final ay = tarih.month;

    if ((ay == 1 && gun >= 20) || (ay == 2 && gun <= 18)) {
      return 'aquarius';
    } else if ((ay == 2 && gun >= 19) || (ay == 3 && gun <= 20)) {
      return 'pisces';
    } else if ((ay == 3 && gun >= 21) || (ay == 4 && gun <= 19)) {
      return 'aries';
    } else if ((ay == 4 && gun >= 20) || (ay == 5 && gun <= 20)) {
      return 'taurus';
    } else if ((ay == 5 && gun >= 21) || (ay == 6 && gun <= 20)) {
      return 'gemini';
    } else if ((ay == 6 && gun >= 21) || (ay == 7 && gun <= 22)) {
      return 'cancer';
    } else if ((ay == 7 && gun >= 23) || (ay == 8 && gun <= 22)) {
      return 'leo';
    } else if ((ay == 8 && gun >= 23) || (ay == 9 && gun <= 22)) {
      return 'virgo';
    } else if ((ay == 9 && gun >= 23) || (ay == 10 && gun <= 22)) {
      return 'libra';
    } else if ((ay == 10 && gun >= 23) || (ay == 11 && gun <= 21)) {
      return 'scorpio';
    } else if ((ay == 11 && gun >= 22) || (ay == 12 && gun <= 21)) {
      return 'sagittarius';
    } else if ((ay == 12 && gun >= 22) || (ay == 1 && gun <= 19)) {
      return 'capricorn';
    } else {
      return 'unknown';
    }
  }

  static String burcIconGetir(DateTime tarih) {
    int gun = tarih.day;
    int ay = tarih.month;
    String yol = "assets/svg/burclar/";

    if ((ay == 1 && gun >= 20) || (ay == 2 && gun <= 18)) {
      return "${yol}aquarius.svg";
    } else if ((ay == 2 && gun >= 19) || (ay == 3 && gun <= 20)) {
      return "${yol}pisces.svg";
    } else if ((ay == 3 && gun >= 21) || (ay == 4 && gun <= 19)) {
      return "${yol}aries.svg";
    } else if ((ay == 4 && gun >= 20) || (ay == 5 && gun <= 20)) {
      return "${yol}taurus.svg";
    } else if ((ay == 5 && gun >= 21) || (ay == 6 && gun <= 20)) {
      return "${yol}gemini.svg";
    } else if ((ay == 6 && gun >= 21) || (ay == 7 && gun <= 22)) {
      return "${yol}cancer.svg";
    } else if ((ay == 7 && gun >= 23) || (ay == 8 && gun <= 22)) {
      return "${yol}leo.svg";
    } else if ((ay == 8 && gun >= 23) || (ay == 9 && gun <= 22)) {
      return "${yol}virgo.svg";
    } else if ((ay == 9 && gun >= 23) || (ay == 10 && gun <= 22)) {
      return "${yol}libra.svg";
    } else if ((ay == 10 && gun >= 23) || (ay == 11 && gun <= 21)) {
      return "${yol}scorpio.svg";
    } else if ((ay == 11 && gun >= 22) || (ay == 12 && gun <= 21)) {
      return "${yol}sagittarius.svg";
    } else if ((ay == 12 && gun >= 22) || (ay == 1 && gun <= 19)) {
      return "${yol}capricorn.svg";
    } else {
      return "Invalid date!";
    }
  }

  static String burcIsimGetir(DateTime tarih) {
    int gun = tarih.day;
    int ay = tarih.month;

    if ((ay == 1 && gun >= 20) || (ay == 2 && gun <= 18)) {
      return "Kova";
    } else if ((ay == 2 && gun >= 19) || (ay == 3 && gun <= 20)) {
      return "Balık";
    } else if ((ay == 3 && gun >= 21) || (ay == 4 && gun <= 19)) {
      return "Koç";
    } else if ((ay == 4 && gun >= 20) || (ay == 5 && gun <= 20)) {
      return "Boğa";
    } else if ((ay == 5 && gun >= 21) || (ay == 6 && gun <= 20)) {
      return "İkizler";
    } else if ((ay == 6 && gun >= 21) || (ay == 7 && gun <= 22)) {
      return "Yengeç";
    } else if ((ay == 7 && gun >= 23) || (ay == 8 && gun <= 22)) {
      return "Aslan";
    } else if ((ay == 8 && gun >= 23) || (ay == 9 && gun <= 22)) {
      return "Başak";
    } else if ((ay == 9 && gun >= 23) || (ay == 10 && gun <= 22)) {
      return "Terazi";
    } else if ((ay == 10 && gun >= 23) || (ay == 11 && gun <= 21)) {
      return "Akrep";
    } else if ((ay == 11 && gun >= 22) || (ay == 12 && gun <= 21)) {
      return "Yay";
    } else if ((ay == 12 && gun >= 22) || (ay == 1 && gun <= 19)) {
      return "Oğlak";
    } else {
      return "Geçersiz tarih!";
    }
  }

  static String burcTarihAraligiGetir(DateTime tarih) {
    int gun = tarih.day;
    int ay = tarih.month;

    if ((ay == 1 && gun >= 20) || (ay == 2 && gun <= 18)) {
      return "20 Ocak - 18 Şubat";
    } else if ((ay == 2 && gun >= 19) || (ay == 3 && gun <= 20)) {
      return "19 Şubat - 20 Mart";
    } else if ((ay == 3 && gun >= 21) || (ay == 4 && gun <= 19)) {
      return "21 Mart - 19 Nisan";
    } else if ((ay == 4 && gun >= 20) || (ay == 5 && gun <= 20)) {
      return "20 Nisan - 20 Mayıs";
    } else if ((ay == 5 && gun >= 21) || (ay == 6 && gun <= 20)) {
      return "21 Mayıs - 20 Haziran";
    } else if ((ay == 6 && gun >= 21) || (ay == 7 && gun <= 22)) {
      return "21 Haziran - 22 Temmuz";
    } else if ((ay == 7 && gun >= 23) || (ay == 8 && gun <= 22)) {
      return "23 Temmuz - 22 Ağustos";
    } else if ((ay == 8 && gun >= 23) || (ay == 9 && gun <= 22)) {
      return "23 Ağustos - 22 Eylül";
    } else if ((ay == 9 && gun >= 23) || (ay == 10 && gun <= 22)) {
      return "23 Eylül - 22 Ekim";
    } else if ((ay == 10 && gun >= 23) || (ay == 11 && gun <= 21)) {
      return "23 Ekim - 21 Kasım";
    } else if ((ay == 11 && gun >= 22) || (ay == 12 && gun <= 21)) {
      return "22 Kasım - 21 Aralık";
    } else if ((ay == 12 && gun >= 22) || (ay == 1 && gun <= 19)) {
      return "22 Aralık - 19 Ocak";
    } else {
      return "Geçersiz tarih!";
    }
  }

  static String tarihYazdir(DateTime tarih) {
    final locale = Get.locale?.toLanguageTag() ?? 'tr';
    return DateFormat('d MMMM y', locale).format(tarih);
  }

  static Future<DogumGunu?> getDogumGunuById(String id) async {
    final db = await DogumGunuVeriTabani.veritabani;
    final sonuc = await db.query(
      'dogumlar',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (sonuc.isEmpty) return null;

    final Map<String, dynamic> veri = sonuc.first;
    final tarih = DateFormat('yyyy-MM-dd').parse(veri['dogumTarihi']);

    return DogumGunu(
      id: veri['id'] as String,
      isim: veri['isim'] as String,
      dogumTarihi: tarih,
    );
  }
}

class DogumGunuVeriYonetim extends GetxController {
  RxList<DogumGunu> dogumGunuListe = <DogumGunu>[].obs;
}
