import 'package:flutter/material.dart';
import '../../../core/widgets/gradient_button.dart';
import '../login_page.dart';
import '../register_page.dart';

class AccountPage extends StatelessWidget {
  const AccountPage({Key? key}) : super(key: key);

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
            children: [
              _HeaderCard(),
              const SizedBox(height: 20),
              _ProfilesRow(),
              const SizedBox(height: 20),
              _MenuCards(),
              const SizedBox(height: 16),
              _StatsList(),
            ],
          ),
        ),
      ),
    );
  }
}

class _HeaderCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AccountPage.headerYellow,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(color: Color(0x66000000), blurRadius: 6, offset: Offset(0, 2))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.close, color: Colors.brown),
                onPressed: () => Navigator.of(context).pop(),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.settings, color: Colors.brown),
                onPressed: () {},
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'Inicia sesión para más',
            style: TextStyle(color: Colors.brown, fontWeight: FontWeight.bold, fontSize: 18),
          ),
          const SizedBox(height: 4),
          const Text(
            'Crea y guarda kahoots, y accede a más funciones con una cuenta de Kahoot!',
            style: TextStyle(color: Colors.brown),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              GradientButton(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const LoginPage()),
                  );
                },
                child: const Text('Iniciar sesión', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(width: 10),
              GradientButton(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const RegisterPage()),
                  );
                },
                child: const Text('Registrarse', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ProfilesRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _ProfileIcon(label: 'Tú', icon: Icons.person),
        _ProfileIcon(label: 'Añadir niño', icon: Icons.child_care),
      ],
    );
  }
}

class _ProfileIcon extends StatelessWidget {
  final String label;
  final IconData icon;
  const _ProfileIcon({required this.label, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 70,
          height: 70,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
            border: Border.all(color: AccountPage.headerYellow, width: 3),
          ),
          child: Icon(icon, color: Colors.brown, size: 36),
        ),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(color: Colors.white)),
      ],
    );
  }
}

class _MenuCards extends StatelessWidget {
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
        color: AccountPage.cardDark,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AccountPage.borderYellow, width: 1),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      child: Row(
        children: [
          Icon(icon, color: AccountPage.headerYellow),
          const SizedBox(width: 10),
          Expanded(
            child: Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
          const Icon(Icons.chevron_right, color: Colors.white70),
        ],
      ),
    );
  }
}

class _StatsList extends StatelessWidget {
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
                color: AccountPage.cardDark,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AccountPage.borderYellow, width: 1),
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
