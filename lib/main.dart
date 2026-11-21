import 'package:dogum_gunu/models/bildirim_ayarlar_yoneticisi.dart';
import 'package:dogum_gunu/models/dogum_gunu.dart';
import 'package:dogum_gunu/models/ikon_yoneticisi.dart';
import 'package:dogum_gunu/tercumeler/tercumeler.dart';
import 'package:dogum_gunu/tema/tema_yoneticisi.dart';
import 'package:dogum_gunu/sayfalar/splash.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/date_symbol_data_local.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  _hataYakalayicilariKur();
  await initializeDateFormatting('tr', null);
  await initializeDateFormatting('en', null);
  await initializeDateFormatting('es', null);
  try {
    await GetStorage.init();
  } catch (hata, yigin) {
    // Depolama açılamazsa uygulama varsayılan ayarlarla açılır.
    FlutterError.reportError(
      FlutterErrorDetails(
        exception: hata,
        stack: yigin,
        library: 'baslangic',
        context: ErrorDescription('yerel depolama açılamadı'),
      ),
    );
  }

  final box = GetStorage();
  final dilController = Get.put(DilSecimiController(box));
  final storedLocale = dilController.readStoredLocale();
  final themeController = Get.put(TemaYoneticisi(box));
  Get.put(BildirimAyarlarYoneticisi(box));

  Get.put(DogumGunuVeriYonetim());
  IkonYoneticisi.baslat();

  runApp(
    MyApp(
      // Seçim yoksa telefonun dili; Türkçe ve İspanyolca dışındaki her dilde İngilizce.
      initialLocale: storedLocale ?? _cihazDili(Get.deviceLocale?.languageCode),
      themeController: themeController,
    ),
  );
}

/// Yakalanmamış hatalar uygulamayı kapatmaz; yalnızca debug'da konsola yazılır.
void _hataYakalayicilariKur() {
  FlutterError.onError = (ayrinti) {
    if (kDebugMode) FlutterError.presentError(ayrinti);
  };
  PlatformDispatcher.instance.onError = (hata, yigin) {
    if (kDebugMode) {
      FlutterError.presentError(
        FlutterErrorDetails(exception: hata, stack: yigin),
      );
    }
    return true;
  };
}

Locale _cihazDili(String? dilKodu) {
  switch (dilKodu) {
    case 'tr':
      return const Locale('tr');
    case 'es':
      return const Locale('es');
    default:
      return const Locale('en');
  }
}

class MyApp extends StatelessWidget {
  const MyApp({
    super.key,
    required this.initialLocale,
    required this.themeController,
  });

  final Locale initialLocale;
  final TemaYoneticisi themeController;

  @override
  Widget build(BuildContext context) {
    return GetBuilder<TemaYoneticisi>(
      init: themeController,
      builder: (tema) {
        return GetMaterialApp(
          debugShowCheckedModeBanner: false,
          translations: Tercumeler(),
          locale: initialLocale,
          fallbackLocale: const Locale('en'),
          supportedLocales: Tercumeler.diller.values,
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          // Çeviriler GetMaterialApp kurulunca yüklenir; başlık o zaman üretilir.
          onGenerateTitle: (_) => 'app.title'.tr,
          theme: tema.themeData,
          darkTheme: tema.darkThemeData,
          themeMode: tema.themeMode,
          // AppBar'ı olmayan ekranlarda da durum çubuğu ikonları temaya uysun.
          builder: (context, child) {
            final koyu = Theme.of(context).brightness == Brightness.dark;
            return MediaQuery.withClampedTextScaling(
              maxScaleFactor: 1.6,
              child: AnnotatedRegion<SystemUiOverlayStyle>(
                value:
                    (koyu
                            ? SystemUiOverlayStyle.light
                            : SystemUiOverlayStyle.dark)
                        .copyWith(
                          statusBarColor: Colors.transparent,
                          systemNavigationBarColor: Theme.of(
                            context,
                          ).scaffoldBackgroundColor,
                          systemNavigationBarIconBrightness: koyu
                              ? Brightness.light
                              : Brightness.dark,
                        ),
                child: child!,
              ),
            );
          },
          home: const Splash(),
        );
      },
    );
  }
}
