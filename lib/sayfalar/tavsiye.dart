import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dogum_gunu/models/dogum_gunu.dart';
import 'package:dogum_gunu/sayfalar/dogum_gunu_ekle.dart';
import 'package:dogum_gunu/tercumeler/tercumeler.dart';
import 'package:dogum_gunu/tercumeler/tr.dart';

import '../tema/renkler.dart';
import '../widgets/burc_rozeti.dart';

class Tavsiye extends StatefulWidget {
  final DogumGunu dogumGunu;
  const Tavsiye({
    required this.dogumGunu,
    super.key,
  });

  @override
  State<Tavsiye> createState() => _TavsiyeState();
}

class _TavsiyeState extends State<Tavsiye> {
  late DogumGunu _kisi = widget.dogumGunu;

  Future<void> _duzenle() async {
    final guncel = await Get.to<DogumGunu>(
      () => DogumGunuEkle(duzenlenecek: _kisi),
    );
    if (guncel != null && mounted) setState(() => _kisi = guncel);
  }

  @override
  Widget build(BuildContext context) {
    final r = context.renk;
    final scheme = Theme.of(context).colorScheme;
    final metin = Theme.of(context).textTheme;

    final tarih = DogumGunu.tarihYazdir(_kisi.dogumTarihi);
    final signId = DogumGunu.burcIdGetir(_kisi.dogumTarihi);
    final localeCode = Get.locale?.languageCode ?? 'tr';
    final translations =
        Tercumeler().keys[localeCode] ?? tr; // fallback to tr for safety
    final signName = tZodiac(signId, 'name', translations);
    final shortText = tZodiac(signId, 'short', translations);
    final giftItems = tZodiacList(signId, 'gifts', translations);
    final surpriseItems = tZodiacList(signId, 'surprises', translations);
    final dateRange = tZodiac(signId, 'range', translations);

    return Scaffold(
      backgroundColor: r.bg,
      appBar: AppBar(
        backgroundColor: r.bg,
        titleSpacing: 0,
        toolbarHeight: 64,
        leading: IconButton(
          tooltip: MaterialLocalizations.of(context).backButtonTooltip,
          onPressed: () => Navigator.of(context).maybePop(),
          icon: const Icon(Icons.arrow_back_rounded),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'advice.appbar'.trParams({'name': _kisi.isim}),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: metin.titleLarge?.copyWith(fontSize: 20, height: 1.3),
            ),
            Text(
              signName,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 13,
                height: 18 / 13,
                color: r.tx2,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'home.menu.edit'.tr,
            onPressed: _duzenle,
            color: r.tx2,
            icon: const Icon(Icons.edit_rounded),
          ),
          const SizedBox(width: 6),
        ],
      ),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
          children: [
            const SizedBox(height: 16),
            Center(
              child: Hero(
                tag: 'zodiac-${_kisi.id}',
                child: Container(
                  width: 112,
                  height: 112,
                  decoration: BoxDecoration(
                    gradient: r.gradyan,
                    borderRadius: BorderRadius.circular(32),
                    boxShadow: [
                      BoxShadow(
                        color: scheme.primaryContainer,
                        spreadRadius: 8,
                      ),
                    ],
                  ),
                  alignment: Alignment.center,
                  child:
                      BurcIkonu(burcId: signId, boyut: 60, renk: Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              signName,
              textAlign: TextAlign.center,
              style: metin.displaySmall?.copyWith(
                fontSize: 34,
                height: 38 / 34,
                letterSpacing: -0.68,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              dateRange,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 15,
                height: 20 / 15,
                color: r.tx2,
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: Container(
                height: 34,
                padding: const EdgeInsets.only(left: 10, right: 14),
                decoration: BoxDecoration(
                  color: r.s2,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.cake_rounded, size: 18, color: scheme.primary),
                    const SizedBox(width: 6),
                    Text(
                      tarih,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: r.tx,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 28),
            Text(
              shortText,
              textAlign: TextAlign.center,
              style: metin.bodyLarge,
            ),
            const SizedBox(height: 28),
            _bolum(
              ikon: Icons.redeem_rounded,
              baslik: 'advice.gifts.title'.tr,
              ogeler: giftItems,
            ),
            const SizedBox(height: 28),
            _bolum(
              ikon: Icons.auto_awesome_rounded,
              baslik: 'advice.surprises.title'.tr,
              ogeler: surpriseItems,
            ),
            const SizedBox(height: 28),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: r.infoc,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.info_rounded, size: 22, color: r.info),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'advice.info'.tr,
                      style: TextStyle(
                        fontSize: 14,
                        height: 20 / 14,
                        color: r.onInfoc,
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

  Widget _bolum({
    required IconData ikon,
    required String baslik,
    required List<String> ogeler,
  }) {
    final r = context.renk;
    final scheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: scheme.primaryContainer,
                borderRadius: BorderRadius.circular(11),
              ),
              child: Icon(ikon, size: 20, color: scheme.onPrimaryContainer),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                baslik,
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(fontSize: 20),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: BoxDecoration(
            color: r.s1,
            borderRadius: BorderRadius.circular(20),
            boxShadow: r.e1,
          ),
          child: Column(
            children: [
              for (var i = 0; i < ogeler.length; i++)
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    border:
                        i == 0 ? null : Border(top: BorderSide(color: r.bd)),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        margin: const EdgeInsets.only(top: 7),
                        decoration: BoxDecoration(
                          color: scheme.primary,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          ogeler[i],
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 15,
                            height: 22 / 15,
                            color: r.tx,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
