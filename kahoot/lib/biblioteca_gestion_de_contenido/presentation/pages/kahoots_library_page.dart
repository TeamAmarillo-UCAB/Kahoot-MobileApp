import 'package:flutter/material.dart';
import '../../../../Creacion_edicion_quices/domain/entities/kahoot.dart';
import '../../../../Creacion_edicion_quices/presentation/widgets/kahoot_details_page.dart';
import '../../../core/widgets/gradient_button.dart';

class KahootsLibraryPage extends StatelessWidget {
  final List<Kahoot> items;
  const KahootsLibraryPage({Key? key, this.items = const []}) : super(key: key);

  static const Color bgBrown = Color(0xFF3A240C);
  static const Color headerYellow = Color(0xFFFFB300);
  static const Color cardYellow = Color(0xFFFFB300);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgBrown,
      body: SafeArea(
        child: Column(
          children: [
            _header(context),
            Expanded(child: _grid(context)),
          ],
        ),
      ),
    );
  }

  Widget _header(BuildContext context) {
    return Container(
      color: headerYellow,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          GradientButton(
            onTap: () => Navigator.of(context).pop(),
            child: const Text('Volver', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
          const Spacer(),
          const Text('Mis Kahoots', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
          const Spacer(),
        ],
      ),
    );
  }

  Widget _grid(BuildContext context) {
    final data = items;
    if (data.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Text('No hay kahoots creados aún', style: TextStyle(color: Colors.white.withOpacity(0.85))),
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final crossAxisCount = constraints.maxWidth > 600 ? 3 : 2;
          return GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 0.7,
            ),
            itemCount: data.length,
            itemBuilder: (context, index) => _AnimatedAppear(
              delayMs: 60 * index,
              child: _KahootCard(item: data[index]),
            ),
          );
        },
      ),
    );
  }
}

class _KahootCard extends StatelessWidget {
  final Kahoot item;
  const _KahootCard({required this.item});

  static const Color cardYellow = Color(0xFFFFB300);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: cardYellow,
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [BoxShadow(color: Color(0x66000000), blurRadius: 6, offset: Offset(0, 2))],
        border: Border.all(color: Colors.blueAccent, width: item.visibility.toShortString() == 'public' ? 3 : 0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.image, color: Colors.black26, size: 48),
              ),
            ),
            const SizedBox(height: 8),
            Text(item.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text('Visibilidad: ${item.visibility.toShortString().capitalize()}', style: const TextStyle(color: Colors.black87)),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(children: const [
                  Icon(Icons.delete, size: 18, color: Colors.black87),
                  SizedBox(width: 8),
                  Icon(Icons.edit, size: 18, color: Colors.black87),
                ]),
                TextButton(
                  style: TextButton.styleFrom(backgroundColor: const Color(0xFFFFEE58), foregroundColor: Colors.black, padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6)),
                  onPressed: () {
                    Navigator.of(context).push(MaterialPageRoute(builder: (_) => KahootDetailsPage(initialKahoot: item)));
                  },
                  child: const Text('Ver detalle'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

extension _Cap on String {
  String capitalize() => isEmpty ? this : '${this[0].toUpperCase()}${substring(1)}';
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
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOut,
      opacity: _visible ? 1 : 0,
      child: AnimatedSlide(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOut,
        offset: _visible ? Offset.zero : const Offset(0, 0.08),
        child: widget.child,
      ),
    );
  }
}