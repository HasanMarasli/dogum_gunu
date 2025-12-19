import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:dogum_gunu/models/dogum_gunu.dart';
import 'package:dogum_gunu/tercumeler/tercumeler.dart';
import 'package:dogum_gunu/tercumeler/tr.dart';
import 'package:dogum_gunu/tema/tema_yoneticisi.dart';

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
  @override
  Widget build(BuildContext context) {
    final tarih = DogumGunu.tarihYazdir(widget.dogumGunu.dogumTarihi);
    final signId = DogumGunu.burcIdGetir(widget.dogumGunu.dogumTarihi);
    final localeCode = Get.locale?.languageCode ?? 'tr';
    final translations = Tercumeler().keys[localeCode] ?? tr; // fallback to tr for safety
    final signName = tZodiac(signId, 'name', translations);
    final shortText = tZodiac(signId, 'short', translations);
    final giftItems = tZodiacList(signId, 'gifts', translations);
    final surpriseItems = tZodiacList(signId, 'surprises', translations);
    final dateRange = tZodiac(signId, 'range', translations);

    final scheme = Theme.of(context).colorScheme;
    final tema = Get.find<TemaYoneticisi>();

    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      appBar: AppBar(
        elevation: 0,
        foregroundColor: Colors.white,
        backgroundColor: Colors.transparent,
        titleSpacing: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'advice.appbar'.trParams({'name': widget.dogumGunu.isim}),
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 2),
            Text(
              signName,
              style: TextStyle(
                color: Colors.white.withOpacity(0.85),
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                tema.gradientStart,
                tema.gradientEnd,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              stops: const [0, 1],
            ),
          ),
        ),
      ),
      body: Container(
        height: Get.height,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              tema.gradientStart,
              tema.gradientEnd,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            stops: const [0, 1],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 24),
            child: Column(
              children: [
                const SizedBox(height: 8),
                Hero(
                  tag: widget.dogumGunu.id,
                  child: Container(
                    height: 180,
                    width: 180,
                    padding: const EdgeInsets.all(28),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [
                          tema.gradientStart,
                          tema.gradientEnd,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.12),
                          blurRadius: 18,
                          offset: const Offset(0, 8),
                        )
                      ],
                    ),
                    child: SvgPicture.asset(
                      DogumGunu.burcIconGetir(widget.dogumGunu.dogumTarihi),
                      color: Colors.white,
                    ),
                  ),
                ),
                const Gap(24),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        signName,
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF2F2F2F),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        dateRange,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade700,
                        ),
                      ),
                      const Gap(16),
                      Row(
                        children: [
                          Icon(Icons.cake_rounded, color: scheme.primary),
                          const SizedBox(width: 8),
                          Text(
                            tarih,
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                      const Gap(14),
                      Text(
                        shortText,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                        textAlign: TextAlign.justify,
                      ),
                      const Gap(12),
                      if (giftItems.isNotEmpty) ...[
                        Row(
                          children: [
                            Icon(Icons.card_giftcard_rounded, color: scheme.primary, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              'advice.gifts.title'.tr,
                              style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                        const Gap(10),
                        ...giftItems.map(
                          (item) => Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  margin: const EdgeInsets.only(top: 6),
                                  width: 6,
                                  height: 6,
                                  decoration: BoxDecoration(
                                    color: scheme.primary,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    item,
                                    style: TextStyle(
                                      color: Colors.grey.shade800,
                                      height: 1.4,
                                      fontSize: 15,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const Gap(16),
                      ],
                      if (surpriseItems.isNotEmpty) ...[
                        Row(
                          children: [
                            Icon(Icons.auto_awesome_rounded, color: scheme.primary, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              'advice.surprises.title'.tr,
                              style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                        const Gap(10),
                        ...surpriseItems.map(
                          (item) => Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  margin: const EdgeInsets.only(top: 6),
                                  width: 6,
                                  height: 6,
                                  decoration: BoxDecoration(
                                    color: scheme.primary,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    item,
                                    style: TextStyle(
                                      color: Colors.grey.shade800,
                                      height: 1.4,
                                      fontSize: 15,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const Gap(16),
                      ],
                      Text(
                        'advice.info'.tr,
                        style: TextStyle(
                          color: Colors.grey.shade700,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
