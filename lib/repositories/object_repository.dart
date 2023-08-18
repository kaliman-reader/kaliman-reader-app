import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:kaliman_reader_app/common/constants.dart';
import 'package:kaliman_reader_app/models/object.dart';

class ObjectRepository {
  static Future<Object> getObject(String key) async {
    final String url = '$apiUrl/objects/?key=$key';
    http.Response response = await http.get(Uri.parse(url));
    Map<String, dynamic> json = jsonDecode(response.body);
    return Object.fromJson(json);
  }
}
