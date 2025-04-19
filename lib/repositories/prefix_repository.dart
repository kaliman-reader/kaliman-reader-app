import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:kaliman_reader_app/common/constants.dart';
import 'package:kaliman_reader_app/models/prefix.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PrefixRepository {
  static const String _prefixesCacheKey = 'prefixes_cache_';

  static Future<List<Prefix>> getPrefixes(String prefix) async {
    // Try to get prefixes from SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    final cachedData = prefs.getString('$_prefixesCacheKey$prefix');

    if (cachedData != null) {
      try {
        final List<dynamic> decodedData = json.decode(cachedData);
        return decodedData.map((e) => Prefix.fromJson(e)).toList();
      } catch (e) {
        // If there's an error parsing the cached data, remove it and continue
        await removeFromCache(prefix);
        // Fall through to fetching from network
      }
    }

    // If not in cache or error parsing, fetch from network
    var url = '$apiUrl/prefixes/?prefix=$prefix';
    http.Response response = await http.get(Uri.parse(url));
    List<dynamic> prefixes = jsonDecode(
      utf8.decode(response.bodyBytes, allowMalformed: true),
    );

    // Convert to list of Prefix objects
    final prefixList = prefixes.map((e) => Prefix.fromJson(e)).toList();

    // Store in SharedPreferences for future use
    await _saveToCache(prefix, prefixList);

    return prefixList;
  }

  // Helper method to save prefixes to SharedPreferences
  static Future<void> _saveToCache(
      String prefix, List<Prefix> prefixList) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonData = json.encode(prefixList.map((e) => e.toJson()).toList());
    await prefs.setString('$_prefixesCacheKey$prefix', jsonData);
  }

  // Method to clear the entire cache
  static Future<void> clearCache() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys();

    for (final key in keys) {
      if (key.startsWith(_prefixesCacheKey)) {
        await prefs.remove(key);
      }
    }
  }

  // Method to remove a specific prefix from cache
  static Future<void> removeFromCache(String prefix) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('$_prefixesCacheKey$prefix');
  }
}
