import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/theme_provider.dart';

const String kTelegramChannelUrl = 'https://t.me/wbnet';

class AboutScreen extends ConsumerWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('درباره ما')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Center(
            child: Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                gradient: AppColors.connectButtonGradient,
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Icon(Icons.shield_moon_rounded,
                  color: Colors.white, size: 42),
            ),
          ),
          const SizedBox(height: 16),
          const Center(
            child: Text(
              'کانفیگ رایگان | FreeConfig Hub',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
          ),
          const SizedBox(height: 8),
          Center(
            child: FutureBuilder<PackageInfo>(
              future: PackageInfo.fromPlatform(),
              builder: (context, snap) {
                final version = snap.data?.version ?? '1.0.0';
                return Text('نسخه $version',
                    style: const TextStyle(color: Colors.grey));
              },
            ),
          ),
          const SizedBox(height: 20),
          const Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'کانفیگ رایگان اپلیکیشنی برای دسترسی آسان و امن به سرورهای '
                'V2Ray/Xray است. هدف ما فراهم کردن اینترنتی آزاد و بدون '
                'محدودیت برای همه است.',
                textAlign: TextAlign.right,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: SwitchListTile(
              title: const Text('حالت تاریک'),
              value: themeMode == ThemeMode.dark,
              onChanged: (_) => ref.read(themeModeProvider.notifier).toggle(),
            ),
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: () =>
                launchUrl(Uri.parse(kTelegramChannelUrl), mode: LaunchMode.externalApplication),
            icon: const Icon(Icons.telegram_rounded),
            label: const Text('عضویت در کانال تلگرام'),
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(52),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
