import 'package:flutter/material.dart';
import 'package:veripic_1/splash_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const VeriPicApp());
}

class VeriPicApp extends StatelessWidget {
  const VeriPicApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'VeriPic',
      theme: ThemeData(
        primarySwatch: Colors.blue
      ),
      home: const SplashScreen(),
    );
  }
}