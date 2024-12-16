class Pdf {
  String url;

  Pdf({required this.url});

  factory Pdf.fromJson(Map<String, dynamic> json) {
    return Pdf(url: json['url']);
  }
}
