import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../home/presentation/widgets/server_card.dart';
import '../../vpn/domain/vpn_service.dart';
import '../../vpn/presentation/vpn_provider.dart';

class ConnectionScreen extends ConsumerWidget {
  const ConnectionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vpnState = ref.watch(vpnProvider);
    final server = vpnState.currentServer;
    final live = vpnState.liveStatus;
    final connected = vpnState.connectionState == VpnConnectionState.connected;

    return Scaffold(
      appBar: AppBar(title: const Text('جزئیات اتصال')),
      body: server == null
          ? const Center(child: Text('هنوز به سروری متصل نشده‌اید.'))
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        Icon(
                          connected
                              ? Icons.verified_user_rounded
                              : Icons.sync_rounded,
                          color: connected ? AppColors.success : AppColors.warning,
                          size: 48,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          connected ? 'متصل' : 'در حال برقراری اتصال',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${countryCodeToFlagEmoji(server.countryCode)}  ${server.name}',
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 1.6,
                  children: [
                    _InfoTile(
                      icon: Icons.timer_outlined,
                      label: 'مدت اتصال',
                      value: live.duration,
                    ),
                    _InfoTile(
                      icon: Icons.speed_rounded,
                      label: 'پینگ',
                      value: server.pingMs > 0 ? '${server.pingMs}ms' : '—',
                    ),
                    _InfoTile(
                      icon: Icons.arrow_upward_rounded,
                      label: 'سرعت آپلود',
                      value: live.uploadSpeed,
                    ),
                    _InfoTile(
                      icon: Icons.arrow_downward_rounded,
                      label: 'سرعت دانلود',
                      value: live.downloadSpeed,
                    ),
                    _InfoTile(
                      icon: Icons.upload_file_rounded,
                      label: 'کل آپلود',
                      value: live.totalUpload,
                    ),
                    _InfoTile(
                      icon: Icons.download_rounded,
                      label: 'کل دانلود',
                      value: live.totalDownload,
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                FilledButton.icon(
                  onPressed: () => ref.read(vpnProvider.notifier).disconnect(),
                  icon: const Icon(Icons.power_settings_new_rounded),
                  label: const Text('قطع اتصال'),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.error,
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

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoTile({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: AppColors.primary, size: 22),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: Theme.of(context).textTheme.bodySmall?.color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
