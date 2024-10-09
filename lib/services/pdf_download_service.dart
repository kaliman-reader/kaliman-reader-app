import 'dart:io';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:http/http.dart' show get;
import 'package:kaliman_reader_app/repositories/object_repository.dart';
import 'package:path_provider/path_provider.dart';

class PdfDownloadService {
  static Future<String> downloadPdf(String prefix) async {
    var object = await ObjectRepository.getObject(prefix);
    var response = await get(Uri.parse(object.url));
    var downloadsDirectoryPath = Platform.isAndroid
        ? '/storage/emulated/0/Download/'
        : await getDownloadsDirectory();
    var file = File('$downloadsDirectoryPath/$prefix');
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
