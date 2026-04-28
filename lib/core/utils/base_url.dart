class BaseUrl {
  static const String _dev  = 'http://86.106.181.31:3002';
  static const String _prod = 'https://api.secure.innovimpactdev.cloud/api';
  
  static const String currentBaseUrl = _prod;
  // ========== AUTH ENDPOINTS ==========
  static const String registerStep1         = '$currentBaseUrl/auth/register/client/step1';
  static const String verifyRegistrationOtp = '$currentBaseUrl/auth/register/client/verify-otp';
  static const String login                 = '$currentBaseUrl/auth/login/client';
  static const String resendOtp             = '$currentBaseUrl/auth/resend-otp';
  static const String logout                = '$currentBaseUrl/auth/logout';
  static const String refreshToken          = '$currentBaseUrl/auth/refresh';
  static const String setupPassword         = '$currentBaseUrl/auth/setup-password';
  static const String resumeSetupRequestOtp = '$currentBaseUrl/auth/register/client/resume-setup/request-otp';
  static const String resumeSetupVerifyOtp  = '$currentBaseUrl/auth/register/client/resume-setup/verify-otp';
  static const String forgotPasswordRequestOtp = '$currentBaseUrl/auth/forget-password/request';
  static const String forgotPasswordResendOtp  = '$currentBaseUrl/auth/forget-password/resend-otp';
  static const String forgotPasswordReset      = '$currentBaseUrl/auth/forget-password/reset';
  // ========== USER ENDPOINTS ==========
  static const String getUserProfile = '$currentBaseUrl/auth/profile';
  static const String updateProfile  = '$currentBaseUrl/user/update';
  // ========== KYC - IDENTITY DOCUMENTS ==========
  static const String identityDocuments = '$currentBaseUrl/users/profile/identity-documents';
  static String identityDocumentFile(String documentId) =>
      '$currentBaseUrl/users/profile/identity-documents/$documentId/file';
  // ========== PROFILE DOCUMENTS ==========
  static const String profileDocumentTypes = '$currentBaseUrl/users/profile/document-types';
  static const String profileCompletion    = '$currentBaseUrl/users/profile/completion';
  static const String profileDocuments     = '$currentBaseUrl/users/profile/documents';
  static const String kycDocumentTypes     = '$currentBaseUrl/users/profile/identity-verification-document-types';
  static String profileDocumentFile(String documentId) =>
      '$currentBaseUrl/users/profile/documents/$documentId/file';
  static String storageFile(String objectKey) =>
      '$currentBaseUrl/storage/files/$objectKey';
  static String deleteProfileDocument(String documentId) =>
      '$currentBaseUrl/users/profile/documents/$documentId';
  static const String updateUserProfile = '$currentBaseUrl/users/me/profile';
  static const String getProfilePicture = '$currentBaseUrl/users/me/profile-picture';
  // ========== CLIENT ENDPOINTS ==========
  static const String getClientDemandes  = '$currentBaseUrl/client/demandes';
  static const String createDemande      = '$currentBaseUrl/client/demandes/create';
  static const String getDemandeDetails  = '$currentBaseUrl/client/demandes';
  static const String getBeneficiaires   = '$currentBaseUrl/client/beneficiaires';
  static const String getDocuments       = '$currentBaseUrl/client/documents';
  static const String getBanques         = '$currentBaseUrl/client/banques';
  static const String getArchives        = '$currentBaseUrl/clients/archives';
  static const String getNotifications   = '$currentBaseUrl/clients/notifications';
  static const String markNotificationsRead    = '$currentBaseUrl/clients/notifications/mark-read';
  static const String markAllNotificationsRead = '$currentBaseUrl/clients/notifications/mark-all-read';
  // ========== FCM ENDPOINTS ==========  👈 NOUVEAU
  static const String registerFcmToken   = '$currentBaseUrl/clients/fcm-token';
  // ========== DEMANDES ENDPOINTS ==========
  static const String recentRequests   = '$currentBaseUrl/clients/recent-requests';
  static const String requests         = '$currentBaseUrl/requests';
  static String requestById(String id) => '$currentBaseUrl/requests/$id';
  static String draftById(String id)   => '$currentBaseUrl/requests/draft/$id';
  static String requestPdf(String id)  => '$currentBaseUrl/requests/$id/pdf';
  static String formPdf(String id)      => '$currentBaseUrl/forms/$id/pdf';
  // ========== HOME ENDPOINTS ==========
  static const String getHomeData       = '$currentBaseUrl/home';
  static const String clientStatistics  = '$currentBaseUrl/clients/statistics';
  // ========== PKI / SIGNATURE ENDPOINTS ==========
  static String uploadToken(String requestId)     => '$currentBaseUrl/requests/$requestId/upload-token';
  static const String pkiEnsureCertificate        = '$currentBaseUrl/pki/ensure-certificate';
  static const String pkiSign                     = '$currentBaseUrl/pki/sign';
  static String pkiVerify(String requestId)       => '$currentBaseUrl/pki/verify/$requestId';
  static const String signedDocumentDeposit       = '$currentBaseUrl/clients/documents/signed';

  static String buildUrl(String endpoint, {Map<String, dynamic>? params}) {
    if (params == null || params.isEmpty) return endpoint;
    final queryString = params.entries.map((e) => '${e.key}=${e.value}').join('&');
    return '$endpoint?$queryString';
  }
  static String buildUrlWithId(String endpoint, String id) => '$endpoint/$id';
}
