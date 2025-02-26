import 'dart:convert';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:http/http.dart' as http;
import 'package:kaliman_reader_app/common/constants.dart';
import 'package:kaliman_reader_app/models/pdf.dart';

class PdfRepository {
  static Future<Pdf> getPdf(String prefix) async {
    final String url = '$apiUrl/pdfs/?prefix=$prefix';
    try {
      http.Response response = await http.get(Uri.parse(url));
      Map<String, dynamic> json = jsonDecode(response.body);
      return Pdf.fromJson(json);
    } catch (e) {
      FirebaseAnalytics.instance.logEvent(name: 'pdf_error', parameters: {
        'error': 'Error fetching pdf',
        'stack_trace': Error().stackTrace.toString(),
        'prefix': prefix
      });
      throw Exception('Error fetching pdf: $e');
    }
  }
}
