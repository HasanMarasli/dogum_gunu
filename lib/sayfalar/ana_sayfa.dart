import 'package:dogum_gunu/models/dogum_gunu.dart';
import 'package:dogum_gunu/veriTabani/dogum_gunu_veri_tabani.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:dogum_gunu/sayfalar/dogum_gunu_ekle.dart';
import 'package:dogum_gunu/sayfalar/tavsiye.dart';
import 'package:dogum_gunu/sayfalar/ayarlar.dart';
import 'package:dogum_gunu/tercumeler/tercumeler.dart';
import 'package:dogum_gunu/tercumeler/tr.dart';
import 'package:dogum_gunu/tema/tema_yoneticisi.dart';

class AnaSayfa extends StatefulWidget {
  const AnaSayfa({super.key});

  @override
  State<AnaSayfa> createState() => _AnaSayfaState();
}

class _AnaSayfaState extends State<AnaSayfa> {
  bool isLoading = true;
  DogumGunuVeriYonetim dogumGunuVeriYonetim = Get.find<DogumGunuVeriYonetim>();

  @override
  void initState() {
    super.initState();
    _verileriCek();
  }

  Future<void> _verileriCek() async {
    setState(() {
      isLoading = true;
    });

    dogumGunuVeriYonetim.dogumGunuListe.value = await DogumGunuVeriTabani.tumVerileriGetir();

    setState(() {
      isLoading = false;
    });
  }

  // Alarm seçeneklerini gösteren fonksiyon

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final tema = Get.find<TemaYoneticisi>();
    const arkaPlan = Color(0xFFF6F7FB);
    final baslikRenk = const Color(0xFF121212);
    final vurgu = scheme.primary;

    return Scaffold(
      backgroundColor: arkaPlan,
      body: SafeArea(
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                tema.gradientStart,
                tema.gradientEnd,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              stops: const [0, 0.35],
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
                child: Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'home.title'.tr,
                          style: const TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          'home.subtitle'.tr,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white.withOpacity(0.85),
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    IconButton.filled(
                      onPressed: _verileriCek,
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.white.withOpacity(0.2),
                        foregroundColor: Colors.white,
                      ),
                      icon: const Icon(Icons.refresh_rounded),
                    ),
                    const SizedBox(width: 8),
                    IconButton.filled(
                      onPressed: () => Get.to(() => const Ayarlar()),
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.white.withOpacity(0.2),
                        foregroundColor: Colors.white,
                      ),
                      icon: const Icon(Icons.settings_rounded),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 6),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    _istatistikKart(
                      baslik: 'home.stats.total'.tr,
                      deger: dogumGunuVeriYonetim.dogumGunuListe.length.toString(),
                      renk: Colors.white,
                      altYazi: 'home.stats.total.suffix'.tr,
                    ),
                    const SizedBox(width: 12),
                    _istatistikKart(
                      baslik: 'home.stats.upcoming'.tr,
                      deger: _yaklasanSayisi().toString(),
                      renk: Colors.white.withOpacity(0.9),
                      altYazi: 'home.stats.upcoming.suffix'.tr,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: RefreshIndicator(
                      onRefresh: _verileriCek,
                      child: isLoading
                          ? const Center(child: CircularProgressIndicator())
                          : Obx(
                              () {
                                if (dogumGunuVeriYonetim.dogumGunuListe.isEmpty) {
                                  return _bosDurum();
                                }

                                final liste = [...dogumGunuVeriYonetim.dogumGunuListe];
                                liste.sort((a, b) => _kalanGun(a).compareTo(_kalanGun(b)));

                                return ListView.separated(
                                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                                  itemCount: liste.length,
                                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                                  itemBuilder: (context, index) {
                                    final dogum = liste[index];
                                    return _dogumKart(dogum, vurgu, baslikRenk);
                                  },
                                );
                              },
                            ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Get.to(() => const DogumGunuEkle()),
        backgroundColor: vurgu,
        foregroundColor: Colors.white,
        label: Text('home.button.newPerson'.tr),
        icon: const Icon(Icons.add_rounded),
      ),
    );
  }

  Widget _istatistikKart({
    required String baslik,
    required String deger,
    required Color renk,
    required String altYazi,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: renk.withOpacity(0.2),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: renk.withOpacity(0.4)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              baslik,
              style: TextStyle(color: renk.withOpacity(0.8)),
            ),
            const SizedBox(height: 4),
            Text(
              deger,
              style: TextStyle(
                color: renk,
                fontWeight: FontWeight.bold,
                fontSize: 22,
              ),
            ),
            Text(
              altYazi,
              style: TextStyle(color: renk.withOpacity(0.7), fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _bosDurum() {
    final scheme = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: scheme.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.celebration_rounded, size: 56, color: scheme.primary),
            ),
            const SizedBox(height: 20),
            Text(
              'home.empty.title'.tr,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Text(
              'home.empty.desc'.tr,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade600, height: 1.5),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () => Get.to(() => const DogumGunuEkle()),
              style: FilledButton.styleFrom(
                backgroundColor: scheme.primary,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              icon: const Icon(Icons.add_rounded),
              label: Text('home.button.newPerson'.tr, style: const TextStyle(fontWeight: FontWeight.w600)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _dogumKart(DogumGunu dogum, Color vurgu, Color metinRenk) {
    final tema = Get.find<TemaYoneticisi>();
    final kalanGun = _kalanGun(dogum);
    final yas = DateTime.now().year - dogum.dogumTarihi.year;
    final signId = DogumGunu.burcIdGetir(dogum.dogumTarihi);
    final localeCode = Get.locale?.languageCode ?? 'tr';
    final translations =
        Tercumeler().keys[localeCode] ?? tr; // fallback to tr for safety
    final burc = tZodiac(signId, 'name', translations);

    return GestureDetector(
      onTap: () => Get.to(() => Tavsiye(dogumGunu: dogum)),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
          border: Border.all(color: Colors.grey.shade200),
        ),
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Hero(
              tag: dogum.id,
              child: Container(
                height: 60,
                width: 60,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      tema.gradientStart,
                      tema.gradientEnd,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(14),
                ),
                padding: const EdgeInsets.all(10),
                child: SvgPicture.asset(
                  DogumGunu.burcIconGetir(dogum.dogumTarihi),
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    dogum.isim,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: metinRenk,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(Icons.cake_rounded, size: 16, color: Colors.grey.shade600),
                      const SizedBox(width: 6),
                      Text(
                        DogumGunu.tarihYazdir(dogum.dogumTarihi),
                        style: TextStyle(color: Colors.grey.shade700),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: [
                      _etiket('home.age'.trParams({'age': yas.toString()})),
                      _etiket(burc),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: kalanGun == 0 ? Colors.green.shade50 : vurgu.withOpacity(0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    kalanGun == 0
                        ? 'home.countdown.today'.tr
                        : 'home.countdown.days'.trParams({'days': kalanGun.toString()}),
                    style: TextStyle(
                      color: kalanGun == 0 ? Colors.green.shade700 : vurgu,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    'home.countdown.left'.tr,
                    style: TextStyle(
                      color: kalanGun == 0 ? Colors.green.shade700 : Colors.grey.shade600,
                      fontSize: 12,
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

  Widget _etiket(String yazi) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: scheme.primary.withOpacity(0.08),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        yazi,
        style: TextStyle(
          color: scheme.primary,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      ),
    );
  }

  int _kalanGun(DogumGunu dogum) {
    final simdi = DateTime.now();
    final bugun = DateTime(simdi.year, simdi.month, simdi.day);
    var sonrakiDogum = DateTime(bugun.year, dogum.dogumTarihi.month, dogum.dogumTarihi.day);
    if (sonrakiDogum.isBefore(bugun)) {
      sonrakiDogum = DateTime(bugun.year + 1, dogum.dogumTarihi.month, dogum.dogumTarihi.day);
    }
    return sonrakiDogum.difference(bugun).inDays;
  }

  int _yaklasanSayisi() {
    return dogumGunuVeriYonetim.dogumGunuListe.where((e) => _kalanGun(e) <= 7).length;
  }
}
