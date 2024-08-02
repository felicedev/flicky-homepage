import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:async'; // Import per Timer e altre funzioni async
import 'config.dart';  // Importa la classe Config

class HomePage extends StatefulWidget {
  final Position? position;

  HomePage({this.position});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<String> _imagePaths = [
    'assets/image1.jpg',
    'assets/image2.jpg',
    'assets/image3.jpg'
  ];
  int _currentIndex = 0;
  DateTime _currentTime = DateTime.now();
  double _fontSize = 20.0;
  String _infoPosition = 'Basso - Destra'; // Posizione predefinita del riquadro

  @override
  void initState() {
    super.initState();
    _startImageSlider();
    _startClock();
  }

  void _startImageSlider() {
    Timer.periodic(Duration(seconds: 5), (timer) {
      setState(() {
        _currentIndex = (_currentIndex + 1) % _imagePaths.length;
      });
    });
  }

  void _startClock() {
    Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        _currentTime = DateTime.now();
      });
    });
  }

  String _formattedDate() {
    final dayOfWeek = _currentTime.weekday;
    final month = _currentTime.month;
    final day = _currentTime.day;
    final year = _currentTime.year;

    final daysOfWeek = ['Lun', 'Mar', 'Mer', 'Gio', 'Ven', 'Sab', 'Dom'];
    final months = [
      'Gennaio', 'Febbraio', 'Marzo', 'Aprile', 'Maggio', 'Giugno',
      'Luglio', 'Agosto', 'Settembre', 'Ottobre', 'Novembre', 'Dicembre'
    ];

    return '${daysOfWeek[dayOfWeek - 1]} ${day.toString().padLeft(2, '0')} ${months[month - 1]} ${year}';
  }

  IconData _getWeatherIcon() {
    final weather = Config.weatherData?['weather'] ?? '';
    switch (weather.toLowerCase()) {
      case 'clear':
        return Icons.wb_sunny;
      case 'clouds':
        return Icons.cloud;
      case 'rain':
        return Icons.beach_access;
      case 'snow':
        return Icons.ac_unit;
      case 'thunderstorm':
        return Icons.flash_on;
      default:
        return Icons.help_outline;
    }
  }

  void _showSettingsDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Impostazioni'),
          content: Container(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Impostazioni di posizione
                Text('Posizione'),
                SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _positionOptionButton('Alto - Sinistra'),
                    _positionOptionButton('Alto - Destra'),
                    _positionOptionButton('Basso - Sinistra'),
                    _positionOptionButton('Basso - Destra'),
                  ],
                ),
                SizedBox(height: 16),
                // Modifica font
                Text('Modifica Font'),
                SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: [
                    _fontAdjustmentButton('-', -5),
                    _fontAdjustmentButton('+', 5),
                    _fontAdjustmentButton('+10%', 0.1),
                    _fontAdjustmentButton('+20%', 0.2),
                    _fontAdjustmentButton('+50%', 0.5),
                    _fontAdjustmentButton('-10%', -0.1),
                    _fontAdjustmentButton('-20%', -0.2),
                    _fontAdjustmentButton('-50%', -0.5),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: Text('Chiudi'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Widget _positionOptionButton(String label) {
    return ElevatedButton(
      onPressed: () {
        setState(() {
          _infoPosition = label;
        });
        Navigator.of(context).pop(); // Chiude il dialog
      },
      child: Text(label),
    );
  }

  Widget _fontAdjustmentButton(String label, double adjustment) {
    return ElevatedButton(
      onPressed: () {
        setState(() {
          if (label.contains('%')) {
            _fontSize *= (1 + adjustment);
          } else {
            _fontSize += adjustment;
            if (_fontSize < 10) _fontSize = 10; // Limita la dimensione minima
          }
        });
      },
      child: Text(label),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isFullscreen = MediaQuery.of(context).orientation == Orientation.landscape;

    double _calculateFontSize(double baseSize) {
      // Calcola la dimensione del font in base alla larghezza dello schermo e modalità fullscreen
      return baseSize * (screenSize.width / 1280) * (isFullscreen ? 1.5 : 1);
    }

    final fontSizeSmall = _calculateFontSize(20);
    final fontSizeMedium = _calculateFontSize(24);
    final fontSizeLarge = _calculateFontSize(_fontSize);

    final weatherData = Config.weatherData;
    final temperature = weatherData?['temperature'] ?? 'N/A';
    final cityName = weatherData?['city'] ?? 'N/A';

    // Posizionamento del riquadro
    late AlignmentGeometry alignment;
    switch (_infoPosition) {
      case 'Alto - Sinistra':
        alignment = Alignment.topLeft;
        break;
      case 'Alto - Destra':
        alignment = Alignment.topRight;
        break;
      case 'Basso - Sinistra':
        alignment = Alignment.bottomLeft;
        break;
      case 'Basso - Destra':
        alignment = Alignment.bottomRight;
        break;
      default:
        alignment = Alignment.bottomRight;
    }

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Positioned.fill(
            child: Image.asset(
              _imagePaths[_currentIndex],
              fit: BoxFit.cover,
              alignment: Alignment.center,
            ),
          ),
          Positioned(
            top: 15,
            right: 15,
            child: MenuButton(),
          ),
          Align(
            alignment: alignment,
            child: Padding(
              padding: EdgeInsets.all(15),
              child: IntrinsicWidth(
                child: Container(
                  padding: EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (weatherData != null)
                        Row(
                          children: [
                            Icon(_getWeatherIcon(), color: Colors.white, size: fontSizeMedium),
                            SizedBox(width: 8),
                            Text(temperature, style: TextStyle(color: Colors.white, fontSize: fontSizeMedium)),
                            SizedBox(width: 8),
                            Text(cityName, style: TextStyle(color: Colors.white, fontSize: fontSizeMedium)),
                          ],
                        ),
                      SizedBox(height: 8),
                      Text(
                        _formattedDate(),
                        style: TextStyle(color: Colors.white, fontSize: fontSizeSmall),
                      ),
                      SizedBox(height: 16),
                      Text(
                        '${_currentTime.hour.toString().padLeft(2, '0')}:${_currentTime.minute.toString().padLeft(2, '0')}',
                        style: TextStyle(color: Colors.white, fontSize: fontSizeLarge, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class MenuButton extends StatefulWidget {
  @override
  _MenuButtonState createState() => _MenuButtonState();
}

class _MenuButtonState extends State<MenuButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: () {
          // Aggiungi qui la logica per il click
        },
        child: Container(
          width: 50, // Larghezza del cerchio
          height: 50, // Altezza del cerchio
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: _isHovered ? Colors.grey[700]?.withAlpha(600) : Colors.grey[500]?.withAlpha(600), // Cambia colore al passaggio del mouse
          ),
          child: Center(
            child: Icon(
              Icons.menu,
              color: Colors.white,
              size: 24,
            ),
          ),
        ),
      ),
    );
  }
}
