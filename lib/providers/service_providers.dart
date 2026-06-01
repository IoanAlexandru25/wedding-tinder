import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

import '../core/config/api_config.dart';
import '../services/api/api_dismissed_service.dart';
import '../services/api/api_favorites_service.dart';
import '../services/api/api_final_selections_service.dart';
import '../services/api/api_http_client.dart';
import '../services/api/api_user_service.dart';
import '../services/api/api_wedding_service.dart';
import '../services/dismissed_service.dart';
import '../services/favorites_service.dart';
import '../services/final_selections_service.dart';
import '../services/mock/mock_dismissed_service.dart';
import '../services/mock/mock_favorites_service.dart';
import '../services/mock/mock_final_selections_service.dart';
import '../services/mock/mock_user_service.dart';
import '../services/mock/mock_wedding_service.dart';
import '../services/user_service.dart';
import '../services/wedding_service.dart';

// Shared HTTP client — a single connection pool for the whole app.
final httpClientProvider = Provider<http.Client>((ref) {
  final client = http.Client();
  ref.onDispose(client.close);
  return client;
});

// ApiHttpClient adds auth token + error mapping on top of the raw client.
final _apiHttpClientProvider = Provider<ApiHttpClient>((ref) {
  return ApiHttpClient(
    ref.watch(httpClientProvider),
    () async => fb_auth.FirebaseAuth.instance.currentUser?.getIdToken(),
  );
});

final weddingServiceProvider = Provider<WeddingService>((ref) {
  if (kUseMock) return MockWeddingService();
  return ApiWeddingService(ref.watch(_apiHttpClientProvider));
});

final userServiceProvider = Provider<UserService>((ref) {
  if (kUseMock) return MockUserService();
  return ApiUserService(ref.watch(_apiHttpClientProvider));
});

final favoritesServiceProvider = Provider<FavoritesService>((ref) {
  if (kUseMock) return MockFavoritesService();
  return ApiFavoritesService(ref.watch(_apiHttpClientProvider));
});

final finalSelectionsServiceProvider = Provider<FinalSelectionsService>((ref) {
  if (kUseMock) return MockFinalSelectionsService();
  return ApiFinalSelectionsService(ref.watch(_apiHttpClientProvider));
});

final dismissedServiceProvider = Provider<DismissedService>((ref) {
  if (kUseMock) return MockDismissedService();
  return ApiDismissedService(ref.watch(_apiHttpClientProvider));
});
