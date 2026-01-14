import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../../../Contenido_Multimedia/presentation/pages/media_resource_selector.dart';
import '../../../core/widgets/gradient_button.dart';

class LibraryShortAnswerEditorPage extends StatefulWidget {
  final int? index;
  final String? initialTitle;
  final String? initialCorrect;
  final List<String>? initialOthers;
  final int? initialTime;
  const LibraryShortAnswerEditorPage({Key? key, this.index, this.initialTitle, this.initialCorrect, this.initialOthers, this.initialTime}) : super(key: key);
  @override
  State<LibraryShortAnswerEditorPage> createState() => _LibraryShortAnswerEditorPageState();
}

class _LibraryShortAnswerEditorPageState extends State<LibraryShortAnswerEditorPage> {
  final TextEditingController questionController = TextEditingController();
  final TextEditingController correctController = TextEditingController();
  final List<TextEditingController> extraControllers = [];
  final List<int> timeOptions = [5, 10, 20, 30, 45, 60, 90, 120, 180, 240];
  int selectedTime = 30;
  bool showExtra = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialTitle != null) questionController.text = widget.initialTitle!;
    if (widget.initialCorrect != null) correctController.text = widget.initialCorrect!;
    if (widget.initialTime != null) selectedTime = widget.initialTime!;
    final others = widget.initialOthers ?? const <String>[];
    if (others.isNotEmpty) {
      showExtra = true;
      for (final t in others) {
        extraControllers.add(TextEditingController(text: t));
      }
    }
  }

  void _save() {
    final questionText = questionController.text.trim();
    final answers = <Map<String, dynamic>>[];
    final correct = correctController.text.trim();
    if (correct.isNotEmpty) {
      answers.add({'text': correct, 'isCorrect': true});
    }
    for (final c in extraControllers) {
      final t = c.text.trim();
      if (t.isNotEmpty) {
        answers.add({'text': t, 'isCorrect': true});
      }
    }
    Navigator.of(context).pop({
      'type': 'single',
      'title': questionText,
      'time': selectedTime,
      'answers': answers,
    });
  }

  void _openTimeMenu() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          decoration: const BoxDecoration(color: Color(0xFF333333), borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
          padding: const EdgeInsets.all(16),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const Text('Selecciona tiempo', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: timeOptions.map((t) {
                final isSelected = t == selectedTime;
                return ChoiceChip(
                  label: Text('$t s'),
                  selected: isSelected,
                  labelStyle: TextStyle(color: isSelected ? Colors.brown : Colors.white),
                  selectedColor: const Color(0xFFFFD54F),
                  backgroundColor: const Color(0xFF444444),
                  onSelected: (_) => setState(() => selectedTime = t),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFD54F),
                  foregroundColor: Colors.brown,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('Listo'),
              ),
            ),
          ]),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF222222),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF2C147),
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.close, color: Colors.brown), onPressed: () => Navigator.of(context).pop()),
        title: const Text('Respuesta corta', style: TextStyle(color: Colors.brown, fontWeight: FontWeight.bold)),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: GradientButton(onTap: _save, child: const Text('Listo', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 24),
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          const SizedBox(height: 16),
          const MediaResourceSelector(),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF673AB7),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              ),
              onPressed: _openTimeMenu,
              icon: const Icon(Icons.timer),
              label: Text('$selectedTime s'),
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              controller: questionController,
              maxLines: 2,
              decoration: InputDecoration(
                filled: true,
                fillColor: const Color(0xFF3A3A3A),
                hintText: 'Pulsa para añadir una pregunta',
                hintStyle: const TextStyle(color: Colors.white70),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
              ),
              style: const TextStyle(color: Colors.white),
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              decoration: BoxDecoration(color: const Color(0xFFE53935), borderRadius: BorderRadius.circular(8)),
              padding: const EdgeInsets.all(12),
              child: Row(children: [
                Expanded(
                  child: TextField(
                    controller: correctController,
                    decoration: const InputDecoration(hintText: 'Pulsa para escribir la respuesta correcta', hintStyle: TextStyle(color: Colors.white), border: InputBorder.none),
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
                IconButton(
                  tooltip: 'Subir imagen',
                  icon: const Icon(Icons.image, color: Colors.white),
                  onPressed: () async {
                    final res = await FilePicker.platform.pickFiles(type: FileType.image, allowMultiple: false);
                    final name = res?.files.first.name;
                    if (name != null) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Imagen seleccionada: $name')));
                    }
                  },
                ),
              ]),
            ),
          ),
        ]),
      ),
    );
  }
}
