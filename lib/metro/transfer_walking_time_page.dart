import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

// Model for transfer walking time
class TransferWalkingTime {
  final String sno;
  final String station;
  final int minutes;
  final String updateDate;

  TransferWalkingTime({
    required this.sno,
    required this.station,
    required this.minutes,
    required this.updateDate,
  });

  factory TransferWalkingTime.fromJson(Map<String, dynamic> json) {
    return TransferWalkingTime(
      sno: json['sno'] as String,
      station: json['station'] as String,
      minutes: int.tryParse(json['time'] as String) ?? 0,
      updateDate: json['updatetime'] as String,
    );
  }
}

class TransferWalkingPage extends StatefulWidget {
  const TransferWalkingPage({Key? key}) : super(key: key);

  @override
  _TransferWalkingPageState createState() => _TransferWalkingPageState();
}

class _TransferWalkingPageState extends State<TransferWalkingPage> {
  final String apiUrl =
      'https://data.taipei/api/v1/dataset/14fd1af0-dc2b-4174-87d4-fcb9de783496?scope=resourceAquire&limit=1000';
  List<TransferWalkingTime> list = [];
  bool loading = true;
  String? errorMessage;
  bool ascending = true;

  @override
  void initState() {
    super.initState();
    fetchWalkingData();
  }

  Future<void> fetchWalkingData() async {
    setState(() {
      loading = true;
      errorMessage = null;
    });
    try {
      final res = await http.get(Uri.parse(apiUrl));
      if (res.statusCode == 200) {
        final body = json.decode(res.body);
        final items = (body['result']['results'] as List<dynamic>)
            .map((e) => TransferWalkingTime.fromJson(e))
            .toList();
        setState(() {
          list = items;
          sortList();
          loading = false;
        });
      } else {
        throw Exception('API 回應 ${res.statusCode}');
      }
    } catch (e) {
      setState(() {
        loading = false;
        errorMessage = '無法載入資料，請檢查網路或稍後再試';
      });
    }
  }

  void sortList() {
    list.sort((a, b) => ascending
        ? a.minutes.compareTo(b.minutes)
        : b.minutes.compareTo(a.minutes));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('轉乘步行時間排行'),
        centerTitle: true,
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage != null
              ? Center(child: Text(errorMessage!))
              : Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              setState(() {
                                ascending = true;
                                sortList();
                              });
                            },
                            child: const Text('時間最短'),
                          ),
                          const SizedBox(width: 16),
                          ElevatedButton(
                            onPressed: () {
                              setState(() {
                                ascending = false;
                                sortList();
                              });
                            },
                            child: const Text('時間最長'),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        itemCount: list.length,
                        itemBuilder: (context, index) {
                          final item = list[index];
                          return ListTile(
                            leading: Text(item.sno),
                            title: Text(item.station),
                            trailing: Text('${item.minutes} 分鐘'),
                          );
                        },
                      ),
                    ),
                  ],
                ),
    );
  }
}
