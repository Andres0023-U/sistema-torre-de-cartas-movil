import 'package:torre_de_cartas_movil/models/account/history_entry_entity.dart';
import 'package:torre_de_cartas_movil/models/account/my_stats_entity.dart';

abstract class AccountRepository {
  Future<String> updateMyName(String name);
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
    String? email,
  });
  Future<MyStatsEntity> getMyStats();
  Future<List<HistoryEntryEntity>> getMyHistory();
}
