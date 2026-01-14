import 'package:dio/dio.dart';
import 'dart:convert';
import '../../domain/datasource/user_datasource.dart';
import '../../domain/entities/user.dart';
import '../../../core/auth_state.dart';

class UserDatasourceImpl implements UserDatasource {
  final Dio dio = Dio();

  UserDatasourceImpl() {
    dio.interceptors.add(
      LogInterceptor(
        requestHeader: true,
        requestBody: true,
        responseHeader: false,
        responseBody: true,
      ),
    );
  }

  @override
  Future<void> createUser(String email, String username, String password) async {
      final body = {
        'email': email,
        'username': username,
        'password': password,
        'name': AuthState.fullName.value ?? '',
        'type': AuthState.userType.value ?? 'STUDENT',
      };
    // Debug: imprimir el JSON que se envía
    // ignore: avoid_print
    print('POST '+ (dio.options.baseUrl.isNotEmpty ? dio.options.baseUrl : '(sin baseUrl)') + '/users payload: ' + jsonEncode(body));

    try {
      final res = await dio.post(
        '/user/register',
        data: body,
        options: Options(headers: {'Content-Type': 'application/json'}),
      );
      // Mostrar respuesta del endpoint para verificar
      try {
        print('Respuesta POST '+ (dio.options.baseUrl.isNotEmpty ? dio.options.baseUrl : '(sin baseUrl)') + '/users (status ${res.statusCode}): ' + jsonEncode(res.data));
      } catch (_) {
        print('Respuesta POST '+ (dio.options.baseUrl.isNotEmpty ? dio.options.baseUrl : '(sin baseUrl)') + '/users (status ${res.statusCode}): ' + res.data.toString());
      }
    } on DioException catch (e) {
      // Imprimir errores detallados de Dio
      print('DioException POST '+ (dio.options.baseUrl.isNotEmpty ? dio.options.baseUrl : '(sin baseUrl)') + '/users: ' + e.message.toString());
      if (e.response != null) {
        try {
          print('Error response (status ${e.response!.statusCode}): ' + jsonEncode(e.response!.data));
        } catch (_) {
          print('Error response (status ${e.response!.statusCode}): ' + e.response!.data.toString());
        }
      }
      rethrow;
    } catch (e) {
      // Otros errores
      print('Error POST '+ (dio.options.baseUrl.isNotEmpty ? dio.options.baseUrl : '(sin baseUrl)') + '/users: ' + e.toString());
      rethrow;
    }
  }

  @override
  Future<void> updateUser(User user) async {
    final body = {
      'email': user.email,
      'username': user.name,
      'password': user.password,
    };
    await dio.put(
      '/profile',
      data: body,
      options: Options(headers: {'Content-Type': 'application/json'}),
    );
  }

  @override
  Future<void> deleteUser(String userId) async {
    await dio.delete(
      '/users/$userId',
      options: Options(headers: {'Content-Type': 'application/json'}),
    );
  }

  @override
  Future<User?> getUserById(String userId) async {
    final response = await dio.get(
      '/users/$userId',
      options: Options(headers: {'Content-Type': 'application/json'}),
    );
    if (response.statusCode == 200) {
      return User.fromJson(response.data);
    } else {
      return null;
    }
  }

  @override
  Future<void> userLogin(String userName, String password) async {
    final body = {
      'username': userName,
      'password': password,
    };
    // Debug
    print('POST '+ (dio.options.baseUrl.isNotEmpty ? dio.options.baseUrl : '(sin baseUrl)') + '/auth/login payload: ' + jsonEncode(body));
    final Response res = await dio.post(
      '/auth/login',
      data: body,
      options: Options(headers: {'Content-Type': 'application/json'}),
    );
    try {
      // Intentar extraer token de distintas formas habituales
      final data = res.data;
      String? token;
      if (data is Map<String, dynamic>) {
        token = (data['token'] as String?) ??
                (data['accessToken'] as String?) ??
                (data['jwt'] as String?) ??
                (data['authToken'] as String?);
        if (token == null && data['data'] is Map<String, dynamic>) {
          final inner = data['data'] as Map<String, dynamic>;
          token = (inner['token'] as String?) ?? (inner['accessToken'] as String?);
        }
      } else if (data is String) {
        // Si el backend devuelve el token plano como string
        token = data;
      }
      if (token != null && token.isNotEmpty) {
        AuthState.token.value = token;
        print('Login token capturado: ' + token);
      } else {
        print('Login sin token detectable en la respuesta: ' + res.data.toString());
      }
    } catch (e) {
      print('No se pudo parsear el token del login: ' + e.toString());
    }
  }

  @override
  Future<void> userLogout() async {
    final body = {
      'email': '',
      'password': '',
    };
    print('POST '+ (dio.options.baseUrl.isNotEmpty ? dio.options.baseUrl : '(sin baseUrl)') + '/auth/logout payload: ' + jsonEncode(body));
    await dio.post(
      '/auth/logout',
      data: body,
      options: Options(headers: {'Content-Type': 'application/json'}),
    );
  }
}
