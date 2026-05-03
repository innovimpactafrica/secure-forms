import 'package:http/http.dart' as http;
import 'package:quick_forms/core/utils/authenticated_http_client.dart';

/// Client HTTP singleton partagé entre tous les services.
/// Intercepte automatiquement les 401 et rafraîchit le token.
class HttpClientSingleton {
  HttpClientSingleton._();
  static http.Client get instance => AuthenticatedHttpClient.instance;
}
