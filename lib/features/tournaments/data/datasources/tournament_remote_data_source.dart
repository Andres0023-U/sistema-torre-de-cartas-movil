import '../../../../core/network/dio_client.dart';
import '../models/tournament_model.dart';

abstract class TournamentRemoteDataSource {
  Future<List<TournamentModel>> getTournaments();
}

class TournamentRemoteDataSourceImpl implements TournamentRemoteDataSource {
  final DioClient dioClient;

  TournamentRemoteDataSourceImpl({required this.dioClient});

  @override
  Future<List<TournamentModel>> getTournaments() async {
    final response = await dioClient.dio.get('/tournaments/');
    final rawList = response.data as List<dynamic>? ?? [];
    return rawList
        .map((e) => TournamentModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
