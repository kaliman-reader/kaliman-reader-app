import 'package:kaliman_reader_app/repositories/object_key_repository.dart';
import 'package:kaliman_reader_app/repositories/object_repository.dart';
import 'package:kaliman_reader_app/repositories/prefix_repository.dart';

class LeadingImageSelector {
  static Future<String> getLeadingImage(bool isFinalFolder, String key) async {
    String url;
    if (isFinalFolder) {
      var imagesKeys = await ObjectKeyRepository.getKeys(key);
      url = (await ObjectRepository.getObject(imagesKeys.first.key)).url;
    } else {
      var imagesPrefixes = await PrefixRepository.getPrefixes(key);
      var imagesKeys =
          await ObjectKeyRepository.getKeys(imagesPrefixes.first.prefix);
      url = (await ObjectRepository.getObject(imagesKeys.first.key)).url;
    }
    return url;
  }
}
