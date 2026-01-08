import 'package:flutter/material.dart';
import 'Creacion_edicion_quices/presentation/pages/home/home_page.dart';
import 'exploracion_busqueda/presentation/exploracion_busqueda_page.dart';
import 'package:google_fonts/google_fonts.dart';
import 'biblioteca_gestion_de_contenido/presentation/pages/library_page.dart';
import 'Creacion_edicion_quices/presentation/pages/create/create_kahoot_page.dart';

const String apiBaseUrl = String.fromEnvironment('API_BASE_URL', defaultValue: 'https://quizzy-backend-0wh2.onrender.com/api'); //back 1
// const String apiBaseUrl = String.fromEnvironment('API_BASE_URL', defaultValue: 'https://backcomun-gc5j.onrender.com'); //back comun
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Kahoot',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFF2C147)),
        useMaterial3: true,
        textTheme: GoogleFonts.nunitoTextTheme(),
      ),
      home: const MainShell(),
    );
  }
}

// La página de creación real ahora está en create_kahoot_page.dart

class MainShell extends StatefulWidget {
  const MainShell({Key? key}) : super(key: key);

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _index = 0; // 0: Inicio, 3: Crear, 4: Biblioteca

  static const Color bgBrown = Color(0xFF3A240C);
  static const Color headerYellow = Color(0xFFF2C147);
  static const Color iconDarkYellow = Color(0xFFB67F16);

  @override
  Widget build(BuildContext context) {
    final pages = [
      HomePage(showFooter: false), // 0
      const ExploracionBusquedaPage(), // 1
      CreateKahootPage(), // 2
      BibliotecaPage(), // 3
    ];

    final body = IndexedStack(
      index: _index,
      children: pages,
    );

    return Scaffold(
      backgroundColor: bgBrown,
      body: SafeArea(child: body),
      bottomNavigationBar: _buildFooter(context),
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Container(
      color: headerYellow,
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _BottomNavItem(
            icon: Icons.home,
            label: 'Inicio',
            selected: _index == 0,
            iconSize: 28,
            onTap: () => setState(() => _index = 0),
          ),
          _BottomNavItem(
            icon: Icons.explore,
            label: 'Descubre',
            selected: _index == 1,
            iconSize: 28,
            onTap: () => setState(() => _index = 1),
          ),
          const _BottomNavItem(
            icon: Icons.group_add_outlined,
            label: 'Unirse',
            iconSize: 28,
          ),
          _BottomNavItem(
            icon: Icons.add_box,
            label: 'Crear',
            iconSize: 30,
            selected: _index == 2,
            onTap: () => setState(() => _index = 2),
          ),
          _BottomNavItem(
            icon: Icons.library_books,
            label: 'Biblioteca',
            selected: _index == 3,
            iconSize: 28,
            onTap: () => setState(() => _index = 3),
          ),
        ],
      ),
    );
  }
}

class _BottomNavItem extends StatefulWidget {
  final IconData? icon;
  final String label;
  final bool selected;
  final double iconSize;
  final VoidCallback? onTap;
  const _BottomNavItem({
    this.icon,
    required this.label,
    this.selected = false,
    this.iconSize = 24,
    this.onTap,
  });

  @override
  State<_BottomNavItem> createState() => _BottomNavItemState();
}

class _BottomNavItemState extends State<_BottomNavItem> {
  double _scale = 1.0;

  void _press(bool down) => setState(() => _scale = down ? 0.95 : 1.0);

  @override
  Widget build(BuildContext context) {
    final color = widget.selected ? Colors.brown : _MainShellState.iconDarkYellow;
    final content = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(widget.icon, color: color, size: widget.iconSize),
        const SizedBox(height: 2),
        Text(widget.label, style: TextStyle(color: color, fontWeight: widget.selected ? FontWeight.bold : FontWeight.normal, fontSize: 12)),
      ],
    );
    final child = Transform.translate(
      offset: const Offset(0, -3),
      child: AnimatedScale(
        scale: _scale,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        child: content,
      ),
    );
    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: (_) => _press(true),
      onTapUp: (_) => _press(false),
      onTapCancel: () => _press(false),
      child: Padding(padding: const EdgeInsets.all(4), child: child),
    );
  }
}


// Eliminado el badge de "Unirse" superpuesto y sus helpers.