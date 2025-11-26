import 'package:flutter/material.dart';

class CreateKahootPage extends StatelessWidget {
  const CreateKahootPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF222222),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFD54F),
        title: const Text('Crear', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        centerTitle: true,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFFFFB300),
                borderRadius: BorderRadius.circular(12),
              ),
              child: _TemplateCard(
                icon: Icons.brush,
                title: 'Lienzo en blanco',
                subtitle: 'Toma el control total de la creación de kahoots',
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const _BlankEditorPage()),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _CreateBottomNav(currentIndex: 3),
    );
  }
}

class _TemplateCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  const _TemplateCard({required this.icon, required this.title, required this.subtitle, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFA46000),
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
          child: Row(
            children: [
              Icon(icon, color: Colors.black, size: 32),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text(subtitle, style: const TextStyle(color: Colors.white70, fontSize: 12)),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.white),
            ],
          ),
        ),
      ),
    );
  }
}

class _BlankEditorPage extends StatelessWidget {
  const _BlankEditorPage({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nuevo Kahoot')),
      body: const Center(child: Text('Editor en blanco (pendiente de implementar)')),
    );
  }
}

class _CreateBottomNav extends StatelessWidget {
  final int currentIndex;
  const _CreateBottomNav({required this.currentIndex});
  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      backgroundColor: const Color(0xFFFFD54F),
      selectedItemColor: Colors.brown,
      unselectedItemColor: Colors.brown.withOpacity(0.7),
      currentIndex: currentIndex,
      onTap: (index) {
        if (index == 3) return; // ya estamos en Crear
        Navigator.of(context).popUntil((r) => r.isFirst); // volver al root
      },
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Inicio'),
        BottomNavigationBarItem(icon: Icon(Icons.explore), label: 'Descubre'),
        BottomNavigationBarItem(icon: Icon(Icons.group), label: 'Unirse'),
        BottomNavigationBarItem(icon: Icon(Icons.add_circle_outline), label: 'Crear'),
        BottomNavigationBarItem(icon: Icon(Icons.library_books), label: 'Biblioteca'),
      ],
    );
  }
}
