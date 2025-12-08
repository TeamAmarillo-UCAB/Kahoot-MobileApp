// lib/Motor_Juego_Vivo/infrastructure/datasource/game_api_datasource_impl.dart

import 'package:dio/dio.dart';
import '../../domain/datasource/game_api_datasource.dart';

class GameApiDatasourceImpl implements GameApiDatasource {
  final Dio http;

  GameApiDatasourceImpl(this.http);

  @override
  Future<Map<String, dynamic>> createSession({required String kahootId}) async {
    // TODO: Implementar al conectar con backend real
    throw UnimplementedError();
  }

  @override
  Future<Map<String, dynamic>> getSessionByQrToken({required String qrToken}) async {
    // TODO: Implementar al conectar backend real
    throw UnimplementedError();
  }
}
