import 'package:flutter/foundation.dart';

class AuthState {
  static final ValueNotifier<bool> isLoggedIn = ValueNotifier<bool>(false);
  static final ValueNotifier<String?> email = ValueNotifier<String?>(null);
  static final ValueNotifier<String?> username = ValueNotifier<String?>(null);
  static final ValueNotifier<String?> token = ValueNotifier<String?>(null);
}
