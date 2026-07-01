import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../data/servers_repository.dart';
import '../domain/models/server_model.dart';

final serversRepositoryProvider = Provider<ServersRepository>(
  (ref) => ServersRepository(),
);

/// لیست سرورهای اختصاصی برنامه (از API + کش)
final officialServersProvider =
    FutureProvider.autoDispose<List<ServerModel>>((ref) async {
  final repo = ref.watch(serversRepositoryProvider);
  return repo.getOfficialServers();
});

/// لیست سرورهای شخصی کاربر (Hive محلی، همگام)
final personalServersProvider =
    StateNotifierProvider<PersonalServersNotifier, List<ServerModel>>(
  (ref) => PersonalServersNotifier(ref.watch(serversRepositoryProvider)),
);

class PersonalServersNotifier extends StateNotifier<List<ServerModel>> {
  PersonalServersNotifier(this._repo) : super(_repo.getPersonalServers());

  final ServersRepository _repo;
  final _uuid = const Uuid();

  Future<void> addFromLink(String link, {String? name, String? country}) async {
    final protocol = ServerModel.detectProtocolFromLink(link);
    final server = ServerModel(
      id: _uuid.v4(),
      name: name?.trim().isNotEmpty == true ? name!.trim() : 'سرور شخصی',
      countryCode: country?.trim().isNotEmpty == true ? country!.trim() : 'UN',
      protocol: protocol,
      source: ServerSource.personal,
      rawConfig: link.trim(),
    );
    await _repo.addPersonalServer(server);
    state = _repo.getPersonalServers();
  }

  Future<void> update(ServerModel server) async {
    await _repo.updatePersonalServer(server);
    state = _repo.getPersonalServers();
  }

  Future<void> delete(String id) async {
    await _repo.deletePersonalServer(id);
    state = _repo.getPersonalServers();
  }

  Future<void> refreshPing(ServerModel server) async {
    // پیاده‌سازی واقعی تست پینگ از طریق VpnCoreService.getServerDelay انجام می‌شود
    // (در لایه presentation صدا زده می‌شود تا وابستگی چرخه‌ای ایجاد نشود)
  }
}

/// دسته‌بندی انتخاب‌شده در صفحه اصلی
final selectedCategoryProvider = StateProvider<String>((ref) => 'همه');

const List<String> kCategories = [
  'همه',
  'پرسرعت',
  'ایران',
  'اروپا',
  'آمریکا',
  'آسیا',
  'V2Ray',
  'VLESS',
  'VMESS',
  'Trojan',
  'Clash',
];
