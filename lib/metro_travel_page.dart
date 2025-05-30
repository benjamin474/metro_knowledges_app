import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:taipei_metro_app/travel_time_model.dart';
import 'tdx_auth.dart'; // 引用你放 TdxAuth 的檔案
import 'travel_time_model.dart'; // 引用 model

class MetroTravelPage extends StatefulWidget {
  const MetroTravelPage({super.key});

  @override
  State<MetroTravelPage> createState() => _MetroTravelPageState();
}

class _MetroTravelPageState extends State<MetroTravelPage> {
  List<TravelTime> travelList = [];
  List<TravelTime> filteredList = [];
  bool loading = true;

  final TextEditingController fromStationController = TextEditingController();
  final TextEditingController toStationController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchTravelData();
  }

  Future<void> fetchTravelData() async {
    try {
      final token = await TdxAuth.getToken();
      final res = await http.get(
        // Uri.parse('https://tdx.transportdata.tw/api/basic/v2/Rail/Metro/S2STravelTime/TRTC?\$format=JSON&\$top=1000000'),
        Uri.parse('https://tdx.transportdata.tw/api/basic/v2/Rail/Metro/S2STravelTime/KRTC?%24top=1000000&%24format=JSON'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (res.statusCode == 200) {
        final List<dynamic> jsonList = json.decode(res.body);
        final travelTimes = jsonList
            .expand((route) => route['TravelTimes'])
            .map<TravelTime>((e) => TravelTime.fromJson(e))
            .toList();

        setState(() {
          travelList = travelTimes;
          filteredList = travelTimes; // 初始化時顯示所有數據
          loading = false;
        });
      } else {
        throw Exception('API 回應錯誤 ${res.statusCode}');
      }
    } catch (e) {
      debugPrint('錯誤: $e');
    }
  }

  void filterResults() {
    final fromStation = fromStationController.text.toLowerCase();
    final toStation = toStationController.text.toLowerCase();

    setState(() {
      filteredList = travelList.where((t) {
        final fromMatch = t.fromStation.toLowerCase().contains(fromStation);
        final toMatch = t.toStation.toLowerCase().contains(toStation);
        return fromMatch && toMatch;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('捷運站對站行車時間')),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Autocomplete<String>(
                          optionsBuilder: (TextEditingValue textEditingValue) {
                            final input = textEditingValue.text.toLowerCase();
                            return travelList
                                .map((t) => t.fromStation)
                                .where((station) => station.toLowerCase().contains(input))
                                .toSet()
                                .toList();
                          },
                          onSelected: (String selection) {
                            fromStationController.text = selection;
                            filterResults();
                          },
                          fieldViewBuilder: (context, controller, focusNode, onEditingComplete) {
                            fromStationController.text = controller.text;
                            return TextField(
                              controller: controller,
                              focusNode: focusNode,
                              decoration: const InputDecoration(
                                labelText: '出發站',
                                border: OutlineInputBorder(),
                              ),
                              onChanged: (value) => filterResults(),
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Autocomplete<String>(
                          optionsBuilder: (TextEditingValue textEditingValue) {
                            final input = textEditingValue.text.toLowerCase();
                            return travelList
                                .map((t) => t.toStation)
                                .where((station) => station.toLowerCase().contains(input))
                                .toSet()
                                .toList();
                          },
                          onSelected: (String selection) {
                            toStationController.text = selection;
                            filterResults();
                          },
                          fieldViewBuilder: (context, controller, focusNode, onEditingComplete) {
                            toStationController.text = controller.text;
                            return TextField(
                              controller: controller,
                              focusNode: focusNode,
                              decoration: const InputDecoration(
                                labelText: '終點站',
                                border: OutlineInputBorder(),
                              ),
                              onChanged: (value) => filterResults(),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: filteredList.length,
                    itemBuilder: (context, index) {
                      final t = filteredList[index];
                      return ListTile(
                        title: Text('${t.fromStation} ➜ ${t.toStation}'),
                        subtitle: Text('行車：${t.runTime} 秒、停靠：${t.stopTime} 秒'),
                        leading: Text('${t.sequence}'),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}
