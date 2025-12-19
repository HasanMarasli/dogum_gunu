import 'package:dogum_gunu/models/dogum_gunu.dart';
import 'package:dogum_gunu/sayfalar/ana_sayfa.dart';
import 'package:dogum_gunu/tercumeler/tercumeler.dart';
import 'package:flutter/material.dart';
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

  Get.put(DogumGunuVeriYonetim());

  runApp(MyApp(
    initialLocale: storedLocale ?? const Locale('tr'),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key, required this.initialLocale});

  final Locale initialLocale;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: GetMaterialApp(
        debugShowCheckedModeBanner: false,
        translations: Tercumeler(),
        locale: initialLocale,
        fallbackLocale: const Locale('en'),
        title: 'app.title'.tr,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF6C63FF),
            brightness: Brightness.light,
          ),
          scaffoldBackgroundColor: const Color(0xFFF6F7FB),
          appBarTheme: const AppBarTheme(
            centerTitle: false,
            elevation: 0,
            backgroundColor: Colors.transparent,
            foregroundColor: Colors.black,
          ),
          snackBarTheme: const SnackBarThemeData(
            behavior: SnackBarBehavior.floating,
          ),
          fontFamily: 'Kalam',
          useMaterial3: true,
        ),
        home: const AnaSayfa(),
      ),
    );
  }
}
