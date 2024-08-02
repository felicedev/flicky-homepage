import 'package:flutter/material.dart';
import 'splash.dart';
import 'config.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Config.loadConfig();  // Carica la configurazione
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: SplashScreen(
        pngAssetPath: 'assets/logo.png', // Sostituisci con il percorso corretto del tuo asset SVG
        backgroundColor: Colors.black,
        loaderColor: Colors.blue,
      ),
    );
  }
}