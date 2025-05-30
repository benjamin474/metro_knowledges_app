class MetroData {
  final int id;
  final String year;
  final String month;
  final String url;

  MetroData({
    required this.id,
    required this.year,
    required this.month,
    required this.url,
  });

  factory MetroData.fromJson(Map<String, dynamic> json) {
    return MetroData(
      id: json['_id'] ?? json['seqno'] ?? 0,
      year: json['西元年'].toString(),
      month: json['月'].toString().padLeft(2, '0'),
      url: json['url'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'year': year,
      'month': month,
      'url': url,
    };
  }
}
