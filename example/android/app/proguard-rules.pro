# Add project specific ProGuard rules here.
# By default, the flags in this file are appended to flags specified
# in /Users/koojh74/Library/Android/sdk/tools/proguard/proguard-android.txt
# You can edit the include path and order by changing the proguardFiles
# directive in build.gradle.
#
# For more details, see
#   http://developer.android.com/guide/developing/tools/proguard.html

-keeppackagenames com.loplat.placeengine.**, com.plengi.app

-keepattributes Signature, Exceptions, *Annotation*, SourceFile, LineNumberTable, EnclosingMethod, InnerClasses

# Add any project specific keep options here:
-keep class * implements java.io.Serializable {*;}
-keep class * implements android.os.Parcelable {*;}
-keep class com.loplat.placeengine.Plengi {*;}
-keep class com.loplat.placeengine.PlengiBase {*;}
-keep class com.loplat.placeengine.PlaceEngine {public *;}
-keep public class com.loplat.placeengine.PlaceEngineBase$* {public *;}
-keep class com.loplat.placeengine.PlengiListener {*;}
-keep class com.loplat.placeengine.OnPlengiListener {*;}
-keep class com.loplat.placeengine.PlengiResponse** {*;}
-keep public class com.loplat.placeengine.PlengiResponse$* {*;}
-keep class com.loplat.placeengine.utils.LoplatLogger { public *;}
-keep class com.loplat.placeengine.cloud.RequestMessage** {*;}
-keep class com.loplat.placeengine.cloud.ResponseMessage** {*;}
-keep class com.loplat.placeengine.wifi.WifiType {public *;}
-keep class com.loplat.placeengine.SpaceTracker {*;}
-keep class com.loplat.placeengine.SpaceTrackerListener {*;}
-keep class com.loplat.placeengine.SpaceTrackerResponse {*;}
#-keep class com.loplat.placeengine.BuildConfig {public *;}
#-keep class com.loplat.placeengine.database.DBHelper {public *;}
#-keep class com.loplat.placeengine.database.SharedDataHandler {public *;}
#-keep class com.loplat.placeengine.wifi.WifiScanManager {public *;}
-keep public class com.loplat.placeengine.wifi.WifiScanManager {
    public static void deleteOldScan(android.content.Context);
    public static java.util.List getStoredScan(android.content.Context);
}
#-keep class com.loplat.placeengine.ads.notification.AdsProcess {public *;}
-keep class com.loplat.placeengine.ads.LoplatAdsActivity {public *;}

-dontwarn okio.**
-dontwarn javax.annotation.**
-keepclasseswithmembers class * {
    @retrofit2.http.* <methods>;
}

 # Keep generic signature of Call, Response (R8 full mode strips signatures from non-kept items).
-keep,allowobfuscation,allowshrinking interface retrofit2.Call
-keep,allowobfuscation,allowshrinking class retrofit2.Response

-assumenosideeffects class com.loplat.placeengine.utils.LoplatLogger  {
    public static void v(...);
    public static void i(...);
    public static void w(...);
    public static void d(...);
    public static void e(...);
    public static void a(...);
    public static void json(...);
}

-assumenosideeffects class com.loplat.placeengine.utils.PlengiMonitor {
    public static void debugLogToClient(android.content.Context, java.lang.String);
}

-keep class com.loplat.placeengine.cloud.ResponseMessage** {*;}