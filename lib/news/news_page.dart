import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import '../tdx_auth.dart';
import '../models/news_model.dart';
import '../utils/animated_widgets.dart';

class NewsPage extends StatefulWidget {
  const NewsPage({super.key});

  @override
  State<NewsPage> createState() => _NewsPageState();
}

class _NewsPageState extends State<NewsPage> {
  final List<Map<String, String>> metroSystems = [
    {'label': '臺北捷運', 'code': 'TRTC'},
    {'label': '高雄捷運', 'code': 'KRTC'},
    {'label': '桃園捷運', 'code': 'TYMC'},
    {'label': '高雄輕軌', 'code': 'KLRT'},
    {'label': '臺中捷運', 'code': 'TMRT'},
  ];
  String selectedCode = 'TRTC';
  bool loading = true;
  String? errorMessage;
  List<NewsItem> newsList = [];

  @override
  void initState() {
    super.initState();
    fetchNewsData();
  }

  Future<void> fetchNewsData() async {
    setState(() {
      loading = true;
      errorMessage = null;
    });
    try {
      final token = await TdxAuth.getToken();
      final url =
          'https://tdx.transportdata.tw/api/basic/v2/Rail/Metro/News/$selectedCode?%24top=30&%24format=JSON';
      final res = await http.get(
        Uri.parse(url),
        headers: {'Authorization': 'Bearer $token'},
      );
      if (res.statusCode == 200) {
        final data = json.decode(res.body);
        final List<dynamic> items = data['Newses'] as List<dynamic>;
        final list = items
            .map((e) => NewsItem.fromJson(e as Map<String, dynamic>))
            .toList();
        setState(() {
          newsList = list;
          loading = false;
        });
      } else {
        throw Exception('API error: ${res.statusCode}');
      }
    } catch (e) {
      setState(() {
        loading = false;
        errorMessage = '請檢查網路連線或稍後重試';
      });
    }
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('無法開啟連結')));
    }
  }

  Future<void> _fetchNews() async {
    await fetchNewsData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.teal.withOpacity(0.7), Colors.blueAccent.withOpacity(0.7)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Text('最新新聞', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF232526), Color(0xFF414345)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: RefreshIndicator(
          onRefresh: _fetchNews,
          child: loading
              ? const Center(child: CircularProgressIndicator())
              : (errorMessage != null
                  ? Center(child: Text(errorMessage!, style: const TextStyle(fontSize: 16, color: Colors.redAccent)))
                  : newsList.isEmpty
                      ? Center(child: Text('查無新聞', style: TextStyle(fontSize: 16, color: Colors.white70)))
                      : SafeArea(
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.08),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: DropdownButtonFormField<String>(
                                    value: selectedCode,
                                    items: metroSystems
                                        .map((m) => DropdownMenuItem(
                                              value: m['code'],
                                              child: Text(m['label']!),
                                            ))
                                        .toList(),
                                    decoration: const InputDecoration(
                                      labelText: '選擇捷運公司',
                                      border: OutlineInputBorder(),
                                    ),
                                    onChanged: (value) {
                                      if (value != null) {
                                        setState(() => selectedCode = value);
                                        fetchNewsData();
                                      }
                                    },
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Expanded(
                                  child: ListView.builder(
                                    itemCount: newsList.length,
                                    itemBuilder: (context, index) {
                                      final item = newsList[index];
                                      return AnimatedOpacity(
                                        opacity: 1.0,
                                        duration: Duration(milliseconds: 300 + index * 30),
                                        child: Card(
                                          elevation: 6,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(18),
                                          ),
                                          margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
                                          color: null, // 使用自訂 Container 當底色
                                          child: Container(
                                            decoration: BoxDecoration(
                                              gradient: LinearGradient(
                                                colors: [
                                                  const Color(0xFFB2FEFA).withOpacity(0.85), // 淡藍綠
                                                  const Color(0xFF0ED2F7).withOpacity(0.7),  // 淡藍
                                                ],
                                                begin: Alignment.topLeft,
                                                end: Alignment.bottomRight,
                                              ),
                                              borderRadius: BorderRadius.circular(18),
                                            ),
                                            child: ListTile(
                                              title: Text(
                                                item.title,
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.black87,
                                                ),
                                              ),
                                              subtitle: Text(
                                                '發布時間: ${item.publishTime.toLocal().toString().substring(0, 16)}',
                                                style: const TextStyle(color: Colors.black54),
                                              ),
                                              trailing: const Icon(Icons.chevron_right, color: Colors.teal),
                                              onTap: () => _launchUrl(item.newsURL),
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )),
        ),
      ),
    );
  }
}
