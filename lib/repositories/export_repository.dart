import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:kaliman_reader_app/common/constants.dart';
import 'package:kaliman_reader_app/models/pdf.dart';

class ObjectRepository {
  static Future<Pdf> getPdf(String prefix) async {
    final String url = '$apiUrl/pdfs/?key=$prefix';
    http.Response response = await http.get(Uri.parse(url));
    Map<String, dynamic> json = jsonDecode(response.body);
    return Pdf.fromJson(json);
  }
}
