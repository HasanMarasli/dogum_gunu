import 'package:dogum_gunu/models/dogum_gunu.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dogum_gunu/veriTabani/dogum_gunu_veri_tabani.dart';
import 'package:uuid/uuid.dart'; // Benzersiz ID oluşturmak için

class DogumGunuEkle extends StatefulWidget {
  const DogumGunuEkle({super.key});

  @override
  State<DogumGunuEkle> createState() => _KisiEkleState();
}

class _KisiEkleState extends State<DogumGunuEkle> {
  final TextEditingController kisiAd = TextEditingController();
  DateTime? secilenTarih;
  final Color _vurgu = const Color(0xFF6C63FF);

  // Veri yönetim nesnesi
  final DogumGunuVeriYonetim dogumGunuYonetim = Get.find();

  Future<void> _tarihSec(BuildContext context) async {
    final DateTime? secilen = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: ColorScheme.fromSeed(
              seedColor: _vurgu,
              brightness: Brightness.light,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(foregroundColor: _vurgu),
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
      Get.snackbar(
        "Hata",
        "Lütfen isim ve tarih seçin!",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
      return;
    }

    // Benzersiz ID oluştur
    final String id = const Uuid().v4();

    // Yeni doğum günü verisi oluştur
    final DogumGunu yeniDogum = DogumGunu(
      id: id,
      isim: kisiAd.text,
      dogumTarihi: secilenTarih!,
    );

    // Veritabanına ekle
    await DogumGunuVeriTabani.veriEkle(yeniDogum);

    // RxList'e yeni veriyi ekle
    dogumGunuYonetim.dogumGunuListe.add(yeniDogum);
    Get.back();

    // Başarı mesajı
    Get.snackbar(
      "Başarılı",
      "Doğum günü başarıyla eklendi.",
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green,
      colorText: Colors.white,
    );

    // Formu sıfırla
    setState(() {
      kisiAd.clear();
      secilenTarih = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text("Yeni Kişi Ekle"),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF6C63FF), Color(0xFF928DFF)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            stops: [0, 0.25],
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
                  const Text(
                    "Sevdiklerini listene ekle,\nbildirimleri otomatik alsın.",
                    style: TextStyle(
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
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 14,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Kişi Bilgileri",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 14),
                        TextField(
                          controller: kisiAd,
                          decoration: InputDecoration(
                            labelText: "Kişi adı",
                            hintText: "Örn: Ayşe Yılmaz",
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
                                Icon(Icons.date_range_rounded, color: Colors.grey.shade700),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    secilenTarih == null
                                        ? "Doğum tarihini seçin"
                                        : "${secilenTarih!.day} ${_ayAdi(secilenTarih!.month)} ${secilenTarih!.year}",
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
                                    color: const Color(0xFFEEF0FF),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    secilenTarih == null ? "Seç" : "Değiştir",
                                    style: const TextStyle(
                                      color: Color(0xFF5B54E3),
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
                              backgroundColor: _vurgu,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                            ),
                            icon: const Icon(Icons.notifications_active_rounded),
                            label: const Text(
                              "Kaydet ve Hatırlat",
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
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

  // Ay numarasını Türkçe isimle döndüren yardımcı metot
  String _ayAdi(int ay) {
    const List<String> aylar = [
      "Ocak",
      "Şubat",
      "Mart",
      "Nisan",
      "Mayıs",
      "Haziran",
      "Temmuz",
      "Ağustos",
      "Eylül",
      "Ekim",
      "Kasım",
      "Aralık",
    ];
    return aylar[ay - 1];
  }
}
