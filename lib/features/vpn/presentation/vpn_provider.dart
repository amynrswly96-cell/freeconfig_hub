import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../servers/domain/models/server_model.dart';
import '../domain/vpn_service.dart';

const String kSettingsBox = 'settings_box';
const String kLastServerKey = 'last_connected_server_id';

class VpnState {
  final VpnConnectionState connectionState;
  final ServerModel? currentServer;
  final VpnLiveStatus liveStatus;
  final String? errorMessage;

  const VpnState({
    this.connectionState = VpnConnectionState.disconnected,
    this.currentServer,
    this.liveStatus = const VpnLiveStatus(),
    this.errorMessage,
  });

  VpnState copyWith({
    VpnConnectionState? connectionState,
    ServerModel? currentServer,
    VpnLiveStatus? liveStatus,
    String? errorMessage,
  }) {
    return VpnState(
      connectionState: connectionState ?? this.connectionState,
      currentServer: currentServer ?? this.currentServer,
      liveStatus: liveStatus ?? this.liveStatus,
      errorMessage: errorMessage,
    );
  }
}

class VpnNotifier extends StateNotifier<VpnState> {
  VpnNotifier() : super(const VpnState()) {
    _sub = VpnCoreService.instance.statusStream.listen((live) {
      state = state.copyWith(
        connectionState: live.state,
        liveStatus: live,
      );
    });
  }

  late final StreamSubscription<VpnLiveStatus> _sub;

  Future<void> connect(ServerModel server) async {
    state = state.copyWith(
      connectionState: VpnConnectionState.connecting,
      currentServer: server,
      errorMessage: null,
    );
    try {
      await VpnCoreService.instance.connect(server);
      Hive.box(kSettingsBox).put(kLastServerKey, server.id);
    } on VpnException catch (e) {
      state = state.copyWith(
        connectionState: VpnConnectionState.error,
        errorMessage: e.message,
      );
    } catch (e) {
      state = state.copyWith(
        connectionState: VpnConnectionState.error,
        errorMessage: 'خطای غیرمنتظره در برقراری اتصال.',
      );
    }
  }

  Future<void> disconnect() async {
    await VpnCoreService.instance.disconnect();
    state = state.copyWith(
      connectionState: VpnConnectionState.disconnected,
      errorMessage: null,
    );
  }

  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }
}

final vpnProvider = StateNotifierProvider<VpnNotifier, VpnState>(
  (ref) => VpnNotifier(),
);
