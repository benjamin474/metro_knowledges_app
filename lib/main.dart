import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:taipei_metro_app/metro_travel_page.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<void> main() async {
  await dotenv.load();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Metro Travel Demo',
      theme: ThemeData(useMaterial3: true),
      home: const MetroTravelPage(), // 正確入口頁
    );
  }
}
