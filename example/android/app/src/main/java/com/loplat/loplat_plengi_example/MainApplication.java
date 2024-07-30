package com.loplat.loplat_plengi_example;

import io.flutter.app.FlutterApplication;

import android.content.Context;
import com.loplat.placeengine.Plengi;

public class MainApplication extends FlutterApplication {
    @Override
    public void onCreate() {
        super.onCreate();

        Context applicationContext = getApplicationContext();
        Plengi plengi = Plengi.getInstance(applicationContext);
        plengi.setListener(new LoplatPlengiListener());
        plengi.setEchoCode("[your_echo_code]");
    }
}
