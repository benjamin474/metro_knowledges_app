import 'package:flutter/material.dart';
import 'package:country_picker/country_picker.dart';
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
  String? selectedGender;
  String? selectedCountry;
  final List<String> allLines = [
    '板南線', '文湖線', '淡水信義線', '松山新店線', '環狀線', '中和新蘆線'
  ];
  List<String> selectedLines = [];

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
      selectedGender = null;
      selectedCountry = null;
      selectedLines = [];
      setState(() {});
      return;
    }
    final data = await JsonStorage.getUserData(account);
    setState(() {
      nicknameController.text = data['nickname'] ?? '';
      birthdayController.text = data['birthday'] ?? '';
      selectedGender = data['gender'];
      selectedCountry = data['nationality'];
      selectedLines = List<String>.from(data['lines'] ?? []);
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
      selectedGender ?? '',
      selectedCountry ?? '',
      selectedLines,
    );
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('設定已儲存')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('使用者設定')),
      body: RefreshIndicator(
        onRefresh: _loadPreferences,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
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
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: selectedGender,
              decoration: const InputDecoration(labelText: '性別'),
              items: const [
                DropdownMenuItem(value: '男', child: Text('男')),
                DropdownMenuItem(value: '女', child: Text('女')),
                DropdownMenuItem(value: '其他', child: Text('其他')),
                DropdownMenuItem(value: '不願透露', child: Text('不願透露')),
              ],
              onChanged: (value) => setState(() => selectedGender = value),
            ),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: () {
                showCountryPicker(
                  context: context,
                  showPhoneCode: false,
                  onSelect: (Country country) {
                    setState(() {
                      selectedCountry = country.name;
                    });
                  },
                );
              },
              child: AbsorbPointer(
                child: TextField(
                  controller: TextEditingController(text: selectedCountry ?? ''),
                  decoration: const InputDecoration(labelText: '國籍'),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text('常搭的捷運線', style: TextStyle(fontWeight: FontWeight.bold)),
            ...allLines.map((line) => CheckboxListTile(
                  title: Text(line),
                  value: selectedLines.contains(line),
                  onChanged: (checked) {
                    setState(() {
                      if (checked == true) {
                        selectedLines.add(line);
                      } else {
                        selectedLines.remove(line);
                      }
                    });
                  },
                )),
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
