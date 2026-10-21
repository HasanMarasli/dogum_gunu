import 'package:dogum_gunu/models/dogum_gunu.dart';
import 'package:dogum_gunu/widgets/ozel_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dogum_gunu/veriTabani/dogum_gunu_veri_tabani.dart';
import 'package:uuid/uuid.dart';

import '../tema/renkler.dart';
import '../widgets/tarih_secici.dart';

/// Yeni kişi ekleme ekranı. [duzenlenecek] verilirse aynı ekran
/// "Kişiyi Düzenle" olarak açılır.
class DogumGunuEkle extends StatefulWidget {
  const DogumGunuEkle({super.key, this.duzenlenecek});

  final DogumGunu? duzenlenecek;

  @override
  State<DogumGunuEkle> createState() => _KisiEkleState();
}

class _KisiEkleState extends State<DogumGunuEkle> {
  final TextEditingController kisiAd = TextEditingController();
  final FocusNode _adOdak = FocusNode();
  DateTime? secilenTarih;
  bool _tarihAcik = false;
  bool _kaydediliyor = false;

  final DogumGunuVeriYonetim dogumGunuYonetim = Get.find();

  bool get _duzenleme => widget.duzenlenecek != null;

  @override
  void initState() {
    super.initState();
    final d = widget.duzenlenecek;
    if (d != null) {
      kisiAd.text = d.isim;
      secilenTarih = d.dogumTarihi;
    }
    _adOdak.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    kisiAd.dispose();
    _adOdak.dispose();
    super.dispose();
  }

  Future<void> _tarihSec(BuildContext context) async {
    FocusScope.of(context).unfocus();
    setState(() => _tarihAcik = true);
    final secilen = await dogumTarihiSec(context, baslangic: secilenTarih);
    if (!mounted) return;
    setState(() {
      _tarihAcik = false;
      if (secilen != null) secilenTarih = secilen;
    });
  }

  Future<void> _kaydet() async {
    if (_kaydediliyor) return;
    final isim = kisiAd.text.trim().replaceAll(RegExp(r'\s+'), ' ');
    if (isim.isEmpty || secilenTarih == null) {
      OzelSnackbar.hata(
        baslik: 'add.error.title'.tr,
        mesaj: 'add.error.missing'.tr,
      );
      return;
    }

    if (await DogumGunuVeriTabani.isimZatenVar(isim,
        haricId: widget.duzenlenecek?.id)) {
      OzelSnackbar.uyari(
        baslik: 'add.error.title'.tr,
        mesaj: 'add.error.duplicate'.tr,
      );
      return;
    }

    setState(() => _kaydediliyor = true);
    try {
      if (_duzenleme) {
        final guncel = DogumGunu(
          id: widget.duzenlenecek!.id,
          isim: isim,
          dogumTarihi: secilenTarih!,
        );
        await DogumGunuVeriTabani.veriGuncelle(guncel);
        final liste = dogumGunuYonetim.dogumGunuListe;
        final i = liste.indexWhere((e) => e.id == guncel.id);
        if (i >= 0) liste[i] = guncel;
        if (mounted) Navigator.of(context).pop(guncel);
        OzelSnackbar.basari(
          baslik: 'add.success.title'.tr,
          mesaj: 'edit.success.message'.tr,
        );
      } else {
        final yeniDogum = DogumGunu(
          id: const Uuid().v4(),
          isim: isim,
          dogumTarihi: secilenTarih!,
        );
        await DogumGunuVeriTabani.veriEkle(yeniDogum);
        dogumGunuYonetim.dogumGunuListe.add(yeniDogum);
        if (mounted) Navigator.of(context).pop(yeniDogum);
        OzelSnackbar.basari(
          baslik: 'add.success.title'.tr,
          mesaj: 'add.success.message'.tr,
        );
      }
    } finally {
      if (mounted) setState(() => _kaydediliyor = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final r = context.renk;
    final scheme = Theme.of(context).colorScheme;
    final metin = Theme.of(context).textTheme;
    final klavyeAcik = MediaQuery.of(context).viewInsets.bottom > 0;
    final odakli = _adOdak.hasFocus;

    return Scaffold(
      backgroundColor: r.bg,
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        backgroundColor: r.bg,
        titleSpacing: 0,
        leading: IconButton(
          tooltip: MaterialLocalizations.of(context).backButtonTooltip,
          onPressed: () => Navigator.of(context).maybePop(),
          icon: const Icon(Icons.arrow_back_rounded),
        ),
        title: Text(_duzenleme ? 'edit.title'.tr : 'add.title'.tr),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _duzenleme ? 'edit.hero'.tr : 'add.hero'.tr,
                    style: metin.bodyLarge?.copyWith(color: r.tx2),
                  ),
                  const SizedBox(height: 28),
                  Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: scheme.primaryContainer,
                          borderRadius: BorderRadius.circular(11),
                        ),
                        child: Icon(Icons.person_rounded,
                            size: 20, color: scheme.onPrimaryContainer),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'add.section.info'.tr,
                        style: metin.titleLarge?.copyWith(fontSize: 20),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'add.field.name.label'.tr,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                      color: odakli ? scheme.primary : r.tx2,
                    ),
                  ),
                  const SizedBox(height: 6),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: odakli
                          ? [
                              BoxShadow(
                                color: scheme.primary.withValues(alpha: 0.2),
                                spreadRadius: 3,
                              )
                            ]
                          : null,
                    ),
                    child: TextField(
                      controller: kisiAd,
                      focusNode: _adOdak,
                      textCapitalization: TextCapitalization.words,
                      textInputAction: TextInputAction.done,
                      maxLength: 60,
                      buildCounter: (_,
                              {required currentLength,
                              required isFocused,
                              maxLength}) =>
                          null,
                      cursorColor: scheme.primary,
                      style: metin.bodyLarge,
                      decoration: InputDecoration(
                        hintText: 'add.field.name.hint'.tr,
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 14),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Semantics(
                    button: true,
                    label: 'add.field.date.placeholder'.tr,
                    child: Material(
                      color: r.s1,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                        side: BorderSide(
                          color: _tarihAcik ? scheme.primary : r.bd2,
                          width: 1.5,
                        ),
                      ),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(14),
                        onTap: () => _tarihSec(context),
                        child: SizedBox(
                          height: 52,
                          child: Padding(
                            padding: const EdgeInsets.only(left: 14, right: 10),
                            child: Row(
                              children: [
                                Icon(Icons.calendar_month_rounded,
                                    size: 22, color: scheme.primary),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    secilenTarih == null
                                        ? 'add.field.date.placeholder'.tr
                                        : DogumGunu.tarihYazdir(secilenTarih!),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: metin.bodyLarge?.copyWith(
                                      color:
                                          secilenTarih == null ? r.tx3 : r.tx,
                                    ),
                                  ),
                                ),
                                Container(
                                  height: 32,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 14),
                                  decoration: BoxDecoration(
                                    color: scheme.primaryContainer,
                                    borderRadius: BorderRadius.circular(999),
                                  ),
                                  child: Center(
                                    widthFactor: 1,
                                    child: Text(
                                      secilenTarih == null
                                          ? 'add.field.date.select'.tr
                                          : 'add.field.date.change'.tr,
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 13,
                                        color: scheme.onPrimaryContainer,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.fromLTRB(
              20,
              12,
              20,
              klavyeAcik ? 12 : 20 + MediaQuery.of(context).padding.bottom,
            ),
            decoration: BoxDecoration(
              color: r.bg,
              border: Border(
                top: BorderSide(
                  color: klavyeAcik ? r.bd : Colors.transparent,
                ),
              ),
            ),
            child: SizedBox(
              width: double.infinity,
              height: 52,
              child: FilledButton.icon(
                onPressed: _kaydediliyor ? null : _kaydet,
                style: FilledButton.styleFrom(
                  textStyle: metin.labelLarge?.copyWith(fontSize: 16),
                ),
                icon: Icon(
                  _duzenleme
                      ? Icons.check_rounded
                      : Icons.notifications_active_rounded,
                  size: 20,
                ),
                label: Text(
                  _duzenleme ? 'edit.button.save'.tr : 'add.button.save'.tr,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
