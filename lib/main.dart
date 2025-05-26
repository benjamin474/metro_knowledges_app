
import 'package:flutter/material.dart';
import 'package:taipei_metro_app/home_page.dart';
import 'package:taipei_metro_app/metro_csv_viewer.dart';

void main() async {
  // await dotenv.load(fileName: ".env");
  runApp(const MaterialApp(
    home: MetroCsvViewer(), 
  ));
}
