import 'dart:async';
import 'dart:io';

import 'package:dogum_gunu/models/bildirim_ayarlar_yoneticisi.dart';
import 'package:dogum_gunu/sayfalar/tavsiye.dart';
import 'package:dogum_gunu/tercumeler/tercumeler.dart';
import 'package:dogum_gunu/veriTabani/dogum_gunu_veri_tabani.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:timezone/data/latest_10y.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'dogum_gunu.dart';

/// Planlanacak tek bir hatırlatma: (kişi, gün seçeneği, yıl sırası).
class _Hedef {
  _Hedef(this.id, this.kisi, this.gun, this.yas, this.zaman);

  final int id;
  final DogumGunu kisi;
  final int gun;
  final int yas;
  final tz.TZDateTime zaman;
}

class BildirimYoneticisi {
  static final BildirimYoneticisi _nesne = BildirimYoneticisi._();

  factory BildirimYoneticisi() => _nesne;

  BildirimYoneticisi._();

  final FlutterLocalNotificationsPlugin bildirimYoneticisi =
      FlutterLocalNotificationsPlugin();

  static const String _kanalId = 'dogum_gunu_kanali';
  static const String _imzaAnahtari = 'bildirim_plan_imzasi';
  static const String _planAnahtari = 'bildirim_plan_ozetleri';

  /// Uygulama uzun süre açılmasa da hatırlatma kesilmesin diye
  /// her seçenek için önümüzdeki iki doğum günü aday olarak üretilir.
  static const int _planlananYil = 2;

  /// iOS en fazla 64 bekleyen bildirim tutar; Android'de alarm sınırı 500'dür
  /// (uygulamanın ikon alarmı için pay bırakılır).
  static int get _enFazlaBildirim => Platform.isIOS ? 60 : 400;

  Future<void>? _kurulum;
  String? _uygulamaSurumu;

  Future<void>? _calisan;
  Completer<void>? _sonraki;
  bool _sonrakiZorla = false;

  /// Eklenti ve saat dilimi kurulumunu bir kez yapar; her işlemden önce beklenir.
  /// Kurulum hata verirse önbellek sıfırlanır, bir sonraki çağrı yeniden dener.
  Future<void> hazirla() {
    return _kurulum ??= _bildirimKurulum().then<void>(
      (_) {},
      onError: (Object hata, StackTrace yigin) {
        _kurulum = null;
        Error.throwWithStackTrace(hata, yigin);
      },
    );
  }

  Future<void> _bildirimKurulum() async {
    tz.initializeTimeZones();
    try {
      final yerel = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(yerel.identifier));
    } catch (hata, yigin) {
      // Bölge adı alınamazsa cihazın saat farkına uyan bir bölge kullanılır;
      // bölge adı plan imzasında olduğu için sonraki açılışta düzelir.
      _hataBildir(hata, yigin, 'saat dilimi alınamadı');
      tz.setLocalLocation(_yedekKonum());
    }

    const androidAyari = AndroidInitializationSettings('@drawable/ic_bildirim');
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

  /// Cihazın şu anki ve altı ay sonraki saat farkına uyan bölgeyi seçer;
  /// böylece yaz saati davranışı da mümkün olduğunca korunur.
  tz.Location _yedekKonum() {
    final simdi = DateTime.now();
    final ofset = simdi.timeZoneOffset.inMilliseconds;
    final altiAySonra = simdi.add(const Duration(days: 182));
    final ofsetYaz = altiAySonra.timeZoneOffset.inMilliseconds;
    final yazMs = altiAySonra.millisecondsSinceEpoch;
    tz.Location? yalnizSimdi;
    for (final konum in tz.timeZoneDatabase.locations.values) {
      if (konum.currentTimeZone.offset != ofset) continue;
      if (konum.timeZone(yazMs).offset == ofsetYaz) return konum;
      yalnizSimdi ??= konum;
    }
    return yalnizSimdi ?? tz.UTC;
  }

  /// Uygulama bir bildirime dokunularak açıldıysa ilgili kişinin id'sini döner.
  Future<String?> acilisYuku() async {
    try {
      await hazirla();
      final detay = await bildirimYoneticisi.getNotificationAppLaunchDetails();
      if (detay?.didNotificationLaunchApp ?? false) {
        return detay!.notificationResponse?.payload;
      }
    } catch (hata, yigin) {
      _hataBildir(hata, yigin, 'açılış bildirimi okunamadı');
    }
    return null;
  }

  static Future<void> bildirimSecilme(
    NotificationResponse notificationResponse,
  ) async {
    final payload = notificationResponse.payload;
    if (payload == null) return;
    final DogumGunu? dogumGunu = await DogumGunu.getDogumGunuById(payload);
    if (dogumGunu != null) {
      Get.to(() => Tavsiye(dogumGunu: dogumGunu));
    }
  }

  /// Tüm bildirimleri sıralı bir kuyrukla yeniden planlar.
  ///
  /// Bir planlama sürerken gelen istekler birleştirilir ve o bitince bir kez
  /// daha çalıştırılır. [zorla] false ise plan imzası (dil, seçili günler,
  /// bugünün tarihi, sürüm, saat dilimi, kişi verisi) değişmediyse atlanır.
  /// Hata fırlatmaz; hatalar raporlanır ve imza yazılmadığı için sonraki
  /// çağrıda yeniden denenir.
  Future<void> yenidenPlanla({bool zorla = false}) {
    if (_calisan == null) {
      return _calisan = _kuyruk(zorla);
    }
    _sonrakiZorla = _sonrakiZorla || zorla;
    return (_sonraki ??= Completer<void>()).future;
  }

  Future<void> _kuyruk(bool zorla) async {
    var buTur = zorla;
    Completer<void>? bekleyenler;
    try {
      while (true) {
        try {
          await _planla(buTur);
        } catch (hata, yigin) {
          _hataBildir(hata, yigin, 'bildirimler planlanamadı');
        }
        bekleyenler?.complete();
        bekleyenler = _sonraki;
        if (bekleyenler == null) break;
        _sonraki = null;
        buTur = _sonrakiZorla;
        _sonrakiZorla = false;
      }
    } finally {
      _calisan = null;
    }
  }

  Future<void> _planla(bool zorla) async {
    await hazirla();
    final kisiler = await DogumGunuVeriTabani.tumVerileriGetir();
    final kutu = GetStorage();
    final imza = await _imzaHesapla(kisiler);
    if (!zorla && kutu.read<String>(_imzaAnahtari) == imza) return;

    final basarili = await _uygula(kisiler, kutu);
    if (basarili) {
      await kutu.write(_imzaAnahtari, imza);
    } else {
      await kutu.remove(_imzaAnahtari);
    }
  }

  /// En yakın [_enFazlaBildirim] hedefi planlar; listede olmayan bekleyen
  /// bildirimleri (silinen kişiler, eski kimlikler, sınır dışı kalanlar) iptal
  /// eder. İçeriği ve zamanı değişmeyen bildirimlere dokunulmaz.
  Future<bool> _uygula(List<DogumGunu> kisiler, GetStorage kutu) async {
    final hedefler = _hedefleriUret(kisiler)
      ..sort((a, b) => a.zaman.compareTo(b.zaman));
    final istenen = <int, _Hedef>{};
    for (final hedef in hedefler) {
      if (istenen.length >= _enFazlaBildirim) break;
      istenen.putIfAbsent(hedef.id, () => hedef);
    }

    final bekleyen = (await bildirimYoneticisi.pendingNotificationRequests())
        .map((istek) => istek.id)
        .toSet();
    final kayitli = Map<String, dynamic>.from(
      kutu.read<Map<String, dynamic>>(_planAnahtari) ?? const {},
    );
    var hataVar = false;

    for (final id in bekleyen) {
      if (istenen.containsKey(id)) continue;
      try {
        await bildirimYoneticisi.cancel(id);
      } catch (hata, yigin) {
        hataVar = true;
        _hataBildir(hata, yigin, 'bildirim iptal edilemedi');
      }
    }

    final baslik = 'notification.title'.tr;
    final kanalAdi = 'notification.channel.name'.tr;
    final kanalAciklama = 'notification.channel.desc'.tr;
    final yeniKayit = <String, String>{};

    for (final hedef in istenen.values) {
      final govde = _govde(hedef);
      final ozet = _ozet(
        [
          hedef.zaman.millisecondsSinceEpoch,
          baslik,
          govde,
          hedef.kisi.id,
          kanalAdi,
          kanalAciklama,
        ].join('|'),
      );
      final anahtar = '${hedef.id}';
      if (bekleyen.contains(hedef.id) && kayitli[anahtar] == ozet) {
        yeniKayit[anahtar] = ozet;
        continue;
      }

      final detay = NotificationDetails(
        android: AndroidNotificationDetails(
          _kanalId,
          kanalAdi,
          channelDescription: kanalAciklama,
          importance: Importance.max,
          priority: Priority.high,
          icon: '@drawable/ic_bildirim',
          styleInformation: BigTextStyleInformation(govde),
        ),
        iOS: const DarwinNotificationDetails(),
      );

      try {
        await bildirimYoneticisi.zonedSchedule(
          hedef.id,
          baslik,
          govde,
          hedef.zaman,
          detay,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
          payload: hedef.kisi.id,
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        );
        yeniKayit[anahtar] = ozet;
      } catch (hata, yigin) {
        hataVar = true;
        _hataBildir(hata, yigin, 'bildirim planlanamadı');
      }
    }

    await kutu.write(_planAnahtari, yeniKayit);
    return !hataVar;
  }

  String _govde(_Hedef hedef) {
    final isim = hedef.kisi.isim;
    return hedef.gun == 0
        ? 'notification.body.today'.trParams({
            'name': isim,
            'age': '${hedef.yas}',
          })
        : trSayi('notification.body.before', hedef.gun, {
            'name': isim,
            'age': '${hedef.yas}',
            'days': '${hedef.gun}',
          });
  }

  /// Her kişi, açık gün seçeneği ve önümüzdeki iki doğum günü için
  /// gelecekteki 09:00 hatırlatmalarını üretir.
  List<_Hedef> _hedefleriUret(List<DogumGunu> kisiler) {
    final gunler = _aktifGunler();
    final simdi = tz.TZDateTime.now(tz.local);
    final sonuc = <_Hedef>[];
    for (final kisi in kisiler) {
      for (final gunOnce in gunler) {
        var sira = 0;
        for (var yil = simdi.year; sira < _planlananYil; yil++) {
          final gun = DogumGunu.yildakiDogumGunu(kisi.dogumTarihi, yil);
          final zaman = tz.TZDateTime(
            tz.local,
            gun.year,
            gun.month,
            gun.day - gunOnce,
            9,
          );
          if (!zaman.isAfter(simdi)) continue;
          final yas = gun.year - kisi.dogumTarihi.year;
          // Bu yıl doğan biri için "0 yaşında" bildirimi gönderilmez.
          if (yas >= 1) {
            sonuc.add(
              _Hedef(
                _bildirimIdUret(kisi.id, gunOnce, sira),
                kisi,
                gunOnce,
                yas,
                zaman,
              ),
            );
          }
          sira++;
        }
      }
    }
    return sonuc;
  }

  Future<String> _imzaHesapla(List<DogumGunu> kisiler) async {
    final simdi = tz.TZDateTime.now(tz.local);
    final kisiSatirlari =
        kisiler
            .map(
              (k) =>
                  '${k.id}|${k.isim}|${k.dogumTarihi.year}-${k.dogumTarihi.month}-${k.dogumTarihi.day}',
            )
            .toList()
          ..sort();
    return [
      Get.locale?.toString() ?? '',
      _aktifGunler().join(','),
      '${simdi.year}-${simdi.month}-${simdi.day}',
      await _surum(),
      tz.local.name,
      kisiler.length,
      _ozet(kisiSatirlari.join('\n')),
    ].join(';');
  }

  Future<String> _surum() async {
    if (_uygulamaSurumu != null) return _uygulamaSurumu!;
    try {
      final bilgi = await PackageInfo.fromPlatform();
      return _uygulamaSurumu = '${bilgi.version}+${bilgi.buildNumber}';
    } catch (hata, yigin) {
      _hataBildir(hata, yigin, 'uygulama sürümü okunamadı');
      return '';
    }
  }

  /// Kalıcı ve sürümden bağımsız kısa özet (FNV-1a, 32 bit).
  static String _ozet(String metin) {
    var h = 0x811c9dc5;
    for (final birim in metin.codeUnits) {
      h ^= birim;
      h = (h * 0x01000193) & 0xffffffff;
    }
    return h.toRadixString(16);
  }

  /// İşletim sisteminin bildirim izni penceresini gösterir.
  Future<bool> izinIste() async {
    try {
      await hazirla();
      final android = bildirimYoneticisi
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();
      if (android != null) {
        return await android.requestNotificationsPermission() ?? false;
      }
      final ios = bildirimYoneticisi
          .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin
          >();
      if (ios != null) {
        return await ios.requestPermissions(
              alert: true,
              badge: true,
              sound: true,
            ) ??
            false;
      }
    } catch (hata, yigin) {
      _hataBildir(hata, yigin, 'bildirim izni istenemedi');
      return false;
    }
    return true;
  }

  /// Bildirimlerin sistem düzeyinde açık olup olmadığını döner.
  Future<bool> izinVarMi() async {
    try {
      await hazirla();
      final android = bildirimYoneticisi
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();
      if (android != null) {
        return await android.areNotificationsEnabled() ?? true;
      }
      final ios = bildirimYoneticisi
          .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin
          >();
      if (ios != null) {
        final durum = await ios.checkPermissions();
        return durum?.isEnabled ?? true;
      }
    } catch (hata, yigin) {
      _hataBildir(hata, yigin, 'bildirim izni okunamadı');
    }
    return true;
  }

  int _bildirimIdUret(String guid, int gun, int sira) {
    final temizGuid = guid.replaceAll('-', '');
    final sonSekiz = temizGuid.length > 8
        ? temizGuid.substring(temizGuid.length - 8)
        : temizGuid;
    final base =
        int.tryParse(sonSekiz, radix: 16) ?? int.parse(_ozet(guid), radix: 16);
    // İlk yıl eski kimliklerle aynı kalır.
    return (base + gun + sira * 1000) & 0x7fffffff;
  }

  List<int> _aktifGunler() {
    if (Get.isRegistered<BildirimAyarlarYoneticisi>()) {
      return Get.find<BildirimAyarlarYoneticisi>().aktifGunler();
    }
    return BildirimAyarlarYoneticisi.tumSecenekler;
  }

  /// Hata uygulamayı çökertmeden genel hata yakalayıcıya iletilir.
  /// Bağlam metnine kişisel veri yazılmaz.
  static void _hataBildir(Object hata, StackTrace yigin, String baglam) {
    FlutterError.reportError(
      FlutterErrorDetails(
        exception: hata,
        stack: yigin,
        library: 'bildirim',
        context: ErrorDescription(baglam),
      ),
    );
  }
}
