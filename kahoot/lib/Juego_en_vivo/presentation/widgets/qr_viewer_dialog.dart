import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class QRViewerDialog extends StatelessWidget {
  final String sessionPin;
  final String qrToken;

  const QRViewerDialog({
    super.key,
    required this.sessionPin,
    required this.qrToken,
  });

  @override
  Widget build(BuildContext context) {
    final String joinUrl = qrToken;

    return AlertDialog(
      title: const Text('Escanea para unirte', textAlign: TextAlign.center),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 250,
            height: 250,
            child: QrImageView(
              data: joinUrl,
              version: QrVersions.auto,
              size: 250.0,
              gapless: false,
              embeddedImage: const AssetImage('assets/images/logo_icon.png'),
              embeddedImageStyle: const QrEmbeddedImageStyle(
                size: Size(40, 40),
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Text('O ingresa el PIN:'),
          Text(
            sessionPin,
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w900,
              letterSpacing: 4,
              color: Colors.amber,
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('CERRAR'),
        ),
      ],
    );
  }
}
