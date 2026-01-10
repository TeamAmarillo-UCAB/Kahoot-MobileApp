import 'package:flutter/material.dart';

class ExploracionBusquedaPage extends StatefulWidget {
  const ExploracionBusquedaPage({Key? key}) : super(key: key);

  @override
  State<ExploracionBusquedaPage> createState() => _ExploracionBusquedaPageState();
}

class _ExploracionBusquedaPageState extends State<ExploracionBusquedaPage> {
  static const Color bgBrown = Color(0xFF3A240C);
  static const Color headerYellow = Color(0xFFF2C147);
  static const Color textYellow = Color(0xFFF2C147);
  static const Color cardBrown = Color(0xFF5C3A0C);
  static const Color cardYellow = Color(0xFFF2C147);

  bool _showSearch = false;
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgBrown,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  Expanded(
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 250),
                      child: _showSearch
                          ? Container(
                              key: const ValueKey('searchBar'),
                              height: 40,
                              decoration: BoxDecoration(
                                color: headerYellow.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: TextField(
                                controller: _searchController,
                                autofocus: true,
                                style: const TextStyle(color: Colors.white),
                                cursorColor: headerYellow,
                                decoration: InputDecoration(
                                  hintText: 'Buscar un kahoot...',
                                  hintStyle: TextStyle(color: headerYellow.withOpacity(0.7)),
                                  border: InputBorder.none,
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                                ),
                                onSubmitted: (_) => setState(() => _showSearch = false),
                              ),
                            )
                          : const SizedBox.shrink(),
                    ),
                  ),
                  IconButton(
                    key: const ValueKey('searchIcon'),
                    icon: Icon(_showSearch ? Icons.close : Icons.search, color: headerYellow, size: 28),
                    onPressed: () {
                      setState(() {
                        if (_showSearch) {
                          _searchController.clear();
                        }
                        _showSearch = !_showSearch;
                      });
                    },
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(24),
                children: [
                  const SizedBox(height: 8),
                  Icon(Icons.search, color: headerYellow, size: 48),
                  const SizedBox(height: 16),
                  Text(
                    '¡Explora Kahoots!',
                    style: TextStyle(
                      color: textYellow,
                      fontWeight: FontWeight.bold,
                      fontSize: 28,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Busca o descubre los mejores Kahoots para ti',
                    style: TextStyle(
                      color: headerYellow.withOpacity(0.85),
                      fontSize: 16,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  _KahootCard(
                    title: 'Historia de la Navidad en Europa',
                    author: 'Wikipedia_Espanol',
                    color: cardBrown,
                    number: 1,
                  ),
                  _KahootCard(
                    title: 'Datos curiosos de Navidad',
                    author: 'KStudio_Espanol',
                    color: cardYellow,
                    number: 2,
                    textColor: bgBrown,
                  ),
                  _KahootCard(
                    title: 'Adornos de Navidad',
                    author: 'Wikipedia_Espanol',
                    color: cardBrown,
                    number: 3,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _KahootCard extends StatelessWidget {
  final String title;
  final String author;
  final Color color;
  final int number;
  final Color? textColor;
  const _KahootCard({
    required this.title,
    required this.author,
    required this.color,
    required this.number,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.transparent,
          child: Text('$number', style: TextStyle(color: textColor ?? Colors.white, fontWeight: FontWeight.bold)),
        ),
        title: Text(
          title,
          style: TextStyle(color: textColor ?? Colors.white, fontWeight: FontWeight.bold),
        ),
        subtitle: Row(
          children: [
            Icon(Icons.verified, color: textColor ?? Colors.amber, size: 16),
            const SizedBox(width: 4),
            Text(
              author,
              style: TextStyle(color: (textColor ?? Colors.white).withOpacity(0.8), fontSize: 13),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: (textColor ?? Colors.white).withOpacity(0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text('Gratis', style: TextStyle(color: textColor ?? Colors.white, fontSize: 11)),
            ),
          ],
        ),
        trailing: Icon(Icons.chevron_right, color: textColor ?? Colors.white54),
      ),
    );
  }
}
