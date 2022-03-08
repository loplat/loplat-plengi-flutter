package com.loplat.loplat_plengi;

import android.content.Context;

import androidx.annotation.NonNull;

import com.google.gson.Gson;
import com.loplat.placeengine.OnPlengiListener;
import com.loplat.placeengine.PlaceEngine;
import com.loplat.placeengine.Plengi;
import com.loplat.placeengine.PlengiResponse;

import java.util.ArrayList;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;

/** LoplatPlengiPlugin */
public class LoplatPlengiPlugin implements FlutterPlugin, MethodCallHandler {
  /// The MethodChannel that will the communication between Flutter and native Android
  ///
  /// This local reference serves to register the plugin with the Flutter Engine and unregister it
  /// when the Flutter Engine is detached from the Activity
  private MethodChannel channel;
  private Context mContext;

  @Override
  public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
    mContext = flutterPluginBinding.getApplicationContext();
    channel = new MethodChannel(flutterPluginBinding.getBinaryMessenger(), "loplat_plengi");
    channel.setMethodCallHandler(this);
  }

  @Override
  public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {
    if (call.method.equals("getPlatformVersion")) {
      result.success("Android " + android.os.Build.VERSION.RELEASE + " loplat SDK version code: " + PlaceEngine.getCurrentSdkVerCode(mContext));
    } else if (call.method.equals("getEngineStatus")) {
      result.success(Plengi.getInstance(mContext).getEngineStatus());
    } else if (call.method.equals("start")) {
      try {
        ArrayList arguments = (ArrayList) call.arguments;
        String id = (String) arguments.get(0);
        String pw = (String) arguments.get(1);
        result.success(Plengi.getInstance(mContext).start(id, pw));
      } catch (Exception ex) {
        result.error("1", ex.getMessage(), ex.getStackTrace());
      }
    } else if (call.method.equals("stop")) {
      try {
        result.success(Plengi.getInstance(mContext).stop());
      } catch (Exception ex) {
        result.error("1", ex.getMessage(), ex.getStackTrace());
      }
    } else if (call.method.equals("setEchoCode")) {
      try {
        ArrayList arguments = (ArrayList) call.arguments;
        String code = (String) arguments.get(0);
        Plengi.getInstance(mContext).setEchoCode(code);
        result.success("success");
      } catch (Exception ex) {
        result.error("1", ex.getMessage(), ex.getStackTrace());
      }
    } else if (call.method.equals("enableAdNetwork")) {
      try {
        ArrayList arguments = (ArrayList) call.arguments;
        int argLen = arguments.size();
        if (argLen == 2) {
          boolean enableAd = (boolean) arguments.get(0);
          boolean enableNoti = (boolean) arguments.get(1);
          Plengi.getInstance(mContext).enableAdNetwork(enableAd, enableNoti);
          result.success("success");
        } else {
          result.error("1", "invalid argument size", "");
        }
      } catch (Exception ex) {
        result.error("1", ex.getMessage(), ex.getStackTrace());
      }
    } else if (call.method.equals("enableTestServer")) {
      try {
        ArrayList arguments = (ArrayList) call.arguments;
        int argLen = arguments.size();
        if (argLen == 1) {
          int value = (int) arguments.get(0);
          Plengi.getInstance(mContext).enableTestServer(value);
          result.success("success");
        } else {
          result.error("1", "invalid argument size", "");
        }
      } catch (Exception ex) {
        result.error("1", ex.getMessage(), ex.getStackTrace());
      }
    } else if (call.method.equals("getTestServerMode")) {
      try {
        result.success(Plengi.getInstance(mContext).getTestServerMode());
      } catch (Exception ex) {
        result.error("1", ex.getMessage(), ex.getStackTrace());
      }
    } else if (call.method.equals("TEST_refreshPlace_foreground")) {
      try {
        Plengi.getInstance(mContext).TEST_refreshPlace_foreground(new OnPlengiListener() {
          @Override
          public void onSuccess(PlengiResponse response) {
            result.success(new Gson().toJson(response));
          }

          @Override
          public void onFail(PlengiResponse response) {
            result.success(new Gson().toJson(response));
          }
        });
      } catch (Exception ex) {
        result.error("1", ex.getMessage(), ex.getStackTrace());
      }
    } else {
      result.notImplemented();
    }
  }

  @Override
  public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
    channel.setMethodCallHandler(null);
  }
}
