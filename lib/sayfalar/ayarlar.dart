import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../tercumeler/tercumeler.dart';

class Ayarlar extends StatelessWidget {
  const Ayarlar({super.key});

  @override
  Widget build(BuildContext context) {
    final current = Get.locale ?? Get.deviceLocale ?? const Locale('tr');
    return Scaffold(
      appBar: AppBar(
        title: Text('settings.title'.tr),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'settings.selectLanguage'.tr,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 12),
          ...Tercumeler.diller.entries.map(
            (entry) {
              final locale = entry.value;
              final isSelected = locale.languageCode == current.languageCode;
              return Card(
                child: ListTile(
                  title: Text(entry.key),
                  subtitle: Text(locale.toLanguageTag()),
                  trailing: isSelected ? Text('settings.current'.tr) : const SizedBox(),
                  onTap: () {
                    Get.find<DilSecimiController>().dilDegistir(locale.toString());
                  },
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
