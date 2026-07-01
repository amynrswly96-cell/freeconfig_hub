import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../vpn/domain/vpn_service.dart';

/// دکمه‌ی بزرگ اتصال - بزرگ‌ترین عنصر صفحه اصلی
/// «اینترنت آزاد برای همه یا هیچ‌کس»
class ConnectButton extends StatefulWidget {
  final VpnConnectionState state;
  final VoidCallback onTap;

  const ConnectButton({
    super.key,
    required this.state,
    required this.onTap,
  });

  @override
  State<ConnectButton> createState() => _ConnectButtonState();
}

class _ConnectButtonState extends State<ConnectButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _glowController = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 2),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _glowController.dispose();
    super.dispose();
  }

  String get _label {
    switch (widget.state) {
      case VpnConnectionState.connected:
        return 'متصل شد • اینترنت آزاد برای همه یا هیچ‌کس';
      case VpnConnectionState.connecting:
        return 'در حال اتصال...';
      case VpnConnectionState.error:
        return 'خطا در اتصال • تلاش مجدد';
      case VpnConnectionState.disconnected:
        return 'اینترنت آزاد برای همه یا هیچ‌کس';
    }
  }

  IconData get _icon {
    switch (widget.state) {
      case VpnConnectionState.connected:
        return Icons.shield_rounded;
      case VpnConnectionState.connecting:
        return Icons.sync_rounded;
      case VpnConnectionState.error:
        return Icons.error_outline_rounded;
      case VpnConnectionState.disconnected:
        return Icons.power_settings_new_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isConnecting = widget.state == VpnConnectionState.connecting;

    return AnimatedBuilder(
      animation: _glowController,
      builder: (context, child) {
        final glow = 0.25 + (_glowController.value * 0.25);
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(glow),
                blurRadius: 30,
                spreadRadius: 4,
              ),
              BoxShadow(
                color: AppColors.secondary.withOpacity(glow * 0.8),
                blurRadius: 40,
                spreadRadius: 2,
              ),
            ],
          ),
          child: child,
        );
      },
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(999),
        child: InkWell(
          borderRadius: BorderRadius.circular(999),
          onTap: isConnecting ? null : widget.onTap,
          splashColor: Colors.white24,
          child: Ink(
            height: 68,
            decoration: BoxDecoration(
              gradient: AppColors.connectButtonGradient,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (isConnecting)
                  const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: Colors.white,
                    ),
                  )
                else
                  Icon(_icon, color: Colors.white, size: 26),
                const SizedBox(width: 12),
                Flexible(
                  child: Text(
                    _label,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
