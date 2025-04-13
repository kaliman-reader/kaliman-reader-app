import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:kaliman_reader_app/common/constants.dart';
import 'package:kaliman_reader_app/models/prefix.dart';

class PrefixRepository {
  static Future<List<Prefix>> getPrefixes(String prefix) async {
    var url = '$apiUrl/prefixes/?prefix=$prefix';
    http.Response response = await http.get(Uri.parse(url));
    List<dynamic> prefixes = jsonDecode(
      utf8.decode(response.bodyBytes, allowMalformed: true),
    );
    return prefixes.map((e) => Prefix.fromJson(e)).toList();
  }
}
