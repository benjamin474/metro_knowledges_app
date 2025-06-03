import 'package:flutter/material.dart';
import '../utils/json_storage.dart';

class SettingsPage extends StatefulWidget {
  final String userAccount;
  const SettingsPage({super.key, required this.userAccount});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final TextEditingController accountController = TextEditingController();
  final TextEditingController nicknameController = TextEditingController();
  final TextEditingController birthdayController = TextEditingController();

  @override
  void initState() {
    super.initState();
    accountController.text = widget.userAccount;
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final account = accountController.text;
    if (account.isEmpty) {
      nicknameController.clear();
      birthdayController.clear();
      return;
    }
    final data = await JsonStorage.getUserData(account);
    setState(() {
      nicknameController.text = data['nickname'] ?? '';
      birthdayController.text = data['birthday'] ?? '';
    });
  }

  Future<void> _savePreferences() async {
    final account = accountController.text;
    if (account.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('請先輸入帳號')));
      return;
    }
    await JsonStorage.saveData(
      account,
      nicknameController.text,
      birthdayController.text,
    );
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
              enabled: false, // disable editing as it's auto-filled
            ),
            const SizedBox(height: 16),
            TextField(
              controller: nicknameController,
              decoration: const InputDecoration(labelText: '暱稱'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: birthdayController,
              decoration: const InputDecoration(labelText: '生日 (YYYY-MM-DD)'),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _savePreferences,
              child: const Text('儲存設定'),
            ),
          ],
        ),
      ),
    );
  }
}
