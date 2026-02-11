class BaseUrl {
  // Base URLs
  static const String baseUrl = 'https://api.votreapp.com/api';
  static const String baseUrlDev = 'https://dev-api.votreapp.com/api';
  static const String baseUrlProd = 'https://prod-api.votreapp.com/api';

  // Current environment
  static const String currentBaseUrl = baseUrlDev; // Change selon l'environnement

  // ========== AUTH ENDPOINTS ==========
  static const String login = '$currentBaseUrl/auth/login';
  static const String register = '$currentBaseUrl/auth/register';
  static const String verifyOtp = '$currentBaseUrl/auth/verify-otp';
  static const String logout = '$currentBaseUrl/auth/logout';
  static const String refreshToken = '$currentBaseUrl/auth/refresh';
  
  // ========== USER ENDPOINTS ==========
  static const String getUserProfile = '$currentBaseUrl/user/profile';
  static const String updateProfile = '$currentBaseUrl/user/update';
  
  // ========== CLIENT ENDPOINTS ==========
  static const String getClientDemandes = '$currentBaseUrl/client/demandes';
  static const String createDemande = '$currentBaseUrl/client/demandes/create';
  static const String getDemandeDetails = '$currentBaseUrl/client/demandes'; // + /{id}
  static const String getBeneficiaires = '$currentBaseUrl/client/beneficiaires';
  static const String getDocuments = '$currentBaseUrl/client/documents';
  static const String getBanques = '$currentBaseUrl/client/banques';
  
  // ========== HOME ENDPOINTS ==========
  static const String getHomeData = '$currentBaseUrl/home';
  
  // Méthode pour construire une URL avec paramètres
  static String buildUrl(String endpoint, {Map<String, dynamic>? params}) {
    if (params == null || params.isEmpty) return endpoint;
    
    final queryString = params.entries
        .map((e) => '${e.key}=${e.value}')
        .join('&');
    return '$endpoint?$queryString';
  }
  
  // Méthode pour construire une URL avec ID
  static String buildUrlWithId(String endpoint, String id) {
    return '$endpoint/$id';
  }
}