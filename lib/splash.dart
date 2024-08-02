import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'home.dart';
import 'config.dart'; // Importa la classe Config

class SplashScreen extends StatefulWidget {
  final String pngAssetPath;
  final Color backgroundColor;
  final Color loaderColor;

  SplashScreen({
    required this.pngAssetPath,
    this.backgroundColor = Colors.white,
    this.loaderColor = Colors.blue,
  });

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkLocationPermission();
  }

  _checkLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Verifica se il servizio di geolocalizzazione è abilitato
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      _navigateToHome();
      return;
    }

    // Verifica lo stato del permesso di geolocalizzazione
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        _navigateToHome();
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      _navigateToHome();
      return;
    }

    // Permesso concesso, ottieni la posizione e fai la richiesta a OpenWeather
    await _fetchWeatherData();
    _navigateToHome();
  }

  Future<void> _fetchWeatherData() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      // Usa le coordinate della posizione per ottenere i dati meteo
      final response = await http.get(
        Uri.parse(
            'https://api.openweathermap.org/data/2.5/weather?lat=${position.latitude}&lon=${position.longitude}&appid=${Config.apiKey}&units=metric'),
      );

      if (response.statusCode == 200) {
        // Salva i dati meteo in Config
        final data = json.decode(response.body);
        Config.weatherData = {
          'temperature': data['main']['temp'].toString(),
          'weather': data['weather'][0]['description'],
          'city': data['name'],
        };
      } else {
        // Gestisci errori nella richiesta
        print('Failed to load weather data');
      }
    } catch (e) {
      print('Error fetching weather data: $e');
    }
  }

  _navigateToHome() async {
    // Attende 3 secondi (puoi cambiare il tempo di attesa se necessario)
    await Future.delayed(Duration(seconds: 3));

    // Naviga alla homepage
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => HomePage()), // Assicurati che HomePage sia implementata
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: widget.backgroundColor,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Container per l'immagine PNG
          Expanded(
            child: Center(
              child: Container(
                width: MediaQuery.of(context).size.width * 0.6, // 60% della larghezza dello schermo
                child: Image.asset(
                  widget.pngAssetPath,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
          // Spazio tra l'immagine e il loader
          SizedBox(height: 20),
          // Loader
          SpinKitFadingCircle(
            color: widget.loaderColor,
            size: 50.0,
          ),
          SizedBox(height: 30), // Spazio inferiore per evitare overflow
        ],
      ),
    );
  }
}
