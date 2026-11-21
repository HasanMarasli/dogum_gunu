package com.muhammet.hasan.marasli.DogumGunu

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent

/** Gece yarısı alarmında, açılışta ve saat/saat dilimi değişince ikonu kontrol eder. */
class IkonAlici : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        IkonYoneticisi.ikonuGuncelle(context)
        IkonYoneticisi.gecelikKontroluPlanla(context)
    }
}
