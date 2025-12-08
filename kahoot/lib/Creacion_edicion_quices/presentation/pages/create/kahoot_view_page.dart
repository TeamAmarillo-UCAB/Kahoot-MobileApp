import 'package:flutter/material.dart';
import '../../../domain/entities/kahoot.dart';
import '../../../domain/entities/question.dart';
import '../../widgets/kahoot_details_page.dart';
import '../../../application/usecases/kahoot/get_kahoot_by_kahoot_id.dart';
import '../../../infrastructure/datasource/kahoot_datasource_impl.dart';
import '../../../infrastructure/repositories/kahoot_repository_impl.dart';
import '../../../../main.dart';

class KahootViewPage extends StatefulWidget {
  final Kahoot kahoot;
  const KahootViewPage({Key? key, required this.kahoot}) : super(key: key);

  @override
  State<KahootViewPage> createState() => _KahootViewPageState();
}

class _KahootViewPageState extends State<KahootViewPage> {
  late final KahootDatasourceImpl _datasource;
  late final KahootRepositoryImpl _repository;
  late final GetKahootByKahootId _getById;
  Kahoot? _data;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _datasource = KahootDatasourceImpl();
    _datasource.dio.options.baseUrl = apiBaseUrl;
    _repository = KahootRepositoryImpl(datasource: _datasource);
    _getById = GetKahootByKahootId(_repository);
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    final result = await _getById.call(widget.kahoot.kahootId);
    if (result.isSuccessful()) {
      setState(() {
        _data = result.getValue();
        _loading = false;
      });
    } else {
      setState(() {
        _error = 'No se pudo obtener el detalle del kahoot.';
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final kahoot = _data ?? widget.kahoot;
    return Scaffold(
      backgroundColor: const Color(0xFF222222),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFD54F),
        title: const Text('Ver Kahoot', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        centerTitle: true,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        actions: [
          TextButton.icon(
            onPressed: () async {
              final result = await Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => KahootDetailsPage(initialKahoot: kahoot)),
              );
              Navigator.of(context).pop(result);
            },
            icon: const Icon(Icons.edit, color: Colors.black),
            label: const Text('Editar', style: TextStyle(color: Colors.black)),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Padding(
                  padding: const EdgeInsets.all(16),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFB300),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(_error!, style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        TextButton.icon(
                          onPressed: _load,
                          icon: const Icon(Icons.refresh, color: Colors.black),
                          label: const Text('Reintentar', style: TextStyle(color: Colors.black)),
                        ),
                      ],
                    ),
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFB300),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    kahoot.title,
                                    style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                TextButton.icon(
                                  onPressed: () async {
                                    final result = await Navigator.of(context).push(
                                      MaterialPageRoute(builder: (_) => KahootDetailsPage(initialKahoot: kahoot)),
                                    );
                                    Navigator.of(context).pop(result);
                                  },
                                  icon: const Icon(Icons.edit, color: Colors.black),
                                  label: const Text('Editar', style: TextStyle(color: Colors.black)),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(kahoot.description.isEmpty ? 'Sin descripción' : kahoot.description, style: const TextStyle(color: Colors.black87)),
                            const SizedBox(height: 10),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                  _InfoChip(label: 'Autor', value: kahoot.authorId),
                                  _InfoChip(label: 'Visibilidad', value: kahoot.visibility.toShortString()),
                                  _InfoChip(label: 'Tema (id)', value: kahoot.theme.isEmpty ? '—' : kahoot.theme),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFB300),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Preguntas', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 8),
                            if (kahoot.question.isEmpty)
                              const Text('No hay preguntas todavía.', style: TextStyle(color: Colors.black54))
                            else
                              ...kahoot.question.asMap().entries.map((entry) {
                                final i = entry.key;
                                final q = entry.value;
                                return Container(
                                  margin: const EdgeInsets.only(bottom: 8),
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(color: const Color(0xFF444444), borderRadius: BorderRadius.circular(8)),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('Pregunta ${i + 1}: ${q.title.isEmpty ? q.text : q.title}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                      const SizedBox(height: 6),
                                      Text('Tipo: ${q.type.toShortString()} • Tiempo: ${q.timeLimitSeconds}s • Puntos: ${q.points}', style: const TextStyle(color: Colors.white70)),
                                      const SizedBox(height: 8),
                                      const Text('Respuestas:', style: TextStyle(color: Colors.white70)),
                                      const SizedBox(height: 4),
                                      ...q.answer.map((a) => Row(
                                        children: [
                                          Icon(a.isCorrect ? Icons.check_circle : Icons.radio_button_unchecked, color: a.isCorrect ? Colors.lightGreen : Colors.white54, size: 16),
                                          const SizedBox(width: 6),
                                          Expanded(child: Text(a.text.isEmpty ? '(sin texto)' : a.text, style: const TextStyle(color: Colors.white)) ),
                                        ],
                                      )),
                                    ],
                                  ),
                                );
                              }),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }
}

// Removed unused/duplicated _Section widget

class _InfoChip extends StatelessWidget {
  final String label;
  final String value;
  const _InfoChip({required this.label, required this.value});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFA46000),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('$label: ', style: const TextStyle(color: Colors.white70)),
          Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}