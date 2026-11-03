import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../tema/renkler.dart';

enum SnackbarTipi { basari, hata, uyari, bilgi }

class OzelSnackbar {
  static const Duration _sure = Duration(seconds: 3);

  static void goster({
    required String baslik,
    required String mesaj,
    required SnackbarTipi tip,
    Duration sure = _sure,
  }) {
    final context = Get.context;
    if (context == null) return;
    final r = Theme.of(context).extension<AppRenkler>();
    if (r == null) return;
    final config = _getConfig(tip, r);
    final azHareket = MediaQuery.maybeOf(context)?.disableAnimations ?? false;

    // Aynı anda tek mesaj: yenisi gelince mevcut olan kapanır.
    if (Get.isSnackbarOpen) Get.closeCurrentSnackbar();

    Get.showSnackbar(
      GetSnackBar(
        messageText: _SnackIcerik(
          baslik: baslik,
          mesaj: mesaj,
          config: config,
          sure: sure,
        ),
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.transparent,
        padding: EdgeInsets.zero,
        margin: const EdgeInsets.fromLTRB(12, 8, 12, 0),
        borderRadius: 18,
        maxWidth: 560,
        boxShadows: r.e3,
        duration: sure,
        isDismissible: true,
        dismissDirection: DismissDirection.horizontal,
        animationDuration: Duration(milliseconds: azHareket ? 150 : 350),
        forwardAnimationCurve: const Cubic(0.05, 0.7, 0.1, 1),
        reverseAnimationCurve: const Cubic(0.3, 0, 0.8, 0.15),
        snackStyle: SnackStyle.FLOATING,
      ),
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

  static _SnackbarConfig _getConfig(SnackbarTipi tip, AppRenkler r) {
    switch (tip) {
      case SnackbarTipi.basari:
        return _SnackbarConfig(
          vurgu: r.suc,
          vurguUstu: r.onSuc,
          zemin: r.succ,
          yazi: r.onSucc,
          icon: Icons.check_circle_rounded,
        );
      case SnackbarTipi.hata:
        return _SnackbarConfig(
          vurgu: r.err,
          vurguUstu: r.onErr,
          zemin: r.errc,
          yazi: r.onErrc,
          icon: Icons.error_rounded,
        );
      case SnackbarTipi.uyari:
        return _SnackbarConfig(
          vurgu: r.warn,
          vurguUstu: r.onWarn,
          zemin: r.warnc,
          yazi: r.onWarnc,
          icon: Icons.warning_rounded,
        );
      case SnackbarTipi.bilgi:
        return _SnackbarConfig(
          vurgu: r.info,
          vurguUstu: r.onInfo,
          zemin: r.infoc,
          yazi: r.onInfoc,
          icon: Icons.info_rounded,
        );
    }
  }
}

class _SnackIcerik extends StatelessWidget {
  const _SnackIcerik({
    required this.baslik,
    required this.mesaj,
    required this.config,
    required this.sure,
  });

  final String baslik;
  final String mesaj;
  final _SnackbarConfig config;
  final Duration sure;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      liveRegion: true,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Container(
          color: config.zemin,
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 12, 16, 14),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: config.vurgu,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child:
                          Icon(config.icon, size: 22, color: config.vurguUstu),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            baslik,
                            style: TextStyle(
                              fontFamily: 'Figtree',
                              fontWeight: FontWeight.w700,
                              fontSize: 15,
                              height: 20 / 15,
                              color: config.yazi,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            mesaj,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontFamily: 'Figtree',
                              fontWeight: FontWeight.w400,
                              fontSize: 14,
                              height: 20 / 14,
                              color: config.yazi,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                height: 3,
                child: _SureCubugu(sure: sure, renk: config.vurgu),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Otomatik kapanmaya kalan süreyi gösteren ince çubuk.
class _SureCubugu extends StatefulWidget {
  const _SureCubugu({required this.sure, required this.renk});

  final Duration sure;
  final Color renk;

  @override
  State<_SureCubugu> createState() => _SureCubuguState();
}

class _SureCubuguState extends State<_SureCubugu>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl =
      AnimationController(vsync: this, duration: widget.sure)..forward();

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (context, _) => FractionallySizedBox(
        alignment: Alignment.centerLeft,
        widthFactor: _ctrl.value,
        heightFactor: 1,
        child: ColoredBox(color: widget.renk),
      ),
    );
  }
}

class _SnackbarConfig {
  final Color vurgu;
  final Color vurguUstu;
  final Color zemin;
  final Color yazi;
  final IconData icon;

  _SnackbarConfig({
    required this.vurgu,
    required this.vurguUstu,
    required this.zemin,
    required this.yazi,
    required this.icon,
  });
}
