import 'package:dogum_gunu/models/bildirim_yoneticisi.dart';
import 'package:dogum_gunu/models/dogum_gunu.dart';
import 'package:dogum_gunu/models/oneri_motoru.dart';
import 'package:flutter/foundation.dart';
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
      version: 4,
      onCreate: _ilkTabloOlustur,
      onUpgrade: (db, eski, yeni) async {
        // Aynı isimde birden fazla kişi olabilir; eski benzersiz indeks kalkar.
        if (eski < 3) {
          await db.execute('DROP INDEX IF EXISTS idx_dogumlar_isim_nocase');
        }
        if (eski < 4) {
          await db.execute('ALTER TABLE dogumlar ADD COLUMN cinsiyet TEXT');
          await db.execute('ALTER TABLE dogumlar ADD COLUMN yakinlik TEXT');
        }
      },
    );
  }

  static Future<void> _ilkTabloOlustur(Database db, int version) async {
    await db.execute('''
      CREATE TABLE dogumlar (
        id TEXT PRIMARY KEY,
        isim TEXT NOT NULL,
        dogumTarihi TEXT NOT NULL,
        cinsiyet TEXT,
        yakinlik TEXT
      )
    ''');
  }

  // Veri ekleme
  static Future<int> veriEkle(DogumGunu dogum) async {
    final db = await veritabani;

    // Tarih formatını uygun şekilde kaydediyoruz
    String formattedDate = DateFormat('yyyy-MM-dd').format(dogum.dogumTarihi);

    // Veritabanına doğum günü ekleniyor
    int sonuc = await db.insert('dogumlar', {
      'id': dogum.id,
      'isim': dogum.isim,
      'dogumTarihi': formattedDate,
      'cinsiyet': dogum.cinsiyet?.name,
      'yakinlik': dogum.yakinlik?.name,
    });

    await _bildirimleriGuncelle();

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
        cinsiyet: Cinsiyet.values.asNameMap()[sonuc[i]['cinsiyet']],
        yakinlik: Yakinlik.values.asNameMap()[sonuc[i]['yakinlik']],
      );
    });
  }

  /// Açılışta ve ayar/dil değişikliğinde çağrılır; plan imzası değişmediyse
  /// iş yapmaz. Çalışmalar sıralı kuyrukta birleştirilir, hata fırlatmaz.
  static Future<void> tumBildirimleriYenidenPlanla() {
    return BildirimYoneticisi().yenidenPlanla();
  }

  /// Kişi verisi değiştiğinde planı hemen yeniler. Bildirim adımındaki bir
  /// hata, başarılı veritabanı işleminin sonucunu engellemez.
  static Future<void> _bildirimleriGuncelle() async {
    try {
      await BildirimYoneticisi().yenidenPlanla(zorla: true);
    } catch (hata, yigin) {
      FlutterError.reportError(
        FlutterErrorDetails(
          exception: hata,
          stack: yigin,
          library: 'veritabani',
          context: ErrorDescription('bildirimler güncellenemedi'),
        ),
      );
    }
  }

  // Veri güncelleme
  static Future<int> veriGuncelle(DogumGunu dogum) async {
    final db = await veritabani;

    // Veritabanında güncelleme yapılır
    int sonuc = await db.update(
      'dogumlar',
      {
        'isim': dogum.isim,
        'dogumTarihi': DateFormat('yyyy-MM-dd').format(dogum.dogumTarihi),
        'cinsiyet': dogum.cinsiyet?.name,
        'yakinlik': dogum.yakinlik?.name,
      },
      where: 'id = ?',
      whereArgs: [dogum.id],
    );

    // Eski bildirimler iptal edilip yenileri planlanır.
    await _bildirimleriGuncelle();

    return sonuc;
  }

  // Veri silme
  static Future<int> veriSil(String id) async {
    final db = await veritabani;

    // Veritabanından doğum günü silinir
    int sonuc = await db.delete('dogumlar', where: 'id = ?', whereArgs: [id]);

    OneriMotoru.turlariSil(id);
    // Silinen kişinin bekleyen bildirimleri planda olmadığı için iptal edilir.
    await _bildirimleriGuncelle();

    return sonuc;
  }
}
