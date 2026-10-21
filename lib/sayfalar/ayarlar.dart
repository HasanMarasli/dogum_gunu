import 'package:dogum_gunu/models/bildirim_ayarlar_yoneticisi.dart';
import 'package:dogum_gunu/veriTabani/dogum_gunu_veri_tabani.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../tercumeler/tercumeler.dart';
import '../tema/tema_yoneticisi.dart';

class Ayarlar extends StatelessWidget {
  const Ayarlar({super.key});

  @override
  Widget build(BuildContext context) {
    final current = Get.locale ?? Get.deviceLocale ?? const Locale('tr');
    final tema = Get.find<TemaYoneticisi>();
    final bildirimAyar = Get.find<BildirimAyarlarYoneticisi>();
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 120,
            floating: false,
            pinned: true,
            elevation: 0,
            backgroundColor: tema.gradientStart,
            foregroundColor: Colors.white,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                'settings.title'.tr,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [tema.gradientStart, tema.gradientEnd],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Dil Seçimi Bölümü
                  _buildSectionHeader(
                    context,
                    icon: Icons.language_rounded,
                    title: 'settings.selectLanguage'.tr,
                    scheme: scheme,
                  ),
                  const SizedBox(height: 12),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: Tercumeler.diller.entries.map((entry) {
                        final locale = entry.value;
                        final isSelected =
                            locale.languageCode == current.languageCode;
                        final isFirst =
                            entry.key == Tercumeler.diller.keys.first;
                        final isLast = entry.key == Tercumeler.diller.keys.last;

                        return Column(
                          children: [
                            ListTile(
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 4),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.vertical(
                                  top: isFirst
                                      ? const Radius.circular(16)
                                      : Radius.zero,
                                  bottom: isLast
                                      ? const Radius.circular(16)
                                      : Radius.zero,
                                ),
                              ),
                              leading: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: scheme.primary.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  locale.languageCode.toUpperCase(),
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: scheme.primary,
                                  ),
                                ),
                              ),
                              title: Text(
                                entry.key,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w600),
                              ),
                              trailing: isSelected
                                  ? Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: Colors.green.shade50,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(Icons.check_circle_rounded,
                                              size: 16,
                                              color: Colors.green.shade600),
                                          const SizedBox(width: 4),
                                          Text(
                                            'settings.current'.tr,
                                            style: TextStyle(
                                              color: Colors.green.shade600,
                                              fontWeight: FontWeight.w600,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ),
                                    )
                                  : Icon(Icons.arrow_forward_ios_rounded,
                                      size: 16, color: Colors.grey.shade400),
                              onTap: () {
                                Get.find<DilSecimiController>()
                                    .dilDegistir(locale.toString());
                              },
                            ),
                            if (!isLast)
                              Divider(
                                  height: 1,
                                  indent: 16,
                                  endIndent: 16,
                                  color: Colors.grey.shade200),
                          ],
                        );
                      }).toList(),
                    ),
                  ),

                  const SizedBox(height: 28),

                  // Tema Seçimi Bölümü
                  _buildSectionHeader(
                    context,
                    icon: Icons.palette_rounded,
                    title: 'settings.selectTheme'.tr,
                    scheme: scheme,
                  ),
                  const SizedBox(height: 12),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: tema.palettes.entries.map((entry) {
                        final key = entry.key;
                        final color = entry.value;
                        final isSelected = tema.currentKey == key;
                        final keys = tema.palettes.keys.toList();
                        final isFirst = key == keys.first;
                        final isLast = key == keys.last;

                        return Column(
                          children: [
                            ListTile(
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 4),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.vertical(
                                  top: isFirst
                                      ? const Radius.circular(16)
                                      : Radius.zero,
                                  bottom: isLast
                                      ? const Radius.circular(16)
                                      : Radius.zero,
                                ),
                              ),
                              leading: Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      color,
                                      HSLColor.fromColor(color)
                                          .withLightness(0.65)
                                          .toColor()
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: color.withOpacity(0.3),
                                      blurRadius: 6,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                              ),
                              title: Text(
                                'theme.$key'.tr,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w600),
                              ),
                              trailing: isSelected
                                  ? Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: Colors.green.shade50,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(Icons.check_circle_rounded,
                                              size: 16,
                                              color: Colors.green.shade600),
                                          const SizedBox(width: 4),
                                          Text(
                                            'settings.current'.tr,
                                            style: TextStyle(
                                              color: Colors.green.shade600,
                                              fontWeight: FontWeight.w600,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ),
                                    )
                                  : Icon(Icons.arrow_forward_ios_rounded,
                                      size: 16, color: Colors.grey.shade400),
                              onTap: () => tema.setTheme(key),
                            ),
                            if (!isLast)
                              Divider(
                                  height: 1,
                                  indent: 16,
                                  endIndent: 16,
                                  color: Colors.grey.shade200),
                          ],
                        );
                      }).toList(),
                    ),
                  ),

                  const SizedBox(height: 32),

                  _buildSectionHeader(
                    context,
                    icon: Icons.notifications_active_rounded,
                    title: 'settings.notifications.title'.tr,
                    scheme: scheme,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'settings.notifications.subtitle'.tr,
                    style: TextStyle(
                      color: Colors.grey.shade700,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Obx(
                    () {
                      final secili = bildirimAyar.seciliGunler;
                      return Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.04),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          children: BildirimAyarlarYoneticisi.tumSecenekler
                              .map((gun) {
                            final isFirst = gun ==
                                BildirimAyarlarYoneticisi.tumSecenekler.first;
                            final isLast = gun ==
                                BildirimAyarlarYoneticisi.tumSecenekler.last;
                            final isSelected = secili.contains(gun);

                            return Column(
                              children: [
                                ListTile(
                                  contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 4),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.vertical(
                                      top: isFirst
                                          ? const Radius.circular(16)
                                          : Radius.zero,
                                      bottom: isLast
                                          ? const Radius.circular(16)
                                          : Radius.zero,
                                    ),
                                  ),
                                  leading: Icon(
                                    Icons.schedule_rounded,
                                    color: scheme.primary,
                                  ),
                                  title: Text(
                                    _gunMetni(gun),
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w600),
                                  ),
                                  trailing: Checkbox(
                                    value: isSelected,
                                    onChanged: (_) =>
                                        _gunSecimiDegistir(bildirimAyar, gun),
                                    activeColor: scheme.primary,
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(6)),
                                  ),
                                  onTap: () =>
                                      _gunSecimiDegistir(bildirimAyar, gun),
                                ),
                                if (!isLast)
                                  Divider(
                                    height: 1,
                                    indent: 16,
                                    endIndent: 16,
                                    color: Colors.grey.shade200,
                                  ),
                              ],
                            );
                          }).toList(),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(
    BuildContext context, {
    required IconData icon,
    required String title,
    required ColorScheme scheme,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: scheme.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: scheme.primary, size: 20),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  String _gunMetni(int gun) {
    switch (gun) {
      case 7:
        return 'settings.notifications.option.7'.tr;
      case 2:
        return 'settings.notifications.option.2'.tr;
      case 1:
        return 'settings.notifications.option.1'.tr;
      case 0:
        return 'settings.notifications.option.0'.tr;
      default:
        return 'settings.notifications.option.dynamic'
            .trParams({'days': gun.toString()});
    }
  }

  Future<void> _gunSecimiDegistir(
      BildirimAyarlarYoneticisi controller, int gun) async {
    controller.toggleGun(gun);
    await DogumGunuVeriTabani.tumBildirimleriYenidenPlanla();
  }
}
