import 'dart:convert';

import 'package:kaliman_reader_app/common/constants.dart';
import 'package:kaliman_reader_app/models/picture_key.dart';
import 'package:http/http.dart' as http;

class ObjectKeyRepository {
  static Future<List<PictureKey>> getKeys(String prefix) async {
    var url = '$apiUrl/prefixes/?prefix=$prefix';
    http.Response response = await http.get(Uri.parse(url));
    List<dynamic> prefixes = jsonDecode(response.body);
    return prefixes.map((e) => PictureKey.fromJson(e)).toList();
  }
}
