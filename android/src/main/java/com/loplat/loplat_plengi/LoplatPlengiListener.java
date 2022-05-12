package com.loplat.loplat_plengi;

import android.content.Context;
import android.util.Log;

import com.google.gson.Gson;
import com.loplat.placeengine.PlengiResponse;

/**
 * Created by sebastian song on 22. 4. 8.
 */
public class LoplatPlengiListener implements com.loplat.placeengine.PlengiListener {
    private static final String TAG = LoplatPlengiListener.class.getSimpleName();
    private Context mContext;
    public LoplatPlengiListener(Context context) {
        mContext = context;
    }

    @Override
    public void listen(PlengiResponse response) {
        Log.i(TAG, "LoplatPlengiListener: " + response.type);
        Context context = mContext;
        try {
            String jsonStr = new Gson().toJson(response);
            FlutterBackgroundExecutor.getInstance().forwardMessageToFlutter(context, jsonStr);
        } catch (Exception ignored) {
            Log.e(TAG, ignored.toString());
        }
    }
}
