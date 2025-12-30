import 'package:flutter/material.dart';
import 'kahoots_library_page.dart';

class BibliotecaPage extends StatelessWidget {
  const BibliotecaPage({Key? key}) : super(key: key);

  static const Color bgBrown = Color(0xFF3A240C);
  static const Color headerYellow = Color(0xFFFFD36F);
  static const Color cardYellow = Color(0xFFFFB300);
  static const Color dividerColor = Color(0xFFDAA520);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgBrown,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                child: Column(
                  children: [
                    _AnimatedAppear(
                      delayMs: 0,
                      child: _LibraryCard(
                        titleTop: 'Kahoots',
                        titleBottom: 'Informes',
                        topIcon: Icons.person_outline,
                        bottomIcon: Icons.bar_chart,
                        navigateTop: true,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _AnimatedAppear(
                      delayMs: 120,
                      child: _LibraryCard(
                        titleTop: 'Cursos',
                        titleBottom: 'Grupos',
                        topIcon: Icons.sticky_note_2_outlined,
                        bottomIcon: Icons.group,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _AnimatedAppear(
                      delayMs: 240,
                      child: const _SingleCard(
                        title: 'Tu aprendizaje',
                        icon: Icons.school,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Header eliminado según solicitud
}

class _AnimatedAppear extends StatefulWidget {
  final int delayMs;
  final Widget child;
  const _AnimatedAppear({required this.child, this.delayMs = 0});

  @override
  State<_AnimatedAppear> createState() => _AnimatedAppearState();
}

class _AnimatedAppearState extends State<_AnimatedAppear> {
  bool _visible = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(milliseconds: widget.delayMs), () {
      if (mounted) setState(() => _visible = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOut,
      opacity: _visible ? 1 : 0,
      child: AnimatedSlide(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOut,
        offset: _visible ? Offset.zero : const Offset(0, 0.06),
        child: widget.child,
      ),
    );
  }
}

class _LibraryCard extends StatelessWidget {
  final String titleTop;
  final String titleBottom;
  final IconData topIcon;
  final IconData bottomIcon;
  final bool navigateTop;
  const _LibraryCard({
    required this.titleTop,
    required this.titleBottom,
    required this.topIcon,
    required this.bottomIcon,
    this.navigateTop = false,
  });

  static const Color cardYellow = Color(0xFFFFB300);
  static const Color dividerColor = Color(0xFFDAA520);

  @override
  Widget build(BuildContext context) {
    final card = Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: cardYellow,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [BoxShadow(color: Color(0x66000000), blurRadius: 6, offset: Offset(0, 2))],
      ),
      child: Column(
        children: [
          _tile(context, topIcon, titleTop, top: true),
          const Divider(height: 1, thickness: 1, color: dividerColor),
          _tile(context, bottomIcon, titleBottom, top: false),
        ],
      ),
    );
    return card;
  }

  Widget _tile(BuildContext context, IconData icon, String title, {required bool top}) {
    final content = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      child: Row(
        children: [
          Icon(icon, color: Colors.black87),
          const SizedBox(width: 8),
          Text(title, style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w600)),
        ],
      ),
    );
    final isTopNavigable = navigateTop && top;
    return isTopNavigable
        ? InkWell(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const KahootsLibraryPage()),
              );
            },
            child: content,
          )
        : content;
  }
}

class _SingleCard extends StatelessWidget {
  final String title;
  final IconData icon;
  const _SingleCard({required this.title, required this.icon});

  static const Color cardYellow = Color(0xFFFFB300);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: cardYellow,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [BoxShadow(color: Color(0x66000000), blurRadius: 6, offset: Offset(0, 2))],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        child: Row(
          children: [
            Icon(icon, color: Colors.black87),
            const SizedBox(width: 8),
            Text(title, style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}