class Object {
  String url;

  Object({required this.url});

  factory Object.fromJson(Map<String, dynamic> json) {
    return Object(url: json['url']);
  }
}
