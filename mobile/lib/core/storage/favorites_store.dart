import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class FavoriteItem {
  final String videoId;
  final String title;
  final String? thumbnailUrl;

  const FavoriteItem({required this.videoId, required this.title, this.thumbnailUrl});

  Map<String, dynamic> toJson() => {
        'videoId': videoId,
        'title': title,
        'thumbnailUrl': thumbnailUrl,
      };

  factory FavoriteItem.fromJson(Map<String, dynamic> json) => FavoriteItem(
        videoId: json['videoId']?.toString() ?? '',
        title: json['title']?.toString() ?? 'Video',
        thumbnailUrl: json['thumbnailUrl']?.toString(),
      );
}

class FavoritesStore {
  static const String _prefsKey = 'favorites_v1';

  static Future<List<FavoriteItem>> getFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_prefsKey);
    if (raw == null || raw.isEmpty) return [];
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      return list
          .whereType<Map<String, dynamic>>()
          .map((e) => FavoriteItem.fromJson(e))
          .toList(growable: false);
    } catch (_) {
      return [];
    }
  }

  static Future<void> _save(List<FavoriteItem> items) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = items.map((e) => e.toJson()).toList(growable: false);
    await prefs.setString(_prefsKey, jsonEncode(jsonList));
  }

  static Future<bool> isFavorite(String videoId) async {
    final items = await getFavorites();
    return items.any((e) => e.videoId == videoId);
  }

  static Future<void> add(FavoriteItem item) async {
    final items = await getFavorites();
    if (items.any((e) => e.videoId == item.videoId)) return;
    final updated = [...items, item];
    await _save(updated);
  }

  static Future<void> remove(String videoId) async {
    final items = await getFavorites();
    final updated = items.where((e) => e.videoId != videoId).toList(growable: false);
    await _save(updated);
  }
}


