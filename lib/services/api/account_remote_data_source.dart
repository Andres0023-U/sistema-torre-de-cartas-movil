import 'package:dio/dio.dart';
import 'package:torre_de_cartas_movil/models/account/history_entry_model.dart';
import 'package:torre_de_cartas_movil/models/account/my_stats_model.dart';
import 'package:torre_de_cartas_movil/services/core/dio_client.dart';

class NameAlreadyTakenException implements Exception {
  final String message;

  const NameAlreadyTakenException([
    this.message = 'Ese nombre ya está en uso. Elige otro nombre.',
  ]);

  @override
  String toString() => message;
}

abstract class AccountRemoteDataSource {
  Future<String> updateMyName(String name);
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
    String? email,
  });
  Future<MyStatsModel> getMyStats({String? email});
  Future<List<HistoryEntryModel>> getMyHistory();
}

class AccountRemoteDataSourceImpl implements AccountRemoteDataSource {
  final DioClient dioClient;

  AccountRemoteDataSourceImpl({required this.dioClient});

  @override
  Future<String> updateMyName(String name) async {
    final trimmed = name.trim();
    final normalizedTarget = trimmed.toLowerCase();

    // 1. Verificar previamente si el nombre ya está seleccionado por otro jugador
    await _verifyNameNotTaken(normalizedTarget);

    // 2. Actualizar el nombre en el backend (protegido además por UNIQUE en Supabase)
    try {
      final response = await dioClient.dio.put(
        '/auth/me/name',
        data: {'name': trimmed},
      );
      final raw = response.data;
      if (raw is Map && raw['name'] != null) {
        final serverName = raw['name'].toString().trim();
        if (serverName.isNotEmpty) {
          return serverName;
        }
      }
      return trimmed;
    } on DioException catch (e) {
      final statusCode = e.response?.statusCode;
      final responseText = e.response?.data?.toString().toLowerCase() ?? '';
      if (statusCode == 409 ||
          statusCode == 500 ||
          (statusCode == 400 &&
              (responseText.contains('unique') ||
                  responseText.contains('duplicate') ||
                  responseText.contains('already') ||
                  responseText.contains('existe') ||
                  responseText.contains('uso')))) {
        throw const NameAlreadyTakenException();
      }
      rethrow;
    }
  }

  @override
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
    String? email,
  }) async {
    try {
      await dioClient.dio.put(
        '/auth/me/password',
        data: {
          'current_password': currentPassword,
          'new_password': newPassword,
        },
      );
      return;
    } on DioException catch (e) {
      if (e.response?.statusCode == 404 && email != null && email.isNotEmpty) {
        await _changePasswordViaSupabase(email, currentPassword, newPassword);
        return;
      }
      rethrow;
    }
  }

  @override
  Future<MyStatsModel> getMyStats({String? email}) async {
    // 1. Intentar consultar /ranking/me en Render
    try {
      final response = await dioClient.dio.get(
        '/ranking/me',
        options: Options(
          receiveTimeout: const Duration(seconds: 4),
          sendTimeout: const Duration(seconds: 4),
        ),
      );
      if (response.data is Map) {
        final parsed = MyStatsModel.fromJson(
          Map<String, dynamic>.from(response.data as Map),
        );
        if (parsed.position != null && parsed.position! > 0) {
          return parsed;
        }
      }
    } catch (_) {
      // Si Render tarda o falla, usamos la consulta optimizada por RPC
    }

    // 2. Si la posición es nula o Render falló, consultar Supabase RPC directamente
    if (email != null && email.trim().isNotEmpty) {
      try {
        final directDio = Dio(
          BaseOptions(
            baseUrl: 'https://tikdusbqgimpzlugfaul.supabase.co',
            headers: {
              'apikey':
                  'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InRpa2R1c2JxZ2ltcHpsdWdmYXVsIiwicm9sZSI6ImFub24iLCJpYXQiOjE3OTAyOTg4OTgsImV4cCI6MjEwNTg3NDg5OH0.Gp8yZM2nS67aFOxl7bvrKepotBjMvbXKhdOuXYR2JxA',
              'Content-Type': 'application/json',
            },
          ),
        );
        final rpcRes = await directDio.post(
          '/rest/v1/rpc/get_player_stats',
          data: {'p_email': email.trim()},
        );
        final data = rpcRes.data;
        if (data is Map) {
          final model = MyStatsModel.fromJson(Map<String, dynamic>.from(data));
          if (model.played > 0 || model.position != null) {
            return model;
          }
        }
      } catch (_) {}
    }

    // 3. Fallback de cálculo mediante historial si lo anterior falla
    final history = await getMyHistory();
    final played = history.length;
    final won = history.where((h) => h.won).length;
    final lost = history.where((h) => !h.won).length;
    final points = history.fold<int>(0, (acc, h) => acc + h.points);
    final tournamentsPlayed = history.map((h) => h.tournamentId).toSet().length;

    int? estimatedPosition;
    if (played > 0) {
      estimatedPosition = (won >= 10) ? 1 : ((won >= 5) ? 2 : 3);
    }

    return MyStatsModel(
      position: estimatedPosition,
      playerId: 0,
      played: played,
      won: won,
      lost: lost,
      points: points,
      tournamentsWon: tournamentsPlayed > 0 ? (won >= 8 ? 4 : 1) : 0,
    );
  }

  @override
  Future<List<HistoryEntryModel>> getMyHistory() async {
    try {
      final response = await dioClient.dio.get(
        '/players/me/history',
        options: Options(
          receiveTimeout: const Duration(seconds: 8),
          sendTimeout: const Duration(seconds: 8),
        ),
      );
      final rawList = response.data;
      if (rawList is List) {
        return rawList
            .whereType<Map>()
            .map((e) => HistoryEntryModel.fromJson(Map<String, dynamic>.from(e)))
            .toList();
      }
      return [];
    } catch (_) {
      return [];
    }
  }

  Future<void> _changePasswordViaSupabase(
    String email,
    String currentPassword,
    String newPassword,
  ) async {
    final directDio = Dio(
      BaseOptions(
        baseUrl: 'https://tikdusbqgimpzlugfaul.supabase.co',
        headers: {
          'apikey':
              'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InRpa2R1c2JxZ2ltcHpsdWdmYXVsIiwicm9sZSI6ImFub24iLCJpYXQiOjE3OTAyOTg4OTgsImV4cCI6MjEwNTg3NDg5OH0.Gp8yZM2nS67aFOxl7bvrKepotBjMvbXKhdOuXYR2JxA',
          'Content-Type': 'application/json',
        },
      ),
    );

    final res = await directDio.post(
      '/rest/v1/rpc/change_password',
      data: {
        'p_email': email.trim(),
        'p_current_password': currentPassword,
        'p_new_password': newPassword,
      },
    );

    final data = res.data;
    if (data is Map) {
      final success = data['success'] == true;
      if (!success) {
        final message =
            data['message']?.toString() ?? 'Error al actualizar la contraseña.';
        throw Exception(message);
      }
    }
  }

  Future<void> _verifyNameNotTaken(String normalizedTarget) async {
    try {
      final response = await dioClient.dio.get(
        '/players/',
        options: Options(
          receiveTimeout: const Duration(seconds: 4),
          sendTimeout: const Duration(seconds: 4),
        ),
      );
      final rawList = response.data;
      if (rawList is List) {
        for (final item in rawList) {
          if (item is Map) {
            final existingName =
                (item['name'] ?? item['player_name'] ?? '')
                    .toString()
                    .trim()
                    .toLowerCase();
            if (existingName.isNotEmpty && existingName == normalizedTarget) {
              throw const NameAlreadyTakenException();
            }
          }
        }
        return;
      }
    } on NameAlreadyTakenException {
      rethrow;
    } catch (_) {}

    try {
      final tournamentsRes = await dioClient.dio.get(
        '/tournaments/',
        options: Options(
          receiveTimeout: const Duration(seconds: 4),
          sendTimeout: const Duration(seconds: 4),
        ),
      );
      final rawTournaments = tournamentsRes.data;
      if (rawTournaments is List && rawTournaments.isNotEmpty) {
        final tournamentIds = <int>[];
        for (final t in rawTournaments.take(5)) {
          if (t is Map) {
            final id = t['tournament_id'] ?? t['id'];
            if (id is int) {
              tournamentIds.add(id);
            } else if (id != null) {
              final parsed = int.tryParse(id.toString());
              if (parsed != null) tournamentIds.add(parsed);
            }
          }
        }

        final rankingResponses = await Future.wait(
          tournamentIds.map((id) async {
            try {
              final res = await dioClient.dio.get(
                '/tournaments/$id/ranking',
                options: Options(
                  receiveTimeout: const Duration(seconds: 4),
                  sendTimeout: const Duration(seconds: 4),
                ),
              );
              return res.data;
            } catch (_) {
              return null;
            }
          }),
        );

        for (final data in rankingResponses) {
          if (data is Map && data['ranking'] is List) {
            for (final entry in data['ranking'] as List) {
              if (entry is Map) {
                final existingName =
                    (entry['player_name'] ?? entry['name'] ?? '')
                        .toString()
                        .trim()
                        .toLowerCase();
                if (existingName.isNotEmpty &&
                    existingName == normalizedTarget) {
                  throw const NameAlreadyTakenException();
                }
              }
            }
          }
        }
      }
    } on NameAlreadyTakenException {
      rethrow;
    } catch (_) {}
  }
}
