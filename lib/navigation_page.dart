import 'package:flutter/material.dart';
import 'package:taipei_metro_app/account/signin_page.dart';
import 'metro_travel_page.dart';

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
        body: MetroTravelPage(
          onToggleTheme: _toggleTheme,
          themeMode: _themeMode,
        ),
      ),
    );
  }
}