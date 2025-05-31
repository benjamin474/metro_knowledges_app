import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'account/signin_page.dart';
import 'utils/csv_storage.dart';

class ThemeNotifier extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.light;

  ThemeMode get themeMode => _themeMode;

  Future<void> loadThemePreference() async {
    final theme = await CsvStorage.getThemePreference();
    _themeMode = theme == 'dark' ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }

  Future<void> toggleTheme() async {
    _themeMode = _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    await CsvStorage.saveThemePreference(_themeMode == ThemeMode.dark);
    notifyListeners();
  }
}

Future<void> main() async {
  await dotenv.load(fileName: 'assets/.env');
  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeNotifier()..loadThemePreference(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: '登入系統',
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      themeMode: themeNotifier.themeMode,
      home: SignInPage(),
    );
  }
}
