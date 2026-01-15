// lib/Informes_Estadisticas/infrastructure/datasource/reports_datasource_impl.dart

import 'package:dio/dio.dart';
import '../../../config/api_config.dart'; // Ajusta según tu estructura real
import '../../../core/auth_state.dart';   // Ajusta según tu estructura real
import '../../domain/datasource/reports_datasource.dart';
import '../../domain/entities/player_result_detail.dart';
import '../../domain/entities/result_summary.dart';
import '../../domain/entities/session_report.dart';

class ReportsDatasourceImpl implements ReportsDatasource {
  final Dio dio;

  ReportsDatasourceImpl({Dio? dio})
      : dio = dio ??
            Dio(
              BaseOptions(
                headers: {'Content-Type': 'application/json'},
              ),
            ) {
    // Interceptor para inyectar la URL base y el Token JWT dinámicamente
    this.dio.interceptors.add(
          InterceptorsWrapper(
            onRequest: (options, handler) {
              options.baseUrl = ApiConfig().baseUrl; // Usando configuración global
              
              final token = AuthState.token.value; // Obteniendo token actual
              
              if (token != null && token.isNotEmpty) {
                options.headers['Authorization'] = 'Bearer $token';
              }
              
              return handler.next(options);
            },
            onError: (DioException e, handler) {
              // Aquí podrías loguear errores o manejar refresh token si fuera necesario
              return handler.next(e);
            },
          ),
        );
  }

  @override
  Future<PaginatedResult> getMyResultsHistory({int page = 1, int limit = 20}) async {
    final response = await dio.get(
      '/reports/kahoots/my-results',
      queryParameters: {
        'page': page,
        'limit': limit,
      },
    );
    return PaginatedResult.fromJson(response.data);
  }

  @override
  Future<SessionReport> getSessionReport(String sessionId) async {
    final response = await dio.get('/reports/sessions/$sessionId');
    return SessionReport.fromJson(response.data);
  }

  @override
  Future<PlayerResultDetail> getMultiplayerResult(String sessionId) async {
    final response = await dio.get('/reports/multiplayer/$sessionId');
    return PlayerResultDetail.fromJson(response.data);
  }

  @override
  Future<PlayerResultDetail> getSingleplayerResult(String attemptId) async {
    final response = await dio.get('/reports/singleplayer/$attemptId');
    return PlayerResultDetail.fromJson(response.data);
  }
}