import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../application/usecases/kahoot/create_kahoot.dart';
import '../../application/usecases/kahoot/update_kahoot.dart';
import '../../application/usecases/kahoot/get_themes.dart';
import '../../infrastructure/datasource/kahoot_datasource_impl.dart';
import '../../infrastructure/repositories/kahoot_repository_impl.dart';
import '../../presentation/blocs/kahoot_editor_cubit.dart';
import '../pages/create/add_question_modal.dart';
import '../pages/create/quiz_editor_page.dart';
import '../pages/create/true_false_editor_page.dart';
import '../pages/create/short_answer_editor_page.dart';
import '../../../main.dart';
import '../../domain/entities/question.dart';
import '../../domain/entities/answer.dart';
import '../../domain/entities/kahoot.dart';
import '../../../Creacion_edicion_quices/domain/entities/theme.dart' as entity;

import '../../../../Contenido_Multimedia/presentation/pages/media_resource_selector.dart';
import '../../../core/widgets/gradient_button.dart';

class KahootDetailsPage extends StatefulWidget {
  final Kahoot? initialKahoot;
  const KahootDetailsPage({Key? key, this.initialKahoot}) : super(key: key);

  @override
  State<KahootDetailsPage> createState() => _KahootDetailsPageState();
}

class _KahootDetailsPageState extends State<KahootDetailsPage> {
  String visibility = 'private';
  String? _selectedThemeId; //THEMES
  final List<String> visibilityOptions = ['private', 'public'];
  int questionsCount = 0;
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _themeController = TextEditingController();

  late final KahootDatasourceImpl _datasource;
  late final KahootRepositoryImpl _repository;
  late final CreateKahoot _createKahoot;
  late final UpdateKahoot _updateKahoot;
  late final KahootEditorCubit _editorCubit;

  late final GetKahootThemes _getThemes;
  List<entity.KahootTheme> _availableThemes = [];
  String? _selectedThemeUrl;
  bool _isLoadingThemes = true;

  @override
  void initState() {
    super.initState();
    _datasource = KahootDatasourceImpl();
    // set base URL from main.dart constant (trim to avoid whitespace issues)
    _datasource.dio.options.baseUrl = apiBaseUrl.trim();
    // ignore: avoid_print
    print(
      'KahootDatasource baseUrl: ' + _datasource.dio.options.baseUrl.toString(),
    );
    _repository = KahootRepositoryImpl(datasource: _datasource);
    _createKahoot = CreateKahoot(_repository);
    _updateKahoot = UpdateKahoot(_repository);
    _editorCubit = KahootEditorCubit(
      createKahootUseCase: _createKahoot,
      updateKahootUseCase: _updateKahoot,
      initialAuthorId: 'author123',
    );

    _getThemes = GetKahootThemes(_repository);
    _loadThemes();

    final k = widget.initialKahoot;
    if (k != null) {
      _titleController.text = k.title;
      visibility = k.visibility == KahootVisibility.private
          ? 'private'
          : 'public';
      _selectedThemeId = k.theme;
      _editorCubit
        ..setAuthor(k.authorId)
        ..setTitle(k.title)
        ..setDescription(k.description)
        ..setCoverImage(k.image)
        ..setVisibility(k.visibility.toShortString())
        ..setTheme(k.theme);
      for (final q in k.question) {
        _editorCubit.addQuestion(q);
      }
    }
  }

  Future<void> _loadThemes() async {
    try {
      final themes = await _getThemes.execute();
      setState(() {
        _availableThemes = themes;
        _isLoadingThemes = false;

        if (widget.initialKahoot != null && _selectedThemeId == null) {}
      });
    } catch (e) {
      setState(() => _isLoadingThemes = false);
      debugPrint('Error cargando temas: $e');
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _themeController.dispose(); // Dispose of the theme controller
    _editorCubit.close();
    super.dispose();
  }

  Question? _mapResultToQuestion(Map result) {
    try {
      final String type = (result['type'] as String?) ?? '';
      final String title = (result['title'] as String?)?.trim() ?? '';
      final int time = (result['time'] as int?) ?? 20;
      final String? mediaId = result['mediaId'] as String?;
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
        case 'short_answer':
          qType = QuestionType.short_answer;
          break;
        case 'quiz':
        default:
          qType = QuestionType.quiz_single;
      }

      return Question(
        text: title,
        title: title,
        mediaId: mediaId ?? '',
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
        title: const Text(
          'Crear Kahoot',
          style: TextStyle(color: Colors.brown, fontWeight: FontWeight.bold),
        ),
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
                // Validación: no permitir guardar si no hay preguntas
                if (_editorCubit.state.questions.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Debes añadir al menos una pregunta antes de guardar.',
                      ),
                    ),
                  );
                  return;
                }
                final visibilityValue = visibility == 'private'
                    ? 'private'
                    : 'public';
                final isEditing = widget.initialKahoot != null;

                // Validación amigable en UI: si estamos creando (draft) y visibilidad es pública, bloquear y avisar
                /*if (!isEditing && visibilityValue == 'public') {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Cuando el estado es borrador (draft), la visibilidad no puede ser pública.'),
                    ),
                  );
                  return;
                }*/

                _editorCubit
                  ..setTitle(title)
                  ..setVisibility(visibilityValue)
                  ..setTheme(_themeController.text.trim());

                if (isEditing) {
                  final kahootToUpdate = _buildKahootFromState(
                    widget.initialKahoot!,
                  );
                  await _editorCubit.saveUpdate(kahootToUpdate);
                } else {
                  await _editorCubit.saveCreate();
                }
                final state = _editorCubit.state;
                if (state.status == EditorStatus.saved) {
                  // Éxito: volver automáticamente y avisar a la pantalla anterior con datos útiles
                  final createdId = widget.initialKahoot == null
                      ? _datasource.lastCreatedKahootId
                      : null;
                  final updatedId = widget.initialKahoot?.kahootId;
                  Navigator.of(context).pop({
                    'saved': true,
                    'title': state.title,
                    'isEditing': widget.initialKahoot != null,
                    if (createdId != null) 'newKahootId': createdId,
                    if (updatedId != null && updatedId.isNotEmpty)
                      'updatedKahootId': updatedId,
                  });
                } else if (state.status == EditorStatus.error) {
                  // Error: mostrar mensaje conciso y permanecer en la vista
                  final msg =
                      state.errorMessage ??
                      'No se pudo guardar. Revisa título, visibilidad, tema y preguntas.';
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text(msg)));
                }
              },
              child: const Text(
                'Guardar',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 80),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 16),
                MediaResourceSelector(
                  onIdSelected: (assetId) {
                    _editorCubit.setCoverImage(assetId);

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Imagen cargada correctamente'),
                      ),
                    );
                  },
                ),
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
                            hintStyle: TextStyle(color: Colors.black54),
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
                    onChanged: (value) {
                      _editorCubit.setTheme(value.trim());
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: _isLoadingThemes
                      ? const Center(
                          child: CircularProgressIndicator(color: Colors.white),
                        )
                      : DropdownButtonFormField<String>(
                          value: _selectedThemeId,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: headerYellow,
                            labelText: 'Estilo visual del Kahoot',
                            labelStyle: const TextStyle(
                              color: Colors.brown,
                              fontWeight: FontWeight.bold,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide.none,
                            ),
                          ),
                          dropdownColor: cardDark,
                          items: _availableThemes.map((
                            entity.KahootTheme theme,
                          ) {
                            return DropdownMenuItem<String>(
                              value: theme.assetId,
                              child: Row(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(4),
                                    child: Image.network(
                                      theme.url,
                                      width: 40,
                                      height: 25,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) =>
                                          const Icon(Icons.palette, size: 20),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    theme.name,
                                    style: const TextStyle(
                                      color: Colors.black87,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                          onChanged: (newId) {
                            if (newId != null) {
                              setState(() => _selectedThemeId = newId);
                              _editorCubit.setTheme(newId);
                            }
                          },
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
                      hintStyle: TextStyle(color: Colors.black54),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    items: visibilityOptions.map((option) {
                      return DropdownMenuItem(
                        value: option,
                        child: Text(option),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        visibility = value!;
                      });
                    },
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
                          Text(
                            'Preguntas (${state.questions.length})',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          ...List.generate(
                            state.questions.length,
                            (i) => Container(
                              margin: const EdgeInsets.only(bottom: 8),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 14,
                              ),
                              decoration: BoxDecoration(
                                color: cardDark,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: InkWell(
                                onTap: () async {
                                  final q = state.questions[i];
                                  Map<String, dynamic>? result;
                                  if (q.type == QuestionType.true_false) {
                                    result = await Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (_) => TrueFalseEditorPage(
                                          index: i,
                                          initialTitle: q.title,
                                          initialTrueText: q.answer.isNotEmpty
                                              ? q.answer.first.text
                                              : 'Verdadero',
                                          initialFalseText: q.answer.length > 1
                                              ? q.answer[1].text
                                              : 'Falso',
                                          initialTime: q.timeLimitSeconds,
                                        ),
                                      ),
                                    );
                                  } else if (q.type ==
                                      QuestionType.short_answer) {
                                    final correct = q.answer.isNotEmpty
                                        ? q.answer.first.text
                                        : '';
                                    final others = q.answer.length > 1
                                        ? q.answer
                                              .skip(1)
                                              .map((a) => a.text)
                                              .toList()
                                        : <String>[];
                                    result = await Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (_) => ShortAnswerEditorPage(
                                          index: i,
                                          initialTitle: q.title,
                                          initialCorrect: correct,
                                          initialOthers: others,
                                          initialTime: q.timeLimitSeconds,
                                        ),
                                      ),
                                    );
                                  } else {
                                    // quiz_single
                                    final texts = q.answer
                                        .map((a) => a.text)
                                        .toList();
                                    result = await Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (_) => QuizEditorPage(
                                          index: i,
                                          initialTitle: q.title,
                                          initialMediaId: q.mediaId,
                                          initialAnswers: texts,
                                          initialTime: q.timeLimitSeconds,
                                        ),
                                      ),
                                    );
                                  }
                                  if (result != null) {
                                    final updated = _mapResultToQuestion(
                                      result,
                                    );
                                    if (updated != null) {
                                      _editorCubit.updateQuestion(i, updated);
                                    }
                                  }
                                },
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      state.questions[i].title.isNotEmpty
                                          ? state.questions[i].title
                                          : 'Pregunta ${i + 1}',
                                      style: const TextStyle(
                                        color: Colors.white,
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(
                                        Icons.delete,
                                        color: Colors.redAccent,
                                      ),
                                      onPressed: () {
                                        _editorCubit.removeQuestion(i);
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
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
              backgroundColor: Color(0xFFFFD54F),
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
                      const SnackBar(
                        content: Text(
                          'No se pudo crear la pregunta. Revisa los datos.',
                        ),
                      ),
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

  Kahoot _buildKahootFromState(Kahoot original) {
    final vis = KahootVisibilityX.fromString(_editorCubit.state.visibility);
    print(_selectedThemeId ?? original.theme);
    return Kahoot(
      kahootId: original.kahootId,
      authorId: _editorCubit.state.authorId,
      title: _editorCubit.state.title,
      description: _editorCubit.state.description,
      visibility: vis,
      question: _editorCubit.state.questions,
      image: _editorCubit.state.coverImageId,
      theme: _selectedThemeId ?? original.theme,
    );
  }
}
