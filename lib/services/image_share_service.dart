import 'package:http/http.dart';
import 'package:kaliman_reader_app/repositories/object_repository.dart';
import 'package:share_plus/share_plus.dart';

class ImageShareService {
  static Future<void> shareImage(String key) async {
    var object = await ObjectRepository.getObject(key);
    var response = await get(Uri.parse(object.url));
    await Share.shareXFiles(
      [XFile.fromData(response.bodyBytes)],
      text: '¡Mira esta increíble página de Kaliman!',
      fileNameOverrides: ['kaliman.jpeg'],
    );
  }
}
