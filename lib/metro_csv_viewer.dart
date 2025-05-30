import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:csv/csv.dart';
import 'package:charset_converter/charset_converter.dart';
import 'dart:convert';
import 'metro_data.dart';

class MetroCsvViewer extends StatefulWidget {
  const MetroCsvViewer({super.key});
  @override
  State<MetroCsvViewer> createState() => _MetroCsvViewerState();
}

class _MetroCsvViewerState extends State<MetroCsvViewer> {
  List<List<dynamic>> rawCsv = [];
  List<List<dynamic>> filteredCsv = [];
  String searchQuery = "";

  @override
  void initState() {
    super.initState();
    fetchCsvByYearMonth(year: "2025", month: "04");
  }

  Future<void> fetchCsvByYearMonth({required String year, required String month}) async {
    const apiUrl =
        'https://data.taipei/api/v1/dataset?scope=resourceAquire&resource_id=eb481f58-1238-4cff-8caa-fa7bb20cb4f4';
    final apiResponse = await http.get(Uri.parse(apiUrl));

    if (apiResponse.statusCode == 200) {
      final json = jsonDecode(apiResponse.body);

      final results = json['result']['results'] as List<dynamic>;
      final allFiles = results.map((e) => MetroData.fromJson(e)).toList();

      final target = allFiles.firstWhere(
        (e) => e.year == year && e.month == month,
        orElse: () => throw Exception("找不到 $year 年 $month 月資料"),
      );

      final csvResponse = await http.get(Uri.parse(target.url));
      if (csvResponse.statusCode == 200) {
        final csvString = await CharsetConverter.decode("big5", csvResponse.bodyBytes);
        final parsed = const CsvToListConverter(eol: '\n').convert(csvString);

        // 欄位加總與排序
        final header = parsed[0];
        final dataRows = parsed.sublist(1);
        final transposed = transpose(dataRows);

        final totals = <String, int>{};
        for (int i = 1; i < transposed.length; i++) {
          final station = header[i].toString();
          final sum = transposed[i]
              .map((v) => int.tryParse(v.toString()) ?? 0)
              .reduce((a, b) => a + b);
          totals[station] = sum;
        }

        final topStations = totals.entries.toList()
          ..sort((a, b) => b.value.compareTo(a.value));
        final selected = topStations.take(20).map((e) => e.key).toList();
        final selectedIndices = selected.map((s) => header.indexOf(s)).toList();

        // 重建資料表
        List<List<dynamic>> reduced = [
          [header[0], ...selected]
        ];
        for (var row in dataRows) {
          reduced.add([row[0], ...selectedIndices.map((i) => row[i])]);
        }

        setState(() {
          rawCsv = reduced;
          filteredCsv = reduced;
        });
      }
    }
  }

  List<List<dynamic>> transpose(List<List<dynamic>> input) {
    final rowCount = input.length;
    final colCount = input[0].length;
    List<List<dynamic>> output =
        List.generate(colCount, (_) => List.filled(rowCount, null));
    for (int i = 0; i < rowCount; i++) {
      for (int j = 0; j < colCount; j++) {
        output[j][i] = input[i][j];
      }
    }
    return output;
  }

  void filterByStation(String query) {
    final lowered = query.toLowerCase();
    final header = rawCsv[0];
    final matchIdx = <int>[];

    for (int i = 1; i < header.length; i++) {
      if (header[i].toString().toLowerCase().contains(lowered)) {
        matchIdx.add(i);
      }
    }

    final filtered = [
      [header[0], ...matchIdx.map((i) => header[i])]
    ];

    for (int r = 1; r < rawCsv.length; r++) {
      final row = rawCsv[r];
      filtered.add([row[0], ...matchIdx.map((i) => row[i])]);
    }

    setState(() {
      searchQuery = query;
      filteredCsv = filtered;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("台北捷運進站量排名")),
      body: rawCsv.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    decoration: const InputDecoration(
                      labelText: '搜尋站名',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: filterByStation,
                  ),
                ),
                Expanded(
                  child: ListView.separated(
                    itemCount: filteredCsv.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final row = filteredCsv[index];
                      return ListTile(
                        title: Text(row[0].toString()),
                        subtitle: Text(row.sublist(1).join(' , ')),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}
