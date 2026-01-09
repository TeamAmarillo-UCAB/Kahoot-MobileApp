import 'package:flutter/material.dart';
import 'profile_configuration.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  static const Color bgBrown = Color(0xFF3A240C);
  static const Color headerYellow = Color(0xFFF2C147);
  static const Color cardDark = Color(0xFF4A3A23);
  static const Color borderYellow = Color(0xFFA46000);

  bool music = true;
  bool soundEffects = true;
  bool haptics = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgBrown,
      appBar: AppBar(
        backgroundColor: bgBrown,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Configuración', style: TextStyle(color: Colors.white)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _SectionTitle('Perfil'),
          _MenuTile('Configuración del perfil', onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const ProfileConfigurationPage()),
            );
          }),
          _MenuTile('Configuración de privacidad'),
          _MenuTile('Eliminar cuenta'),
          _MenuTile('Cerrar sesión'),
          const SizedBox(height: 16),
          _SectionTitle('General'),
          _MenuTile('Idioma'),
          const SizedBox(height: 16),
          _SectionTitle('Música y hápticos'),
          _SwitchTile('Música', music, (v) => setState(() => music = v)),
          _SwitchTile('Efectos de sonido', soundEffects, (v) => setState(() => soundEffects = v)),
          _SwitchTile('Hápticos', haptics, (v) => setState(() => haptics = v)),
        ],
      ),
    );
  }

  Widget _SectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(text, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
    );
  }

  Widget _MenuTile(String title, {VoidCallback? onTap}) {
    return Container(
      decoration: BoxDecoration(
        color: cardDark,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: borderYellow, width: 1),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: onTap,
        child: Row(
          children: [
            Expanded(child: Text(title, style: const TextStyle(color: Colors.white))),
            const Icon(Icons.chevron_right, color: Colors.white70),
          ],
        ),
      ),
    );
  }

  Widget _SwitchTile(String title, bool value, ValueChanged<bool> onChanged) {
    return Container(
      decoration: BoxDecoration(
        color: cardDark,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: borderYellow, width: 1),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      margin: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Expanded(child: Text(title, style: const TextStyle(color: Colors.white))),
          Switch(
            value: value,
            activeColor: headerYellow,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}
