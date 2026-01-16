class ApiConfig {
  // Singleton: Para asegurar que siempre se use la misma instancia en toda la app
  static final ApiConfig _instance = ApiConfig._internal();
  factory ApiConfig() => _instance;
  ApiConfig._internal();

  // URL por defecto
  String _currentUrl = 'https://quizzy-backend-1-zpvc.onrender.com/api';

  // Getter para obtener la URL
  String get baseUrl => _currentUrl;

  // Setter para cambiar la URL
  void setUrl(String newUrl) {
    _currentUrl = newUrl;
    print("API URL cambiada a: $_currentUrl");
  }
}
