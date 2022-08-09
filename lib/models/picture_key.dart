class PictureKey {
  String key;
  int size;

  PictureKey({required this.key, required this.size});

  factory PictureKey.fromJson(Map<String, dynamic> json) {
    return PictureKey(key: json["Key"], size: json["Size"]);
  }
}
