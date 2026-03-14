class BaseUrl {
  static const String _dev  = 'http://86.106.181.31:3002';
  static const String _prod = 'https://api.secure.innovimpactdev.cloud/api';

  
  static const String currentBaseUrl = _prod;

  // ========== AUTH ENDPOINTS ==========
  static const String registerStep1         = '$currentBaseUrl/auth/register/client/step1';
  static const String verifyRegistrationOtp = '$currentBaseUrl/auth/register/client/verify-otp';
  static const String login                 = '$currentBaseUrl/auth/login';
  static const String resendOtp             = '$currentBaseUrl/auth/resend-otp';
  static const String logout                = '$currentBaseUrl/auth/logout';
  static const String refreshToken          = '$currentBaseUrl/auth/refresh';
  static const String setupPassword         = '$currentBaseUrl/auth/setup-password';

  // ========== USER ENDPOINTS ==========
  static const String getUserProfile = '$currentBaseUrl/user/profile';
  static const String updateProfile  = '$currentBaseUrl/user/update';

  // ========== CLIENT ENDPOINTS ==========
  static const String getClientDemandes = '$currentBaseUrl/client/demandes';
  static const String createDemande     = '$currentBaseUrl/client/demandes/create';
  static const String getDemandeDetails = '$currentBaseUrl/client/demandes';
  static const String getBeneficiaires  = '$currentBaseUrl/client/beneficiaires';
  static const String getDocuments      = '$currentBaseUrl/client/documents';
  static const String getBanques        = '$currentBaseUrl/client/banques';

  // ========== HOME ENDPOINTS ==========
  static const String getHomeData = '$currentBaseUrl/home';

  static String buildUrl(String endpoint, {Map<String, dynamic>? params}) {
    if (params == null || params.isEmpty) return endpoint;
    final queryString = params.entries.map((e) => '${e.key}=${e.value}').join('&');
    return '$endpoint?$queryString';
  }

  static String buildUrlWithId(String endpoint, String id) => '$endpoint/$id';
}