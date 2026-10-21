import 'package:dogum_gunu/models/bildirim_ayarlar_yoneticisi.dart';
import 'package:dogum_gunu/models/dogum_gunu.dart';
import 'package:dogum_gunu/tercumeler/tercumeler.dart';
import 'package:dogum_gunu/tema/tema_yoneticisi.dart';
import 'package:dogum_gunu/sayfalar/splash.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/date_symbol_data_local.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('tr', null);
  await initializeDateFormatting('en', null);
  await GetStorage.init();

  final box = GetStorage();
  final dilController = Get.put(DilSecimiController(box));
  final storedLocale = dilController.readStoredLocale();
  final themeController = Get.put(TemaYoneticisi(box));
  Get.put(BildirimAyarlarYoneticisi(box));

  Get.put(DogumGunuVeriYonetim());

  runApp(MyApp(
    initialLocale: storedLocale ?? const Locale('tr'),
    themeController: themeController,
  ));
}

class MyApp extends StatelessWidget {
  const MyApp(
      {super.key, required this.initialLocale, required this.themeController});

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
          title: 'app.title'.tr,
          theme: tema.themeData,
          darkTheme: tema.darkThemeData,
          themeMode: tema.themeMode,
          // AppBar'ı olmayan ekranlarda da durum çubuğu ikonları temaya uysun.
          builder: (context, child) {
            final koyu = Theme.of(context).brightness == Brightness.dark;
            return AnnotatedRegion<SystemUiOverlayStyle>(
              value: (koyu
                      ? SystemUiOverlayStyle.light
                      : SystemUiOverlayStyle.dark)
                  .copyWith(
                statusBarColor: Colors.transparent,
                systemNavigationBarColor:
                    Theme.of(context).scaffoldBackgroundColor,
                systemNavigationBarIconBrightness:
                    koyu ? Brightness.light : Brightness.dark,
              ),
              child: child!,
            );
          },
          home: const Splash(),
        );
      },
    );
  }
}
