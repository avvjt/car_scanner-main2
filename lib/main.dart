// lib/main.dart
import 'package:card_scanner/screens/bottom_navigation.dart';

import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Permission.storage.request();
  await Permission.manageExternalStorage.request();
  runApp(BusinessCardScannerApp());
}

class BusinessCardScannerApp extends StatelessWidget {

  const BusinessCardScannerApp({Key? key})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}
