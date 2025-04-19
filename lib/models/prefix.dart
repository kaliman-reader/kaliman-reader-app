class Prefix {
  String prefix;

  Prefix({required this.prefix});

  factory Prefix.fromJson(Map<String, dynamic> json) {
    if (json['Prefix'] == null) {
      throw Exception("No prefix");
    }
    return Prefix(prefix: json['Prefix']);
  }

  Map<String, dynamic> toJson() {
    return {
      'Prefix': prefix,
    };
  }
}
