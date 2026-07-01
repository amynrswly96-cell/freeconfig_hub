import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/empty_state.dart';
import '../../home/presentation/widgets/server_card.dart';
import '../../servers/domain/models/server_model.dart';
import '../../servers/presentation/servers_provider.dart';
import '../../vpn/presentation/vpn_provider.dart';

class MyServersScreen extends ConsumerWidget {
  const MyServersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final personal = ref.watch(personalServersProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('سرورهای من'),
        actions: [
          IconButton(
            icon: const Icon(Icons.qr_code_scanner_rounded),
            onPressed: () => context.push('/my-servers/scan'),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/my-servers/add'),
        icon: const Icon(Icons.add_rounded),
        label: const Text('افزودن کانفیگ'),
      ),
      body: personal.isEmpty
          ? EmptyState(
              icon: Icons.dns_rounded,
              message: 'هنوز سرور شخصی اضافه نکرده‌اید.',
              actionLabel: 'افزودن کانفیگ',
              onAction: () => context.push('/my-servers/add'),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: personal.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, i) {
                final server = personal[i];
                return _PersonalServerTile(server: server);
              },
            ),
    );
  }
}

class _PersonalServerTile extends ConsumerWidget {
  final ServerModel server;
  const _PersonalServerTile({required this.server});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ServerCard(
              server: server,
              onTap: () => ref.read(vpnProvider.notifier).connect(server),
            ),
            const SizedBox(height: 10),
            SelectableText(
              server.rawConfig,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 11, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              children: [
                _ActionIcon(
                  icon: Icons.copy_rounded,
                  tooltip: 'کپی',
                  onTap: () async {
                    await Clipboard.setData(ClipboardData(text: server.rawConfig));
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('کانفیگ کپی شد.')),
                      );
                    }
                  },
                ),
                _ActionIcon(
                  icon: Icons.share_rounded,
                  tooltip: 'اشتراک‌گذاری',
                  onTap: () => Share.share(server.rawConfig),
                ),
                _ActionIcon(
                  icon: Icons.edit_rounded,
                  tooltip: 'ویرایش',
                  onTap: () => context.push('/my-servers/add', extra: server),
                ),
                _ActionIcon(
                  icon: Icons.delete_outline_rounded,
                  tooltip: 'حذف',
                  color: AppColors.error,
                  onTap: () => _confirmDelete(context, ref),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('حذف سرور'),
        content: Text('آیا از حذف «${server.name}» مطمئن هستید؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('انصراف'),
          ),
          TextButton(
            onPressed: () {
              ref.read(personalServersProvider.notifier).delete(server.id);
              Navigator.pop(ctx);
            },
            child: Text('حذف', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }
}

class _ActionIcon extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;
  final Color? color;

  const _ActionIcon({
    required this.icon,
    required this.tooltip,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: (color ?? AppColors.primary).withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 18, color: color ?? AppColors.primary),
        ),
      ),
    );
  }
}
