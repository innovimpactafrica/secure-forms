class BaseUrl {
  static const String _dev  = 'http://86.106.181.31:3002';
  //static const String _prod = 'https://prod-api.votreapp.com';

  
  static const String currentBaseUrl = _dev;

  // ========== AUTH ENDPOINTS ==========
  static const String registerStep1         = '$currentBaseUrl/api/auth/register/client/step1';
  static const String verifyRegistrationOtp = '$currentBaseUrl/api/auth/register/client/verify-otp';
  static const String login                 = '$currentBaseUrl/api/auth/login';
  static const String resendOtp             = '$currentBaseUrl/api/auth/resend-otp';
  static const String logout                = '$currentBaseUrl/api/auth/logout';
  static const String refreshToken          = '$currentBaseUrl/api/auth/refresh';
  static const String setupPassword         = '$currentBaseUrl/api/auth/setup-password'; // ✅

  // ========== USER ENDPOINTS ==========
  static const String getUserProfile = '$currentBaseUrl/api/user/profile';
  static const String updateProfile  = '$currentBaseUrl/api/user/update';

  // ========== CLIENT ENDPOINTS ==========
  static const String getClientDemandes = '$currentBaseUrl/api/client/demandes';
  static const String createDemande     = '$currentBaseUrl/api/client/demandes/create';
  static const String getDemandeDetails = '$currentBaseUrl/api/client/demandes';
  static const String getBeneficiaires  = '$currentBaseUrl/api/client/beneficiaires';
  static const String getDocuments      = '$currentBaseUrl/api/client/documents';
  static const String getBanques        = '$currentBaseUrl/api/client/banques';

  // ========== HOME ENDPOINTS ==========
  static const String getHomeData = '$currentBaseUrl/api/home';

  static String buildUrl(String endpoint, {Map<String, dynamic>? params}) {
    if (params == null || params.isEmpty) return endpoint;
    final queryString = params.entries.map((e) => '${e.key}=${e.value}').join('&');
    return '$endpoint?$queryString';
  }

  static String buildUrlWithId(String endpoint, String id) => '$endpoint/$id';
}