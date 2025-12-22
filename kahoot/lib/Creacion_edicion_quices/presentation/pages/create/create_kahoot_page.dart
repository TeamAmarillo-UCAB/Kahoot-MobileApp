import 'package:flutter/material.dart';
import '../../widgets/kahoot_details_page.dart';

class CreateKahootPage extends StatelessWidget {
  const CreateKahootPage({Key? key}) : super(key: key);

  static const Color bgBrown = Color(0xFF3A240C);
  static const Color headerYellow = Color(0xFFFFD36F);
  static const Color cardYellow = Color(0xFFFFB300);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgBrown,
      appBar: AppBar(
        backgroundColor: headerYellow,
        title: TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.0, end: 1.0),
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeOut,
          builder: (context, t, child) => Opacity(
            opacity: t,
            child: Transform.translate(offset: Offset(0, (1 - t) * 8), child: child),
          ),
          child: const Text('Crear', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        ),
        centerTitle: true,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: Column(
          children: [
            _AnimatedAppear(
              delayMs: 80,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: cardYellow,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: const [BoxShadow(color: Color(0x66000000), blurRadius: 6, offset: Offset(0, 2))],
                  border: Border.all(color: Color(0xFFA46000), width: 1),
                ),
                child: _TemplateCard(
                  icon: Icons.brush,
                  title: 'Lienzo en blanco',
                  subtitle: 'Toma el control total de la creación de kahoots',
                  onTap: () async {
                    final result = await Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const KahootDetailsPage()),
                    );
                    if (result is Map && result['saved'] == true) {
                      final String title = (result['title'] as String?) ?? 'Kahoot';
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('$title guardado.')),
                      );
                    }
                  },
                ),
              ),
            ),
          ],
        ),
      ),
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
        child: TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.98, end: 1.0),
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeOutBack,
          builder: (context, scale, child) => Transform.scale(scale: scale, child: child),
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
      ),
    );
  }
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

// Removed local list and footer: navigation controlled by MainShell footer.
