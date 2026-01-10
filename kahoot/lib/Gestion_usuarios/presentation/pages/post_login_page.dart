import 'package:flutter/material.dart';
import 'settings_page.dart';
import '../../../main.dart';
import '../../../core/auth_state.dart';

class PostLoginPage extends StatelessWidget {
  const PostLoginPage({Key? key}) : super(key: key);

  static const Color bgBrown = Color(0xFF3A240C);
  static const Color headerYellow = Color(0xFFF2C147);
  static const Color cardDark = Color(0xFF4A3A23);
  static const Color borderYellow = Color(0xFFA46000);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgBrown,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: const [
              _Header(),
              SizedBox(height: 20),
              _ProfilesRow(),
              SizedBox(height: 20),
              _MenuCards(),
              SizedBox(height: 16),
              _StatsList(),
            ],
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: PostLoginPage.headerYellow,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(color: Color(0x66000000), blurRadius: 6, offset: Offset(0, 2)),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.close, color: Colors.brown),
                onPressed: () {
                  // Salir a Home: limpia el stack y navega a MainShell
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (_) => const MainShell()),
                    (route) => false,
                  );
                },
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.edit, color: Colors.brown),
                onPressed: () {},
              ),
              IconButton(
                icon: const Icon(Icons.settings, color: Colors.brown),
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const SettingsPage()),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 12),
          ValueListenableBuilder<String?>(
            valueListenable: AuthState.username,
            builder: (context, username, _) {
              final display = (username ?? 'usuario');
              final initial = display.isNotEmpty ? display[0].toUpperCase() : 'U';
              return Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _Avatar(initial: initial, username: display),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  final String initial;
  final String username;
  const _Avatar({required this.initial, required this.username});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
            border: Border.all(color: PostLoginPage.headerYellow, width: 3),
          ),
          alignment: Alignment.center,
          child: Text(initial, style: const TextStyle(color: Colors.brown, fontSize: 36, fontWeight: FontWeight.bold)),
        ),
        const SizedBox(height: 8),
        Text(username, style: const TextStyle(color: Colors.brown, fontWeight: FontWeight.bold)),
      ],
    );
  }
}

class _ProfilesRow extends StatelessWidget {
  const _ProfilesRow();
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: const [
        _KidsTile(),
      ],
    );
  }
}

class _KidsTile extends StatelessWidget {
  const _KidsTile();
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 70,
          height: 70,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.black,
            border: Border.all(color: PostLoginPage.headerYellow, width: 3),
          ),
          alignment: Alignment.center,
          child: const Text('kids', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ),
        const SizedBox(height: 8),
        const Text('Añadir niño', style: TextStyle(color: Colors.white)),
      ],
    );
  }
}

class _MenuCards extends StatelessWidget {
  const _MenuCards();
  @override
  Widget build(BuildContext context) {
    return Column(
      children: const [
        _MenuTile(title: 'Tu plan y funciones', icon: Icons.auto_awesome),
        SizedBox(height: 8),
        _MenuTile(title: 'Tu contenido comprado', icon: Icons.shopping_cart),
      ],
    );
  }
}

class _MenuTile extends StatelessWidget {
  final String title;
  final IconData icon;
  const _MenuTile({required this.title, required this.icon});
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: PostLoginPage.cardDark,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: PostLoginPage.borderYellow, width: 1),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      child: Row(
        children: [
          Icon(icon, color: PostLoginPage.headerYellow),
          const SizedBox(width: 10),
          Expanded(child: Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
          const Icon(Icons.chevron_right, color: Colors.white70),
        ],
      ),
    );
  }
}

class _StatsList extends StatelessWidget {
  const _StatsList();
  final List<Map<String, String>> stats = const [
    {'label': 'Kahoots creados', 'value': '0'},
    {'label': 'Kahoots presentados', 'value': '0'},
    {'label': 'Kahoots asignados jugados', 'value': '0'},
    {'label': 'Kahoots en vivo jugados', 'value': '0'},
    {'label': 'Total de juegos jugados', 'value': '0'},
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: stats
          .map(
            (e) => Container(
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                color: PostLoginPage.cardDark,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: PostLoginPage.borderYellow, width: 1),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              child: Row(
                children: [
                  Expanded(child: Text(e['label']!, style: const TextStyle(color: Colors.white))),
                  Text(e['value']!, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          )
          .toList(),
    );
  }
}
