package com.loplat.loplat_plengi;

import android.content.Context;
import android.content.Intent;
import android.content.SharedPreferences;
import android.content.res.AssetManager;
import android.util.Log;

import io.flutter.FlutterInjector;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.embedding.engine.dart.DartExecutor;
import io.flutter.embedding.engine.dart.DartExecutor.DartCallback;
import io.flutter.embedding.engine.plugins.shim.ShimPluginRegistry;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.JSONMethodCodec;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry.PluginRegistrantCallback;
import io.flutter.view.FlutterCallbackInformation;
import java.util.concurrent.CountDownLatch;
import java.util.concurrent.atomic.AtomicBoolean;

/**
 * An background execution abstraction which handles initializing a background isolate running a
 * callback dispatcher, used to invoke Dart callbacks while backgrounded.
 */
public class FlutterBackgroundExecutor implements MethodCallHandler {
    private static final String TAG = FlutterBackgroundExecutor.class.getSimpleName();
    private static final String BG_CHANNEL_CALLBACK_HANDLE_KEY = "callback_handle";
    private static final String LISTENER_CALLBACK_HANDLE_KEY = "listener_callback_handle";
    private static final String SHARED_PREFERENCES_KEY = "com.loplat.plengi.background";
    private static PluginRegistrantCallback pluginRegistrantCallback;

    private static FlutterBackgroundExecutor mFlutterBackgroundExecutor;

    public static synchronized FlutterBackgroundExecutor getInstance() {
        if (mFlutterBackgroundExecutor == null) {
            mFlutterBackgroundExecutor = new FlutterBackgroundExecutor();
        }
        return mFlutterBackgroundExecutor;
    }

    /**
     * The {@link MethodChannel} that connects the Android side of this plugin with the background
     * Dart isolate that was created by this plugin.
     */
    private MethodChannel backgroundChannel;

    private FlutterEngine backgroundFlutterEngine;

    private final AtomicBoolean isCallbackDispatcherReady = new AtomicBoolean(false);

    /**
     * Sets the {@code PluginRegistrantCallback} used to register plugins with the newly spawned
     * isolate.
     *
     * <p>Note: this is only necessary for applications using the V1 engine embedding API as plugins
     * are automatically registered via reflection in the V2 engine embedding API. If not set, alarm
     * callbacks will not be able to utilize functionality from other plugins.
     */
    public static void setPluginRegistrant(PluginRegistrantCallback callback) {
        pluginRegistrantCallback = callback;
    }

    class PluginRegistrantException extends RuntimeException {
        public PluginRegistrantException() {
            super(
                    "PluginRegistrantCallback is not set. Did you forget to call "
                            + "AlarmService.setPluginRegistrant? See the README for instructions.");
        }
    }


    /**
     * Sets the Dart callback handle for the Dart method that is responsible for initializing the
     * background Dart isolate, preparing it to receive Dart callback tasks requests.
     */
    public static void setCallbackDispatcher(Context context, long callbackHandle) {
        SharedPreferences prefs = context.getSharedPreferences(SHARED_PREFERENCES_KEY, 0);
        prefs.edit().putLong(BG_CHANNEL_CALLBACK_HANDLE_KEY, callbackHandle).apply();
    }

    public static void setListenerCallback(Context context, long callbackHandle) {
        SharedPreferences prefs = context.getSharedPreferences(SHARED_PREFERENCES_KEY, 0);
        prefs.edit().putLong(LISTENER_CALLBACK_HANDLE_KEY, callbackHandle).apply();
    }


    /** Returns true when the background isolate has started and is ready to handle alarms. */
    public boolean isRunning() {
        return isCallbackDispatcherReady.get();
    }

    private void onInitialized() {
        isCallbackDispatcherReady.set(true);
        //AlarmService.onInitialized();
    }

    @Override
    public void onMethodCall(MethodCall call, Result result) {
        String method = call.method;
        Object arguments = call.arguments;
        try {
            if (method.equals("plengi.initialized")) {
                // This message is sent by the background method channel as soon as the background isolate
                // is running. From this point forward, the Android side of this plugin can send
                // callback handles through the background method channel, and the Dart side will execute
                // the Dart methods corresponding to those callback handles.
                onInitialized();
                result.success(true);
                Log.e(TAG, "plengi.initialize success");
            } else {
                result.notImplemented();
            }
        } catch (PluginRegistrantException e) {
            result.error("error", "AlarmManager error: " + e.getMessage(), null);
        }
    }

    /**
     * Starts running a background Dart isolate within a new {@link FlutterEngine} using a previously
     * used entrypoint.
     *
     * <p>The isolate is configured as follows:
     *
     * <ul>
     *   <li>Bundle Path: {@code FlutterMain.findAppBundlePath(context)}.
     *   <li>Entrypoint: The Dart method used the last time this plugin was initialized in the
     *       foreground.
     *   <li>Run args: none.
     * </ul>
     *
     * <p>Preconditions:
     *
     * <ul>
     *   <li>The given callback must correspond to a registered Dart callback. If the handle does not
     *       resolve to a Dart callback then this method does nothing.
     *   <li>A static {@link #pluginRegistrantCallback} must exist, otherwise a {@link
     *       PluginRegistrantException} will be thrown.
     * </ul>
     */
    public void startBackgroundIsolate(Context context) {
        //if (!isRunning()) {
            long callbackHandle = getBgChannelCallbackHandle(context);
            startBackgroundIsolate(context, callbackHandle);
        //}
    }

    public long getBgChannelCallbackHandle(Context context) {
        SharedPreferences p = context.getSharedPreferences(SHARED_PREFERENCES_KEY, 0);
        return p.getLong(BG_CHANNEL_CALLBACK_HANDLE_KEY, 0);
    }

    /**
     * Starts running a background Dart isolate within a new {@link FlutterEngine}.
     *
     * <p>The isolate is configured as follows:
     *
     * <ul>
     *   <li>Bundle Path: {@code FlutterMain.findAppBundlePath(context)}.
     *   <li>Entrypoint: The Dart method represented by {@code callbackHandle}.
     *   <li>Run args: none.
     * </ul>
     *
     * <p>Preconditions:
     *
     * <ul>
     *   <li>The given {@code callbackHandle} must correspond to a registered Dart callback. If the
     *       handle does not resolve to a Dart callback then this method does nothing.
     *   <li>A static {@link #pluginRegistrantCallback} must exist, otherwise a {@link
     *       PluginRegistrantException} will be thrown.
     * </ul>
     */
    public void startBackgroundIsolate(Context context, long callbackHandle) {
        if (backgroundFlutterEngine != null) {
            Log.e(TAG, "Background isolate already started");
            return;
        }

        Log.e(TAG, "Starting PlengiListener...");
        if (!isRunning()) {
            backgroundFlutterEngine = new FlutterEngine(context);

            String appBundlePath = FlutterInjector.instance().flutterLoader().findAppBundlePath();
            AssetManager assets = context.getAssets();

            // We need to create an instance of `FlutterEngine` before looking up the
            // callback. If we don't, the callback cache won't be initialized and the
            // lookup will fail.
            FlutterCallbackInformation flutterCallback =
                    FlutterCallbackInformation.lookupCallbackInformation(callbackHandle);
            if (flutterCallback == null) {
                Log.e(TAG, "Fatal: failed to find callback : " + callbackHandle);
                return;
            } else {
                Log.e(TAG, "Found callback : " + callbackHandle);
            }

            DartExecutor executor = backgroundFlutterEngine.getDartExecutor();
            initializeMethodChannel(executor);
            DartCallback dartCallback = new DartCallback(assets, appBundlePath, flutterCallback);

            executor.executeDartCallback(dartCallback);

            // The pluginRegistrantCallback should only be set in the V1 embedding as
            // plugin registration is done via reflection in the V2 embedding.
            if (pluginRegistrantCallback != null) {
                pluginRegistrantCallback.registerWith(new ShimPluginRegistry(backgroundFlutterEngine));
            }
        }
    }

    /**
     * Executes the desired Dart callback in a background Dart isolate.
     *
     * <p>The given {@code intent} should contain a {@code long} extra called "callbackHandle", which
     * corresponds to a callback registered with the Dart VM.
     */
    public void executeDartCallbackInBackgroundIsolate(Intent intent, final CountDownLatch latch) {
        // Grab the handle for the callback associated with this alarm. Pay close
        // attention to the type of the callback handle as storing this value in a
        // variable of the wrong size will cause the callback lookup to fail.
        long callbackHandle = intent.getLongExtra("callbackHandle", 0);

        // If another thread is waiting, then wake that thread when the callback returns a result.
        MethodChannel.Result result = null;
        if (latch != null) {
            result =
                    new MethodChannel.Result() {
                        @Override
                        public void success(Object result) {
                            latch.countDown();
                        }

                        @Override
                        public void error(String errorCode, String errorMessage, Object errorDetails) {
                            latch.countDown();
                        }

                        @Override
                        public void notImplemented() {
                            latch.countDown();
                        }
                    };
        }

        // Handle the alarm event in Dart. Note that for this plugin, we don't
        // care about the method name as we simply lookup and invoke the callback
        // provided.
        backgroundChannel.invokeMethod(
                "invokeAlarmManagerCallback",
                new Object[] {callbackHandle, intent.getIntExtra("id", -1)},
                result);
    }

    public void forwardMessageToFlutter(Context context, String msg) {
        //if (!isRunning()) {
        Log.i(TAG, "start");

        MethodChannel.Result result =
                new MethodChannel.Result() {
                    @Override
                    public void success(Object result) {
                        Log.e(TAG, "success");
                    }

                    @Override
                    public void error(String errorCode, String errorMessage, Object errorDetails) {
                        Log.e(TAG, "error");
                    }

                    @Override
                    public void notImplemented() {
                        Log.e(TAG, "notImplemented");
                    }
                };

            SharedPreferences p = context.getSharedPreferences(SHARED_PREFERENCES_KEY, 0);
            long callbackHandle = p.getLong(LISTENER_CALLBACK_HANDLE_KEY, 0);
            backgroundChannel.invokeMethod(
                    "invokeSetListenerCallback",
                    new Object[] {callbackHandle, msg},
                    result);
        Log.i(TAG, "" + msg);
        //}
    }

    private void initializeMethodChannel(BinaryMessenger isolate) {
        // backgroundChannel is the channel responsible for receiving the following messages from
        // the background isolate that was setup by this plugin:
        // - "plengi.initialized"
        //
        // This channel is also responsible for sending requests from Android to Dart to execute Dart
        // callbacks in the background isolate.
        backgroundChannel =
                new MethodChannel(
                        isolate,
                        "com.loplat.plengi/background",
                        JSONMethodCodec.INSTANCE);
        backgroundChannel.setMethodCallHandler(this);
    }
}