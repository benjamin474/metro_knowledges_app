import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() => runApp(const MetroRawApp());

/// 最簡單的 MaterialApp
class MetroRawApp extends StatelessWidget {
  const MetroRawApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MetroRawPage(),
    );
  }
}

/// 首頁：下載並顯示原始 JSON 字串
class MetroRawPage extends StatelessWidget {
  const MetroRawPage({super.key});

  /// 取得原始 JSON
  Future<String> _fetchRaw() async {
    // 用 Uri.https 組合查詢參數，比手動拼字串安全
    final uri = Uri.https(
      'data.taipei',
      '/api/v1/dataset/eb481f58-1238-4cff-8caa-fa7bb20cb4f4',
      {
        'scope': 'resourceAquire',
        'resource_id': 'eb481f58-1238-4cff-8caa-fa7bb20cb4f4',
        // 其他可選參數：'limit': '1000', 'offset': '0'
      },
    );

    final res = await http.get(uri);

    if (res.statusCode == 200) {
      return res.body; // 直接回傳原始內容
    } else {
      throw Exception('HTTP ${res.statusCode}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('北捷進站量 - 原始 JSON')),
      body: FutureBuilder<String>(
        future: _fetchRaw(),
        builder: (context, snapshot) {
          // 下載中
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          // 發生錯誤
          if (snapshot.hasError) {
            return Center(child: Text('錯誤：${snapshot.error}'));
          }
          // 成功：用 SingleChildScrollView 顯示完整字串
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: SelectableText(snapshot.data ?? ''),
          );
        },
      ),
    );
  }
}
