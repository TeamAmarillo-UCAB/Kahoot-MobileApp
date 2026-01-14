import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../Creacion_edicion_quices/infrastructure/datasource/kahoot_datasource_impl.dart';
import '../../../../Creacion_edicion_quices/infrastructure/repositories/kahoot_repository_impl.dart';
import '../../../../Creacion_edicion_quices/application/usecases/kahoot/create_kahoot.dart';
import '../../../../Creacion_edicion_quices/application/usecases/kahoot/update_kahoot.dart';
import '../../../../Creacion_edicion_quices/presentation/blocs/kahoot_editor_cubit.dart';
import '../../infrastructure/datasource/library_kahoot_datasource_impl.dart';
import '../../infrastructure/repository/library_kahoot_repository_impl.dart';
import '../../../../Creacion_edicion_quices/presentation/pages/create/add_question_modal.dart';
import 'library_quiz_editor_page.dart';
import 'library_true_false_editor_page.dart';
import 'library_short_answer_editor_page.dart';
import '../../../../Creacion_edicion_quices/domain/entities/kahoot.dart';
import '../../../../Creacion_edicion_quices/domain/entities/question.dart';
import '../../../../Creacion_edicion_quices/domain/entities/answer.dart';
import '../../../core/widgets/gradient_button.dart';
import '../../../main.dart';
import '../../../Contenido_Multimedia/presentation/pages/media_resource_selector.dart';

class LibraryKahootEditorPage extends StatefulWidget {
  final Kahoot initialKahoot;
  const LibraryKahootEditorPage({Key? key, required this.initialKahoot}) : super(key: key);

  @override
  State<LibraryKahootEditorPage> createState() => _LibraryKahootEditorPageState();
}

class _LibraryKahootEditorPageState extends State<LibraryKahootEditorPage> {

  String visibility = 'private';
  final List<String> visibilityOptions = ['private', 'public'];
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _themeController = TextEditingController();
  bool _loading = true;

  late final KahootDatasourceImpl _ds;
  late final KahootRepositoryImpl _repo;
  late final CreateKahoot _createKahoot;
  late final UpdateKahoot _updateKahoot;
  late final KahootEditorCubit _editorCubit;
  late final LibraryKahootDatasourceImpl _libDs;
  late final LibraryKahootRepositoryImpl _libRepo;

  @override
  void initState() {
    super.initState();
    _ds = KahootDatasourceImpl()..dio.options.baseUrl = apiBaseUrl.trim();
    _repo = KahootRepositoryImpl(datasource: _ds);
    _createKahoot = CreateKahoot(_repo);
    _updateKahoot = UpdateKahoot(_repo);
    _editorCubit = KahootEditorCubit(
      createKahootUseCase: _createKahoot,
      updateKahootUseCase: _updateKahoot,
      initialAuthorId: widget.initialKahoot.authorId,
    );
    // Datasource/Repo de biblioteca para actualizar kahoots de la librería
    _libDs = LibraryKahootDatasourceImpl()..dio.options.baseUrl = apiBaseUrl.trim();
    _libRepo = LibraryKahootRepositoryImpl(datasource: _libDs);

    final k = widget.initialKahoot;
    _titleController.text = k.title;
    visibility = k.visibility == KahootVisibility.private ? 'private' : 'public';
    _themeController.text = k.theme;
    _editorCubit
      ..setAuthor(k.authorId)
      ..setTitle(k.title)
      ..setDescription(k.description)
      ..setCoverImage(k.image)
      ..setVisibility(visibility)
      ..setTheme(k.theme);
    for (final q in k.question) {
      _editorCubit.addQuestion(q);
    }
    // Cargar detalles completos por ID desde la API
    _loadFullDetails();
  }

  Future<void> _loadFullDetails() async {
    try {
      final full = await _ds.getKahootByKahootId(widget.initialKahoot.kahootId);
      if (!mounted) return;
      if (full != null) {
        // Reemplazar preguntas con las obtenidas por ID
        final len = _editorCubit.state.questions.length;
        for (int i = len - 1; i >= 0; i--) {
          _editorCubit.removeQuestion(i);
        }
        for (final q in full.question) {
          _editorCubit.addQuestion(q);
        }
        // Actualizar metadatos visibles
        setState(() {
          _titleController.text = full.title;
          _themeController.text = full.theme;
          visibility = full.visibility == KahootVisibility.private ? 'private' : 'public';
          _loading = false;
        });
        _editorCubit
          ..setAuthor(full.authorId)
          ..setTitle(full.title)
          ..setDescription(full.description)
          ..setCoverImage(full.image)
          ..setVisibility(visibility)
          ..setTheme(full.theme);
      } else {
        setState(() => _loading = false);
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _themeController.dispose();
    _editorCubit.close();
    
    super.dispose();
  }

  Question? _mapResultToQuestion(Map result) {
    try {
      final String rawType = (result['type'] as String?)?.trim().toLowerCase() ?? '';
      final String type = rawType.replaceAll(' ', '_').replaceAll('true_or_false', 'true_false');
      final String title = (result['title'] as String?)?.trim() ?? '';
      final int time = (result['time'] as int?) ?? 20;
      final List answersRaw = (result['answers'] as List?) ?? [];
      final answers = answersRaw
          .map(
            (e) => Answer(
              image: '',
              isCorrect: (e['isCorrect'] as bool?) ?? false,
              text: (e['text'] as String?) ?? '',
              questionId: '',
            ),
          )
          .toList();

      QuestionType qType;
      switch (type) {
        case 'true_false':
          qType = QuestionType.true_false;
          break;
        case 'single':
          // Map 'single' to short answer editor
          qType = QuestionType.short_answer;
          break;
        case 'multiple':
          qType = QuestionType.quiz_multiple;
          break;
        case 'short_answer':
          qType = QuestionType.short_answer;
          break;
        default:
          qType = QuestionType.quiz_multiple;
      }

      return Question(
        text: title,
        title: title,
        mediaId: '',
        type: qType,
        points: 1000,
        timeLimitSeconds: time,
        answer: answers,
      );
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    const bgBrown = Color(0xFF3A240C);
    const headerYellow = Color(0xFFF2C147);
    const cardDark = Color(0xFF444444);
    return Scaffold(
        backgroundColor: bgBrown,
        appBar: AppBar(
          backgroundColor: headerYellow,
          elevation: 0,
          title: const Text('Editar Kahoot', style: TextStyle(color: Colors.brown, fontWeight: FontWeight.bold)),
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.brown),
            onPressed: () => Navigator.of(context).pop(),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: GradientButton(
                onTap: () async {
                  final title = _titleController.text.trim();
                  if (title.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('El título es requerido.')),
                    );
                    return;
                  }
                  if (_editorCubit.state.questions.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Debes añadir al menos una pregunta.')),
                    );
                    return;
                  }
                  _editorCubit
                    ..setTitle(title)
                    ..setVisibility(visibility)
                    ..setTheme(_themeController.text.trim());
                  final isEditing = true;
                  if (isEditing) {
                    final s = _editorCubit.state;
                    await _libRepo.updateMyKahoot(
                      widget.initialKahoot.kahootId,
                      s.title,
                      s.description,
                      s.coverImageId,
                      s.visibility,
                      'published',
                      s.themeId,
                      s.questions,
                      const <Answer>[],
                    );
                  }
                  // Feedback simple tras update
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Kahoot actualizado')),
                  );
                  Navigator.of(context).pop({'updatedKahootId': widget.initialKahoot.kahootId, 'saved': true});
                },
                child: const Text('Guardar', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
        body: _loading
            ? const Center(child: CircularProgressIndicator())
            : Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 80),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 16),
                  const MediaResourceSelector(),
                  const SizedBox(height: 24),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _titleController,
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: headerYellow,
                              hintText: 'Título',
                              hintStyle: const TextStyle(color: Colors.black54),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: TextField(
                      controller: _themeController,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: headerYellow,
                        hintText: 'Categoría/Tema',
                        hintStyle: const TextStyle(color: Colors.black54),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      onChanged: (value) => _editorCubit.setTheme(value.trim()),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: DropdownButtonFormField<String>(
                      value: visibility,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: headerYellow,
                        hintText: 'Visible para',
                        hintStyle: const TextStyle(color: Colors.black54),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      items: visibilityOptions.map((option) => DropdownMenuItem(value: option, child: Text(option))).toList(),
                      onChanged: (value) => setState(() => visibility = value!),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: BlocBuilder<KahootEditorCubit, KahootEditorState>(
                      bloc: _editorCubit,
                      builder: (context, state) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Preguntas (${state.questions.length})', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 8),
                            ...List.generate(state.questions.length, (i) => _questionTile(state, i, cardDark)), 
                          ],
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 80),
                ],
              ),
            ),
            Positioned(
              right: 16,
              bottom: 16,
              child: FloatingActionButton.extended(
                backgroundColor: const Color(0xFFFFD54F),
                foregroundColor: Colors.brown,
                elevation: 4,
                onPressed: () async {
                  final result = await showModalBottomSheet(
                    context: context,
                    backgroundColor: Colors.transparent,
                    isScrollControlled: true,
                    builder: (_) => const AddQuestionModal(),
                  );
                  if (result != null && result is Map) {
                    final q = _mapResultToQuestion(result);
                    if (q != null) {
                      _editorCubit.addQuestion(q);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('No se pudo crear la pregunta. Revisa los datos.')),
                      );
                    }
                  }
                },
                label: const Text('Añadir pregunta'),
                icon: const Icon(Icons.add),
              ),
            ),
          ],
        ),
      );
  }

  Widget _questionTile(KahootEditorState state, int i, Color cardDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      decoration: BoxDecoration(color: cardDark, borderRadius: BorderRadius.circular(8)),
      child: InkWell(
        onTap: () async {
          final q = state.questions[i];
          Map<String, dynamic>? result;
          if (q.type == QuestionType.true_false) {
            final String initTrue = q.answer.isNotEmpty ? q.answer.first.text : 'Verdadero';
            final String initFalse = q.answer.length > 1 ? q.answer[1].text : 'Falso';
            result = await Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => LibraryTrueFalseEditorPage(
                  index: i,
                  initialTitle: q.title,
                  initialTrueText: initTrue,
                  initialFalseText: initFalse,
                  initialTime: q.timeLimitSeconds,
                ),
              ),
            );
          } else if (q.type == QuestionType.quiz_single || q.type == QuestionType.short_answer) {
            final correct = q.answer.isNotEmpty ? q.answer.first.text : '';
            final others = q.answer.length > 1 ? q.answer.skip(1).map((a) => a.text).toList() : <String>[];
            result = await Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => LibraryShortAnswerEditorPage(
                  index: i,
                  initialTitle: q.title,
                  initialCorrect: correct,
                  initialOthers: others,
                  initialTime: q.timeLimitSeconds,
                ),
              ),
            );
          } else {
            final texts = q.answer.map((a) => a.text).toList();
            result = await Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => LibraryQuizEditorPage(
                  index: i,
                  initialTitle: q.title,
                  initialAnswers: texts,
                  initialTime: q.timeLimitSeconds,
                ),
              ),
            );
          }
          if (result != null) {
            final updated = _mapResultToQuestion(result);
            if (updated != null) {
              _editorCubit.updateQuestion(i, updated);
            }
          }
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              state.questions[i].title.isNotEmpty ? state.questions[i].title : 'Pregunta ${i + 1}',
              style: const TextStyle(color: Colors.white),
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.redAccent),
              onPressed: () => _editorCubit.removeQuestion(i),
            ),
          ],
        ),
      ),
    );
  }

  Kahoot _buildKahootFromState(Kahoot original) {
    final vis = KahootVisibilityX.fromString(_editorCubit.state.visibility);
    return Kahoot(
      kahootId: original.kahootId,
      authorId: _editorCubit.state.authorId,
      title: _editorCubit.state.title,
      description: _editorCubit.state.description,
      visibility: vis,
      question: _editorCubit.state.questions,
      image: _editorCubit.state.coverImageId,
      theme: _editorCubit.state.themeId,
    );
  }
}
