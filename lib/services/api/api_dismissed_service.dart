import '../dismissed_service.dart';
import 'api_http_client.dart';

class ApiDismissedService implements DismissedService {
  ApiDismissedService(this._client);

  final ApiHttpClient _client;

  @override
  Future<List<String>> listDismissed(String weddingId) async {
    final list = await _client.getList('/weddings/$weddingId/dismissed');
    return list.cast<String>().toList(growable: false);
  }

  @override
  Future<void> dismiss(String weddingId, String vendorId) async {
    await _client.postNoContent(
      '/weddings/$weddingId/dismissed',
      {'vendorId': vendorId},
    );
  }
}
