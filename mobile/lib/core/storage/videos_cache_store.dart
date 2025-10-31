import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class VideosCacheStore {
  static const String _key = 'videos_cache_latest_v1';
  static const String _tsKey = 'videos_cache_latest_ts_v1';

  // default TTL: 30 minutes
  static const Duration defaultTtl = Duration(minutes: 30);

  static Future<List<dynamic>> getLatest({Duration? maxAge}) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null || raw.isEmpty) return [];
    final ts = prefs.getInt(_tsKey);
    if (ts != null) {
      final age = DateTime.now().millisecondsSinceEpoch - ts;
      final ttlMs = (maxAge ?? defaultTtl).inMilliseconds;
      if (age > ttlMs) return [];
    }
    try {
      final data = jsonDecode(raw);
      if (data is List) return data.cast<dynamic>();
      return [];
    } catch (_) {
      return [];
    }
  }

  static Future<void> saveLatest(List<dynamic> videos) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jsonEncode(videos));
    await prefs.setInt(_tsKey, DateTime.now().millisecondsSinceEpoch);
  }
}


