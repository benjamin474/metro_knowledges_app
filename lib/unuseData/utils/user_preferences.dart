// import 'package:shared_preferences/shared_preferences.dart';

// class UserPreferences {
//   static const _keyAccount = 'account';
//   static const _keyNickname = 'nickname';
//   static const _keySearchHistory = 'search_history';

//   static Future<void> setAccount(String account) async {
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.setString(_keyAccount, account);
//   }

//   static Future<String?> getAccount() async {
//     final prefs = await SharedPreferences.getInstance();
//     return prefs.getString(_keyAccount);
//   }

//   static Future<void> setNickname(String nickname) async {
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.setString(_keyNickname, nickname);
//   }

//   static Future<String?> getNickname() async {
//     final prefs = await SharedPreferences.getInstance();
//     return prefs.getString(_keyNickname);
//   }

//   static Future<List<String>> getSearchHistory() async {
//     final prefs = await SharedPreferences.getInstance();
//     return prefs.getStringList(_keySearchHistory) ?? [];
//   }

//   static Future<void> addSearchQuery(String query) async {
//     final prefs = await SharedPreferences.getInstance();
//     final history = prefs.getStringList(_keySearchHistory) ?? [];
//     history.add(query);
//     await prefs.setStringList(_keySearchHistory, history);
//   }

//   static Future<void> clearSearchHistory() async {
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.remove(_keySearchHistory);
//   }
// }
