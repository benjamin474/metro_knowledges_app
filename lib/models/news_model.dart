class NewsItem {
  final String newsID;
  final String title;
  final String description;
  final String newsURL;
  final DateTime startTime;
  final DateTime endTime;
  final DateTime publishTime;
  final DateTime updateTime;

  NewsItem({
    required this.newsID,
    required this.title,
    required this.description,
    required this.newsURL,
    required this.startTime,
    required this.endTime,
    required this.publishTime,
    required this.updateTime,
  });

  factory NewsItem.fromJson(Map<String, dynamic> json) {
    return NewsItem(
      newsID: json['NewsID'] as String,
      title: json['Title'] as String,
      description: json['Description'] as String,
      newsURL: json['NewsURL'] as String,
      startTime: DateTime.parse(json['StartTime'] as String),
      endTime: DateTime.parse(json['EndTime'] as String),
      publishTime: DateTime.parse(json['PublishTime'] as String),
      updateTime: DateTime.parse(json['UpdateTime'] as String),
    );
  }
}
