import 'package:flutter/material.dart';
// Dependencias eliminadas, vista solo UI

class TrueFalseEditorPage extends StatefulWidget {
	final int? index; // null => new question
	const TrueFalseEditorPage({Key? key, this.index}) : super(key: key);

	@override
	State<TrueFalseEditorPage> createState() => _TrueFalseEditorPageState();
}

class _TrueFalseEditorPageState extends State<TrueFalseEditorPage> {
	final TextEditingController questionController = TextEditingController();
	final TextEditingController trueController = TextEditingController(text: 'Verdadero');
	final TextEditingController falseController = TextEditingController(text: 'Falso');
	final List<int> timeOptions = [5, 10, 20, 45, 60, 90, 120, 180, 240];
	int selectedTime = 20;

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
		final questionText = questionController.text.trim();
		final answers = <Map<String, dynamic>>[
			{'text': trueController.text.trim(), 'isCorrect': true},
			{'text': falseController.text.trim(), 'isCorrect': false},
		];
		Navigator.of(context).pop({
			'type': 'true_false',
			'title': questionText,
			'time': selectedTime,
			'answers': answers,
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
				title: const Text('Verdadero o falso', style: TextStyle(color: Colors.brown, fontWeight: FontWeight.bold)),
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
							child: Row(
								children: [
									Expanded(child: _TFBox(controller: trueController, color: const Color(0xFF1E88E5))),
									const SizedBox(width: 8),
									Expanded(child: _TFBox(controller: falseController, color: const Color(0xFFE53935))),
								],
							),
						),
					],
				),
			),
		);
	}
}

class _TFBox extends StatelessWidget {
	final TextEditingController controller;
	final Color color;
	const _TFBox({required this.controller, required this.color});

	@override
	Widget build(BuildContext context) {
		return Container(
			decoration: BoxDecoration(
				color: color,
				borderRadius: BorderRadius.circular(8),
			),
			padding: const EdgeInsets.all(12),
			child: TextField(
				controller: controller,
				decoration: const InputDecoration(
					hintText: 'Pulsa para añadir respuesta',
					hintStyle: TextStyle(color: Colors.white),
					border: InputBorder.none,
				),
				style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
			),
		);
	}
}
