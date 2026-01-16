import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ChatbotPage extends StatefulWidget {
  const ChatbotPage({super.key});

  @override
  State<ChatbotPage> createState() => _ChatbotPageState();
}

class _ChatbotPageState extends State<ChatbotPage> {
  final apiKey = dotenv.env['GEMINI_API_KEY'];

  late final GenerativeModel _model;
  late final ChatSession _chat;
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _cargando = false;
  final List<MensajeBubble> _mensajes = [];

  final Color bgBrown = const Color(0xFF3A240C);
  final Color headerYellow = const Color(0xFFF2C147);

  @override
  void initState() {
    super.initState();
    _model = GenerativeModel(
      model: 'gemini-2.5-flash',
      apiKey: apiKey!,
      systemInstruction: Content.system(
        'Eres el Asistente K, una IA de apoyo emocional dentro de una aplicación de quizzes educativos estilo Kahoot. '
        'Tu objetivo principal es motivar, calmar y animar a los estudiantes, especialmente cuando se sienten frustrados con las preguntas. '
        'Reglas estrictas: '
        '1. Habla siempre en español. '
        '2. Sé extremadamente amable, empático y cariñoso. '
        '3. PROHIBIDO usar formato Markdown: nunca uses asteriscos (*), negritas, cursivas ni bloques de código. Escribe solo texto plano limpio. '
        '4. Usa emojis ocasionalmente para ser más amigable.',
      ),
    );
    _chat = _model.startChat();
  }

  Future<void> _enviarMensaje() async {
    final texto = _textController.text;
    if (texto.isEmpty) return;

    setState(() {
      _mensajes.add(MensajeBubble(texto: texto, esUsuario: true));
      _cargando = true;
      _textController.clear();
    });
    _scrollAbajo();

    try {
      final response = await _chat.sendMessage(Content.text(texto));
      final textoRespuesta = response.text ?? "No entendí la respuesta.";

      setState(() {
        _mensajes.add(MensajeBubble(texto: textoRespuesta, esUsuario: false));
        _cargando = false;
      });
      _scrollAbajo();
    } catch (e) {
      setState(() {
        _mensajes.add(
          MensajeBubble(
            texto:
                "Ocurrió un error de conexión, pero estoy aquí para intentarlo de nuevo contigo.",
            esUsuario: false,
          ),
        );
        _cargando = false;
      });
    }
  }

  void _scrollAbajo() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgBrown,
      appBar: AppBar(
        backgroundColor: headerYellow,
        title: const Text(
          'Asistente K!',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _mensajes.length,
              itemBuilder: (context, index) => _mensajes[index],
            ),
          ),
          if (_cargando)
            const LinearProgressIndicator(color: Color(0xFFF2C147)),
          Container(
            padding: const EdgeInsets.all(10),
            color: Colors.white,
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _textController,
                    decoration: InputDecoration(
                      hintText: 'Cuéntame cómo te sientes...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                      ),
                    ),
                    onSubmitted: (_) => _enviarMensaje(),
                  ),
                ),
                const SizedBox(width: 8),
                CircleAvatar(
                  backgroundColor: headerYellow,
                  child: IconButton(
                    icon: const Icon(Icons.send, color: Colors.black),
                    onPressed: _enviarMensaje,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class MensajeBubble extends StatelessWidget {
  final String texto;
  final bool esUsuario;

  const MensajeBubble({
    super.key,
    required this.texto,
    required this.esUsuario,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: esUsuario ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.all(12),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        decoration: BoxDecoration(
          color: esUsuario ? const Color(0xFFF2C147) : Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(12),
            topRight: const Radius.circular(12),
            bottomLeft: esUsuario ? const Radius.circular(12) : Radius.zero,
            bottomRight: esUsuario ? Radius.zero : const Radius.circular(12),
          ),
        ),
        child: Text(
          texto,
          style: const TextStyle(color: Colors.black, fontSize: 16),
        ),
      ),
    );
  }
}
