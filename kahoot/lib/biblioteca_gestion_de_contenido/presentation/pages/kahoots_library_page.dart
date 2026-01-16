import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../Creacion_edicion_quices/domain/entities/kahoot.dart';
import 'kahoots_library_details_page.dart';
import '../../../core/widgets/gradient_button.dart';
import 'library_kahoot_editor_page.dart';
import '../blocs/favorites_cubit.dart';
import '../blocs/delete_kahoot_cubit.dart';
import '../blocs/library_list_cubit.dart';

class KahootsLibraryPage extends StatelessWidget {
  final List<Kahoot> items;
  const KahootsLibraryPage({Key? key, this.items = const []}) : super(key: key);

  static const Color bgBrown = Color(0xFF3A240C);
  static const Color headerYellow = Color(0xFFFFB300);
  static const Color cardYellow = Color(0xFFFFB300);
  static const Color lightYellow = Color(0xFFFFD36F);

  @override
  Widget build(BuildContext context) {
    return BlocListener<DeleteKahootCubit, DeleteKahootState>(
      listener: (context, state) {
        if (state.status == DeleteKahootStatus.deleted) {
          context.read<LibraryListCubit>().load();
        } else if (state.status == DeleteKahootStatus.error) {
          final msg = state.errorMessage ?? 'Error al eliminar';
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(msg)));
        }
      },
      child: Scaffold(
        backgroundColor: bgBrown,
        body: SafeArea(
          child: Column(
            children: [
              _header(context),
              Expanded(child: _grid(context)),
            ],
          ),
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
            child: const Text(
              'Volver',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const Spacer(),
          const Text(
            'Mis Kahoots',
            style: TextStyle(
              color: Colors.black87,
              fontWeight: FontWeight.bold,
            ),
          ),
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
          child: Text(
            'No hay kahoots creados aún',
            style: TextStyle(color: Colors.white.withOpacity(0.85)),
          ),
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final cross = constraints.maxWidth > 600 ? 3 : 2;
          return GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: cross,
              mainAxisSpacing: 18,
              crossAxisSpacing: 18,
              childAspectRatio: 0.55,
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
  static const Color lightYellow = Color(0xFFFFD36F);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: cardYellow,
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [
          BoxShadow(
            color: Color(0x66000000),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Stack(
          children: [
            Positioned(
              top: -2,
              right: 6,
              child: BlocBuilder<FavoritesCubit, FavoritesState>(
                builder: (context, favState) {
                  final isFav = favState.favorites.contains(item.kahootId);
                  final busy = favState.loading.contains(item.kahootId);
                  return GestureDetector(
                    onTap: busy
                        ? null
                        : () => context.read<FavoritesCubit>().toggle(
                            item.kahootId,
                          ),
                    child: Icon(
                      isFav ? Icons.star : Icons.star_border,
                      color: isFav ? Colors.black : const Color(0xFF3A240C),
                      size: 22,
                    ),
                  );
                },
              ),
            ),
            Positioned(
              top: -2,
              left: 8,
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => context.read<DeleteKahootCubit>().removeById(
                      item.kahootId,
                    ),
                    child: const Icon(
                      Icons.delete,
                      size: 20,
                      color: Color(0xFF3A240C),
                    ),
                  ),
                  const SizedBox(width: 6),
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) =>
                              LibraryKahootEditorPage(initialKahoot: item),
                        ),
                      );
                    },
                    child: const Icon(
                      Icons.edit,
                      size: 20,
                      color: Color(0xFF3A240C),
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 26),
                // Image container with light background
                Container(
                  height: 110,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: lightYellow,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  alignment: Alignment.center,
                  child:
                      (item.image.isNotEmpty && item.image.startsWith('http'))
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.network(
                            item.image,
                            height: 110,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => const Icon(
                              Icons.image,
                              color: Colors.black45,
                              size: 40,
                            ),
                          ),
                        )
                      : const Icon(
                          Icons.image,
                          color: Colors.black45,
                          size: 40,
                        ),
                ),
                const SizedBox(height: 12),
                Center(
                  child: Text(
                    item.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
                const SizedBox(height: 3),
                Center(
                  child: Text(
                    'Visibilidad: ${item.visibility == KahootVisibility.public ? 'Pública' : 'Privada'}',
                    style: const TextStyle(color: Colors.black87, fontSize: 13),
                  ),
                ),
                const SizedBox(height: 16),
                Center(
                  child: GradientButton(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 10,
                    ),
                    borderRadius: const BorderRadius.all(Radius.circular(16)),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => LibraryKahootDetailsPage(item: item),
                        ),
                      );
                    },
                    child: const Text(
                      'ver detalles',
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// capitalize helper removed as unused

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
