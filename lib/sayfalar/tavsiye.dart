import 'package:dogum_gunu/models/dogum_gunu.dart';
import 'package:dogum_gunu/tercumeler/tr.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';

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
    final signName = tZodiac(signId, 'name', tr);
    final shortText = tZodiac(signId, 'short', tr);
    final giftItems = tZodiacList(signId, 'gifts', tr);
    final surpriseItems = tZodiacList(signId, 'surprises', tr);

    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text("${widget.dogumGunu.isim} için"),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF6C63FF), Color(0xFF928DFF)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            stops: [0, 0.3],
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
                      gradient: const LinearGradient(
                        colors: [Color(0xFF6C63FF), Color(0xFF928DFF)],
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
                        DogumGunu.burcTarihAraligiGetir(widget.dogumGunu.dogumTarihi),
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade700,
                        ),
                      ),
                      const Gap(16),
                      Row(
                        children: [
                          const Icon(Icons.cake_rounded, color: Color(0xFF6C63FF)),
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
                        const Text(
                          'Hediye Önerileri',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const Gap(8),
                        ...giftItems.map(
                          (item) => Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('• '),
                              Expanded(
                                child: Text(
                                  item,
                                  style: TextStyle(
                                    color: Colors.grey.shade800,
                                    height: 1.4,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Gap(12),
                      ],
                      if (surpriseItems.isNotEmpty) ...[
                        const Text(
                          'Sürpriz Önerileri',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const Gap(8),
                        ...surpriseItems.map(
                          (item) => Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('• '),
                              Expanded(
                                child: Text(
                                  item,
                                  style: TextStyle(
                                    color: Colors.grey.shade800,
                                    height: 1.4,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Gap(12),
                      ],
                      Text(
                        "Doğum günü yaklaştığında otomatik hatırlatma alacaksın. Bu kartı kişiye özel notlar ve hediye fikirleri için kullanabilirsin.",
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
