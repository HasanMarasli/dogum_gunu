import 'package:dogum_gunu/sayfalar/tavsiye.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'dogum_gunu.dart';

class BildirimYoneticisi {
  final FlutterLocalNotificationsPlugin bildirimYoneticisi = FlutterLocalNotificationsPlugin();

  BildirimYoneticisi() {
    bildirimKurulum();
  }

  void bildirimKurulum() async {
    tz.initializeTimeZones();

    var androidAyari = const AndroidInitializationSettings('@mipmap/ic_launcher');
    var iosAyari = const DarwinInitializationSettings();

    var kurulumAyari = InitializationSettings(
      android: androidAyari,
      iOS: iosAyari,
    );

    await bildirimYoneticisi.initialize(kurulumAyari, onDidReceiveBackgroundNotificationResponse: BildirimYoneticisi.bildirimSecilme);
  }

  static Future<void> bildirimSecilme(NotificationResponse notificationResponse) async {
    var payload = notificationResponse.payload;
    if (payload != null) {
      // Payload doğrudan doğum günü ID'si
      final DogumGunu? dogumGunu = await DogumGunu.getDogumGunuById(payload);

      if (dogumGunu != null) {
        Get.to(Tavsiye(dogumGunu: dogumGunu));
      }
    }
  }

  Future<void> bildirimZamanlamasiYap(DogumGunu dogumGunu) async {
    var androidBildirimDetay = AndroidNotificationDetails(
      'dogum_gunu_kanali',
      'Doğum Günü Bildirimleri',
      channelDescription: 'Doğum günü hatırlatıcıları için kanal',
      importance: Importance.max,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
      styleInformation: BigTextStyleInformation("Bugün ${dogumGunu.isim}'in doğum günü!"),
    );
    var iosBildirimDetay = const DarwinNotificationDetails();

    var bildirimDetay = NotificationDetails(
      android: androidBildirimDetay,
      iOS: iosBildirimDetay,
    );

    tz.initializeTimeZones();

    // Doğum günü tarihine göre bildirim tarihlerini hesapla
    List<int> oncedenGunler = [7, 2, 1, 0]; // 7 gün, 2 gün, 1 gün ve doğum günü
    for (var gun in oncedenGunler) {
      final scheduledDate = tz.TZDateTime.from(
        _hedefTarih(dogumGunu.dogumTarihi, gun),
        tz.local,
      );

      final int bildirimID = _bildirimIdUret(dogumGunu.id, gun);

      await bildirimYoneticisi.zonedSchedule(
        bildirimID,
        'Doğum Günü Hatırlatıcı',
        gun == 0
            ? '${dogumGunu.isim} Bugün ${DateTime.now().year - dogumGunu.dogumTarihi.year} Yaşında!'
            : '${dogumGunu.isim} $gun Sonra ${DateTime.now().year - dogumGunu.dogumTarihi.year} Yaşına Girecek!',
        scheduledDate,
        bildirimDetay,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.dateAndTime,
        payload: dogumGunu.id, // Doğrudan GUID gönderiyoruz
        androidScheduleMode: AndroidScheduleMode.inexact,
      );
    }
  }

  Future<void> bildirimIptalEt(DogumGunu dogumGunu) async {
    // Bildirim ID'leri için önceden tanımladığımız günler
    List<int> oncedenGunler = [7, 2, 1, 0];

    for (var gun in oncedenGunler) {
      final int bildirimID = _bildirimIdUret(dogumGunu.id, gun);
      await bildirimYoneticisi.cancel(bildirimID);
    }
  }

  /// Aynı algoritma hem bildirim oluşturma hem de iptalde kullanılmalı.
  int _bildirimIdUret(String guid, int gun) {
    final temizGuid = guid.replaceAll('-', '');
    final sonSekiz = temizGuid.length > 8 ? temizGuid.substring(temizGuid.length - 8) : temizGuid;
    final base = int.parse(sonSekiz, radix: 16);
    return (base + gun) & 0x7fffffff; // pozitif int sınırı içinde tut
  }

  /// Doğum gününden `gun` gün öncesinin gelecek tarihteki karşılığını verir.
  DateTime _hedefTarih(DateTime dogumTarihi, int gunOnce) {
    final simdi = DateTime.now();
    final buYil = DateTime(simdi.year, dogumTarihi.month, dogumTarihi.day);
    DateTime hedef = buYil.subtract(Duration(days: gunOnce));

    // Eğer hedef tarih geçmişteyse bir sonraki yıla kaydır
    if (!hedef.isAfter(simdi)) {
      final gelecekYil = DateTime(simdi.year + 1, dogumTarihi.month, dogumTarihi.day);
      hedef = gelecekYil.subtract(Duration(days: gunOnce));
    }

    // Bildirimleri sabah 09:00'a sabitle
    return DateTime(hedef.year, hedef.month, hedef.day, 9);
  }
}
