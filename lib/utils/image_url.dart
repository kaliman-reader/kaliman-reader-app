import 'package:kaliman_reader_app/common/constants.dart';

String getImageUrl(String key) {
  return '$apiUrl/images/?key=$key';
}

String getCoverUrl(String prefix) {
  return '$apiUrl/covers/?prefix=$prefix';
}
