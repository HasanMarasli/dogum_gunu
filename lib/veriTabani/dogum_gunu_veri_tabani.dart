import 'package:dogum_gunu/models/bildirim_yoneticisi.dart';
import 'package:dogum_gunu/models/dogum_gunu.dart';
import 'package:intl/intl.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DogumGunuVeriTabani {
  static final DogumGunuVeriTabani _nesne = DogumGunuVeriTabani._ozelYapici();
  static Database? _veritabani;

  factory DogumGunuVeriTabani() => _nesne;

  DogumGunuVeriTabani._ozelYapici();

  static Future<Database> get veritabani async {
    if (_veritabani != null) return _veritabani!;
    _veritabani = await _veritabaniOlustur();
    return _veritabani!;
  }

  static Future<Database> _veritabaniOlustur() async {
    String yol = join(await getDatabasesPath(), 'dogum_gunu.db');
    return await openDatabase(
      yol,
      version: 1,
      onCreate: _ilkTabloOlustur,
    );
  }

  static Future<void> _ilkTabloOlustur(Database db, int version) async {
    await db.execute('''
      CREATE TABLE dogumlar (
        id TEXT PRIMARY KEY,
        isim TEXT NOT NULL,
        dogumTarihi TEXT NOT NULL
      )
    ''');
  }

  // Veri ekleme
  static Future<int> veriEkle(DogumGunu dogum) async {
    final db = await veritabani;

    // Tarih formatını uygun şekilde kaydediyoruz
    String formattedDate = DateFormat('yyyy-MM-dd').format(dogum.dogumTarihi);

    // Veritabanına doğum günü ekleniyor
    int sonuc = await db.insert(
      'dogumlar',
      {
        'id': dogum.id,
        'isim': dogum.isim,
        'dogumTarihi': formattedDate,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    // Bildirim ekleniyor
    BildirimYoneticisi bildirimYoneticisi = BildirimYoneticisi();
    await bildirimYoneticisi.bildirimZamanlamasiYap(dogum);

    return sonuc;
  }

  // Veri listeleme
  static Future<List<DogumGunu>> tumVerileriGetir() async {
    final db = await veritabani;
    final List<Map<String, dynamic>> sonuc = await db.query('dogumlar');
    return List.generate(sonuc.length, (i) {
      String tarihStr = sonuc[i]['dogumTarihi'];
      DateTime dogumTarihi = DateFormat('yyyy-MM-dd').parse(tarihStr);
      return DogumGunu(
        id: sonuc[i]['id'],
        isim: sonuc[i]['isim'],
        dogumTarihi: dogumTarihi,
      );
    });
  }

  // Veri güncelleme
  static Future<int> veriGuncelle(DogumGunu dogum) async {
    final db = await veritabani;

    // İlk olarak eski bildirim iptal edilir
    BildirimYoneticisi bildirimYoneticisi = BildirimYoneticisi();
    await bildirimYoneticisi.bildirimIptalEt(dogum);

    // Veritabanında güncelleme yapılır
    int sonuc = await db.update(
      'dogumlar',
      {
        'isim': dogum.isim,
        'dogumTarihi': DateFormat('yyyy-MM-dd').format(dogum.dogumTarihi),
      },
      where: 'id = ?',
      whereArgs: [dogum.id],
    );

    // Yeni bildirim eklenir
    await bildirimYoneticisi.bildirimZamanlamasiYap(dogum);

    return sonuc;
  }

  // Veri silme
  static Future<int> veriSil(String id) async {
    final db = await veritabani;

    // Bildirimi iptal etmek için kaydı silmeden önce getiriyoruz
    DogumGunu? dogumGunu = await DogumGunu.getDogumGunuById(id);

    // Veritabanından doğum günü silinir
    int sonuc = await db.delete(
      'dogumlar',
      where: 'id = ?',
      whereArgs: [id],
    );

    // Doğum günü silindiğinde, bildirim iptal edilir
    if (dogumGunu != null) {
      BildirimYoneticisi bildirimYoneticisi = BildirimYoneticisi();
      await bildirimYoneticisi.bildirimIptalEt(dogumGunu);
    }

    return sonuc;
  }
}
