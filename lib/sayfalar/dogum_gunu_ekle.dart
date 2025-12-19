import 'package:dogum_gunu/models/dogum_gunu.dart';
import 'package:dogum_gunu/tema/tema_yoneticisi.dart';
import 'package:dogum_gunu/widgets/ozel_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:dogum_gunu/veriTabani/dogum_gunu_veri_tabani.dart';
import 'package:uuid/uuid.dart';

class DogumGunuEkle extends StatefulWidget {
  const DogumGunuEkle({super.key});

  @override
  State<DogumGunuEkle> createState() => _KisiEkleState();
}

class _KisiEkleState extends State<DogumGunuEkle> {
  final TextEditingController kisiAd = TextEditingController();
  DateTime? secilenTarih;

  final DogumGunuVeriYonetim dogumGunuYonetim = Get.find();

  Future<void> _tarihSec(BuildContext context) async {
    final scheme = Theme.of(context).colorScheme;
    final DateTime? secilen = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: ColorScheme.fromSeed(
              seedColor: scheme.primary,
              brightness: Brightness.light,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(foregroundColor: scheme.primary),
            ),
          ),
          child: child!,
        );
      },
    );

    if (secilen != null) {
      setState(() {
        secilenTarih = secilen;
      });
    }
  }

  Future<void> _tarihEkle() async {
    if (kisiAd.text.isEmpty || secilenTarih == null) {
      OzelSnackbar.hata(
        baslik: 'add.error.title'.tr,
        mesaj: 'add.error.missing'.tr,
      );
      return;
    }

    final isim = kisiAd.text.trim();
    if (await DogumGunuVeriTabani.isimZatenVar(isim)) {
      OzelSnackbar.uyari(
        baslik: 'add.error.title'.tr,
        mesaj: 'add.error.duplicate'.tr,
      );
      return;
    }

    final String id = const Uuid().v4();

    final DogumGunu yeniDogum = DogumGunu(
      id: id,
      isim: isim,
      dogumTarihi: secilenTarih!,
    );

    await DogumGunuVeriTabani.veriEkle(yeniDogum);

    dogumGunuYonetim.dogumGunuListe.add(yeniDogum);
    Get.back();

    OzelSnackbar.basari(
      baslik: 'add.success.title'.tr,
      mesaj: 'add.success.message'.tr,
    );

    setState(() {
      kisiAd.clear();
      secilenTarih = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final tema = Get.find<TemaYoneticisi>();
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      appBar: AppBar(
        elevation: 0,
        foregroundColor: Colors.white,
        backgroundColor: Colors.transparent,
        title: Text(
          'add.title'.tr,
          style: const TextStyle(fontWeight: FontWeight.w700, color: Colors.white),
        ),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [tema.gradientStart, tema.gradientEnd],
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
            colors: [tema.gradientStart, tema.gradientEnd],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            stops: const [0, 1],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 6),
                  Text(
                    'add.hero'.tr,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 18),
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.06),
                          blurRadius: 14,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: scheme.primary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(Icons.person_add_rounded, color: scheme.primary, size: 20),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'add.section.info'.tr,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        TextField(
                          controller: kisiAd,
                          decoration: InputDecoration(
                            labelText: 'add.field.name.label'.tr,
                            hintText: 'add.field.name.hint'.tr,
                            filled: true,
                            fillColor: const Color(0xFFF6F7FB),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),
                        GestureDetector(
                          onTap: () => _tarihSec(context),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF6F7FB),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: const Color(0xFFE3E3EE)),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.date_range_rounded, color: scheme.primary),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    secilenTarih == null
                                        ? 'add.field.date.placeholder'.tr
                                        : DateFormat('d MMMM y', Get.locale?.toLanguageTag() ?? 'tr').format(secilenTarih!),
                                    style: TextStyle(
                                      fontSize: 16.0,
                                      color: secilenTarih == null ? Colors.grey.shade600 : Colors.black,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: scheme.primary.withOpacity(0.12),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    secilenTarih == null ? 'add.field.date.select'.tr : 'add.field.date.change'.tr,
                                    style: TextStyle(
                                      color: scheme.primary,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton.icon(
                            onPressed: _tarihEkle,
                            style: FilledButton.styleFrom(
                              backgroundColor: scheme.primary,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                            ),
                            icon: const Icon(Icons.notifications_active_rounded),
                            label: Text(
                              'add.button.save'.tr,
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
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
        ),
      ),
    );
  }
}
