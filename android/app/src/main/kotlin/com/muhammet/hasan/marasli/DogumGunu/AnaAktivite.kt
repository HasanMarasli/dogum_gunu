package com.muhammet.hasan.marasli.DogumGunu

import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity

// Launcher'da doğrudan görünmez; manifestteki activity-alias'lar bu aktiviteyi açar,
// hangi alias'ın etkin olduğunu IkonYoneticisi belirler.
class AnaAktivite : FlutterActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        IkonYoneticisi.gecelikKontroluPlanla(this)
    }

    // Kişi eklenip silindikten sonra ikon, uygulama arka plana geçince güncellenir;
    // ön plandayken alias değiştirmek bazı launcher'larda uygulamayı kapatır.
    override fun onStop() {
        super.onStop()
        IkonYoneticisi.ikonuGuncelle(this)
    }
}
