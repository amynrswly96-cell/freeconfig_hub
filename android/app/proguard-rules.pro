# قوانین Proguard/R8 برای جلوگیری از حذف کلاس‌های ضروری هسته VPN در بیلد Release

-keep class com.github.blueboytm.flutter_v2ray.** { *; }
-keep class libv2ray.** { *; }
-keep class go.** { *; }
-keepattributes Signature
-keepattributes *Annotation*
-dontwarn io.flutter.embedding.**
