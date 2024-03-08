import 'package:shared_preferences/shared_preferences.dart';

class AppConfig {
  // Singleton instance
  static final AppConfig _instance = AppConfig._internal();

  // Private constructor
  AppConfig._internal();

  // Getter for the singleton instance
  factory AppConfig() {
    return _instance;
  }

  // Getter for the Flask server URL
  Future<String> getFlaskServerUrl() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('flaskServerUrl') ?? 'http://192.168.114.241:5000';
  }

  // Setter for updating the Flask server URL
  Future<void> setFlaskServerUrl(String newUrl) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('flaskServerUrl', newUrl);
  }
}
