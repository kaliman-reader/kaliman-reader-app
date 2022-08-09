import 'package:kaliman_reader_app/models/picture_key.dart';
import 'package:kaliman_reader_app/services/picture_sorter.dart';
import 'package:test/expect.dart';
import 'package:test/scaffolding.dart';

void main() {
  test('PictureSorter', () {
    final List<PictureKey> pictureKeys = [
      PictureKey(key: 'La Bruja Blanca/500-501/1.jpg', size: 1000),
      PictureKey(key: 'La Bruja Blanca/500-501/17.jpg', size: 1000),
      PictureKey(key: 'La Bruja Blanca/500-501/10.jpg', size: 1000),
      PictureKey(key: 'La Bruja Blanca/500-501/11.jpg', size: 1000),
      PictureKey(key: 'La Bruja Blanca/500-501/100.jpg', size: 1000),
    ];
    final List<PictureKey> sortedPictureKeys =
        PictureKeySorter.sort(pictureKeys);
    expect(sortedPictureKeys[0].key, 'La Bruja Blanca/500-501/1.jpg');
    expect(sortedPictureKeys[1].key, 'La Bruja Blanca/500-501/10.jpg');
    expect(sortedPictureKeys[2].key, 'La Bruja Blanca/500-501/11.jpg');
    expect(sortedPictureKeys[3].key, 'La Bruja Blanca/500-501/17.jpg');
    expect(sortedPictureKeys[4].key, 'La Bruja Blanca/500-501/100.jpg');
  });
}
