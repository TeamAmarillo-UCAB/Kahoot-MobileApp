import 'package:flutter/material.dart';
import '../application/usecases/get_categories_usecase.dart';
import '../infrastructure/datasource/explore_datasource_impl.dart';
import '../infrastructure/repositories/explore_repository_impl.dart';
import '../domain/entities/category.dart';
import '../../core/result.dart';


class ExploreSearchPage extends StatefulWidget {
  const ExploreSearchPage({Key? key}) : super(key: key);

  @override
  State<ExploreSearchPage> createState() => _ExploreSearchPageState();
}

class _ExploreSearchPageState extends State<ExploreSearchPage> {
  static const Color bg = Color(0xFF1F1F1F);
  static const Color surface = Color(0xFF2A2A2A);
  static const Color accent = Color(0xFFF2C147); // app yellow
  final TextEditingController _controller = TextEditingController();

  late final GetCategoriesUseCase _getCategories = GetCategoriesUseCase(
    repository: ExploreRepositoryImpl(datasource: ExploreDatasourceImpl()),
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 42,
                      decoration: BoxDecoration(
                        color: surface,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Row(
                        children: [
                          const Icon(Icons.search, color: Colors.white70),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextField(
                              controller: _controller,
                              style: const TextStyle(color: Colors.white),
                              decoration: const InputDecoration(
                                hintText: 'Buscar un kahoot sobre...',
                                hintStyle: TextStyle(color: Colors.white54),
                                border: InputBorder.none,
                              ),
                              onSubmitted: (_) {},
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cancelar', style: TextStyle(color: Colors.white70)),
                  ),
                ],
              ),
            ),
            Expanded(
              child: FutureBuilder<Result<List<Category>>>(
                future: _getCategories(),
                builder: (BuildContext context, AsyncSnapshot<Result<List<Category>>> result) {
                  if (result.connectionState != ConnectionState.done) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final data = result.data; // Result<List<Category>>
                  List<Category> categories = const [];
                  if (data != null && data.isSuccessful()) {
                    categories = data.getValue();
                  }
                  if (categories.isEmpty) {
                    return const Center(
                      child: Text('Sin categorías', style: TextStyle(color: Colors.white70)),
                    );
                  }
                  return GridView.builder(
                    padding: const EdgeInsets.all(12),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 2.8,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                    ),
                    itemCount: categories.length,
                    itemBuilder: (context, i) {
                      final c = categories[i];
                      return _CategoryTile(name: c.name);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryTile extends StatelessWidget {
  final String name;
  const _CategoryTile({required this.name});

  @override
  Widget build(BuildContext context) {
    const Color overlay = Color(0xFF3A240C); // brown
    const Color label = Color(0xFFF2C147); // yellow
    return InkWell(
      onTap: () {
        // TODO: hook to filter kahoots by category
        Navigator.of(context).pop(name);
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: const LinearGradient(
            colors: [Color(0xFF4A2B0E), Color(0xFF2A2A2A)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Container(
          decoration: BoxDecoration(
            color: overlay.withOpacity(0.55),
            borderRadius: BorderRadius.circular(16),
          ),
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          child: Text(
            name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: label,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
