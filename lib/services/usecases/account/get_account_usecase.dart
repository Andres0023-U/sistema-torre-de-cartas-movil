import 'package:torre_de_cartas_movil/models/account/history_entry_entity.dart';
import 'package:torre_de_cartas_movil/models/account/my_stats_entity.dart';
import 'package:torre_de_cartas_movil/repositories/account/account_repository.dart';

class PlayerStatsResult {
  final MyStatsEntity stats;
  final List<HistoryEntryEntity> history;

  const PlayerStatsResult({
    required this.stats,
    required this.history,
  });
}

class GetAccountUseCase {
  final AccountRepository repository;

  GetAccountUseCase({required this.repository});

  Future<PlayerStatsResult> call() async {
    final statsFuture = repository.getMyStats();
    final historyFuture = repository.getMyHistory();

    final results = await Future.wait([statsFuture, historyFuture]);
    return PlayerStatsResult(
      stats: results[0] as MyStatsEntity,
      history: results[1] as List<HistoryEntryEntity>,
    );
  }
}
