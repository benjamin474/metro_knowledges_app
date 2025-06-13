import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

// Model for fare and distance
class FareDistance {
  final String startStation;
  final String endStation;
  final String fare;
  final String distance;

  FareDistance({
    required this.startStation,
    required this.endStation,
    required this.fare,
    required this.distance,
  });

  factory FareDistance.fromJson(Map<String, dynamic> json) {
    return FareDistance(
      startStation: json['起站'] as String,
      endStation: json['訖站'] as String,
      fare: json['全票票價'] as String,
      distance: json['距離'] as String,
    );
  }
}

class FareDistancePage extends StatefulWidget {
  const FareDistancePage({super.key});

  @override
  State<FareDistancePage> createState() => _FareDistancePageState();
}

class _FareDistancePageState extends State<FareDistancePage> {
  final String apiUrl =
      'https://data.taipei/api/v1/dataset/893c2f2a-dcfd-407b-b871-394a14105532?scope=resourceAquire';
  List<FareDistance> dataList = [];
  bool loading = true;
  int totalCount = 0;
  int loadedCount = 0;
  double progress = 0.0;
  String? errorMessage;

  String? selectedStart;
  String? selectedEnd;
  FareDistance? result;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  // 修改 fetchData 增加 mounted 檢查
  Future<void> fetchData() async {
    if (!mounted) return;
    setState(() {
      loading = true;
      loadedCount = 0;
      progress = 0.0;
    });
    try {
      List<FareDistance> allRecords = [];
      int offset = 0;
      const int limit = 1000;
      int total = 0;
      while (true) {
        final url = '$apiUrl&limit=$limit&offset=$offset';
        final res = await http.get(Uri.parse(url));
        if (!mounted) return;
        if (res.statusCode != 200) {
          throw Exception('API 回應錯誤: ${res.statusCode}');
        }
        final jsonBody = json.decode(res.body);
        if (offset == 0) {
          total = (jsonBody['result']['count'] as num).toInt();
          if (!mounted) return;
          setState(() {
            totalCount = total;
          });
        }
        final List<dynamic> records = jsonBody['result']['results'];
        if (records.isEmpty) break;
        final batch = records.map((e) => FareDistance.fromJson(e as Map<String, dynamic>));
        allRecords.addAll(batch);
        loadedCount = allRecords.length;
        progress = total > 0 ? loadedCount / total : 0.0;
        if (!mounted) return;
        setState(() {});
        if (records.length < limit) break;
        offset += limit;
      }
      if (!mounted) return;
      setState(() {
        dataList = allRecords;
        loading = false;
      });
    } catch (e) {
      debugPrint('錯誤: $e');
      if (!mounted) return;
      setState(() {
        loading = false;
      });
    }
  }

  void searchRecord() {
    if (selectedStart != null && selectedEnd != null) {
      final found = dataList.firstWhere(
        (r) => r.startStation == selectedStart && r.endStation == selectedEnd,
        orElse: () => FareDistance(
            startStation: '', endStation: '', fare: '查無資料', distance: '查無資料'),
      );
      setState(() {
        result = found;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // 替換起站選擇 UI，改為可輸入補全的 Autocomplete
    final stationNames = dataList.map((e) => e.startStation).toSet().toList();
    return Scaffold(
      appBar: AppBar(
        title: const Text('票價與距離查詢'),
        centerTitle: true,
      ),
      body: loading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('載入資料中：$loadedCount / $totalCount'),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: 200,
                    child: LinearProgressIndicator(value: progress),
                  ),
                ],
              ),
            )
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Autocomplete<String>(
                    optionsBuilder: (TextEditingValue textEditingValue) {
                      if (textEditingValue.text.isEmpty) return const Iterable<String>.empty();
                      return stationNames.where((option) => option.contains(textEditingValue.text));
                    },
                    fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
                      return TextField(
                        controller: controller,
                        focusNode: focusNode,
                        decoration: const InputDecoration(labelText: '起站'),
                        onSubmitted: (value) {
                          setState(() { selectedStart = value; result = null; });
                          onFieldSubmitted();
                        },
                      );
                    },
                    onSelected: (selection) => setState(() { selectedStart = selection; result = null; }),
                  ),
                  const SizedBox(height: 12),
                  // 替換訖站選擇 UI，改為可輸入補全的 Autocomplete
                  Autocomplete<String>(
                    optionsBuilder: (TextEditingValue textEditingValue) {
                      if (textEditingValue.text.isEmpty) return const Iterable<String>.empty();
                      return stationNames.where((option) => option.contains(textEditingValue.text));
                    },
                    fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
                      return TextField(
                        controller: controller,
                        focusNode: focusNode,
                        decoration: const InputDecoration(labelText: '訖站'),
                        onSubmitted: (value) {
                          setState(() { selectedEnd = value; result = null; });
                          onFieldSubmitted();
                        },
                      );
                    },
                    onSelected: (selection) => setState(() { selectedEnd = selection; result = null; }),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: searchRecord,
                    child: const Text('查詢'),
                  ),
                  const SizedBox(height: 20),
                  if (result != null)
                    Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 2),
                      color: null, // 用自訂 Container 當底色
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Color(0xFFB7F8DB).withOpacity(0.85), // 淡綠
                              Color(0xFF50A7C2).withOpacity(0.7),  // 淡藍綠
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('起站: ${result!.startStation}', style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
                            Text('訖站: ${result!.endStation}', style: const TextStyle(color: Colors.black87)),
                            Text('全票票價: ${result!.fare}', style: const TextStyle(color: Colors.black87)),
                            Text('距離: ${result!.distance} 公里', style: const TextStyle(color: Colors.black87)),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
    );
  }
}
