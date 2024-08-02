class Config {
  static String? apiKey;
  static Map<String, String>? weatherData;

  static Future<void> loadConfig() async {
    // Carica la chiave API e altre configurazioni
    apiKey = '0547e840b7e8ab44080ae53e1d72b954'; // Sostituisci con la tua chiave API
  }
}
