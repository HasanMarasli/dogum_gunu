import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class BildirimAyarlarYoneticisi extends GetxController {
  BildirimAyarlarYoneticisi(this._box);

  final GetStorage _box;

  static const String _key = 'notification_days';
  static const List<int> tumSecenekler = [7, 2, 1, 0];

  final RxSet<int> seciliGunler = <int>{}.obs;

  @override
  void onInit() {
    super.onInit();
    final kayitli = _box.read<List<dynamic>>(_key);
    final gecerliGunler = kayitli
            ?.whereType<int>()
            .where((gun) => tumSecenekler.contains(gun))
            .toSet() ??
        <int>{};
    seciliGunler
      ..clear()
      ..addAll(gecerliGunler.isNotEmpty ? gecerliGunler : tumSecenekler);
  }

  List<int> aktifGunler() {
    return tumSecenekler.where((gun) => seciliGunler.contains(gun)).toList();
  }

  void toggleGun(int gun) {
    if (!tumSecenekler.contains(gun)) return;
    if (seciliGunler.contains(gun)) {
      seciliGunler.remove(gun);
    } else {
      seciliGunler.add(gun);
    }
    seciliGunler.refresh();
    _box.write(_key, aktifGunler());
  }
}
