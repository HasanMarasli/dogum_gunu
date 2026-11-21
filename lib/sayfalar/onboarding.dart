import 'dart:math' as math;

import 'package:dogum_gunu/models/bildirim_yoneticisi.dart';
import 'package:dogum_gunu/tercumeler/tercumeler.dart';
import 'package:dogum_gunu/tercumeler/en.dart';
import 'package:dogum_gunu/tercumeler/tr.dart' show tZodiac;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/intl.dart';

import '../tema/ekran.dart';
import '../tema/renkler.dart';
import '../widgets/burc_rozeti.dart';
import 'ana_sayfa.dart';

class Onboarding extends StatefulWidget {
  const Onboarding({super.key});

  static const String _tamamKey = 'onboarding_done';

  static bool tamamlandiMi(GetStorage box) =>
      box.read<bool>(_tamamKey) ?? false;

  @override
  State<Onboarding> createState() => _OnboardingState();
}

class _OnboardingState extends State<Onboarding> {
  final PageController _sayfa = PageController();
  int _adim = 0;
  bool _izinBekleniyor = false;

  static const int _adimSayisi = 4;
  static const double _cizimMaxYukseklik = 348;
  static const double _cizimMinYukseklik = 160;
  static const double _cizimMaxYukseklikTablet = 420;
  static const double _dikeyGenislik = 560;
  static const double _yanYanaGenislik = 960;

  @override
  void dispose() {
    _sayfa.dispose();
    super.dispose();
  }

  void _bitir() {
    GetStorage().write(Onboarding._tamamKey, true);
    Get.offAll(
      () => const AnaSayfa(),
      transition: Transition.fade,
      duration: const Duration(milliseconds: 250),
    );
  }

  bool get _azHareket => MediaQuery.of(context).disableAnimations;

  void _adimaGit(int adim) {
    if (_azHareket) {
      _sayfa.jumpToPage(adim);
    } else {
      _sayfa.animateToPage(
        adim,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
      );
    }
  }

  // Atla, bildirim izni adımını da geçmesin diye son adıma götürür.
  void _sonAdimaGit() => _adimaGit(_adimSayisi - 1);

  void _ileri() => _adimaGit(_adim + 1);

  Future<void> _izinIste() async {
    if (_izinBekleniyor) return;
    setState(() => _izinBekleniyor = true);
    try {
      await BildirimYoneticisi().izinIste();
    } finally {
      _bitir();
    }
  }

  @override
  Widget build(BuildContext context) {
    final r = context.renk;
    final metin = Theme.of(context).textTheme;
    final pencere = MediaQuery.sizeOf(context);
    final sonAdim = _adim == _adimSayisi - 1;
    // Yatay telefon ve yatay geniş tablette çizim ile metin yan yana durur,
    // düğmeler tek satırda toplanır.
    final yanYana =
        context.alcakMi() ||
        (pencere.width >= Ekran.buyukTabletEsik &&
            pencere.width > pencere.height);
    final cizimMax = context.tabletMi
        ? _cizimMaxYukseklikTablet
        : _cizimMaxYukseklik;

    final basliklar = [
      'onboarding.1.title'.tr,
      'onboarding.2.title'.tr,
      'onboarding.3.title'.tr,
      'onboarding.4.title'.tr,
    ];
    final aciklamalar = [
      'onboarding.1.desc'.tr,
      'onboarding.2.desc'.tr,
      'onboarding.3.desc'.tr,
      'onboarding.4.desc'.tr,
    ];

    Widget metinBlogu(int i) => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(basliklar[i], style: metin.headlineMedium),
        const SizedBox(height: 10),
        Text(aciklamalar[i], style: metin.bodyLarge?.copyWith(color: r.tx2)),
      ],
    );

    Widget cizim(int i) => AspectRatio(
      aspectRatio: 312 / 348,
      child: RepaintBoundary(child: _CizimCercevesi(adim: i)),
    );

    final sayfalar = PageView.builder(
      controller: _sayfa,
      itemCount: _adimSayisi,
      onPageChanged: (i) => setState(() => _adim = i),
      itemBuilder: (context, i) {
        return LayoutBuilder(
          builder: (context, c) {
            if (yanYana) {
              final cizimYuksekligi = math.min(cizimMax, c.maxHeight);
              return Row(
                children: [
                  if (cizimYuksekligi >= _cizimMinYukseklik) ...[
                    SizedBox(height: cizimYuksekligi, child: cizim(i)),
                    const SizedBox(width: 32),
                  ],
                  Expanded(
                    child: Center(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: SizedBox(
                          width: double.infinity,
                          child: metinBlogu(i),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            }
            // Metne yazı ölçeğiyle büyüyen bir alan ayrılır; çizim
            // kalan yere sığar, çok kısa ekranda hiç gösterilmez.
            final olcek = MediaQuery.textScalerOf(context).scale(16) / 16;
            final metinAlani = 150 * olcek;
            final cizimYuksekligi = math.min(
              cizimMax,
              c.maxHeight - 8 - 24 - metinAlani,
            );
            final cizimGoster = cizimYuksekligi >= _cizimMinYukseklik;
            return Column(
              children: [
                if (cizimGoster) ...[
                  const SizedBox(height: 8),
                  SizedBox(
                    height: cizimYuksekligi,
                    child: Center(child: cizim(i)),
                  ),
                  const SizedBox(height: 24),
                ],
                Expanded(
                  child: SingleChildScrollView(
                    child: SizedBox(
                      width: double.infinity,
                      child: Padding(
                        padding: EdgeInsets.only(top: cizimGoster ? 0 : 8),
                        child: metinBlogu(i),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );

    // Android geri tuşu önceki adıma döner; ilk adımda uygulamadan çıkar.
    return PopScope(
      canPop: _adim == 0,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _adimaGit(_adim - 1);
      },
      child: Scaffold(
        backgroundColor: r.bg,
        body: SafeArea(
          child: OkunurGenislik(
            azami: yanYana ? _yanYanaGenislik : _dikeyGenislik,
            hizalama: Alignment.center,
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                24,
                yanYana ? 12 : 0,
                24,
                yanYana ? 12 : 24,
              ),
              child: yanYana
                  ? Column(
                      children: [
                        Expanded(child: sayfalar),
                        const SizedBox(height: 12),
                        _yatayAltCubuk(sonAdim),
                      ],
                    )
                  : Column(
                      children: [
                        SizedBox(
                          height: 64,
                          child: Align(
                            alignment: Alignment.bottomRight,
                            child: _atlaDugmesi(sonAdim),
                          ),
                        ),
                        Expanded(child: sayfalar),
                        _noktalar(),
                        const SizedBox(height: 24),
                        ConstrainedBox(
                          constraints: const BoxConstraints(
                            minWidth: double.infinity,
                            minHeight: 52,
                          ),
                          child: _anaDugme(sonAdim),
                        ),
                        AnimatedSize(
                          duration: const Duration(milliseconds: 200),
                          child: sonAdim
                              ? Padding(
                                  padding: const EdgeInsets.only(top: 4),
                                  child: SizedBox(
                                    width: double.infinity,
                                    child: _sonraDugmesi(),
                                  ),
                                )
                              : const SizedBox(width: double.infinity),
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }

  /// Yan yana düzende noktalar solda, düğmeler sağda tek satırdadır.
  Widget _yatayAltCubuk(bool sonAdim) {
    return Row(
      children: [
        _noktalar(),
        const Spacer(),
        if (sonAdim) _sonraDugmesi() else _atlaDugmesi(sonAdim),
        const SizedBox(width: 8),
        ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 52, minWidth: 160),
          child: _anaDugme(sonAdim),
        ),
      ],
    );
  }

  Widget _atlaDugmesi(bool sonAdim) {
    final r = context.renk;
    return AnimatedOpacity(
      opacity: sonAdim ? 0 : 1,
      duration: const Duration(milliseconds: 200),
      child: IgnorePointer(
        ignoring: sonAdim,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: TextButton(
            onPressed: _sonAdimaGit,
            style: TextButton.styleFrom(
              foregroundColor: r.tx2,
              minimumSize: const Size(48, 48),
            ),
            child: Text('onboarding.skip'.tr),
          ),
        ),
      ),
    );
  }

  Widget _sonraDugmesi() {
    final r = context.renk;
    return TextButton(
      onPressed: _izinBekleniyor ? null : _bitir,
      style: TextButton.styleFrom(
        foregroundColor: r.tx2,
        minimumSize: const Size(48, 48),
      ),
      child: Text('onboarding.later'.tr),
    );
  }

  Widget _noktalar() {
    final r = context.renk;
    final scheme = Theme.of(context).colorScheme;
    return Semantics(
      label: 'onboarding.step'.trParams({
        'current': '${_adim + 1}',
        'total': '$_adimSayisi',
      }),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: List.generate(_adimSayisi, (i) {
          final aktif = i == _adim;
          return AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            margin: const EdgeInsets.symmetric(horizontal: 4),
            width: aktif ? 24 : 8,
            height: 8,
            decoration: BoxDecoration(
              color: aktif ? scheme.primary : r.bd2,
              borderRadius: BorderRadius.circular(4),
            ),
          );
        }),
      ),
    );
  }

  Widget _anaDugme(bool sonAdim) {
    final metin = Theme.of(context).textTheme;
    return FilledButton(
      onPressed: sonAdim ? _izinIste : _ileri,
      style: FilledButton.styleFrom(
        textStyle: metin.labelLarge?.copyWith(fontSize: 16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: sonAdim
            ? [
                const Icon(Icons.notifications_rounded, size: 20),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    'onboarding.allow'.tr,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ]
            : [
                Text('onboarding.next'.tr),
                const SizedBox(width: 8),
                const Icon(Icons.arrow_forward_rounded, size: 20),
              ],
      ),
    );
  }
}

/// Çizim alanı: 312×348 tasarım ölçüsünde çizilir, ekrana göre ölçeklenir.
class _CizimCercevesi extends StatelessWidget {
  const _CizimCercevesi({required this.adim});

  final int adim;

  @override
  Widget build(BuildContext context) {
    final r = context.renk;
    final scheme = Theme.of(context).colorScheme;
    final koyu = Theme.of(context).brightness == Brightness.dark;
    final zemin = Color.lerp(r.bg, scheme.primaryContainer, koyu ? 0.28 : 0.7)!;

    final Widget icerik;
    switch (adim) {
      case 0:
        icerik = _Cizim1(zemin: zemin);
      case 1:
        icerik = _Cizim2(zemin: zemin);
      case 2:
        icerik = _Cizim3(zemin: zemin);
      default:
        icerik = const _Cizim4();
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(32),
      child: ColoredBox(
        color: zemin,
        // Çizim sabit ölçüde tasarlandı; yazı boyutu ayarı içini taşırmasın.
        child: MediaQuery.withNoTextScaling(
          child: FittedBox(
            child: SizedBox(width: 312, height: 348, child: icerik),
          ),
        ),
      ),
    );
  }
}

/// Çizimlerdeki örnek kişinin doğum tarihi; bildirimdeki yaş buradan çıkar.
final DateTime _ornekDogum = DateTime(1994, 11, 2);

String _gunAy(DateTime t) =>
    DateFormat.MMMMd(Get.locale?.languageCode ?? 'en').format(t);

String _burcAdi(String id) {
  final dil = Get.locale?.languageCode ?? 'en';
  return tZodiac(id, 'name', Tercumeler().keys[dil] ?? en);
}

Widget _okRozeti(BuildContext context, Color zemin) {
  final scheme = Theme.of(context).colorScheme;
  return Container(
    width: 32,
    height: 32,
    decoration: BoxDecoration(
      color: scheme.primary,
      shape: BoxShape.circle,
      border: Border.all(color: zemin, width: 4),
    ),
    child: Icon(Icons.south_rounded, size: 18, color: scheme.onPrimary),
  );
}

class _Cizim1 extends StatelessWidget {
  const _Cizim1({required this.zemin});

  final Color zemin;

  @override
  Widget build(BuildContext context) {
    final r = context.renk;
    final scheme = Theme.of(context).colorScheme;

    Widget satir(
      String isim,
      DateTime tarih,
      String burc,
      int gun, {
      bool vurgulu = false,
    }) {
      return Container(
        margin: EdgeInsets.symmetric(horizontal: vurgulu ? 6 : 0),
        padding: EdgeInsets.symmetric(
          horizontal: vurgulu ? 6 : 12,
          vertical: 6,
        ),
        decoration: vurgulu
            ? BoxDecoration(
                color: Color.lerp(r.s1, scheme.primary, 0.12),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: scheme.primary, width: 1.5),
              )
            : null,
        child: Row(
          children: [
            BurcRozeti(burcId: burc, boyut: 32, gradyan: vurgulu),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isim,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: r.tx,
                    ),
                  ),
                  Text(
                    _gunAy(tarih),
                    style: TextStyle(fontSize: 12, color: r.tx2),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: vurgulu ? scheme.primary : scheme.primaryContainer,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                trSayi('home.countdown.days', gun, {'days': '$gun'}),
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                  color: vurgulu ? scheme.onPrimary : scheme.onPrimaryContainer,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Stack(
      children: [
        Positioned(
          left: 18,
          right: 18,
          bottom: 14,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 4),
            decoration: BoxDecoration(
              color: r.s1,
              borderRadius: BorderRadius.circular(20),
              boxShadow: r.e1,
            ),
            child: Column(
              children: [
                satir(
                  'onboarding.sample.other1'.tr,
                  DateTime(1990, 10, 25),
                  'scorpio',
                  4,
                ),
                satir(
                  'onboarding.sample.main'.tr,
                  _ornekDogum,
                  'scorpio',
                  12,
                  vurgulu: true,
                ),
                satir(
                  'onboarding.sample.other2'.tr,
                  DateTime(1992, 12, 3),
                  'sagittarius',
                  43,
                ),
              ],
            ),
          ),
        ),
        Positioned(left: 140, top: 156, child: _okRozeti(context, zemin)),
        Positioned(
          left: 30,
          right: 30,
          top: 14,
          child: Transform.rotate(
            angle: -2.5 * math.pi / 180,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: r.raised,
                borderRadius: BorderRadius.circular(22),
                boxShadow: r.e3,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: scheme.primaryContainer,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.person_add_rounded,
                          size: 16,
                          color: scheme.onPrimaryContainer,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'onboarding.ill.newPerson'.tr,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontSize: 15,
                          height: 1.2,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  _sahteAlan(
                    context,
                    'onboarding.sample.main'.tr,
                    odakli: false,
                  ),
                  const SizedBox(height: 6),
                  _sahteAlan(
                    context,
                    DateFormat.yMMMMd(
                      Get.locale?.languageCode ?? 'en',
                    ).format(_ornekDogum),
                    odakli: true,
                    ikon: Icons.calendar_month_rounded,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

Widget _sahteAlan(
  BuildContext context,
  String yazi, {
  required bool odakli,
  IconData? ikon,
}) {
  final r = context.renk;
  final scheme = Theme.of(context).colorScheme;
  return Container(
    height: 36,
    padding: const EdgeInsets.symmetric(horizontal: 12),
    decoration: BoxDecoration(
      color: r.s1,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: odakli ? scheme.primary : r.bd2, width: 1.5),
      boxShadow: odakli
          ? [
              BoxShadow(
                color: scheme.primary.withValues(alpha: 0.2),
                spreadRadius: 3,
              ),
            ]
          : null,
    ),
    child: Row(
      children: [
        if (ikon != null) ...[
          Icon(ikon, size: 18, color: scheme.primary),
          const SizedBox(width: 8),
        ],
        Flexible(
          child: Text(
            yazi,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 14,
              color: r.tx,
            ),
          ),
        ),
      ],
    ),
  );
}

class _Cizim2 extends StatelessWidget {
  const _Cizim2({required this.zemin});

  final Color zemin;

  @override
  Widget build(BuildContext context) {
    final r = context.renk;
    final scheme = Theme.of(context).colorScheme;

    Widget yuzenRozet(String burc, double aci) => Transform.rotate(
      angle: aci * math.pi / 180,
      child: Container(
        width: 40,
        height: 40,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: r.s1,
          borderRadius: BorderRadius.circular(13),
          boxShadow: r.e1,
        ),
        child: BurcIkonu(burcId: burc, boyut: 20, renk: r.tx3),
      ),
    );

    Widget baslik(IconData ikon, String yazi, {Widget? sag}) => SizedBox(
      height: 18,
      child: Row(
        children: [
          Icon(ikon, size: 17, color: scheme.primary),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              yazi,
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontSize: 13, height: 1.2),
            ),
          ),
          if (sag != null) sag,
        ],
      ),
    );

    Widget oge(IconData ikon, String yazi) => SizedBox(
      height: 30,
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: scheme.primaryContainer,
              borderRadius: BorderRadius.circular(9),
            ),
            child: Icon(ikon, size: 17, color: scheme.onPrimaryContainer),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              yazi,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 13,
                color: r.tx,
              ),
            ),
          ),
        ],
      ),
    );

    return Stack(
      children: [
        Positioned(left: 18, top: 74, child: yuzenRozet('pisces', -10)),
        Positioned(right: 18, top: 78, child: yuzenRozet('aries', 9)),
        Positioned(
          left: 18,
          right: 18,
          bottom: 14,
          child: Container(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 10),
            decoration: BoxDecoration(
              color: r.s1,
              borderRadius: BorderRadius.circular(20),
              boxShadow: r.e1,
            ),
            child: Column(
              children: [
                baslik(
                  Icons.redeem_rounded,
                  'advice.gifts.title'.tr,
                  sag: Container(
                    padding: const EdgeInsets.fromLTRB(6, 3, 8, 3),
                    decoration: BoxDecoration(
                      color: scheme.primaryContainer,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        BurcIkonu(
                          burcId: 'leo',
                          boyut: 12,
                          renk: scheme.onPrimaryContainer,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _burcAdi('leo'),
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 11,
                            color: scheme.onPrimaryContainer,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                oge(Icons.watch_rounded, 'gift.saat'.tr),
                const SizedBox(height: 4),
                oge(Icons.local_activity_rounded, 'gift.tiyatro'.tr),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Divider(color: r.bd),
                ),
                baslik(Icons.celebration_rounded, 'advice.surprises.title'.tr),
                const SizedBox(height: 4),
                oge(Icons.cake_rounded, 'surprise.miniParti'.tr),
                const SizedBox(height: 4),
                oge(Icons.auto_awesome_rounded, 'surprise.konsept'.tr),
              ],
            ),
          ),
        ),
        Positioned(left: 140, top: 94, child: _okRozeti(context, zemin)),
        Positioned(
          left: 30,
          right: 30,
          top: 20,
          child: Transform.rotate(
            angle: -2.5 * math.pi / 180,
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: r.raised,
                borderRadius: BorderRadius.circular(22),
                boxShadow: r.e3,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 36,
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      decoration: BoxDecoration(
                        color: r.s1,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: r.bd2, width: 1.5),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.calendar_month_rounded,
                            size: 17,
                            color: r.tx2,
                          ),
                          const SizedBox(width: 6),
                          Flexible(
                            child: Text(
                              _gunAy(DateTime(1990, 8, 2)),
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 13,
                                color: r.tx,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(Icons.arrow_forward_rounded, size: 18, color: r.tx3),
                  const SizedBox(width: 8),
                  const BurcRozeti(burcId: 'leo', boyut: 36, gradyan: true),
                  const SizedBox(width: 6),
                  Text(
                    _burcAdi('leo'),
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                      color: r.tx,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _Cizim3 extends StatelessWidget {
  const _Cizim3({required this.zemin});

  final Color zemin;

  @override
  Widget build(BuildContext context) {
    final r = context.renk;
    final scheme = Theme.of(context).colorScheme;

    Widget kisi(String isim, DateTime tarih) => SizedBox(
      height: 30,
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: scheme.primaryContainer,
              shape: BoxShape.circle,
            ),
            child: Text(
              isim.characters.first,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 11,
                color: scheme.onPrimaryContainer,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              isim,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 12,
                color: r.tx,
              ),
            ),
          ),
          Text(
            DateFormat.MMMd(Get.locale?.languageCode ?? 'en').format(tarih),
            style: TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 11,
              color: r.tx3,
            ),
          ),
        ],
      ),
    );

    Widget rozet(IconData ikon, String yazi, double aci) => Transform.rotate(
      angle: aci * math.pi / 180,
      child: Container(
        height: 34,
        padding: const EdgeInsets.only(left: 9, right: 12),
        decoration: BoxDecoration(
          color: r.s1,
          borderRadius: BorderRadius.circular(999),
          boxShadow: r.e1,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(ikon, size: 18, color: scheme.primary),
            const SizedBox(width: 6),
            Text(
              yazi,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 13,
                color: r.tx,
              ),
            ),
          ],
        ),
      ),
    );

    return Stack(
      children: [
        Positioned(
          left: 22,
          top: 28,
          child: Transform.rotate(
            angle: -2 * math.pi / 180,
            child: Container(
              width: 156,
              height: 276,
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
              decoration: BoxDecoration(
                color: r.raised,
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: r.bd2, width: 1.5),
                boxShadow: r.e3,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 44,
                      height: 6,
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: r.bd2,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 2, bottom: 4),
                    child: Text(
                      'home.title'.tr,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontSize: 13,
                        height: 1.2,
                      ),
                    ),
                  ),
                  kisi('onboarding.sample.first1'.tr, DateTime(2000, 8, 2)),
                  const SizedBox(height: 6),
                  kisi('onboarding.sample.first2'.tr, DateTime(2000, 9, 14)),
                  const SizedBox(height: 6),
                  kisi('onboarding.sample.first3'.tr, DateTime(2000, 11, 3)),
                  const SizedBox(height: 6),
                  kisi('onboarding.sample.first4'.tr, DateTime(2000, 12, 21)),
                ],
              ),
            ),
          ),
        ),
        Positioned(
          left: 70,
          top: 256,
          child: Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              gradient: r.gradyan,
              shape: BoxShape.circle,
              border: Border.all(color: zemin, width: 5),
            ),
            child: Icon(Icons.lock_rounded, size: 28, color: r.onGradyan),
          ),
        ),
        Positioned(
          right: 16,
          top: 64,
          child: rozet(
            Icons.no_accounts_rounded,
            'onboarding.ill.noAccount'.tr,
            -8,
          ),
        ),
        Positioned(
          right: 22,
          top: 136,
          child: rozet(Icons.edit_off_rounded, 'onboarding.ill.noSignup'.tr, 7),
        ),
        Positioned(
          right: 14,
          top: 208,
          child: rozet(
            Icons.cloud_off_rounded,
            'onboarding.ill.noCloud'.tr,
            -5,
          ),
        ),
      ],
    );
  }
}

class _Cizim4 extends StatelessWidget {
  const _Cizim4();

  @override
  Widget build(BuildContext context) {
    final r = context.renk;
    final scheme = Theme.of(context).colorScheme;
    final gunler = [
      'onboarding.4.day7'.tr,
      'onboarding.4.day2'.tr,
      'onboarding.4.day1'.tr,
      'settings.notifications.option.0'.tr,
    ];

    return Stack(
      children: [
        Positioned(
          left: 28,
          right: 28,
          top: 46,
          child: Container(
            height: 70,
            decoration: BoxDecoration(
              color: r.s1.withValues(alpha: 0.55),
              borderRadius: BorderRadius.circular(20),
            ),
          ),
        ),
        Positioned(
          left: 16,
          right: 16,
          top: 28,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: r.raised,
              borderRadius: BorderRadius.circular(20),
              boxShadow: r.e3,
            ),
            child: Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    gradient: r.gradyan,
                    borderRadius: BorderRadius.circular(11),
                  ),
                  child: Icon(Icons.cake_rounded, size: 22, color: r.onGradyan),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              'notification.title'.tr,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 13,
                                color: r.tx,
                              ),
                            ),
                          ),
                          Text(
                            DateFormat.jm(
                              Get.locale?.languageCode ?? 'en',
                            ).format(DateTime(2000, 1, 1, 9)),
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 12,
                              color: r.tx3,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'notification.body.today'.trParams({
                          'name': 'onboarding.sample.main'.tr,
                          'age': '${DateTime.now().year - _ornekDogum.year}',
                        }),
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 13,
                          height: 18 / 13,
                          color: r.tx2,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        Positioned(
          left: 16,
          right: 16,
          top: 140,
          child: Container(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 6),
            decoration: BoxDecoration(
              color: r.s1,
              borderRadius: BorderRadius.circular(20),
              boxShadow: r.e1,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 28,
                  child: Row(
                    children: [
                      Icon(
                        Icons.schedule_rounded,
                        size: 18,
                        color: scheme.primary,
                      ),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          'onboarding.4.eachAt'.tr,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                            letterSpacing: 0.24,
                            color: r.tx2,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                for (final g in gunler)
                  Container(
                    height: 34,
                    decoration: BoxDecoration(
                      border: Border(top: BorderSide(color: r.bd)),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            g,
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                              color: r.tx,
                            ),
                          ),
                        ),
                        Icon(
                          Icons.check_circle_rounded,
                          size: 20,
                          color: scheme.primary,
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
