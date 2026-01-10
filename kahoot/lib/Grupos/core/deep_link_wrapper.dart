import 'dart:async';
import 'package:flutter/material.dart';
import 'package:app_links/app_links.dart';

import '../presentation/pages/my_groups_page.dart';

class DeepLinkWrapper extends StatefulWidget {
  final Widget child;

  const DeepLinkWrapper({super.key, required this.child});

  @override
  State<DeepLinkWrapper> createState() => _DeepLinkWrapperState();
}

class _DeepLinkWrapperState extends State<DeepLinkWrapper> {
  late AppLinks _appLinks;
  StreamSubscription<Uri>? _linkSubscription;

  @override
  void initState() {
    super.initState();
    _initDeepLinks();
  }

  @override
  void dispose() {
    _linkSubscription?.cancel();
    super.dispose();
  }

  void _initDeepLinks() {
    _appLinks = AppLinks();

    // Escuchar links entrantes
    _linkSubscription = _appLinks.uriLinkStream.listen(
      (Uri? uri) {
        if (uri != null) {
          _handleDeepLink(uri);
        }
      },
      onError: (err) {
        debugPrint("Error en deep link: $err");
      },
    );
  }

  void _handleDeepLink(Uri uri) {
    // Si la ruta es para unirse a un grupo
    if (uri.path.contains('/groups/join')) {
      final String? token = uri.queryParameters['token'];

      if (token != null) {
        debugPrint("DeepLink recibido con token: $token");

        // Navegar directamente al Wrapper de Grupos pasándole el token
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => MyGroupsPage(invitationToken: token),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
