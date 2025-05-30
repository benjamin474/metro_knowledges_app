import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:csv/csv.dart';
import 'package:taipei_metro_app/metro_data.dart';
import 'package:charset_converter/charset_converter.dart';

class MetroCsvViewer extends StatefulWidget{
  const MetroCsvViewer({super.key});

  @override
  State<MetroCsvViewer> createState() => _MetroCsvViewerState();
}

class _MetroCsvViewerState extends State<MetroCsvViewer> {
  List<List<dynamic>> csvData = [];
  List<MetroData> allFiles = [];

  @override
  void initState() {
    super.initState();
    fetchAndParseCsv();
  }

  Future<void> fetchAndParseCsv() async {
    // Implement your CSV fetching and parsing logic here
    // For example, you can use the http package to fetch the CSV file
    // and then parse it using a CSV parser like csv or csv_parser.
    final apiUrl = 'https://data.taipei/api/v1/dataset/df2da2b6-a3d5-47e7-8c97-8b047d9a2bd1?scope=resourceAquire&resource_id=eb481f58-1238-4cff-8caa-fa7bb20cb4f4';
    final apiResponse = await http.get(Uri.parse(apiUrl));

    if(apiResponse.statusCode == 200){
      debugPrint('API 請求成功: ${apiResponse.statusCode}');
      final data = jsonDecode(apiResponse.body);
      final results = data['result']['results'] as List<dynamic>;

      // 轉換成 MetroData 類別
      allFiles = results.map((e) => MetroData.fromJson(e)).toList();

      final target = allFiles.firstWhere(
        (e) => e.year == "2015" && e.month == "1" , 
        orElse: () => throw Exception("找不到符合條件的資料")
      );

      // 拿第一筆資料的 CSV 字串
      final csvUrl = results[0]['url'];
      debugPrint('獲取的 CSV URL: $csvUrl');

      final csvResponse = await http.get(Uri.parse(csvUrl));
      if(csvResponse.statusCode == 200){
        final csvString = await CharsetConverter.decode("big5", csvResponse.bodyBytes);
        final parsedCsv = const CsvToListConverter(eol: '\n').convert(csvString);
        debugPrint('CSV 解析結果: $parsedCsv');
      
        setState(() => csvData = parsedCsv);
      }
      else{
        debugPrint('CSV 下載失敗: ${csvResponse.statusCode}');
      }
    }
    else{
      debugPrint('API 請求失敗: ${apiResponse.statusCode}');
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('北捷進站量統計'),
      ),
      body: csvData.isEmpty
      ?  Center(child: CircularProgressIndicator())
      : ListView.separated(
        itemCount: csvData.length,
        separatorBuilder: (context, index) => const Divider(),
        itemBuilder: (context, index) {
          final row = csvData[index];
          return ListTile(
            title: Text(row[0].toString()),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for(int i=1;i<row.length;i+=5)
                  Text(row.sublist(i,(i+5>row.length ? row.length : i+5)).join(', ')),
                
              ],
            )

            // Text(row.sublist(1).take(5).join(', ')),
          );
        },
      ),
    );
  }
}

