package com.muhammet.hasan.marasli.DogumGunu

import android.app.AlarmManager
import android.app.PendingIntent
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.database.sqlite.SQLiteDatabase
import java.util.Calendar
import java.util.GregorianCalendar

/** Bugün kayıtlı birinin doğum günüyse launcher ikonunu kutlama ikonuna çevirir. */
object IkonYoneticisi {
    // Eski kullanıcıların ana ekran kısayolu bozulmasın diye varsayılan alias eski adı taşır.
    private const val VARSAYILAN_IKON = "com.muhammet.hasan.marasli.DogumGunu.MainActivity"
    private const val DOGUM_GUNU_IKONU = "com.muhammet.hasan.marasli.DogumGunu.DogumGunuIkonu"
    const val GECELIK_KONTROL = "com.muhammet.hasan.marasli.DogumGunu.IKON_KONTROLU"

    fun ikonuGuncelle(context: Context) {
        val dogumGunu = bugunDogumGunuVarMi(context) ?: return
        val pm = context.packageManager
        val acilacak = ComponentName(context, if (dogumGunu) DOGUM_GUNU_IKONU else VARSAYILAN_IKON)
        val kapanacak = ComponentName(context, if (dogumGunu) VARSAYILAN_IKON else DOGUM_GUNU_IKONU)
        if (acikMi(pm, acilacak) && !acikMi(pm, kapanacak)) return

        // Önce yenisi açılır ki launcher'da bir an bile ikonsuz kalınmasın.
        pm.setComponentEnabledSetting(
            acilacak,
            PackageManager.COMPONENT_ENABLED_STATE_ENABLED,
            PackageManager.DONT_KILL_APP,
        )
        pm.setComponentEnabledSetting(
            kapanacak,
            PackageManager.COMPONENT_ENABLED_STATE_DISABLED,
            PackageManager.DONT_KILL_APP,
        )
    }

    /** Bir sonraki gece yarısı için kontrol kurar; alarm her çalıştığında yenisini kurar. */
    fun gecelikKontroluPlanla(context: Context) {
        val alarm = context.getSystemService(AlarmManager::class.java) ?: return
        val niyet = PendingIntent.getBroadcast(
            context,
            0,
            Intent(context, IkonAlici::class.java).setAction(GECELIK_KONTROL),
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
        )
        val geceYarisi = Calendar.getInstance().apply {
            add(Calendar.DAY_OF_YEAR, 1)
            set(Calendar.HOUR_OF_DAY, 0)
            set(Calendar.MINUTE, 0)
            set(Calendar.SECOND, 5)
            set(Calendar.MILLISECOND, 0)
        }
        // Kesin alarm izni istememek için esnek alarm; Doze'da birkaç dakika kayabilir.
        alarm.setAndAllowWhileIdle(AlarmManager.RTC_WAKEUP, geceYarisi.timeInMillis, niyet)
    }

    private fun acikMi(pm: PackageManager, bilesen: ComponentName): Boolean =
        when (pm.getComponentEnabledSetting(bilesen)) {
            PackageManager.COMPONENT_ENABLED_STATE_ENABLED -> true
            PackageManager.COMPONENT_ENABLED_STATE_DEFAULT -> bilesen.className == VARSAYILAN_IKON
            else -> false
        }

    /** Veritabanı okunamazsa null döner; o durumda ikona dokunulmaz. */
    private fun bugunDogumGunuVarMi(context: Context): Boolean? {
        val dosya = context.getDatabasePath("dogum_gunu.db")
        if (!dosya.exists()) return false

        val bugun = Calendar.getInstance()
        val ay = bugun.get(Calendar.MONTH) + 1
        val gun = bugun.get(Calendar.DAY_OF_MONTH)
        val artikYil = GregorianCalendar().isLeapYear(bugun.get(Calendar.YEAR))

        return try {
            SQLiteDatabase.openDatabase(dosya.path, null, SQLiteDatabase.OPEN_READONLY).use { db ->
                db.rawQuery("SELECT dogumTarihi FROM dogumlar", null).use { satirlar ->
                    var bulundu = false
                    while (!bulundu && satirlar.moveToNext()) {
                        // Kayıt biçimi yyyy-MM-dd
                        val parcalar = satirlar.getString(0).split("-")
                        if (parcalar.size < 3) continue
                        val dAy = parcalar[1].toIntOrNull() ?: continue
                        var dGun = parcalar[2].toIntOrNull() ?: continue
                        // 29 Şubat doğumlular artık olmayan yıllarda 28 Şubat'ta kutlanır.
                        if (dAy == 2 && dGun == 29 && !artikYil) dGun = 28
                        bulundu = dAy == ay && dGun == gun
                    }
                    bulundu
                }
            }
        } catch (e: Exception) {
            null
        }
    }
}
