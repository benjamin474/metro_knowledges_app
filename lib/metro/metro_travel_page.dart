import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:taipei_metro_app/models/travel_time_model.dart'; // 引用 model
import '../tdx_auth.dart'; // 引用你放 TdxAuth 的檔案
import 'package:taipei_metro_app/unuseData/utils/csv_storage.dart';
import '../utils/animated_widgets.dart';

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

  // 進度條狀態
  int _loadedCount = 0;
  int _totalCount = 0;
  double _progress = 0.0;

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

  // 分頁相關
  int currentPage = 0;
  static const int pageSize = 20;

  List<TravelTime> get pagedList {
    final start = currentPage * pageSize;
    final end = (start + pageSize).clamp(0, filteredList.length);
    return filteredList.sublist(start, end);
  }

  void nextPage() {
    if ((currentPage + 1) * pageSize < filteredList.length) {
      setState(() {
        currentPage++;
      });
    }
  }

  void prevPage() {
    if (currentPage > 0) {
      setState(() {
        currentPage--;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    fetchTravelData();
  }

  // 以 1000 筆為單位分批抓取所有資料，並顯示進度條與錯誤排查
  Future<void> fetchTravelData() async {
    setState(() {
      loading = true;
      errorMessage = null;
      _progress = 0.0;
      _loadedCount = 0;
      _totalCount = 0;
    });
    try {
      final token = await TdxAuth.getToken();
      List<TravelTime> allData = [];
      int skip = 0;
      const int top = 1000;
      int total = 0;
      while (true) {
        final url =
            'https://tdx.transportdata.tw/api/basic/v2/Rail/Metro/S2STravelTime/$selectedSystemCode?%24top=$top&%24skip=$skip&%24format=JSON';
        debugPrint('Fetching data from: $url');
        final res = await http.get(
          Uri.parse(url),
          headers: {'Authorization': 'Bearer $token'},
        );
        if (res.statusCode != 200) {
          throw Exception('API 回應錯誤 ${res.statusCode}');
        }
        final List<dynamic> jsonList = json.decode(res.body);
        if (jsonList.isEmpty) break;
        final travelTimes = jsonList
            .expand((route) => route['TravelTimes'])
            .map<TravelTime>((e) => TravelTime.fromJson(e))
            .toList();
        allData.addAll(travelTimes);
        // 嘗試取得總筆數（假設每個 route 都有一個 Count 屬性，否則用 allData.length 估算）
        if (skip == 0) {
          total = 18000; // 若 API 沒有提供總數，這裡可手動設一個大致值
        }
        _loadedCount = allData.length;
        _totalCount = total;
        _progress = total > 0 ? _loadedCount / total : 0.0;
        setState(() {});
        if (travelTimes.length < top) break;
        skip += top;
      }
      setState(() {
        travelList = allData;
        filteredList = allData;
        loading = false;
        errorMessage = null;
      });
    } catch (e) {
      debugPrint('錯誤: $e');
      setState(() {
        errorMessage = '無法載入資料，請檢查網路或稍後再試。';
        loading = false;
      });
    }
  }

  bool isAscending = true;
  String get sortStatusText => isAscending ? '目前：行駛時間升序（由小到大）' : '目前：行駛時間降序（由大到小）';

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
      currentPage = 0;
    });
  }

  // 新增排序功能
  void sortTravelList(bool ascending) {
    setState(() {
      isAscending = ascending;
      filteredList.sort((a, b) => ascending
          ? a.runTime.compareTo(b.runTime)
          : b.runTime.compareTo(a.runTime));
      currentPage = 0;
    });
  }

  Future<void> _refreshData() async {
    fetchTravelData();
  }

  @override
  Widget build(BuildContext context) {
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
      body: SafeArea(
        child: Column(
          children: [
            // 固定搜尋列與系統選擇
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: DropdownButtonFormField<String>(
                          value: selectedSystemCode,
                          items: metroSystems
                              .map(
                                (m) => DropdownMenuItem(
                                  value: m['code'],
                                  child: Text(
                                    m['label']!,
                                    style: const TextStyle(fontSize: 13),
                                  ),
                                ),
                              )
                              .toList(),
                          decoration: InputDecoration(
                            labelText: '路網',
                            labelStyle: const TextStyle(fontSize: 13),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
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
                          decoration: const InputDecoration(
                            labelText: '搜尋站名',
                            prefixIcon: Icon(Icons.search),
                          ),
                          onSubmitted: (_) => filterResults(),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(Icons.arrow_upward), // 升冪排序
                        tooltip: '行駛時間由小到大',
                        onPressed: () => sortTravelList(true),
                      ),
                      IconButton(
                        icon: const Icon(Icons.arrow_downward), // 降冪排序
                        tooltip: '行駛時間由大到小',
                        onPressed: () => sortTravelList(false),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    sortStatusText,
                    style: const TextStyle(fontSize: 13, color: Colors.tealAccent),
                  ),
                ],
              ),
            ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: fetchTravelData,
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  children: [
                    if (loading) ...[
                      Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('載入資料中：$_loadedCount / $_totalCount'),
                            const SizedBox(height: 16),
                            LinearProgressIndicator(value: _progress),
                          ],
                        ),
                      ),
                    ] else if (errorMessage != null) ...[
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          errorMessage!,
                          style: const TextStyle(color: Colors.red, fontSize: 16),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ] else ...[
                      for (int i = 0; i < pagedList.length; i++)
                        AnimatedListCard(
                          index: i,
                          child: Card(
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
                                    Color(0xFFE0C3FC).withOpacity(0.85), // 淡紫
                                    Color(0xFF8EC5FC).withOpacity(0.7),  // 淡藍紫
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: Colors.black,
                                  child: Text(
                                    '${currentPage * pageSize + i + 1}',
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                ),
                                title: Text(
                                  '${pagedList[i].fromStation} ➜ ${pagedList[i].toStation}',
                                  style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
                                ),
                                subtitle: Text(
                                  '行車：${pagedList[i].runTime} 秒  停靠：${pagedList[i].stopTime} 秒',
                                  style: const TextStyle(color: Colors.black54),
                                ),
                              ),
                            ),
                          ),
                        ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton(
                            onPressed: currentPage > 0 ? prevPage : null,
                            child: const Text('上一頁'),
                          ),
                          const SizedBox(width: 16),
                          Text('第 ${currentPage + 1} 頁 / 共 ${(filteredList.length / pageSize).ceil()} 頁'),
                          const SizedBox(width: 16),
                          ElevatedButton(
                            onPressed: (currentPage + 1) * pageSize < filteredList.length ? nextPage : null,
                            child: const Text('下一頁'),
                          ),
                        ],
                      ),
                    ],
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
