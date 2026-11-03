import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import '../models/bildirim_yoneticisi.dart';
import '../models/dogum_gunu.dart';
import '../tema/renkler.dart';
import 'ana_sayfa.dart';
import 'onboarding.dart';
import 'tavsiye.dart';

class Splash extends StatefulWidget {
  const Splash({super.key});

  @override
  State<Splash> createState() => _SplashState();
}

class _SplashState extends State<Splash> with TickerProviderStateMixin {
  late final AnimationController _girisCtrl;
  late final AnimationController _yorungeCtrl;
  late final AnimationController _nefesCtrl;
  late final AnimationController _alevCtrl;

  bool _yukleniyorGoster = false;

  @override
  void initState() {
    super.initState();
    _girisCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..forward();
    _yorungeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat();
    _nefesCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
    _alevCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..repeat(reverse: true);

    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) setState(() => _yukleniyorGoster = true);
    });
    Future.delayed(const Duration(milliseconds: 1000), _devamEt);
  }

  Future<void> _devamEt() async {
    if (!mounted) return;
    final onboardingBitti = Onboarding.tamamlandiMi(GetStorage());
    final yuk =
        onboardingBitti ? await BildirimYoneticisi().acilisYuku() : null;
    if (!mounted) return;
    Get.off(
      () => onboardingBitti ? const AnaSayfa() : const Onboarding(),
      transition: Transition.fade,
      duration: const Duration(milliseconds: 250),
    );
    // Bildirime dokunularak açıldıysa ilgili kişinin sayfası Home'un üstüne açılır.
    if (yuk != null) {
      final kisi = await DogumGunu.getDogumGunuById(yuk);
      if (kisi != null) Get.to(() => Tavsiye(dogumGunu: kisi));
    }
  }

  @override
  void dispose() {
    _girisCtrl.dispose();
    _yorungeCtrl.dispose();
    _nefesCtrl.dispose();
    _alevCtrl.dispose();
    super.dispose();
  }

  Animation<double> _aralik(double bas, double son) => CurvedAnimation(
        parent: _girisCtrl,
        curve: Interval(bas, son, curve: const Cubic(0.2, 0, 0, 1)),
      );

  @override
  Widget build(BuildContext context) {
    final r = context.renk;
    final scheme = Theme.of(context).colorScheme;
    final metin = Theme.of(context).textTheme;
    final koyu = Theme.of(context).brightness == Brightness.dark;
    final azHareket = MediaQuery.of(context).disableAnimations;

    final amblem = _aralik(0, 0.44);
    final baslik = _aralik(0.19, 0.69);
    final altBaslik = _aralik(0.29, 0.79);
    final etiketler = _aralik(0.5, 1);

    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: r.bg,
        body: Stack(
          children: [
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: const Alignment(0, -0.2),
                    radius: 0.75,
                    colors: [
                      scheme.primaryContainer
                          .withValues(alpha: koyu ? 0.45 : 0.75),
                      scheme.primaryContainer.withValues(alpha: 0),
                    ],
                  ),
                ),
              ),
            ),
            SafeArea(
              child: Column(
                children: [
                  Expanded(
                    child: Center(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(horizontal: 28),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            FadeTransition(
                              opacity: amblem,
                              child: ScaleTransition(
                                scale: Tween(begin: 0.92, end: 1.0)
                                    .animate(amblem),
                                child: _amblem(scheme, r, azHareket),
                              ),
                            ),
                            const SizedBox(height: 28),
                            _yukariKay(
                              baslik,
                              Text(
                                'app.title'.tr,
                                textAlign: TextAlign.center,
                                style: metin.displaySmall?.copyWith(
                                  letterSpacing: -1.2,
                                  height: 1.05,
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            _yukariKay(
                              altBaslik,
                              Text(
                                'splash.subtitle'.tr,
                                textAlign: TextAlign.center,
                                style: metin.bodyLarge?.copyWith(color: r.tx2),
                              ),
                            ),
                            const SizedBox(height: 28),
                            FadeTransition(
                              opacity: etiketler,
                              child: ConstrainedBox(
                                constraints:
                                    const BoxConstraints(maxWidth: 300),
                                child: Wrap(
                                  alignment: WrapAlignment.center,
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: [
                                    _etiket(Icons.group_add_rounded,
                                        'splash.pill.add'.tr),
                                    _etiket(Icons.notifications_active_rounded,
                                        'splash.pill.reminder'.tr),
                                    _etiket(Icons.lock_rounded,
                                        'splash.pill.privacy'.tr),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 72,
                    child: AnimatedOpacity(
                      opacity: _yukleniyorGoster ? 1 : 0,
                      duration: const Duration(milliseconds: 200),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: scheme.primary,
                              backgroundColor: scheme.primaryContainer,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            'splash.loading'.tr,
                            style: metin.bodyMedium?.copyWith(
                              color: r.tx3,
                              fontWeight: FontWeight.w500,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _yukariKay(Animation<double> anim, Widget child) {
    return FadeTransition(
      opacity: anim,
      child: SlideTransition(
        position:
            Tween(begin: const Offset(0, 0.25), end: Offset.zero).animate(anim),
        child: child,
      ),
    );
  }

  Widget _amblem(ColorScheme scheme, AppRenkler r, bool azHareket) {
    return SizedBox(
      width: 176,
      height: 176,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: scheme.primary.withValues(alpha: 0.22),
                width: 1.5,
              ),
            ),
          ),
          AnimatedBuilder(
            animation: _yorungeCtrl,
            builder: (context, child) {
              final t = azHareket
                  ? 0.0
                  : Curves.easeInOutCubic.transform(_yorungeCtrl.value);
              return Transform.rotate(
                angle: (40 + 360 * t) * math.pi / 180,
                child: child,
              );
            },
            child: Align(
              alignment: Alignment.topCenter,
              child: Transform.translate(
                offset: const Offset(0, -6),
                child: Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: scheme.primary,
                    shape: BoxShape.circle,
                    border: Border.all(color: r.bg, width: 4),
                  ),
                ),
              ),
            ),
          ),
          AnimatedBuilder(
            animation: _nefesCtrl,
            builder: (context, child) {
              final s = azHareket
                  ? 1.0
                  : 1 + 0.035 * Curves.easeInOut.transform(_nefesCtrl.value);
              return Transform.scale(scale: s, child: child);
            },
            child: Container(
              width: 116,
              height: 116,
              decoration: BoxDecoration(
                gradient: r.gradyan,
                borderRadius: BorderRadius.circular(38),
                boxShadow: [
                  BoxShadow(
                    color: r.g1.withValues(alpha: 0.30),
                    blurRadius: 36,
                    spreadRadius: -10,
                    offset: const Offset(0, 18),
                  ),
                ],
              ),
              padding: const EdgeInsets.only(bottom: 24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  AnimatedBuilder(
                    animation: _alevCtrl,
                    builder: (context, child) {
                      final s = azHareket
                          ? 1.0
                          : 1 -
                              0.14 *
                                  Curves.easeInOut.transform(_alevCtrl.value);
                      return Transform.scale(scale: s, child: child);
                    },
                    child: Transform.rotate(
                      angle: -math.pi / 4,
                      child: Container(
                        width: 18,
                        height: 18,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(9),
                            bottomLeft: Radius.circular(9),
                            bottomRight: Radius.circular(9),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(7),
                    child: const SizedBox(
                      width: 14,
                      height: 38,
                      child: CustomPaint(painter: _MumCizgileri()),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    width: 48,
                    height: 6,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.55),
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _etiket(IconData ikon, String yazi) {
    final r = context.renk;
    return Container(
      height: 32,
      padding: const EdgeInsets.only(left: 10, right: 12),
      decoration: BoxDecoration(
        color: r.s1,
        borderRadius: BorderRadius.circular(999),
        boxShadow:
            Theme.of(context).brightness == Brightness.dark ? null : r.e1,
        border: Theme.of(context).brightness == Brightness.dark
            ? Border.all(color: r.bd)
            : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(ikon, size: 18, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 6),
          Text(
            yazi,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 13,
              color: r.tx2,
            ),
          ),
        ],
      ),
    );
  }
}

class _MumCizgileri extends CustomPainter {
  const _MumCizgileri();

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size,
        Paint()..color = Colors.white.withValues(alpha: 0.62));
    final p = Paint()
      ..color = Colors.white
      ..strokeWidth = 7;
    for (double y = -size.width; y < size.height + size.width; y += 12) {
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y - size.width * 0.7),
        p,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
