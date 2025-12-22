import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../application/usecases/kahoot/create_kahoot.dart';
import '../../application/usecases/kahoot/update_kahoot.dart';
import '../../infrastructure/datasource/kahoot_datasource_impl.dart';
import '../../infrastructure/repositories/kahoot_repository_impl.dart';
import '../../presentation/blocs/kahoot_editor_cubit.dart';
import '../pages/create/add_question_modal.dart';
import '../../../main.dart';
import '../../domain/entities/question.dart';
import '../../domain/entities/answer.dart';
import '../../domain/entities/kahoot.dart';

import '../../../../Contenido_Multimedia/presentation/pages/media_resource_selector.dart';

class KahootDetailsPage extends StatefulWidget {
  final Kahoot? initialKahoot;
  const KahootDetailsPage({Key? key, this.initialKahoot}) : super(key: key);

  @override
  State<KahootDetailsPage> createState() => _KahootDetailsPageState();
}

class _KahootDetailsPageState extends State<KahootDetailsPage> {
  String visibility = 'private';
  final List<String> visibilityOptions = ['private', 'public'];
  int questionsCount = 0;
  final TextEditingController _titleController = TextEditingController();
  String? _selectedTheme;
  final List<String> _themeOptions = const [
    'Matemáticas',
    'Historia',
    'Ciencias',
  ];

  late final KahootDatasourceImpl _datasource;
  late final KahootRepositoryImpl _repository;
  late final CreateKahoot _createKahoot;
  late final UpdateKahoot _updateKahoot;
  late final KahootEditorCubit _editorCubit;

  @override
  void initState() {
    super.initState();
    _datasource = KahootDatasourceImpl();
    // set base URL from main.dart constant
    _datasource.dio.options.baseUrl = apiBaseUrl;
    _repository = KahootRepositoryImpl(datasource: _datasource);
    _createKahoot = CreateKahoot(_repository);
    _updateKahoot = UpdateKahoot(_repository);
    _editorCubit = KahootEditorCubit(
      createKahootUseCase: _createKahoot,
      updateKahootUseCase: _updateKahoot,
      initialAuthorId: 'author123',
    );

    final k = widget.initialKahoot;
    if (k != null) {
      _titleController.text = k.title;
      visibility = k.visibility == KahootVisibility.private
          ? 'private'
          : 'public';
      // Si el theme viene como id/backend y no coincide con las opciones visibles, no preseleccionar para evitar errores en Dropdown
      _selectedTheme = _themeOptions.contains(k.theme) ? k.theme : null;
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

  @override
  void dispose() {
    _titleController.dispose();
    _editorCubit.close();
    super.dispose();
  }

  Question? _mapResultToQuestion(Map result) {
    try {
      final String type = (result['type'] as String?) ?? '';
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
    return Scaffold(
      backgroundColor: const Color(0xFF222222),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFD54F),
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
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFFFFB300),
                foregroundColor: Colors.brown,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () async {
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

                _editorCubit
                  ..setTitle(title)
                  ..setVisibility(visibilityValue)
                  ..setTheme(_selectedTheme ?? '');

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
              child: const Text('Guardar'),
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
                            fillColor: Color(0xFFFFD54F),
                            hintText: 'Título',
                            hintStyle: TextStyle(color: Colors.black54),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        decoration: BoxDecoration(
                          color: Color(0xFFFFB300),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.all(8),
                        child: const Icon(Icons.settings, color: Colors.black),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: DropdownButtonFormField<String>(
                    // Asegurar que el value esté dentro de las opciones; si no, dejar null
                    value: _themeOptions.contains(_selectedTheme)
                        ? _selectedTheme
                        : null,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Color(0xFFFFD54F),
                      hintText: 'Tema',
                      hintStyle: TextStyle(color: Colors.black54),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    items: _themeOptions
                        .map(
                          (t) => DropdownMenuItem<String>(
                            value: t,
                            child: Text(t),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      setState(() => _selectedTheme = value);
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
                      fillColor: Color(0xFFFFD54F),
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
                                color: Color(0xFF444444),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    state.questions[i].title.isNotEmpty
                                        ? state.questions[i].title
                                        : 'Pregunta ${i + 1}',
                                    style: const TextStyle(color: Colors.white),
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
