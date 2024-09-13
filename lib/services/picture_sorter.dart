import '../models/picture_key.dart';

class PictureWithLastKey extends PictureKey {
  final String lastKey;
  PictureWithLastKey({
    required this.lastKey,
    required super.key,
    required super.size,
  });
}

class PictureKeySorter {
  static List<PictureKey> sort(List<PictureKey> pictureKeys) {
    var picturesWithLastKey = pictureKeys
        .map(
          (pictureKey) => PictureWithLastKey(
            lastKey: pictureKey.key.split('/').last,
            key: pictureKey.key,
            size: pictureKey.size,
          ),
        )
        .toList();
    picturesWithLastKey.sort((a, b) {
      final regex = RegExp(r"(\d+)");
      final aint = int.parse(regex.stringMatch(a.lastKey)!);
      final bint = int.parse(regex.stringMatch(b.lastKey)!);
      return aint - bint;
    });
    return picturesWithLastKey
        .map((e) => PictureKey(key: e.key, size: e.size))
        .toList();
  }
}
