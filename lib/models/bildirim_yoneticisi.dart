import 'package:dogum_gunu/models/bildirim_ayarlar_yoneticisi.dart';
import 'package:dogum_gunu/sayfalar/tavsiye.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'dogum_gunu.dart';

class BildirimYoneticisi {
  final FlutterLocalNotificationsPlugin bildirimYoneticisi =
      FlutterLocalNotificationsPlugin();

  BildirimYoneticisi() {
    bildirimKurulum();
  }

  void bildirimKurulum() async {
    tz.initializeTimeZones();

    var androidAyari =
        const AndroidInitializationSettings('@mipmap/ic_launcher');
    // İzin, onboarding'in son adımında açıkça istenir.
    var iosAyari = const DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    var kurulumAyari = InitializationSettings(
      android: androidAyari,
      iOS: iosAyari,
    );

    await bildirimYoneticisi.initialize(kurulumAyari,
        onDidReceiveBackgroundNotificationResponse:
            BildirimYoneticisi.bildirimSecilme);
  }

  static Future<void> bildirimSecilme(
      NotificationResponse notificationResponse) async {
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
    final oncedenGunler = _aktifGunler();
    if (oncedenGunler.isEmpty) return;

    var androidBildirimDetay = AndroidNotificationDetails(
      'dogum_gunu_kanali',
      'Doğum Günü Bildirimleri',
      channelDescription: 'Doğum günü hatırlatıcıları için kanal',
      importance: Importance.max,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
      styleInformation:
          BigTextStyleInformation("Bugün ${dogumGunu.isim}'in doğum günü!"),
    );
    var iosBildirimDetay = const DarwinNotificationDetails();

    var bildirimDetay = NotificationDetails(
      android: androidBildirimDetay,
      iOS: iosBildirimDetay,
    );

    tz.initializeTimeZones();

    // Doğum günü tarihine göre bildirim tarihlerini hesapla
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
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.dateAndTime,
        payload: dogumGunu.id, // Doğrudan GUID gönderiyoruz
        androidScheduleMode: AndroidScheduleMode.inexact,
      );
    }
  }

  /// İşletim sisteminin bildirim izni penceresini gösterir.
  Future<bool> izinIste() async {
    final android = bildirimYoneticisi.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    if (android != null) {
      return await android.requestNotificationsPermission() ?? false;
    }
    final ios = bildirimYoneticisi.resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>();
    if (ios != null) {
      return await ios.requestPermissions(
              alert: true, badge: true, sound: true) ??
          false;
    }
    return true;
  }

  /// Bildirimlerin sistem düzeyinde açık olup olmadığını döner.
  Future<bool> izinVarMi() async {
    final android = bildirimYoneticisi.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    if (android != null) {
      return await android.areNotificationsEnabled() ?? true;
    }
    final ios = bildirimYoneticisi.resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>();
    if (ios != null) {
      final durum = await ios.checkPermissions();
      return durum?.isEnabled ?? true;
    }
    return true;
  }

  Future<void> bildirimIptalEt(DogumGunu dogumGunu) async {
    for (var gun in BildirimAyarlarYoneticisi.tumSecenekler) {
      final int bildirimID = _bildirimIdUret(dogumGunu.id, gun);
      await bildirimYoneticisi.cancel(bildirimID);
    }
  }

  /// Aynı algoritma hem bildirim oluşturma hem de iptalde kullanılmalı.
  int _bildirimIdUret(String guid, int gun) {
    final temizGuid = guid.replaceAll('-', '');
    final sonSekiz = temizGuid.length > 8
        ? temizGuid.substring(temizGuid.length - 8)
        : temizGuid;
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
      final gelecekYil =
          DateTime(simdi.year + 1, dogumTarihi.month, dogumTarihi.day);
      hedef = gelecekYil.subtract(Duration(days: gunOnce));
    }

    // Bildirimleri sabah 09:00'a sabitle
    return DateTime(hedef.year, hedef.month, hedef.day, 9);
  }

  List<int> _aktifGunler() {
    if (Get.isRegistered<BildirimAyarlarYoneticisi>()) {
      final liste = Get.find<BildirimAyarlarYoneticisi>().aktifGunler();
      if (liste.isNotEmpty) return liste;
    }
    return BildirimAyarlarYoneticisi.tumSecenekler;
  }
}
