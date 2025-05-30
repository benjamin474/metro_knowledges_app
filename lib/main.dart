import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'signin_page.dart';

Future<void> main() async {
  await dotenv.load(fileName: 'assets/.env');
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '登入系統',
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      home: const SignInPage(),
    );
  }
}
