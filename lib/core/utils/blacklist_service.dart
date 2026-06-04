import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';
import 'base_url.dart';

class BlacklistService {
  static final BlacklistService _instance = BlacklistService._();
  BlacklistService._();
  static BlacklistService get instance => _instance;

  bool? _isBlacklisted;

  bool get isSubscriptionHidden => _isBlacklisted ?? false;

  Future<void> checkCurrentVersion() async {
    try {
      final info = await PackageInfo.fromPlatform();
      final version = info.version;
      debugPrint('[Blacklist] checking version=$version');

      final res = await http
          .get(Uri.parse(BaseUrl.checkBlacklist(version)))
          .timeout(const Duration(seconds: 5));

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        _isBlacklisted = data['isBlacklisted'] == true;
        debugPrint('[Blacklist] isBlacklisted=$_isBlacklisted');
      } else {
        _isBlacklisted = false;
      }
    } catch (e) {
      debugPrint('[Blacklist] error: $e');
      _isBlacklisted = false;
    }
  }
}
