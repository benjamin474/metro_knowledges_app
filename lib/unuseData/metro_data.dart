class MetroData {
  final int id;
  final String item;
  final String year;
  final String month;
  final String url;

  MetroData({
    required this.id,
    required this.item,
    required this.year,
    required this.month,
    required this.url,
  });

  factory MetroData.fromJson(Map<String, dynamic> json) {
    return MetroData(
      id: json['_id'],
      item: json['項目'],
      year: json['西元年'],
      month: json['月'],
      url: json['url'],
    );
  }
}
