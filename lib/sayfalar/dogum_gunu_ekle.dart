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
  Cinsiyet? _cinsiyet;
  Yakinlik? _yakinlik;
  bool _tarihAcik = false;
  bool _kaydediliyor = false;
  bool _adHatasi = false;
  bool _tarihHatasi = false;
  bool _cinsiyetHatasi = false;

  final DogumGunuVeriYonetim dogumGunuYonetim = Get.find();

  bool get _duzenleme => widget.duzenlenecek != null;

  /// Kaydedilmemiş bir şey varsa çıkarken onay istenir.
  bool get _degisti {
    final d = widget.duzenlenecek;
    final isim = kisiAd.text.trim();
    if (d == null) {
      return isim.isNotEmpty ||
          secilenTarih != null ||
          _cinsiyet != null ||
          _yakinlik != null;
    }
    return isim != d.isim ||
        secilenTarih != d.dogumTarihi ||
        _cinsiyet != d.cinsiyet ||
        _yakinlik != d.yakinlik;
  }

  @override
  void initState() {
    super.initState();
    final d = widget.duzenlenecek;
    if (d != null) {
      kisiAd.text = d.isim;
      secilenTarih = d.dogumTarihi;
      _cinsiyet = d.cinsiyet;
      _yakinlik = d.yakinlik;
    }
    _adOdak.addListener(() => setState(() {}));
    kisiAd.addListener(() {
      setState(() {
        if (kisiAd.text.trim().isNotEmpty) _adHatasi = false;
      });
    });
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
    // Alt sayfa kapanınca odak isim alanına dönüp klavyeyi açmasın.
    FocusManager.instance.primaryFocus?.unfocus();
    setState(() {
      _tarihAcik = false;
      if (secilen != null) {
        secilenTarih = secilen;
        _tarihHatasi = false;
      }
    });
  }

  Future<void> _kaydet() async {
    if (_kaydediliyor) return;
    final isim = kisiAd.text.trim().replaceAll(RegExp(r'\s+'), ' ');
    setState(() {
      _adHatasi = isim.isEmpty;
      _tarihHatasi = secilenTarih == null;
      _cinsiyetHatasi = _cinsiyet == null;
    });
    if (_adHatasi) _adOdak.requestFocus();
    if (_adHatasi || _tarihHatasi || _cinsiyetHatasi) return;

    setState(() => _kaydediliyor = true);
    try {
      if (_duzenleme) {
        final guncel = DogumGunu(
          id: widget.duzenlenecek!.id,
          isim: isim,
          dogumTarihi: secilenTarih!,
          cinsiyet: _cinsiyet,
          yakinlik: _yakinlik,
        );
        await DogumGunuVeriTabani.veriGuncelle(guncel);
        final liste = dogumGunuYonetim.dogumGunuListe;
        final i = liste.indexWhere((e) => e.id == guncel.id);
        if (i >= 0) liste[i] = guncel;
        if (mounted) Navigator.of(context).pop(guncel);
        OzelSnackbar.basari(
          baslik: 'edit.success.title'.tr,
          mesaj: 'edit.success.message'.tr,
        );
      } else {
        final yeniDogum = DogumGunu(
          id: const Uuid().v4(),
          isim: isim,
          dogumTarihi: secilenTarih!,
          cinsiyet: _cinsiyet,
          yakinlik: _yakinlik,
        );
        await DogumGunuVeriTabani.veriEkle(yeniDogum);
        dogumGunuYonetim.dogumGunuListe.add(yeniDogum);
        if (mounted) Navigator.of(context).pop(yeniDogum);
        OzelSnackbar.basari(
          baslik: 'add.success.title'.tr,
          mesaj: 'add.success.message'.tr,
        );
      }
    } catch (_) {
      OzelSnackbar.hata(
        baslik: 'add.error.save.title'.tr,
        mesaj: 'add.error.save.msg'.tr,
      );
    } finally {
      if (mounted) setState(() => _kaydediliyor = false);
    }
  }

  Future<void> _cikisOnayi() async {
    final cik = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('add.discard.title'.tr),
        content: Text('add.discard.msg'.tr),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('add.discard.stay'.tr),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text('add.discard.leave'.tr),
          ),
        ],
      ),
    );
    if (cik == true && mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final r = context.renk;
    final scheme = Theme.of(context).colorScheme;
    final metin = Theme.of(context).textTheme;
    final klavyeAcik = MediaQuery.of(context).viewInsets.bottom > 0;
    final odakli = _adOdak.hasFocus;

    return PopScope(
      canPop: !_degisti,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _cikisOnayi();
      },
      child: Scaffold(
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
                          errorText: _adHatasi ? 'add.error.name'.tr : null,
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 14),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'picker.title'.tr,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                        color: _tarihAcik ? scheme.primary : r.tx2,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Semantics(
                      button: true,
                      label: 'picker.title'.tr,
                      child: Material(
                        color: r.s1,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                          side: BorderSide(
                            color: _tarihHatasi
                                ? r.err
                                : _tarihAcik
                                    ? scheme.primary
                                    : r.bd2,
                            width: 1.5,
                          ),
                        ),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(14),
                          onTap: () => _tarihSec(context),
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(minHeight: 52),
                            child: Padding(
                              padding: const EdgeInsets.only(
                                  left: 14, right: 10, top: 6, bottom: 6),
                              child: Row(
                                children: [
                                  Icon(Icons.calendar_month_rounded,
                                      size: 22, color: scheme.primary),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      secilenTarih == null
                                          ? 'add.field.date.placeholder'.tr
                                          : DogumGunu.tarihYazdir(
                                              secilenTarih!),
                                      style: metin.bodyLarge?.copyWith(
                                        color:
                                            secilenTarih == null ? r.tx3 : r.tx,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    constraints:
                                        const BoxConstraints(minHeight: 32),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 14, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: scheme.primaryContainer,
                                      borderRadius: BorderRadius.circular(999),
                                    ),
                                    child: Center(
                                      widthFactor: 1,
                                      heightFactor: 1,
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
                    if (_tarihHatasi)
                      Padding(
                        padding: const EdgeInsets.only(left: 16, top: 6),
                        child: Text(
                          'add.error.date'.tr,
                          style: TextStyle(fontSize: 12, color: r.err),
                        ),
                      ),
                    const SizedBox(height: 16),
                    Text(
                      'add.field.gender.label'.tr,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                        color: r.tx2,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        for (final c in Cinsiyet.values) ...[
                          if (c != Cinsiyet.values.first)
                            const SizedBox(width: 8),
                          Expanded(
                            child: _SecimKutusu(
                              etiket: 'gender.${c.name}'.tr,
                              secili: _cinsiyet == c,
                              hatali: _cinsiyetHatasi,
                              onTap: () => setState(() {
                                _cinsiyet = c;
                                _cinsiyetHatasi = false;
                              }),
                            ),
                          ),
                        ],
                      ],
                    ),
                    if (_cinsiyetHatasi)
                      Padding(
                        padding: const EdgeInsets.only(left: 16, top: 6),
                        child: Text(
                          'add.error.gender'.tr,
                          style: TextStyle(fontSize: 12, color: r.err),
                        ),
                      ),
                    const SizedBox(height: 16),
                    Text(
                      'add.field.relation.label'.tr,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                        color: r.tx2,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (final y in Yakinlik.values)
                          _SecimKutusu(
                            etiket: 'relation.${y.name}'.tr,
                            secili: _yakinlik == y,
                            // İsteğe bağlı alan: seçili olana dokununca kalkar.
                            onTap: () => setState(() {
                              _yakinlik = _yakinlik == y ? null : y;
                            }),
                          ),
                      ],
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
                  icon: const Icon(Icons.check_rounded, size: 20),
                  label: Text(
                    _duzenleme ? 'edit.button.save'.tr : 'add.button.save'.tr,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SecimKutusu extends StatelessWidget {
  const _SecimKutusu({
    required this.etiket,
    required this.secili,
    required this.onTap,
    this.hatali = false,
  });

  final String etiket;
  final bool secili;
  final bool hatali;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final r = context.renk;
    final scheme = Theme.of(context).colorScheme;
    return Semantics(
      button: true,
      selected: secili,
      child: Material(
        color: secili ? scheme.primaryContainer : r.s1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(
            color: hatali
                ? r.err
                : secili
                    ? scheme.primary
                    : r.bd2,
            width: 1.5,
          ),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () {
            FocusManager.instance.primaryFocus?.unfocus();
            onTap();
          },
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 48),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Flexible(
                    child: Text(
                      etiket,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: secili ? scheme.onPrimaryContainer : r.tx,
                      ),
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
