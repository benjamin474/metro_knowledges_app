import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class MetroDataViewer extends StatefulWidget {
  const MetroDataViewer({super.key});

  @override
  State<MetroDataViewer> createState() => _MetroDataViewerState();
}

class _MetroDataViewerState extends State<MetroDataViewer> {
  String apiResponseText = "正在載入中...";
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchApiData();
  }

  Future<void> fetchApiData() async {
    final apiUrl = Uri.encodeFull('https://data.taipei/api/v1/dataset/df2da2b6-a3d5-47e7-8c97-8b047d9a2bd1?scope=resourceAquire&resource_id=eb481f58-1238-4cff-8caa-fa7bb20cb4f4');
    try {
      final apiResponse = await http.get(Uri.parse(apiUrl));
      if (apiResponse.statusCode == 200) {
        debugPrint('API 請求成功: ${apiResponse.statusCode}');
        setState(() {
          apiResponseText = apiResponse.body; // 將原始 JSON 資料存入變數
          isLoading = false;
        });
      } else {
        debugPrint('API 請求失敗: ${apiResponse.statusCode}');
        setState(() {
          apiResponseText = 'API 請求失敗，狀態碼: ${apiResponse.statusCode}';
          isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('發生錯誤: $e');
      setState(() {
        apiResponseText = '發生錯誤: $e';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('北捷 API 資料檢視'),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                apiResponseText, // 顯示原始 JSON 資料
                style: const TextStyle(fontSize: 14),
              ),
            ),
            
    );
  }
}