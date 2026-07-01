import 'dart:async';
import 'package:flutter_v2ray/flutter_v2ray.dart';
import '../../servers/domain/models/server_model.dart';

enum VpnConnectionState { disconnected, connecting, connected, error }

class VpnLiveStatus {
  final VpnConnectionState state;
  final String duration; // مثل "00:12:45"
  final String uploadSpeed;
  final String downloadSpeed;
  final String totalUpload;
  final String totalDownload;

  const VpnLiveStatus({
    this.state = VpnConnectionState.disconnected,
    this.duration = '00:00:00',
    this.uploadSpeed = '0 KB/s',
    this.downloadSpeed = '0 KB/s',
    this.totalUpload = '0 MB',
    this.totalDownload = '0 MB',
  });
}

/// لایه‌ی دامنه که مستقیماً روی flutter_v2ray (Xray Core + Android VpnService)
/// کار می‌کند. این کلاس مسئول برقراری تونل واقعی VPN است، نه شبیه‌سازی.
///
/// معماری VpnService/AIDL این پکیج از الگوی پروژه‌ی اپن‌سورس v2rayNG
/// (github.com/2dust/v2rayNG) الهام گرفته شده است.
class VpnCoreService {
  VpnCoreService._internal();
  static final VpnCoreService instance = VpnCoreService._internal();

  late final FlutterV2ray _v2ray = FlutterV2ray(
    onStatusChanged: (status) {
      _statusController.add(
        VpnLiveStatus(
          state: _mapState(status.state),
          duration: status.duration,
          uploadSpeed: status.uploadSpeed,
          downloadSpeed: status.downloadSpeed,
          totalUpload: status.upload,
          totalDownload: status.download,
        ),
      );
    },
  );

  final _statusController = StreamController<VpnLiveStatus>.broadcast();
  Stream<VpnLiveStatus> get statusStream => _statusController.stream;

  bool _initialized = false;

  Future<void> _ensureInitialized() async {
    if (_initialized) return;
    await _v2ray.initializeV2Ray();
    _initialized = true;
  }

  VpnConnectionState _mapState(String rawState) {
    switch (rawState.toUpperCase()) {
      case 'CONNECTED':
        return VpnConnectionState.connected;
      case 'CONNECTING':
        return VpnConnectionState.connecting;
      default:
        return VpnConnectionState.disconnected;
    }
  }

  /// درخواست مجوز VPN از سیستم‌عامل (لازم پیش از اولین اتصال)
  Future<bool> requestPermission() async {
    return await _v2ray.requestPermission();
  }

  /// شروع اتصال واقعی به سرور بر اساس لینک کانفیگ خام (vmess/vless/trojan/ss)
  Future<void> connect(ServerModel server) async {
    await _ensureInitialized();

    final hasPermission = await requestPermission();
    if (!hasPermission) {
      throw VpnException('اجازه‌ی دسترسی VPN داده نشد.');
    }

    try {
      final parsed = V2RayURL.parseFromURL(server.rawConfig);
      await _v2ray.startV2Ray(
        remark: server.name,
        config: parsed.getFullConfiguration(),
        proxyOnly: false,
        bypassSubnets: null,
      );
    } catch (e) {
      throw VpnException('اتصال ناموفق بود: ${e.toString()}');
    }
  }

  Future<void> disconnect() async {
    await _v2ray.stopV2Ray();
  }

  Future<int> getServerDelay(ServerModel server) async {
    await _ensureInitialized();
    try {
      final parsed = V2RayURL.parseFromURL(server.rawConfig);
      final delay = await _v2ray.getServerDelay(
        config: parsed.getFullConfiguration(),
      );
      return delay;
    } catch (_) {
      return -1;
    }
  }

  void dispose() {
    _statusController.close();
  }
}

class VpnException implements Exception {
  final String message;
  VpnException(this.message);
  @override
  String toString() => message;
}
