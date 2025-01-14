// lib/main.dart
import 'package:card_scanner/screens/bottom_navigation.dart';
import 'package:card_scanner/screens/camer_screen.dart';
import 'package:card_scanner/screens/report.dart';
import 'package:card_scanner/services/storage.dart';

import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final storageService = StorageService();
  await storageService.initialize();
  runApp(BusinessCardScannerApp(storageService: storageService));
}

class BusinessCardScannerApp extends StatelessWidget {
  final StorageService storageService;

  const BusinessCardScannerApp({Key? key, required this.storageService}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(storageService: storageService),
    );
  }
}
