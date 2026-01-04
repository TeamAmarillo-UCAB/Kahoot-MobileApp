import 'package:flutter/material.dart';

class CustomBottomNav extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const CustomBottomNav({
    Key? key,
    required this.currentIndex,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTap,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: Colors.blue, // Color primario de Quizzy
      unselectedItemColor: Colors.grey,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Inicio'),
        BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Descubre'),
        BottomNavigationBarItem(icon: Icon(Icons.login), label: 'Unirse'),
        BottomNavigationBarItem(
          icon: Icon(Icons.add_circle_outline),
          label: 'Crear',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.library_books),
          label: 'Biblioteca',
        ),
      ],
    );
  }
}
