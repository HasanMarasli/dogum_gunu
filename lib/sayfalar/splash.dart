import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../tema/tema_yoneticisi.dart';
import 'ana_sayfa.dart';

class Splash extends StatefulWidget {
  const Splash({super.key});

  @override
  State<Splash> createState() => _SplashState();
}

class _SplashState extends State<Splash> with TickerProviderStateMixin {
  late final AnimationController _pulseCtrl;
  late final AnimationController _orbitCtrl;

  late final Animation<double> _pulse;
  late final Animation<double> _glow;
  late final Animation<double> _orbit;

  @override
  void initState() {
    super.initState();

    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )..repeat(reverse: true);

    _orbitCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat(reverse: true);

    _pulse = Tween<double>(begin: 0.96, end: 1.06).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut),
    );

    _glow = Tween<double>(begin: 0.22, end: 0.55).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut),
    );

    _orbit = CurvedAnimation(parent: _orbitCtrl, curve: Curves.linear);

    // NOT: Burada sen Duration(minutes: 2) yazmışsın. Splash için genelde hata olur.
    // İstersen 2 saniyeye çek: Duration(seconds: 2)
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) Get.off(() => const AnaSayfa());
    });
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    _orbitCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tema = Get.find<TemaYoneticisi>();
    final gradient = LinearGradient(
      colors: [tema.gradientStart, tema.gradientEnd],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(gradient: gradient),
        child: SafeArea(
          child: Stack(
            children: [
              // HATA DÜZELTME: _SoftBlobs artık t istiyor; bu yüzden const olamaz.
              Positioned.fill(child: _SoftBlobs(t: _orbit)),

              // Üst mini “amaç” kartları
              const Positioned(
                top: 14,
                left: 14,
                right: 14,
                child: Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  alignment: WrapAlignment.center,
                  children: [
                    _MiniInfoPill(
                        icon: Icons.favorite_rounded,
                        text: 'Sevdiklerini ekle'),
                    _MiniInfoPill(
                        icon: Icons.notifications_active_rounded,
                        text: 'Akıllı hatırlatma'),
                    _MiniInfoPill(
                        icon: Icons.lock_rounded, text: 'Gizlilik odaklı'),
                  ],
                ),
              ),

              // Ana içerik
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AnimatedBuilder(
                      animation: Listenable.merge([_pulseCtrl, _orbitCtrl]),
                      builder: (context, _) {
                        return Transform.scale(
                          scale: _pulse.value,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              // dış glow
                              Opacity(
                                opacity: _glow.value,
                                child: Container(
                                  width: 210,
                                  height: 210,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.white.withOpacity(0.10),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.white.withOpacity(0.18),
                                        blurRadius: 55,
                                        spreadRadius: 14,
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                              // orbit ring
                              SizedBox(
                                width: 185,
                                height: 185,
                                child: CustomPaint(
                                  painter: _RingPainter(
                                    t: _orbit.value,
                                    color: Colors.white.withOpacity(0.75),
                                  ),
                                ),
                              ),

                              // ana rozet
                              Container(
                                width: 120,
                                height: 120,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.16),
                                      blurRadius: 22,
                                      offset: const Offset(0, 12),
                                    ),
                                  ],
                                ),
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    // arka ikon (takvim)
                                    Icon(
                                      Icons.calendar_month_rounded,
                                      size: 58,
                                      color: const Color(0xFF2F2F2F)
                                          .withOpacity(0.85),
                                    ),

                                    // önde küçük kalp
                                    Positioned(
                                      right: 30,
                                      bottom: 28,
                                      child: Container(
                                        padding: const EdgeInsets.all(7),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFFF4D6D),
                                          borderRadius:
                                              BorderRadius.circular(999),
                                          boxShadow: [
                                            BoxShadow(
                                              color: const Color(0xFFFF4D6D)
                                                  .withOpacity(0.35),
                                              blurRadius: 16,
                                              offset: const Offset(0, 8),
                                            ),
                                          ],
                                        ),
                                        child: const Icon(
                                          Icons.favorite_rounded,
                                          color: Colors.white,
                                          size: 16,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 18),

                    Text(
                      'app.title'.tr,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        height: 1.05,
                        letterSpacing: 0.2,
                      ),
                    ),
                    const SizedBox(height: 8),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 26),
                      child: Text(
                        'splash.subtitle'.tr,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.88),
                          fontSize: 13.5,
                          height: 1.25,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // alt küçük yükleniyor hissi
                    Opacity(
                      opacity: 0.85,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.10),
                          borderRadius: BorderRadius.circular(999),
                          border:
                              Border.all(color: Colors.white.withOpacity(0.14)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(
                              width: 14,
                              height: 14,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white.withOpacity(0.9),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              'Hazırlanıyor…',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.9),
                                fontWeight: FontWeight.w700,
                                fontSize: 12,
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
      ),
    );
  }
}

// --------------------
// Küçük parçalar
// --------------------

class _MiniInfoPill extends StatelessWidget {
  final IconData icon;
  final String text;

  const _MiniInfoPill({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.20),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withOpacity(0.14)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Colors.white.withOpacity(0.92)),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
              color: Colors.white.withOpacity(0.92),
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _SoftBlobs extends StatelessWidget {
  final Animation<double> t;
  const _SoftBlobs({required this.t});

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: t,
        builder: (context, _) {
          final x = t.value; // 0..1

          // Her blob için farklı hız (speed) ve faz (phase) veriyoruz.
          Offset circle(double radius, double speed, double phase) {
            final a = 2 * math.pi * (x * speed + phase);
            return Offset(math.cos(a) * radius, math.sin(a) * radius);
          }

          final o1 = circle(22, 0.22, 0.05);
          final o2 = circle(26, 0.18, 0.35);
          final o3 = circle(30, 0.14, 0.62);

          double breathe(double amp, double speed, double phase) {
            final a = 2 * math.pi * (x * speed + phase);
            return 1.0 + amp * math.sin(a);
          }

          return Stack(
            children: [
              Positioned(
                left: -90 + o1.dx,
                top: 120 + o1.dy,
                child: _Blob(
                  size: 240,
                  color: Colors.white.withOpacity(0.08),
                  scale: breathe(0.04, 0.30, 0.20),
                ),
              ),
              Positioned(
                right: -120 + o2.dx,
                top: 220 + o2.dy,
                child: _Blob(
                  size: 300,
                  color: Colors.white.withOpacity(0.06),
                  scale: breathe(0.05, 0.26, 0.18),
                ),
              ),
              Positioned(
                left: 40 + o3.dx,
                bottom: -160 + o3.dy,
                child: _Blob(
                  size: 360,
                  color: Colors.white.withOpacity(0.05),
                  scale: breathe(0.035, 0.22, 0.33),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _Blob extends StatelessWidget {
  final double size;
  final Color color;
  final double scale;

  const _Blob({
    required this.size,
    required this.color,
    this.scale = 1.0,
  });

  @override
  Widget build(BuildContext context) {
    return Transform.scale(
      scale: scale,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(size * 0.45),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.9),
              blurRadius: 90,
              spreadRadius: 10,
            ),
          ],
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  final double t;
  final Color color;

  _RingPainter({required this.t, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final r = size.width / 2;

    final base = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..color = color.withOpacity(0.22);

    canvas.drawCircle(center, r, base);

    final dotPaint = Paint()..color = color.withOpacity(0.85);
    final glowPaint = Paint()..color = color.withOpacity(0.18);

    // 2 nokta orbit
    for (final phase in [0.0, 0.5]) {
      final a = 2 * math.pi * (t + phase);
      final p =
          Offset(center.dx + math.cos(a) * r, center.dy + math.sin(a) * r);
      canvas.drawCircle(p, 10, glowPaint);
      canvas.drawCircle(p, 4, dotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _RingPainter oldDelegate) =>
      oldDelegate.t != t || oldDelegate.color != color;
}
