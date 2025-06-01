import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:csv/csv.dart';

class CsvStorage {
  static const String _fileName = 'user_data.csv';

  static Future<File> _getFile() async {
    final directory = await getApplicationDocumentsDirectory();
    return File('${directory.path}/$_fileName');
  }

  static Future<void> saveData(String account, String nickname, List<String> history) async {
    final file = await _getFile();
    final csvData = [
      ['account', 'nickname', 'history'],
      [account, nickname, history.join('|')],
    ];
    final csvString = const ListToCsvConverter().convert(csvData);
    await file.writeAsString(csvString);
  }

  static Future<Map<String, dynamic>> loadData() async {
    try {
      final file = await _getFile();
      if (!await file.exists()) {
        return {'account': '', 'nickname': '', 'history': <String>[]};
      }
      final csvString = await file.readAsString();
      final csvData = const CsvToListConverter().convert(csvString);
      final account = csvData[1][0] as String;
      final nickname = csvData[1][1] as String;
      final history = (csvData[1][2] as String).split('|');
      return {'account': account, 'nickname': nickname, 'history': history};
    } catch (e) {
      return {'account': '', 'nickname': '', 'history': <String>[]};
    }
  }

  static Future<void> clearHistory() async {
    final data = await loadData();
    await saveData(data['account'], data['nickname'], []);
  }

  static Future<bool> getThemePreference() async {
    try {
      final file = await _getFile();
      if (!await file.exists()) {
        return false; // Default to light mode if no preference is saved
      }
      final csvString = await file.readAsString();
      final csvData = const CsvToListConverter().convert(csvString);
      if (csvData.length > 2 && csvData[2].isNotEmpty) {
        return csvData[2][0] == 'dark';
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  static Future<void> saveThemePreference(bool isDarkMode) async {
    try {
      final file = await _getFile();
      final csvString = await file.readAsString();
      final csvData = const CsvToListConverter().convert(csvString);

      if (csvData.length > 2) {
        csvData[2] = [isDarkMode ? 'dark' : 'light'];
      } else {
        csvData.add([isDarkMode ? 'dark' : 'light']);
      }

      final updatedCsvString = const ListToCsvConverter().convert(csvData);
      await file.writeAsString(updatedCsvString);
    } catch (e) {
      // Handle error if needed
    }
  }
}
