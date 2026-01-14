import 'package:flutter/material.dart';
import '../../config/api_config.dart';

class BackendSelector extends StatefulWidget {
  const BackendSelector({Key? key}) : super(key: key);

  @override
  State<BackendSelector> createState() => _BackendSelectorState();
}

class _BackendSelectorState extends State<BackendSelector> {
  final Map<String, String> _serverOptions = {
    'Alpha': 'https://quizzy-backend-1-zpvc.onrender.com/api',
    'Beta': 'https://backcomun-mzvy.onrender.com',
    'Alpha Priv': 'https://quizzy-backend.app/api',
  };

  String? _selectedServerKey;

  @override
  void initState() {
    super.initState();
    _initializeSelection();
  }

  void _initializeSelection() {
    try {
      final currentUrl = ApiConfig().baseUrl;
      // Busca la llave que coincida con la URL actual del Singleton
      final entry = _serverOptions.entries.firstWhere(
        (element) => element.value == currentUrl,
        orElse: () => _serverOptions.entries.first,
      );
      _selectedServerKey = entry.key;
    } catch (e) {
      _selectedServerKey = _serverOptions.keys.first;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 20),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white30),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          dropdownColor: const Color(0xFF9A5C0A),
          value: _selectedServerKey,
          icon: const Icon(Icons.dns, color: Colors.white70, size: 20),
          isDense: true,
          style: const TextStyle(color: Colors.white, fontSize: 12),
          items: _serverOptions.keys.map((String key) {
            return DropdownMenuItem<String>(
              value: key,
              child: Text(
                "$key Env",
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            );
          }).toList(),
          onChanged: (String? newValue) {
            if (newValue != null) {
              setState(() {
                _selectedServerKey = newValue;
                print(_serverOptions[newValue]);
                ApiConfig().setUrl(_serverOptions[newValue]!);
              });

              // Opcional: Mostrar un pequeño aviso
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text("Entorno cambiado a: $newValue"),
                  duration: const Duration(seconds: 1),
                  backgroundColor: Colors.amber[700],
                ),
              );
            }
          },
        ),
      ),
    );
  }
}
