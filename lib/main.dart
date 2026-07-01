import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_provider.dart';
import 'features/servers/data/servers_repository.dart';
import 'features/servers/domain/models/server_model.dart';
import 'features/vpn/presentation/vpn_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();

  // ثبت آداپتورهای Hive برای مدل‌های داده
  Hive.registerAdapter(ServerModelAdapter());
  Hive.registerAdapter(ServerProtocolAdapter());
  Hive.registerAdapter(ServerSourceAdapter());

  // باز کردن Boxهای مورد نیاز پیش از اجرای برنامه
  await Hive.openBox(kSettingsBox);
  await Hive.openBox<ServerModel>(kOfficialBoxName);
  await Hive.openBox<ServerModel>(kPersonalBoxName);

  runApp(const ProviderScope(child: FreeConfigApp()));
}

class FreeConfigApp extends ConsumerWidget {
  const FreeConfigApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp.router(
      title: 'کانفیگ رایگان | FreeConfig Hub',
      debugShowCheckedModeBanner: false,
      locale: const Locale('fa', 'IR'),
      supportedLocales: const [Locale('fa', 'IR'), Locale('en', 'US')],
      localizationsDelegates: const [
        // در صورت نیاز به رشته‌های محلی‌سازی سیستمی، پکیج
        // flutter_localizations را اضافه و delegateها را این‌جا قرار دهید.
      ],
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      routerConfig: router,
      builder: (context, child) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: child ?? const SizedBox.shrink(),
        );
      },
    );
  }
}
