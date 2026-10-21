import 'package:flutter/material.dart';
import 'package:get/get.dart';

enum SnackbarTipi { basari, hata, uyari, bilgi }

class OzelSnackbar {
  static void goster({
    required String baslik,
    required String mesaj,
    required SnackbarTipi tip,
    Duration sure = const Duration(seconds: 3),
  }) {
    final config = _getConfig(tip);

    Get.snackbar(
      '',
      '',
      titleText: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(config.icon, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              baslik,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
      messageText: Padding(
        padding: const EdgeInsets.only(left: 44),
        child: Text(
          mesaj,
          style: TextStyle(
            color: Colors.white.withOpacity(0.9),
            fontSize: 14,
          ),
        ),
      ),
      snackPosition: SnackPosition.TOP,
      backgroundColor: config.renk,
      borderRadius: 16,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      duration: sure,
      isDismissible: true,
      dismissDirection: DismissDirection.horizontal,
      forwardAnimationCurve: Curves.easeOutBack,
      reverseAnimationCurve: Curves.easeInBack,
      animationDuration: const Duration(milliseconds: 400),
      boxShadows: [
        BoxShadow(
          color: config.renk.withOpacity(0.3),
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
      ],
      icon: null,
      shouldIconPulse: false,
      leftBarIndicatorColor: Colors.white.withOpacity(0.3),
      snackStyle: SnackStyle.FLOATING,
    );
  }

  static void basari({
    required String baslik,
    required String mesaj,
  }) {
    goster(baslik: baslik, mesaj: mesaj, tip: SnackbarTipi.basari);
  }

  static void hata({
    required String baslik,
    required String mesaj,
  }) {
    goster(baslik: baslik, mesaj: mesaj, tip: SnackbarTipi.hata);
  }

  static void uyari({
    required String baslik,
    required String mesaj,
  }) {
    goster(baslik: baslik, mesaj: mesaj, tip: SnackbarTipi.uyari);
  }

  static void bilgi({
    required String baslik,
    required String mesaj,
  }) {
    goster(baslik: baslik, mesaj: mesaj, tip: SnackbarTipi.bilgi);
  }

  static _SnackbarConfig _getConfig(SnackbarTipi tip) {
    switch (tip) {
      case SnackbarTipi.basari:
        return _SnackbarConfig(
          renk: const Color(0xFF2ECC71),
          icon: Icons.check_circle_rounded,
        );
      case SnackbarTipi.hata:
        return _SnackbarConfig(
          renk: const Color(0xFFE74C3C),
          icon: Icons.error_rounded,
        );
      case SnackbarTipi.uyari:
        return _SnackbarConfig(
          renk: const Color(0xFFF39C12),
          icon: Icons.warning_rounded,
        );
      case SnackbarTipi.bilgi:
        return _SnackbarConfig(
          renk: const Color(0xFF3498DB),
          icon: Icons.info_rounded,
        );
    }
  }
}

class _SnackbarConfig {
  final Color renk;
  final IconData icon;

  _SnackbarConfig({required this.renk, required this.icon});
}
