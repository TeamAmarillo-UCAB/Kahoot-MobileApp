import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ChatbotPage extends StatefulWidget {
  const ChatbotPage({super.key});

  @override
  State<ChatbotPage> createState() => _ChatbotPageState();
}

class _ChatbotPageState extends State<ChatbotPage> {
  // API KEY NO DOXEARMEEEE
  final apiKey = dotenv.env['GEMINI_API_KEY'];

  late final GenerativeModel _model;
  late final ChatSession _chat;
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _cargando = false;
  final List<MensajeBubble> _mensajes = [];

  // Colores de tu tema Kahoot
  final Color bgBrown = const Color(0xFF3A240C);
  final Color headerYellow = const Color(0xFFF2C147);

  @override
  void initState() {
    super.initState();
    print(apiKey);
    _model = GenerativeModel(model: 'gemini-2.5-flash', apiKey: apiKey!);
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
        _mensajes.add(MensajeBubble(texto: "Error: $e", esUsuario: false));
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
      backgroundColor: bgBrown, // Fondo marrón
      appBar: AppBar(
        backgroundColor: headerYellow, // Cabecera amarilla
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
                      hintText: 'Pregunta sobre un quiz...',
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
