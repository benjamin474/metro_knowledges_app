import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:taipei_metro_app/models/travel_time_model.dart'; // 引用 model
import '../tdx_auth.dart'; // 引用你放 TdxAuth 的檔案
import 'package:taipei_metro_app/unuseData/utils/csv_storage.dart';

class MetroTravelPage extends StatefulWidget {
  const MetroTravelPage({
    super.key,
    required this.onToggleTheme,
    required this.themeMode,
  });
  final VoidCallback onToggleTheme;
  final ThemeMode themeMode;

  @override
  State<MetroTravelPage> createState() => _MetroTravelPageState();
}

class _MetroTravelPageState extends State<MetroTravelPage> {
  List<TravelTime> travelList = [];
  List<TravelTime> filteredList = [];
  bool loading = true;
  String? errorMessage;

  // 多捷運系統選項
  final List<Map<String, String>> metroSystems = [
    {'label': '臺北捷運', 'code': 'TRTC'},
    {'label': '高雄捷運', 'code': 'KRTC'},
    // {'label': '桃園捷運', 'code': 'TYMC'},
    {'label': '臺中捷運', 'code': 'TMRT'},
    {'label': '高雄輕軌', 'code': 'KLRT'},
    {'label': '新北捷運', 'code': 'NTMC'},
  ];
  String selectedSystemCode = 'KRTC';
  final TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchTravelData();
  }

  Future<void> fetchTravelData() async {
    setState(() {
      loading = true;
    });
    try {
      final token = await TdxAuth.getToken();
      final url =
          'https://tdx.transportdata.tw/api/basic/v2/Rail/Metro/S2STravelTime/$selectedSystemCode?%24top=10000&%24format=JSON';
      debugPrint('Fetching data from: $url');
      final res = await http.get(
        Uri.parse(url),
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
          filteredList = travelTimes;
          loading = false;
        });
      } else {
        throw Exception('API 回應錯誤 ${res.statusCode}');
      }
    } catch (e) {
      debugPrint('錯誤: $e');
      setState(() {
        errorMessage = '無法載入資料，請稍後再試。';
        loading = false;
      });
    }
  }

  // 使用單一搜尋條件過濾
  Future<void> filterResults() async {
    final query = searchController.text.trim().toLowerCase();
    if (query.isNotEmpty) {
      // 儲存搜尋歷史到 CSV
      final data = await CsvStorage.loadData();
      final history = data['history'] as List<String>;
      history.add(query);
      await CsvStorage.saveData(data['account'], data['nickname'], history);
    }
    setState(() {
      filteredList = travelList.where((t) {
        return t.fromStation.toLowerCase().contains(query) ||
            t.toStation.toLowerCase().contains(query);
      }).toList();
    });
  }

  // 新增排序功能
  void sortTravelList(bool ascending) {
    setState(() {
      filteredList.sort((a, b) => ascending
          ? a.runTime.compareTo(b.runTime)
          : b.runTime.compareTo(a.runTime));
    });
  }

  @override
  Widget build(BuildContext context) {
    // 決定顯示內容
    Widget bodyContent;
    if (loading) {
      bodyContent = const Center(child: CircularProgressIndicator());
    } else if (errorMessage != null) {
      bodyContent = Center(child: Text(errorMessage!, style: const TextStyle(fontSize: 16)));
    } else if (filteredList.isEmpty) {
      bodyContent = const Center(child: Text('查無資料', style: TextStyle(fontSize: 16)));
    } else {
      bodyContent = SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            children: [
              // Metro system selector and search bar
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: DropdownButtonFormField<String>(
                      value: selectedSystemCode,
                      items: metroSystems
                          .map(
                            (m) => DropdownMenuItem(
                              value: m['code'],
                              child: Text(
                                m['label']!,
                                overflow: TextOverflow.ellipsis, // 防止文字溢出
                              ),
                            ),
                          )
                          .toList(),
                      decoration: InputDecoration(
                        labelText: '路網',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            selectedSystemCode = value;
                            fetchTravelData();
                          });
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    flex: 5,
                    child: TextField(
                      controller: searchController,
                      decoration: InputDecoration(
                        hintText: '輸入站名搜尋',
                        filled: true,
                        fillColor: Theme.of(context).cardColor,
                        prefixIcon: const Icon(Icons.search),
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 0,
                          horizontal: 16,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      onChanged: (value) => filterResults(),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Sorting buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                    onPressed: () => sortTravelList(true),
                    child: const Text('時間最短升序'),
                  ),
                  ElevatedButton(
                    onPressed: () => sortTravelList(false),
                    child: const Text('時間最長降序'),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Result list
              Expanded(
                child: ListView.builder(
                  itemCount: filteredList.length,
                  itemBuilder: (context, index) {
                    final t = filteredList[index];
                    return Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      child: ListTile(
                        title: Text('${t.fromStation} ➜ ${t.toStation}'),
                        subtitle: Text(
                          '行車：${t.runTime} 秒  停靠：${t.stopTime} 秒',
                        ),
                        leading: CircleAvatar(
                          backgroundColor: Theme.of(context).primaryColor,
                          child: Text('${t.sequence}'),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('捷運站對站行車時間'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(
              widget.themeMode == ThemeMode.dark
                  ? Icons.light_mode
                  : Icons.dark_mode,
            ),
            onPressed: widget.onToggleTheme,
          ),
        ],
      ),
      body: bodyContent,
    );
  }
}
