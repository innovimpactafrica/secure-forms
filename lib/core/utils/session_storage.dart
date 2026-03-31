import 'package:shared_preferences/shared_preferences.dart';
import 'user_session.dart';

class SessionStorage {
  SessionStorage._();
  static final SessionStorage instance = SessionStorage._();

  static const String _keyToken        = 'session_access_token';
  static const String _keyRefreshToken  = 'session_refresh_token';
  static const String _keyName          = 'session_name';
  static const String _keyEmail         = 'session_email';
  static const String _keyRole          = 'session_role';
  static const String _keyUserId        = 'session_user_id';
  static const String _keyProfileBannerShown = 'profile_banner_shown_'; // + userId

  Future<void> save({
    required String token,
    String refreshToken = '',
    String name         = '',
    String email        = '',
    String role         = '',
    String userId       = '',
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyToken,       token);
    await prefs.setString(_keyRefreshToken, refreshToken);
    await prefs.setString(_keyName,        name);
    await prefs.setString(_keyEmail,       email);
    await prefs.setString(_keyRole,        role);
    await prefs.setString(_keyUserId,      userId);
  }

  Future<bool> restore() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(_keyToken) ?? '';
    if (token.isEmpty) return false;
    UserSession.instance.accessToken  = token;
    UserSession.instance.refreshToken = prefs.getString(_keyRefreshToken) ?? '';
    UserSession.instance.name         = prefs.getString(_keyName)   ?? '';
    UserSession.instance.email        = prefs.getString(_keyEmail)  ?? '';
    UserSession.instance.role         = prefs.getString(_keyRole)   ?? '';
    UserSession.instance.userId       = prefs.getString(_keyUserId) ?? '';
    return true;
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyToken);
    await prefs.remove(_keyRefreshToken);
    await prefs.remove(_keyName);
    await prefs.remove(_keyEmail);
    await prefs.remove(_keyRole);
    await prefs.remove(_keyUserId);
    UserSession.instance.clear();
  }

  /// Retourne true si le banner "profil 100%" a déjà été affiché pour cet utilisateur
  static Future<bool> hasShownProfileCompleteBanner(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('$_keyProfileBannerShown$userId') ?? false;
  }

  /// Marque le banner comme affiché pour cet utilisateur
  static Future<void> markProfileCompleteBannerShown(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('$_keyProfileBannerShown$userId', true);
  }

  /// Réinitialise le banner (quand la complétion redescend sous 100)
  static Future<void> resetProfileCompleteBanner(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('$_keyProfileBannerShown$userId');
  }
}
