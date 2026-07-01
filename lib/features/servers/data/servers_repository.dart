import 'package:hive_flutter/hive_flutter.dart';
import '../domain/models/server_model.dart';
import 'servers_api_service.dart';

const String kOfficialBoxName = 'official_servers_box';
const String kPersonalBoxName = 'personal_servers_box';

/// Repository لایه‌ی data برای مدیریت سرورهای اختصاصی (کش شده از API)
/// و سرورهای شخصی (اضافه‌شده توسط کاربر) - مطابق Clean Architecture
class ServersRepository {
  ServersRepository({ServersApiService? apiService})
      : _api = apiService ?? ServersApiService();

  final ServersApiService _api;

  Box<ServerModel> get _officialBox =>
      Hive.box<ServerModel>(kOfficialBoxName);
  Box<ServerModel> get _personalBox =>
      Hive.box<ServerModel>(kPersonalBoxName);

  /// دریافت لیست سرورهای اختصاصی از API و ذخیره در کش محلی.
  /// در صورت عدم دسترسی به اینترنت، از کش آخرین داده استفاده می‌شود.
  Future<List<ServerModel>> getOfficialServers(
      {bool forceRefresh = false}) async {
    if (!forceRefresh && _officialBox.isNotEmpty) {
      // ابتدا کش را برمی‌گردانیم؛ فراخوان می‌تواند بعداً refresh کند
    }
    try {
      final servers = await _api.fetchOfficialServers();
      await _officialBox.clear();
      for (final s in servers) {
        await _officialBox.put(s.id, s);
      }
      return servers;
    } catch (_) {
      // آفلاین یا خطای شبکه: بازگرداندن آخرین داده ذخیره‌شده
      return _officialBox.values.toList();
    }
  }

  List<ServerModel> getCachedOfficialServers() => _officialBox.values.toList();

  bool get hasCachedOfficialServers => _officialBox.isNotEmpty;

  // ---------------- سرورهای شخصی کاربر ----------------

  List<ServerModel> getPersonalServers() => _personalBox.values.toList();

  Future<void> addPersonalServer(ServerModel server) async {
    await _personalBox.put(server.id, server);
  }

  Future<void> updatePersonalServer(ServerModel server) async {
    await _personalBox.put(server.id, server);
  }

  Future<void> deletePersonalServer(String id) async {
    await _personalBox.delete(id);
  }

  Future<void> updatePing(String id, int pingMs, {required bool official}) async {
    final box = official ? _officialBox : _personalBox;
    final server = box.get(id);
    if (server != null) {
      server.pingMs = pingMs;
      server.isOnline = pingMs > 0;
      await server.save();
    }
  }
}
