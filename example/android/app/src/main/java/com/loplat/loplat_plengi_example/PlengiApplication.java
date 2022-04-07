package com.loplat.loplat_plengi_example;

import android.content.Context;
import android.content.res.Configuration;
import android.os.Handler;
import android.util.Log;

import com.loplat.loplat_plengi.FlutterBackgroundExecutor;
import com.loplat.placeengine.Plengi;
import com.loplat.placeengine.PlengiListener;

import io.flutter.app.FlutterApplication;


/**
 * Created by Sebastian.Song on 22. 4. 7..
 */
public class PlengiApplication extends FlutterApplication {
    private static final String TAG = PlengiApplication.class.getSimpleName();
    Plengi mPlengi = null;

    private static PlengiApplication instance;
    private static PlengiListener mPlengiListener = new ModePlengiListener();

    public static Context getContext(){
        return instance;
        // or return instance.getApplicationContext();
    }

    @Override
    public void onCreate() {
        super.onCreate();
        //LoplatLogger.setEnablePrintLog(false);
        //LoplatLogger.DEBUG = true;
        Log.i(TAG, "PlengiApplication created ---------------");

        instance = this;
        Context context = getApplicationContext();
        Plengi plengi = Plengi.getInstance(context);
        plengi.setListener(mPlengiListener);

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

    @Override
    public void onTerminate() {
        super.onTerminate();
        Log.w(TAG,"PlengiApplication terminated ---------------");
    }

    @Override
    public void onLowMemory() {
        super.onLowMemory();
        Log.w(TAG, "PlengiApplication onLowMemory ---------------");
    }

    @Override
    public void onConfigurationChanged(Configuration newConfig) {
        super.onConfigurationChanged(newConfig);
        Log.w(TAG, "PlengiApplication onConfigurationChanged ---------------");
    }
}
