package com.loplat.loplat_plengi_example;

import android.content.Context;
import android.os.Handler;
import android.util.Log;

import com.loplat.loplat_plengi.FlutterBackgroundExecutor;
import com.loplat.loplat_plengi.LoplatPlengiListener;
import com.loplat.placeengine.Plengi;

import io.flutter.app.FlutterApplication;


/**
 * Created by Sebastian.Song on 22. 4. 7..
 */
public class MainApplication extends FlutterApplication {
    private static final String TAG = MainApplication.class.getSimpleName();

    @Override
    public void onCreate() {
        super.onCreate();
        Log.i(TAG, "MainApplication created ---------------");

        Context context = getApplicationContext();
        Plengi plengi = Plengi.getInstance(context);
        plengi.setListener(new LoplatPlengiListener(context));

        /**
         * 앱 설치 후 최초 시작시 시간 delay 를 주는 이유는  Background channel 을 만들고
         * Flutter 단에서 callback handler 값이 전달되어 저장되기까지 시간이 걸린다.
         * 저장된 이후로는 문제 없다.
         */
        FlutterBackgroundExecutor flutterBackgroundExecutor = FlutterBackgroundExecutor.getInstance();
        long handle = flutterBackgroundExecutor.getBgChannelCallbackHandle(context);
        if (handle != 0) {
            FlutterBackgroundExecutor.getInstance().startBackgroundIsolate(context);
        } else {
            new Handler().postDelayed(new Runnable() {
                @Override
                public void run() {
                    FlutterBackgroundExecutor.getInstance().startBackgroundIsolate(context);
                }
            }, 2000);
        }
    }
}
