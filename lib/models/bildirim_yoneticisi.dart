import 'package:dogum_gunu/models/bildirim_ayarlar_yoneticisi.dart';
import 'package:dogum_gunu/sayfalar/tavsiye.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:get/get.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'dogum_gunu.dart';

class BildirimYoneticisi {
  static final BildirimYoneticisi _nesne = BildirimYoneticisi._();

  factory BildirimYoneticisi() => _nesne;

  BildirimYoneticisi._();

  final FlutterLocalNotificationsPlugin bildirimYoneticisi =
      FlutterLocalNotificationsPlugin();

  Future<void>? _kurulum;

  /// Eklenti ve saat dilimi kurulumunu bir kez yapar; her işlemden önce beklenir.
  Future<void> hazirla() => _kurulum ??= _bildirimKurulum();

  Future<void> _bildirimKurulum() async {
    tz.initializeTimeZones();
    try {
      final yerel = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(yerel.identifier));
    } catch (_) {
      // Bilinmeyen bölge adı gelirse UTC ile devam edilir.
    }

    const androidAyari = AndroidInitializationSettings('@mipmap/ic_launcher');
    // İzin, onboarding'in son adımında açıkça istenir.
    const iosAyari = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    await bildirimYoneticisi.initialize(
      const InitializationSettings(android: androidAyari, iOS: iosAyari),
      onDidReceiveNotificationResponse: bildirimSecilme,
    );
  }

  /// Uygulama bir bildirime dokunularak açıldıysa ilgili kişinin id'sini döner.
  Future<String?> acilisYuku() async {
    await hazirla();
    final detay = await bildirimYoneticisi.getNotificationAppLaunchDetails();
    if (detay?.didNotificationLaunchApp ?? false) {
      return detay!.notificationResponse?.payload;
    }
    return null;
  }

  static Future<void> bildirimSecilme(
      NotificationResponse notificationResponse) async {
    final payload = notificationResponse.payload;
    if (payload == null) return;
    final DogumGunu? dogumGunu = await DogumGunu.getDogumGunuById(payload);
    if (dogumGunu != null) {
      Get.to(() => Tavsiye(dogumGunu: dogumGunu));
    }
  }

  Future<void> bildirimZamanlamasiYap(DogumGunu dogumGunu) async {
    await hazirla();
    final oncedenGunler = _aktifGunler();
    if (oncedenGunler.isEmpty) return;

    final baslik = 'notification.title'.tr;

    for (final gun in oncedenGunler) {
      final hedefler = _hedefTarihler(dogumGunu.dogumTarihi, gun);
      for (var sira = 0; sira < hedefler.length; sira++) {
        final hedef = hedefler[sira];
        final dogumGunuTarihi = hedef.add(Duration(days: gun));
        final yas = dogumGunuTarihi.year - dogumGunu.dogumTarihi.year;
        final govde = gun == 0
            ? 'notification.body.today'
                .trParams({'name': dogumGunu.isim, 'age': '$yas'})
            : 'notification.body.before'.trParams(
                {'name': dogumGunu.isim, 'age': '$yas', 'days': '$gun'});

        final detay = NotificationDetails(
          android: AndroidNotificationDetails(
            'dogum_gunu_kanali',
            'notification.channel.name'.tr,
            channelDescription: 'notification.channel.desc'.tr,
            importance: Importance.max,
            priority: Priority.high,
            icon: '@mipmap/ic_launcher',
            styleInformation: BigTextStyleInformation(govde),
          ),
          iOS: const DarwinNotificationDetails(),
        );

        try {
          await bildirimYoneticisi.zonedSchedule(
            _bildirimIdUret(dogumGunu.id, gun, sira),
            baslik,
            govde,
            tz.TZDateTime.from(hedef, tz.local),
            detay,
            uiLocalNotificationDateInterpretation:
                UILocalNotificationDateInterpretation.absoluteTime,
            payload: dogumGunu.id, // Doğrudan GUID gönderiyoruz
            androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
          );
        } catch (_) {
          // Bir bildirimin kurulamaması kaydı engellemesin.
        }
      }
    }
  }

  /// İşletim sisteminin bildirim izni penceresini gösterir.
  Future<bool> izinIste() async {
    await hazirla();
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
    await hazirla();
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
    await hazirla();
    for (var gun in BildirimAyarlarYoneticisi.tumSecenekler) {
      for (var sira = 0; sira < _planlananYil; sira++) {
        await bildirimYoneticisi
            .cancel(_bildirimIdUret(dogumGunu.id, gun, sira));
      }
    }
  }

  /// Aynı algoritma hem bildirim oluşturma hem de iptalde kullanılmalı.
  /// Uygulama uzun süre açılmasa da hatırlatma kesilmesin diye
  /// her seçenek için önümüzdeki iki doğum günü planlanır.
  static const int _planlananYil = 2;

  int _bildirimIdUret(String guid, int gun, int sira) {
    final temizGuid = guid.replaceAll('-', '');
    final sonSekiz = temizGuid.length > 8
        ? temizGuid.substring(temizGuid.length - 8)
        : temizGuid;
    final base = int.parse(sonSekiz, radix: 16);
    // İlk yıl eski kimliklerle aynı kalır, böylece önceki planlar da iptal edilir.
    return (base + gun + sira * 1000) & 0x7fffffff;
  }

  /// 29 Şubat doğumlular artık olmayan yıllarda 28 Şubat'ta kutlanır.
  DateTime _yildakiDogumGunu(DateTime dogum, int yil) {
    if (dogum.month == 2 && dogum.day == 29) {
      final artik = (yil % 4 == 0 && yil % 100 != 0) || yil % 400 == 0;
      return DateTime(yil, 2, artik ? 29 : 28);
    }
    return DateTime(yil, dogum.month, dogum.day);
  }

  /// Doğum gününden `gunOnce` gün öncesinin gelecekteki ilk iki 09:00'ını verir.
  List<DateTime> _hedefTarihler(DateTime dogumTarihi, int gunOnce) {
    final simdi = DateTime.now();
    final sonuc = <DateTime>[];
    for (var yil = simdi.year; sonuc.length < _planlananYil; yil++) {
      final gun = _yildakiDogumGunu(dogumTarihi, yil);
      final hedef = DateTime(gun.year, gun.month, gun.day - gunOnce, 9);
      if (hedef.isAfter(simdi)) sonuc.add(hedef);
    }
    return sonuc;
  }

  List<int> _aktifGunler() {
    if (Get.isRegistered<BildirimAyarlarYoneticisi>()) {
      return Get.find<BildirimAyarlarYoneticisi>().aktifGunler();
    }
    return BildirimAyarlarYoneticisi.tumSecenekler;
  }
}
