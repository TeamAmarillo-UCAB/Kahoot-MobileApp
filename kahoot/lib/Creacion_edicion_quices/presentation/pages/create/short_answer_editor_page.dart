import 'package:flutter/material.dart';
// Dependencias eliminadas, vista solo UI

class ShortAnswerEditorPage extends StatefulWidget {
  final int? index; // null => new
  const ShortAnswerEditorPage({Key? key, this.index}) : super(key: key);

  @override
  State<ShortAnswerEditorPage> createState() => _ShortAnswerEditorPageState();
}

class _ShortAnswerEditorPageState extends State<ShortAnswerEditorPage> {
  final TextEditingController questionController = TextEditingController();
  final TextEditingController correctController = TextEditingController();
  final List<TextEditingController> extraControllers = [];
  final List<int> timeOptions = [5, 10, 20, 30, 45, 60, 90, 120, 180, 240];
  int selectedTime = 30;
  bool showExtra = false;

  @override
  void initState() {
    super.initState();
    // Solo UI, sin lógica de persistencia
  }

  void _openTimeMenu() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          decoration: const BoxDecoration(
            color: Color(0xFF333333),
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
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
            ],
          ),
        );
      },
    );
  }

  void _save() {
    // Solo UI, sin lógica de persistencia
    Navigator.of(context).pop({'type': 'short_answer'});
  }

  void _addExtraField() {
    setState(() {
      showExtra = true;
      extraControllers.add(TextEditingController());
      extraControllers.add(TextEditingController());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF222222),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFD54F),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.brown),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Respuesta corta', style: TextStyle(color: Colors.brown, fontWeight: FontWeight.bold)),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFB300),
                foregroundColor: Colors.brown,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: _save,
              child: const Text('Listo'),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 16),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFF333333),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: const [
                  Icon(Icons.insert_photo, color: Colors.white70, size: 40),
                  SizedBox(height: 8),
                  Text('Añadir multimedia', style: TextStyle(color: Colors.white)),
                ],
              ),
            ),
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
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                ),
                style: const TextStyle(color: Colors.white),
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFE53935),
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.all(12),
                child: TextField(
                  controller: correctController,
                  decoration: const InputDecoration(
                    hintText: 'Pulsa para escribir la respuesta correcta',
                    hintStyle: TextStyle(color: Colors.white),
                    border: InputBorder.none,
                  ),
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 12),
            if (!showExtra)
              Center(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black87,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: _addExtraField,
                  child: const Text('Añadir otras respuestas aceptadas'),
                ),
              ),
            if (showExtra)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    ...extraControllers.map((c) => Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          decoration: BoxDecoration(
                            color: const Color(0xFF3A3A3A),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.all(12),
                          child: TextField(
                            controller: c,
                            decoration: const InputDecoration(
                              hintText: 'Respuesta aceptada',
                              hintStyle: TextStyle(color: Colors.white70),
                              border: InputBorder.none,
                            ),
                            style: const TextStyle(color: Colors.white),
                          ),
                        )),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () => setState(() => extraControllers.add(TextEditingController())),
                        child: const Text('Añadir otra', style: TextStyle(color: Color(0xFFFFD54F))),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
