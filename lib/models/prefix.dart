class Prefix {
  String prefix;

  Prefix({required this.prefix});

  factory Prefix.fromJson(Map<String, dynamic> json) {
    return Prefix(prefix: json['Prefix']);
  }
}
