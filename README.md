# کانفیگ رایگان | FreeConfig Hub

اپلیکیشن Flutter Native برای مدیریت و اتصال به کانفیگ‌های V2Ray/Xray با UI مدرن،
معماری Clean Architecture، Riverpod، Hive و اتصال VPN واقعی.

## ⚠️ قبل از هر چیز بخوانید

این اسکلت پروژه بدون دسترسی به Flutter SDK یا اینترنت نوشته شده است (محیط تولید
این فایل‌ها به هیچ‌کدام دسترسی نداشت). یعنی:

1. **کد کامپایل نشده و build واقعی گرفته نشده.** باید حتماً روی سیستم خودتان
   با Flutter نصب‌شده تست کنید.
2. **نسخه‌ی دقیق API پکیج `flutter_v2ray`** (نام کلاس‌ها، متدها، پارامترها) را
   باید بعد از `flutter pub get` با کد واقعی پکیج در
   `~/.pub-cache` یا با مراجعه به صفحه‌ی pub.dev آن مطابقت دهید. ممکن است
   نام سرویس در `AndroidManifest.xml` (`V2rayVpnService`) با نسخه‌ی نصب‌شده
   فرق داشته باشد؛ اگر build خطای Manifest merge داد، به مستندات پکیج نصب‌شده
   مراجعه کنید (فایل `example/android/app/src/main/AndroidManifest.xml` داخل
   خود پکیج معمولاً دقیق‌ترین مرجع است).
3. آدرس API (`kServersApiBaseUrl` در `servers_api_service.dart`) باید با
   آدرس واقعی سرور شما جایگزین شود.
4. آیکون و لوگوی برنامه (`assets/images/logo.png`) باید اضافه شود؛ پوشه‌ی
   `assets/` در این اسکلت خالی ایجاد شده است.

## مراحل راه‌اندازی

```bash
# 1. نصب پکیج‌ها
flutter pub get

# 2. تولید فایل‌های Hive (اختیاری - server_model.g.dart از قبل به‌صورت
#    دستی نوشته شده، اما اگر مدل را تغییر دادید این دستور را اجرا کنید)
flutter pub run build_runner build --delete-conflicting-outputs

# 3. اجرای برنامه روی دستگاه/شبیه‌ساز متصل
flutter run

# 4. گرفتن APK نهایی برای انتشار
flutter build apk --release
```

## ساختار پروژه (Clean Architecture, Feature-first)

```
lib/
  core/
    theme/          تم‌ها، رنگ‌ها، ThemeMode provider
    router/          پیکربندی go_router
    widgets/         RootShell (Bottom Nav)، Skeleton، EmptyState
  features/
    splash/          صفحه اسپلش
    home/             صفحه اصلی، دکمه اتصال، کارت سرور
    servers/
      domain/models/  ServerModel (Hive)
      data/           API service + Repository
      presentation/   Providerهای Riverpod، صفحه دسته‌بندی‌ها
    my_servers/      افزودن/ویرایش/QR اسکن سرور شخصی
    connection/       صفحه جزئیات اتصال زنده
    vpn/
      domain/         VpnCoreService (wrapper روی flutter_v2ray)
      presentation/   vpnProvider (Riverpod StateNotifier)
    about/            درباره ما، لینک تلگرام، سوییچ تم
```

## نکات امنیتی سرورهای اختصاصی

طبق الزامات پروژه، سرورهای دریافتی از API (`ServerSource.official`) در UI
هیچ دکمه‌ی Copy/Share/Export ندارند و متن خام کانفیگ نمایش داده نمی‌شود
(`my_servers_screen.dart` فقط برای `ServerSource.personal` این دکمه‌ها را
نشان می‌دهد). برای محافظت واقعی در برابر سوءاستفاده، توصیه می‌شود:

- کانفیگ خام سرورهای اختصاصی هرگز مستقیم در پاسخ API قابل مشاهده در لاگ/دیباگ
  نباشد (رمزنگاری سمت سرور + رمزگشایی موقت فقط در حافظه هنگام اتصال).
- Certificate pinning برای درخواست‌های Dio به API اضافه شود.
- Root/Jailbreak detection و obfuscation کد (R8/Proguard از قبل فعال است)
  را جدی بگیرید چون این محدودیت‌ها صرفاً UI-level هستند و یک کاربر با دسترسی
  root به‌طور بالقوه می‌تواند ترافیک VPN را بررسی کند.

## گام‌های باقی‌مانده برای Production

- [ ] افزودن آیکون واقعی برنامه (`flutter_launcher_icons`)
- [ ] تنظیم `android/key.properties` برای امضای release واقعی
- [ ] تست کامل جریان اتصال VPN روی دستگاه فیزیکی اندروید
- [ ] ادغام AdMob (ساختار ماژولار آماده است، SDK باید اضافه و پیکربندی شود)
- [ ] افزودن `flutter_localizations` در صورت نیاز به رشته‌های سیستمی فارسی
- [ ] تست Sing-box / پروتکل‌های اضافه در صورت نیاز فراتر از Xray
