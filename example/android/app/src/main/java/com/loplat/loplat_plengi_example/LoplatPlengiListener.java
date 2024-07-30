package com.loplat.loplat_plengi_example;

import android.util.Log;
import com.google.gson.Gson;
import com.loplat.placeengine.PlengiListener;
import com.loplat.placeengine.PlengiResponse;

public class LoplatPlengiListener implements PlengiListener {
    private static final String TAG = LoplatPlengiListener.class.getSimpleName();
    @Override
    public void listen(PlengiResponse response) {
        Log.i(TAG, "LoplatPlengiListener: " + response.type);
        try {
            String jsonStr = new Gson().toJson(response);
            Log.d(TAG, jsonStr);
        } catch (Exception ignored) {
            Log.e(TAG, ignored.toString());
        }
    }
}