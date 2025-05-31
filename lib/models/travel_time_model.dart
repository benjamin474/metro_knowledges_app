class TravelTime {
  final int sequence;
  final String fromStation;
  final String toStation;
  final int runTime;
  final int stopTime;

  TravelTime({
    required this.sequence,
    required this.fromStation,
    required this.toStation,
    required this.runTime,
    required this.stopTime,
  });

  factory TravelTime.fromJson(Map<String, dynamic> json) {
    return TravelTime(
      sequence: json['Sequence'],
      fromStation: json['FromStationName']['Zh_tw'],
      toStation: json['ToStationName']['Zh_tw'],
      runTime: json['RunTime'],
      stopTime: json['StopTime'],
    );
  }
}
