import 'dart:io';
import 'dart:convert';
import 'package:path_provider/path_provider.dart';

class JsonStorage {
  static const String _fileName = 'user_data.json';

  static Future<File> _getFile() async {
    final directory = await getApplicationDocumentsDirectory();
    return File('${directory.path}/$_fileName');
  }

  static Future<void> saveData(String account, String nickname, String birthday) async {
    final file = await _getFile();
    Map<String, dynamic> data = await loadData();
    data[account] = {
      'nickname': nickname,
      'birthday': birthday,
    };
    final jsonString = jsonEncode(data);
    await file.writeAsString(jsonString);
  }

  static Future<Map<String, dynamic>> loadData() async {
    try {
      final file = await _getFile();
      if (!await file.exists()) {
        return {};
      }
      final jsonString = await file.readAsString();
      return jsonDecode(jsonString);
    } catch (e) {
      return {};
    }
  }

  static Future<Map<String, dynamic>> getUserData(String account) async {
    final data = await loadData();
    return data[account] ?? {};
  }
}