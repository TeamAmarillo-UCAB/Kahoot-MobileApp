import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../../core/widgets/gradient_button.dart';
import '../../../../Gestion_usuarios/presentation/pages/account_page.dart';
import '../../../../Gestion_usuarios/presentation/pages/post_login_page.dart';
import '../../../../core/auth_state.dart';
import '../create/create_kahoot_page.dart';
import '../../../../biblioteca_gestion_de_contenido/presentation/pages/library_page.dart';

class HomePage extends StatefulWidget {
  final bool showFooter;
  const HomePage({Key? key, this.showFooter = true}) : super(key: key);
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  late final AnimationController _catCtrl;
  late final AnimationController _arrowCtrl;

  static const Color bgBrown = Color(0xFF3A240C);
  static const Color headerYellow = Color(0xFFF2C147); // amarillo más vivo
  static const Color accentYellow = Color(0xFFE28A3B); // botones estilo pill
  static const Color textGold = Color(0xFFD9B36F);
  static const Color iconYellow = Color(0xFFC28B1A); // iconos amarillo oscuro

  @override
  void initState() {
    super.initState();
    _catCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _arrowCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _catCtrl.dispose();
    _arrowCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgBrown,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(child: _buildBody()),
            if (widget.showFooter) _buildFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOut,
      builder: (context, t, child) => Opacity(
        opacity: t,
        child: Transform.translate(
          offset: Offset(0, (1 - t) * 10),
          child: child,
        ),
      ),
      child: Container(
        color: headerYellow,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          children: [
            GestureDetector(
              onTap: () {
                final logged = AuthState.isLoggedIn.value;
                if (logged) {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const PostLoginPage()),
                  );
                } else {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const AccountPage()),
                  );
                }
              },
              child: CircleAvatar(
                backgroundColor: Colors.brown.shade200,
                radius: 22,
                child: Icon(
                  Icons.person,
                  color: Colors.brown.shade800,
                  size: 26,
                ),
              ),
            ),
            const SizedBox(width: 10),
            _LogoTitle(),
            const Spacer(),
            GradientButton(
              onTap: () {},
              child: const Text(
                'Actualizar',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  letterSpacing: 0.2,
                ),
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.notifications, size: 28),
              color: iconYellow,
              onPressed: () {},
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    return Stack(
      children: [
        Align(
          alignment: Alignment.topCenter,
          child: Column(
            children: [
              const SizedBox(height: 24),
              AnimatedBuilder(
                animation: _catCtrl,
                builder: (context, child) {
                  final dy = math.sin(_catCtrl.value * math.pi * 2) * 6;
                  return Transform.translate(
                    offset: Offset(0, dy),
                    child: child,
                  );
                },
                child: _SafeAsset(
                  path: 'assets/cat_kahoot.png',
                  fallback: Icon(Icons.brush, color: iconYellow, size: 120),
                  height: 120,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                '¡Hola!',
                style: TextStyle(
                  color: headerYellow,
                  fontSize: 34,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Unete a un Kahoot\no crealo tu mismo',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: textGold,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                height: 160,
                child: _AnimatedCreateArrow(progress: _arrowCtrl),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFooter() {
    return Container(
      color: headerYellow,
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          const _BottomNavItem(
            icon: Icons.home,
            label: 'Inicio',
            selected: true,
            iconSize: 28,
          ),
          const _BottomNavItem(
            icon: Icons.search,
            label: 'Descubre',
            iconSize: 28,
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
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const CreateKahootPage()),
              );
            },
          ),
          _BottomNavItem(
            icon: Icons.library_books,
            label: 'Biblioteca',
            iconSize: 28,
            onTap: () {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => const BibliotecaPage()),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _BottomNavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final double iconSize;
  final VoidCallback? onTap;
  const _BottomNavItem({
    required this.icon,
    required this.label,
    this.selected = false,
    this.iconSize = 24,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = selected ? Colors.brown : Colors.black54;
    final widget = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: iconSize),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            color: color,
            fontWeight: selected ? FontWeight.bold : FontWeight.normal,
            fontSize: 12,
          ),
        ),
      ],
    );
    return onTap != null
        ? InkWell(
            onTap: onTap,
            child: Padding(padding: const EdgeInsets.all(4), child: widget),
          )
        : widget;
  }
}

class _SafeAsset extends StatelessWidget {
  final String path;
  final Widget fallback;
  final double? height;
  const _SafeAsset({required this.path, required this.fallback, this.height});

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      path,
      height: height,
      errorBuilder: (context, error, stack) => fallback,
    );
  }
}

class _LogoTitle extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/nombre.png',
      height: 28,
      errorBuilder: (context, error, stack) => const Text(
        'Kahoot!',
        style: TextStyle(
          color: Colors.brown,
          fontWeight: FontWeight.w900,
          fontSize: 22,
        ),
      ),
    );
  }
}

// _MiniSquare removido: ya no se usa tras el rediseño de la sección inferior.
// _UnirseBadge removido: solo se usa el icono estándar en el footer.

class _AnimatedShapes extends StatefulWidget {
  const _AnimatedShapes();
  @override
  State<_AnimatedShapes> createState() => _AnimatedShapesState();
}

class _AnimatedShapesState extends State<_AnimatedShapes>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 64,
      // ... aquí va el contenido animado de _AnimatedShapes ...
    );
  }
}

// Usa GradientButton compartido desde core/widgets/gradient_button.dart

class _AnimatedCreateArrow extends StatelessWidget {
  final Animation<double> progress;
  const _AnimatedCreateArrow({required this.progress});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return AnimatedBuilder(
          animation: progress,
          builder: (_, __) {
            return CustomPaint(
              painter: _PathArrowPainter(
                t: progress.value,
                pathColor: _HomePageState.textGold,
                headColor: _HomePageState.iconYellow,
              ),
              size: Size(constraints.maxWidth, 160),
            );
          },
        );
      },
    );
  }
}

class _PathArrowPainter extends CustomPainter {
  final double t;
  final Color pathColor;
  final Color headColor;
  _PathArrowPainter({
    required this.t,
    required this.pathColor,
    required this.headColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final start = Offset(w * 0.5, 10);
    final end = Offset(w * 0.7, h - 8);
    final cp1 = Offset(w * 0.5, h * 0.35);
    final cp2 = Offset(w * 0.85, h * 0.7);

    final fullPath = Path()
      ..moveTo(start.dx, start.dy)
      ..cubicTo(cp1.dx, cp1.dy, cp2.dx, cp2.dy, end.dx, end.dy);

    final metrics = fullPath.computeMetrics().first;
    final len = metrics.length;
    final currentLen = len * (0.2 + 0.8 * t);

    const double dash = 10;
    const double gap = 6;
    final paintPath = Paint()
      ..color = pathColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    double distance = 0;
    while (distance < currentLen) {
      final double next = math.min(distance + dash, currentLen);
      final segment = metrics.extractPath(distance, next);
      canvas.drawPath(segment, paintPath);
      distance = next + gap;
    }

    final tangent = metrics.getTangentForOffset(currentLen);
    if (tangent != null) {
      final pos = tangent.position;
      final angle = tangent.angle;
      _drawArrowHead(canvas, pos, angle);
    }
  }

  void _drawArrowHead(Canvas canvas, Offset pos, double angle) {
    const double length = 22;
    const double width = 8;
    final a = angle;
    final p0 = pos;
    final p1 = p0 + Offset(-length * math.cos(a), -length * math.sin(a));
    final left =
        p0 +
        Offset(
          -length * 0.6 * math.cos(a) + width * math.sin(a),
          -length * 0.6 * math.sin(a) - width * math.cos(a),
        );
    final right =
        p0 +
        Offset(
          -length * 0.6 * math.cos(a) - width * math.sin(a),
          -length * 0.6 * math.sin(a) + width * math.cos(a),
        );
    final path = Path()
      ..moveTo(p0.dx, p0.dy)
      ..lineTo(left.dx, left.dy)
      ..lineTo(p1.dx, p1.dy)
      ..lineTo(right.dx, right.dy)
      ..close();
    final paintHead = Paint()
      ..color = headColor
      ..style = PaintingStyle.fill;
    canvas.drawPath(path, paintHead);
  }

  @override
  bool shouldRepaint(covariant _PathArrowPainter oldDelegate) {
    return oldDelegate.t != t ||
        oldDelegate.pathColor != pathColor ||
        oldDelegate.headColor != headColor;
  }
}

class _TrianglePainter extends CustomPainter {
  final Color color;
  _TrianglePainter(this.color);
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color.withOpacity(0.9);
    final path = Path()
      ..moveTo(size.width / 2, 0)
      ..lineTo(0, size.height)
      ..lineTo(size.width, size.height)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _TrianglePainter oldDelegate) =>
      oldDelegate.color != color;
}
