import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/csv_storage.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final TextEditingController accountController = TextEditingController();
  final TextEditingController nicknameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController resetTokenController = TextEditingController();
  List<String> history = [];

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final data = await CsvStorage.loadData();
    setState(() {
      accountController.text = data['account'] ?? '';
      nicknameController.text = data['nickname'] ?? '';
      history = data['history'] ?? [];
    });
  }

  Future<void> _savePreferences() async {
    await CsvStorage.saveData(accountController.text, nicknameController.text, history);
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('設定已儲存')));
  }

  Future<void> resetPassword() async {
    final favKey = dotenv.env['FAVQS_API_KEY']!;
    final email = emailController.text.trim();
    final resetToken = resetTokenController.text.trim();

    if (email.isEmpty || resetToken.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('請填寫所有欄位')),
      );
      return;
    }

    try {
      final url = Uri.parse('https://favqs.com/api/users/reset_password');
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Token token="$favKey"',
        },
        body: jsonEncode({
          'user': {
            'email': email,
            'reset_password_token': resetToken,
          },
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data['message'])),
        );
      } else {
        final error = jsonDecode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('錯誤: ${error['message']}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('發生錯誤: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('使用者設定')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: accountController,
              decoration: const InputDecoration(labelText: '帳號'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: nicknameController,
              decoration: const InputDecoration(labelText: '暱稱'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _savePreferences,
              child: const Text('儲存設定'),
            ),
            const SizedBox(height: 24),
            const Text('搜尋歷史'),
            Expanded(
              child: ListView.builder(
                itemCount: history.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(history[index]),
                  );
                },
              ),
            ),
            TextButton(
              onPressed: () {
                CsvStorage.clearHistory().then((_) {
                  setState(() => history = []);
                });
              },
              child: const Text('清除搜尋歷史'),
            ),
            const SizedBox(height: 24),
            const Text('重設密碼', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: '電子郵件'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: resetTokenController,
              decoration: const InputDecoration(labelText: '重設密碼 Token'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: resetPassword,
              child: const Text('重設密碼'),
            ),
          ],
        ),
      ),
    );
  }
}
