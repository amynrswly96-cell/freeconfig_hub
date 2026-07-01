import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../servers/domain/models/server_model.dart';

/// تبدیل کد کشور به ایموجی پرچم (مثل IR -> 🇮🇷)
String countryCodeToFlagEmoji(String code) {
  if (code.length != 2) return '🏳️';
  final base = 0x1F1E6;
  final first = code.toUpperCase().codeUnitAt(0) - 65 + base;
  final second = code.toUpperCase().codeUnitAt(1) - 65 + base;
  return String.fromCharCode(first) + String.fromCharCode(second);
}

String protocolLabel(ServerProtocol p) {
  switch (p) {
    case ServerProtocol.vmess:
      return 'VMESS';
    case ServerProtocol.vless:
      return 'VLESS';
    case ServerProtocol.trojan:
      return 'Trojan';
    case ServerProtocol.shadowsocks:
      return 'Shadowsocks';
    case ServerProtocol.clash:
      return 'Clash';
    case ServerProtocol.unknown:
      return 'نامشخص';
  }
}

class ServerCard extends StatelessWidget {
  final ServerModel server;
  final VoidCallback onTap;

  const ServerCard({super.key, required this.server, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final pingColor = AppColors.pingColor(server.pingMs);

    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Text(
                countryCodeToFlagEmoji(server.countryCode),
                style: const TextStyle(fontSize: 28),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            server.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        if (server.isOfficial) _officialBadge(context),
                        if (server.isPersonal) _personalBadge(context),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        _statusDot(server.isOnline),
                        const SizedBox(width: 6),
                        Text(
                          protocolLabel(server.protocol),
                          style: TextStyle(
                            fontSize: 12,
                            color: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.color
                                ?.withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: pingColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  server.pingMs > 0 ? '${server.pingMs}ms' : '—',
                  style: TextStyle(
                    color: pingColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _statusDot(bool online) => Container(
        width: 8,
        height: 8,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: online ? AppColors.success : Colors.grey,
        ),
      );

  Widget _officialBadge(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        decoration: BoxDecoration(
          color: AppColors.secondary.withOpacity(0.15),
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(
          'سرور اختصاصی',
          style: TextStyle(fontSize: 10, color: AppColors.secondary),
        ),
      );

  Widget _personalBadge(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        decoration: BoxDecoration(
          color: AppColors.accent.withOpacity(0.15),
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(
          'سرور شخصی',
          style: TextStyle(fontSize: 10, color: AppColors.accent),
        ),
      );
}
