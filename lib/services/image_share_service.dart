import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:http/http.dart';
import 'package:kaliman_reader_app/repositories/object_repository.dart';
import 'package:share_plus/share_plus.dart';

class ImageShareService {
  static Future<void> shareImage(String key) async {
    var object = await ObjectRepository.getObject(key);
    var response = await get(Uri.parse(object.url));
    FirebaseAnalytics.instance.logEvent(
      name: 'download_page',
      parameters: {
        'key': key,
      },
    );
    await Share.shareXFiles(
      [XFile.fromData(response.bodyBytes)],
      text: '¡Mira esta increíble página de Kaliman!',
      fileNameOverrides: ['kaliman.jpeg'],
    );
  }
}
