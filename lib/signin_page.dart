import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:taipei_metro_app/metro_csv_viewer.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';

class SignInPage extends StatefulWidget {
  @override
  _SignInPageState createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  String? _message;

  Future<void> _signIn() async {
    final url = Uri.parse('https://favqs.com/api/session');
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Token 3e687cb605c84f63f072330a2efe7f25',
      },
      body: jsonEncode({
        'user': {
          'login': _usernameController.text,
          'password': _passwordController.text,
        },
      }),
    );

    if (response.statusCode == 200) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => MetroCsvViewer()),
      );
    } else {
      setState(() {
        _message = '登入失敗: ${jsonDecode(response.body)['message']}';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('登入系統'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _usernameController,
              decoration: InputDecoration(labelText: '用戶名'),
            ),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: '密碼'),
              obscureText: true,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _signIn,
              child: Text('登入'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => RegisterPage()),
                );
              },
              child: Text('註冊'),
            ),
            if (_message != null) ...[
              SizedBox(height: 20),
              Text(
                _message!,
                style: TextStyle(color: Colors.red, fontSize: 16),
              ),
            ]
          ],
        ),
      ),
    );
  }
}

class RegisterPage extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  String? _message;

  Future<void> _register() async {
    final url = Uri.parse('https://favqs.com/api/users');
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Token 3e687cb605c84f63f072330a2efe7f25',
      },
      body: jsonEncode({
        'user': {
          'login': _usernameController.text,
          'password': _passwordController.text,
        },
      }),
    );

    if (response.statusCode == 200) {
      setState(() {
        _message = '註冊成功，請返回登入';
      });
    } else {
      setState(() {
        _message = '註冊失敗: ${jsonDecode(response.body)['message']}';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('註冊系統'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _usernameController,
              decoration: InputDecoration(labelText: '用戶名'),
            ),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: '密碼'),
              obscureText: true,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _register,
              child: Text('註冊'),
            ),
            if (_message != null) ...[
              SizedBox(height: 20),
              Text(
                _message!,
                style: TextStyle(color: Colors.red, fontSize: 16),
              ),
            ]
          ],
        ),
      ),
    );
  }
}