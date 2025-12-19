import 'package:dogum_gunu/models/dogum_gunu.dart';
import 'package:dogum_gunu/sayfalar/ana_sayfa.dart';
import 'package:dogum_gunu/tercumeler/tercumeler.dart';
import 'package:flutter/material.dart';
import 'package:get/get_instance/get_instance.dart';
import 'package:get/route_manager.dart';

void main() {
  Get.put(DogumGunuVeriYonetim());
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: GetMaterialApp(
        debugShowCheckedModeBanner: false,
        translations: Tercumeler(),
        locale: const Locale("tr"),
        fallbackLocale: const Locale('en'),
        title: 'Doğum Günü',
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
