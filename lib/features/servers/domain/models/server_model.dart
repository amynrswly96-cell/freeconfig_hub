import 'package:hive/hive.dart';

part 'server_model.g.dart';

/// نوع پروتکل کانفیگ
@HiveType(typeId: 1)
enum ServerProtocol {
  @HiveField(0)
  vmess,
  @HiveField(1)
  vless,
  @HiveField(2)
  trojan,
  @HiveField(3)
  shadowsocks,
  @HiveField(4)
  clash,
  @HiveField(5)
  unknown,
}

/// منشأ سرور: اختصاصی برنامه (از API) یا شخصی کاربر
@HiveType(typeId: 2)
enum ServerSource {
  @HiveField(0)
  official, // سرور اختصاصی - محافظت‌شده، بدون کپی/اشتراک‌گذاری
  @HiveField(1)
  personal, // سرور شخصی کاربر - دسترسی کامل
}

@HiveType(typeId: 0)
class ServerModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  String countryCode; // مثل IR, DE, US برای نمایش فلگ

  @HiveField(3)
  ServerProtocol protocol;

  @HiveField(4)
  ServerSource source;

  /// لینک کامل کانفیگ (vmess://, vless://, ...).
  /// برای سرورهای official این مقدار هرگز مستقیم در UI نمایش داده نمی‌شود.
  @HiveField(5)
  String rawConfig;

  @HiveField(6)
  int pingMs; // -1 یعنی تست‌نشده

  @HiveField(7)
  bool isOnline;

  @HiveField(8)
  List<String> tags; // پرسرعت، ایران، اروپا، ...

  @HiveField(9)
  DateTime createdAt;

  ServerModel({
    required this.id,
    required this.name,
    required this.countryCode,
    required this.protocol,
    required this.source,
    required this.rawConfig,
    this.pingMs = -1,
    this.isOnline = false,
    this.tags = const [],
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  bool get isOfficial => source == ServerSource.official;
  bool get isPersonal => source == ServerSource.personal;

  factory ServerModel.fromJson(Map<String, dynamic> json) {
    return ServerModel(
      id: json['id'] as String,
      name: json['name'] as String,
      countryCode: json['country_code'] as String? ?? 'UN',
      protocol: _protocolFromString(json['protocol'] as String? ?? ''),
      source: ServerSource.official,
      rawConfig: json['config'] as String? ?? '',
      pingMs: json['ping'] as int? ?? -1,
      isOnline: json['is_online'] as bool? ?? true,
      tags: (json['tags'] as List?)?.map((e) => e.toString()).toList() ?? [],
    );
  }

  static ServerProtocol _protocolFromString(String value) {
    switch (value.toLowerCase()) {
      case 'vmess':
        return ServerProtocol.vmess;
      case 'vless':
        return ServerProtocol.vless;
      case 'trojan':
        return ServerProtocol.trojan;
      case 'shadowsocks':
      case 'ss':
        return ServerProtocol.shadowsocks;
      case 'clash':
        return ServerProtocol.clash;
      default:
        return ServerProtocol.unknown;
    }
  }

  /// تشخیص خودکار نوع پروتکل از روی لینک کانفیگ (برای افزودن دستی)
  static ServerProtocol detectProtocolFromLink(String link) {
    final trimmed = link.trim().toLowerCase();
    if (trimmed.startsWith('vmess://')) return ServerProtocol.vmess;
    if (trimmed.startsWith('vless://')) return ServerProtocol.vless;
    if (trimmed.startsWith('trojan://')) return ServerProtocol.trojan;
    if (trimmed.startsWith('ss://')) return ServerProtocol.shadowsocks;
    if (trimmed.contains('proxies:') || trimmed.contains('clash')) {
      return ServerProtocol.clash;
    }
    return ServerProtocol.unknown;
  }
}
