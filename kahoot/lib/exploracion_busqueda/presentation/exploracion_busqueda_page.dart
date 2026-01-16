import 'package:flutter/material.dart';
// import 'explore_search_page.dart';
import '../application/usecases/get_categories_usecase.dart';
import '../infrastructure/datasource/explore_datasource_impl.dart';
import '../infrastructure/repositories/explore_repository_impl.dart';
import '../domain/entities/category.dart';
import '../../core/result.dart';
import '../application/usecases/get_kahoots_by_category_usecase.dart';
import '../../Creacion_edicion_quices/domain/entities/kahoot.dart';
import '../../core/widgets/gradient_button.dart';
import '../../Juego_Asincrono/presentation/pages/game_page.dart';
import '../../Juego_en_vivo/presentation/pages/host/host_lobby_page.dart';

class ExploracionBusquedaPage extends StatefulWidget {
  const ExploracionBusquedaPage({Key? key}) : super(key: key);

  @override
  State<ExploracionBusquedaPage> createState() =>
      _ExploracionBusquedaPageState();
}

class _ExploracionBusquedaPageState extends State<ExploracionBusquedaPage> {
  static const Color bgBrown = Color(0xFF3A240C);
  static const Color headerYellow = Color(0xFFF2C147);
  static const Color textYellow = Color(0xFFF2C147);
  static const Color cardBrown = Color(0xFF5C3A0C);
  static const Color cardYellow = Color(0xFFF2C147);

  // Search is always visible in this view
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocus = FocusNode();

  late final GetCategoriesUseCase _getCategories = GetCategoriesUseCase(
    repository: ExploreRepositoryImpl(datasource: ExploreDatasourceImpl()),
  );
  late final GetKahootsByCategoryUseCase _getKahootsByCategory =
      GetKahootsByCategoryUseCase(
        repository: ExploreRepositoryImpl(datasource: ExploreDatasourceImpl()),
      );

  bool _showCategories = false;
  String? _selectedCategory;
  Future<Result<List<Kahoot>>>? _resultsFuture;

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocus.dispose();
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
                    child: Container(
                      key: const ValueKey('searchBar'),
                      height: 40,
                      decoration: BoxDecoration(
                        color: headerYellow.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: TextField(
                        controller: _searchController,
                        focusNode: _searchFocus,
                        onTap: () => setState(() => _showCategories = true),
                        onChanged: (value) {
                          // While typing, keep categories visible until one is selected
                          setState(() => _showCategories = true);
                        },
                        style: const TextStyle(color: Colors.white),
                        cursorColor: headerYellow,
                        decoration: InputDecoration(
                          prefixIcon: const Icon(
                            Icons.search,
                            color: headerYellow,
                          ),
                          hintText: 'Buscar un kahoot...',
                          hintStyle: TextStyle(
                            color: headerYellow.withOpacity(0.7),
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  if (_showCategories)
                    TextButton(
                      onPressed: () {
                        _searchFocus.unfocus();
                        setState(() => _showCategories = false);
                      },
                      child: const Text(
                        'Cancelar',
                        style: TextStyle(color: headerYellow),
                      ),
                    ),
                ],
              ),
            ),

            // One flexible area below the search row:
            // when categories are visible, fill the space with the grid;
            // otherwise show results or placeholder content.
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                child: _showCategories
                    ? _CategoriesPanel(
                        getCategories: _getCategories,
                        onPick: (name) {
                          _searchController.text = name;
                          _searchFocus.unfocus();
                          setState(() {
                            _showCategories = false;
                            _selectedCategory = name;
                            _resultsFuture = _getKahootsByCategory(name);
                          });
                        },
                      )
                    : (_resultsFuture != null
                          ? FutureBuilder<Result<List<Kahoot>>>(
                              future: _resultsFuture,
                              builder: (context, snapshot) {
                                if (snapshot.connectionState !=
                                    ConnectionState.done) {
                                  return const Center(
                                    child: CircularProgressIndicator(),
                                  );
                                }
                                final r = snapshot.data;
                                List<Kahoot> items = const [];
                                if (r != null && r.isSuccessful()) {
                                  items = r.getValue();
                                }
                                if (items.isEmpty) {
                                  return Center(
                                    child: Padding(
                                      padding: const EdgeInsets.all(24.0),
                                      child: Text(
                                        _selectedCategory == null
                                            ? 'Sin resultados'
                                            : 'Sin resultados para "' +
                                                  (_selectedCategory!) +
                                                  '"',
                                        style: const TextStyle(
                                          color: Colors.white70,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  );
                                }
                                return ListView.separated(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 16,
                                  ),
                                  itemCount: items.length,
                                  separatorBuilder: (_, __) =>
                                      const SizedBox(height: 12),
                                  itemBuilder: (_, i) =>
                                      _ResultKahootCard(k: items[i]),
                                );
                              },
                            )
                          : ListView(
                              padding: const EdgeInsets.all(24),
                              children: [
                                const SizedBox(height: 8),
                                Text(
                                  '¡Explora Kahoots!',
                                  style: TextStyle(
                                    color: textYellow,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 28,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  'Busca o descubre los mejores Kahoots para ti',
                                  style: TextStyle(
                                    color: headerYellow.withOpacity(0.85),
                                    fontSize: 16,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 24),
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
                            )),
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
          child: Text(
            '$number',
            style: TextStyle(
              color: textColor ?? Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          title,
          style: TextStyle(
            color: textColor ?? Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        // ... dentro de _KahootCard ...
        subtitle: Row(
          children: [
            Icon(Icons.verified, color: textColor ?? Colors.amber, size: 16),
            const SizedBox(width: 4),

            // --- AQUÍ ESTÁ EL CAMBIO ---
            Expanded(
              // 1. Envuelve el Text en Expanded
              child: Text(
                author,
                style: TextStyle(
                  color: (textColor ?? Colors.white).withOpacity(0.8),
                  fontSize: 13,
                ),
                // 2. Agrega estas dos líneas para cortar el texto si es largo
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),

            // ---------------------------
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: (textColor ?? Colors.white).withOpacity(0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Gratis',
                style: TextStyle(
                  color: textColor ?? Colors.white,
                  fontSize: 11,
                ),
              ),
            ),
          ],
        ),
        // ...
        trailing: Icon(Icons.chevron_right, color: textColor ?? Colors.white54),
      ),
    );
  }
}

class _CategoriesPanel extends StatelessWidget {
  final Future<Result<List<Category>>> Function() getCategories;
  final void Function(String name) onPick;
  const _CategoriesPanel({required this.getCategories, required this.onPick});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Result<List<Category>>>(
      future: getCategories(),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        final result = snapshot.data;
        List<Category> categories = const [];
        if (result != null && result.isSuccessful()) {
          categories = result.getValue();
        }
        if (categories.isEmpty) {
          return const Center(
            child: Text(
              'Sin categorías',
              style: TextStyle(color: Colors.white70),
            ),
          );
        }
        final palette = <Color>[
          const Color(0xFF6EC6FF),
          const Color(0xFFFF8A65),
          const Color(0xFFA5D6A7),
          const Color(0xFFFFF59D),
          const Color(0xFFE1BEE7),
          const Color(0xFFFFAB91),
          const Color(0xFF80CBC4),
          const Color(0xFFCE93D8),
        ];

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Text(
                'Categorías',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
            const SizedBox(height: 6),
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 2.2,
                ),
                itemCount: categories.length,
                itemBuilder: (_, i) {
                  final c = categories[i];
                  final color = palette[i % palette.length];
                  return _CategoryCardTile(
                    label: c.name,
                    color: color,
                    onTap: () => onPick(c.name),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}

// replaced old _CategoryChip with card grid design

class _ResultKahootCard extends StatelessWidget {
  final Kahoot k;
  const _ResultKahootCard({required this.k});

  String _visibilityLabel(KahootVisibility v) {
    switch (v) {
      case KahootVisibility.public:
        return 'Pública';
      case KahootVisibility.private:
        return 'Privada';
    }
  }

  @override
  Widget build(BuildContext context) {
    // Tono cálido inspirado en el diseño adjunto
    const Color cardYellow = Color(0xFFF6C64D);

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
          colors: [cardYellow, Color(0xFFEEA63A)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Image placeholder / thumbnail
            Container(
              height: 110,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.35),
                borderRadius: BorderRadius.circular(12),
              ),
              clipBehavior: Clip.antiAlias,
              child: (k.image.isNotEmpty)
                  ? Image.network(
                      k.image,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) {
                        return const Center(
                          child: Icon(
                            Icons.image,
                            color: Colors.white70,
                            size: 36,
                          ),
                        );
                      },
                    )
                  : const Center(
                      child: Icon(Icons.image, color: Colors.white70, size: 36),
                    ),
            ),
            const SizedBox(height: 12),
            // Title
            Text(
              k.title.isEmpty ? 'Kahoot sin título' : k.title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.black87,
                fontSize: 16,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 4),
            // Visibility
            Text(
              'Visibilidad: Pública',
              style: const TextStyle(color: Colors.black87, fontSize: 13),
            ),
            const SizedBox(height: 12),
            // Actions
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _ActionButton(
                  label: 'Crear sesión',
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => HostLobbyView(kahootId: k.kahootId),
                      ),
                    );
                  },
                ),
                const SizedBox(width: 12),
                _ActionButton(
                  label: 'Jugar solitario',
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => GamePage(kahootId: k.kahootId),
                      ),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  const _ActionButton({required this.label, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return GradientButton(
      onTap: onPressed,
      borderRadius: const BorderRadius.all(Radius.circular(12)),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 14,
          letterSpacing: 0.2,
        ),
      ),
    );
  }
}

class _CategoryCardTile extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _CategoryCardTile({
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            gradient: LinearGradient(
              colors: [color.withOpacity(0.35), const Color(0xFF2A2A2A)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            alignment: Alignment.centerLeft,
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      shadows: [
                        Shadow(
                          color: Colors.black54,
                          blurRadius: 2,
                          offset: Offset(0, 1),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
