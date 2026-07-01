import 'package:dio/dio.dart';
import '../domain/models/server_model.dart';

/// آدرس API اختصاصی برنامه - این مقدار را با آدرس واقعی خود جایگزین کنید
const String kServersApiBaseUrl = 'https://your-api.com';

/// ساختار JSON مورد انتظار از /configs:
/// {
///   "servers": [
///     {
///       "id": "srv-001",
///       "name": "Seychelles - سریع",
///       "country_code": "SC",
///       "protocol": "vless",
///       "config": "vless://...",
///       "ping": 120,
///       "is_online": true,
///       "tags": ["پرسرعت", "آسیا"]
///     }
///   ]
/// }
class ServersApiService {
  ServersApiService({Dio? dio})
      : _dio = dio ??
            Dio(
              BaseOptions(
                baseUrl: kServersApiBaseUrl,
                connectTimeout: const Duration(seconds: 8),
                receiveTimeout: const Duration(seconds: 8),
              ),
            );

  final Dio _dio;

  Future<List<ServerModel>> fetchOfficialServers() async {
    final response = await _dio.get('/configs');
    final data = response.data;
    final List<dynamic> list = data is Map ? (data['servers'] ?? []) : data;
    return list
        .map((e) => ServerModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
