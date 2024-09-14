import 'dart:io';

import 'package:http/http.dart' show get;
import 'package:kaliman_reader_app/repositories/object_repository.dart';
import 'package:path_provider/path_provider.dart';

class ImageDownloadService {
  static Future<String> downloadImage(
      String key, String prefix, int index) async {
    var object = await ObjectRepository.getObject(key);
    var response = await get(Uri.parse(object.url));
    var downloadsDirectoryPath = Platform.isAndroid
        ? '/storage/emulated/0/Download/'
        : await getDownloadsDirectory();
    var file = File('$downloadsDirectoryPath/$key');
    var folderPath = '$downloadsDirectoryPath/$prefix';
    await Directory(folderPath).create(recursive: true);
    file = await file.writeAsBytes(response.bodyBytes, mode: FileMode.write);
    return file.path;
  }
}
