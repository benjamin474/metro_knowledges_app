import 'package:flutter/material.dart';
import '../utils/csv_storage.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final TextEditingController accountController = TextEditingController();
  final TextEditingController nicknameController = TextEditingController();
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
          ],
        ),
      ),
    );
  }
}
