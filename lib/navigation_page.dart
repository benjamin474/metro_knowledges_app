import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:taipei_metro_app/account/signin_page.dart';
import 'metro/metro_travel_page.dart';
import 'news/news_page.dart';
import 'account/settings_page.dart';

class NavigationPage extends StatefulWidget {
  final String userToken;

  const NavigationPage({super.key, required this.userToken});

  @override
  State<NavigationPage> createState() => _NavigationPageState();
}

class _NavigationPageState extends State<NavigationPage> {
  ThemeMode _themeMode = ThemeMode.light;
  String quote = '';
  String author = '';

  void _toggleTheme() {
    setState(() {
      _themeMode =
          _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    });
  }

  @override
  void initState() {
    super.initState();
    fetchQuoteOfTheDay();
  }

  Future<void> fetchQuoteOfTheDay() async {
    try {
      final url = Uri.parse('https://favqs.com/api/qotd');
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          quote = data['quote']['body'];
          author = data['quote']['author'];
        });
      } else {
        setState(() {
          quote = '無法取得每日名言';
          author = '';
        });
      }
    } catch (e) {
      setState(() {
        quote = '發生錯誤，無法取得每日名言';
        author = '';
      });
    }
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
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Text(
                      '每日名言',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '"$quote"',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '- $author',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.article),
                          tooltip: '新聞',
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const NewsPage()),
                            );
                          },
                        ),
                        const Text('新聞'),
                      ],
                    ),
                    const SizedBox(width: 32),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.train),
                          tooltip: '行車時長',
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
                        const Text('行車時長'),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}