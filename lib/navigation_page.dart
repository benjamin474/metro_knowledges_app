import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:taipei_metro_app/account/signin_page.dart';
import 'metro/metro_travel_page.dart';
import 'news/news_page.dart';
import 'account/settings_page.dart';
import 'metro/fare_distance_page.dart';
import 'metro/transfer_walking_time_page.dart';

class NavigationPage extends StatefulWidget {
  final String userToken;
  final String userAccount;

  const NavigationPage({super.key, required this.userToken, required this.userAccount});

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
    return Scaffold(
      appBar: AppBar(
        title: const Text('捷運小知識'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: '設定',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => SettingsPage(userAccount: widget.userAccount)),
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
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/wallpaper.jpeg'),
            fit: BoxFit.cover,
          ),
        ),
        child: RefreshIndicator(
          onRefresh: fetchQuoteOfTheDay,
          child: ListView(
            children: [
              // 每日名言區塊 - 深色漸層底+白字
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF232526), Color(0xFF414345)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                margin: const EdgeInsets.all(16),
                width: double.infinity,
                height: 200,
                child: InkWell(
                  splashColor: Colors.tealAccent.withOpacity(0.3),
                  highlightColor: Colors.blueAccent.withOpacity(0.15),
                  onTap: () async {
                    setState(() {
                      quote = '載入中...';
                      author = '';
                    });
                    await fetchQuoteOfTheDay();
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('每日名言',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge
                                  ?.copyWith(color: Colors.white)),
                          const SizedBox(height: 8),
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 300),
                            child: Text('"$quote"',
                                key: ValueKey(quote),
                                textAlign: TextAlign.center,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyLarge
                                    ?.copyWith(color: Colors.white70)),
                          ),
                          const SizedBox(height: 8),
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 300),
                            child: Text('- $author',
                                key: ValueKey(author),
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(color: Colors.white54)),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              // 四大功能導覽 - 淡色漸層底+深色字
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFFB2FEFA), Color(0xFFE0C3FC)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // News
                    AnimatedScale(
                      duration: const Duration(milliseconds: 500),
                      scale: 1.0,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                              icon: const Icon(Icons.article, color: Colors.black87),
                              tooltip: '新聞',
                              onPressed: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (_) => const NewsPage()));
                              }),
                          const Text('新聞', style: TextStyle(color: Colors.black87)),
                        ],
                      ),
                    ),
                    const SizedBox(width: 32),
                    // Travel Time
                    AnimatedScale(
                      duration: const Duration(milliseconds: 500),
                      scale: 1.0,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                              icon: const Icon(Icons.train, color: Colors.black87),
                              tooltip: '行車時長',
                              onPressed: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (_) => MetroTravelPage(
                                            onToggleTheme: _toggleTheme,
                                            themeMode: _themeMode)));
                              }),
                          const Text('行車時長', style: TextStyle(color: Colors.black87)),
                        ],
                      ),
                    ),
                    const SizedBox(width: 32),
                    // Fare & Distance
                    AnimatedScale(
                      duration: const Duration(milliseconds: 500),
                      scale: 1.0,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                              icon: const Icon(Icons.attach_money, color: Colors.black87),
                              tooltip: '票價距離',
                              onPressed: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (_) => const FareDistancePage()));
                              }),
                          const Text('票價距離', style: TextStyle(color: Colors.black87)),
                        ],
                      ),
                    ),
                    const SizedBox(width: 32),
                    // Transfer Walking
                    AnimatedScale(
                      duration: const Duration(milliseconds: 500),
                      scale: 1.0,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                              icon: const Icon(Icons.directions_walk, color: Colors.black87),
                              tooltip: '步行排行',
                              onPressed: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (_) => const TransferWalkingPage()));
                              }),
                          const Text('步行排行', style: TextStyle(color: Colors.black87)),
                        ],
                      ),
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