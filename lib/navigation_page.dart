import 'package:flutter/material.dart';
import 'package:taipei_metro_app/account/signin_page.dart';
import 'metro_travel_page.dart';
import 'news_page.dart';
import 'account/settings_page.dart';

class NavigationPage extends StatefulWidget {
  final String userToken;

  const NavigationPage({super.key, required this.userToken});

  @override
  State<NavigationPage> createState() => _NavigationPageState();
}

class _NavigationPageState extends State<NavigationPage> {
  ThemeMode _themeMode = ThemeMode.light;

  void _toggleTheme() {
    setState(() {
      _themeMode =
          _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      themeMode: _themeMode,
      home: Scaffold(
        appBar: AppBar(
          title: const Text('導覽頁面'),
          actions: [
            IconButton(
              icon: const Icon(Icons.settings),
              tooltip: '設定',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SettingsPage()),
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const SignInPage()),
                );
              },
            ),
          ],
        ),
        body: SafeArea(
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.article),
                  tooltip: '最新新聞',
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const NewsPage()),
                    );
                  },
                ),
                const SizedBox(width: 32),
                IconButton(
                  icon: const Icon(Icons.train),
                  tooltip: '行車查詢',
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => MetroTravelPage(
                          onToggleTheme: _toggleTheme,
                          themeMode: _themeMode,
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}