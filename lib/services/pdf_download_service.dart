import 'dart:io';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:http/http.dart' show get;
import 'package:kaliman_reader_app/repositories/export_repository.dart';
import 'package:path_provider/path_provider.dart';

class PdfDownloadService {
  static Future<String> downloadPdf(String prefix) async {
    var cleanPrefix = prefix.replaceAll('/', '-');
    var pdf = await PdfRepository.getPdf(prefix);
    var response = await get(Uri.parse(pdf.url));
    var downloadsDirectoryPath = Platform.isAndroid
        ? '/storage/emulated/0/Download'
        : await getDownloadsDirectory();
    var file = File('$downloadsDirectoryPath/$cleanPrefix.pdf');
    var folderPath = '$downloadsDirectoryPath';
    await Directory(folderPath).create(recursive: true);
    file = await file.writeAsBytes(response.bodyBytes, mode: FileMode.write);
    FirebaseAnalytics.instance.logEvent(
      name: 'download_pdf',
      parameters: {
        'prefix': prefix,
        'path': file.path,
      },
    );
    return file.path;
  }
}
