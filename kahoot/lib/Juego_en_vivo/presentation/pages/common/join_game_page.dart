import 'package:flutter/material.dart';
import 'qr_scanner_page.dart';
import 'nickname_entry_page.dart';

class JoinGamePage extends StatelessWidget {
  const JoinGamePage({super.key});

  @override
  Widget build(BuildContext context) {
    final TextEditingController pinController = TextEditingController();

    return Scaffold(
      appBar: AppBar(title: const Text('Unirse al Juego')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: pinController,
              decoration: const InputDecoration(
                labelText: 'PIN del Juego',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                if (pinController.text.isNotEmpty) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const NicknameEntryPage(),
                    ),
                  );
                }
              },
              child: const Text('Entrar con PIN'),
            ),
            const Divider(height: 40),
            IconButton(
              iconSize: 64,
              icon: const Icon(Icons.qr_code_scanner),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const QrScannerPage()),
                );
              },
            ),
            const Text('Escanear QR'),
          ],
        ),
      ),
    );
  }
}
