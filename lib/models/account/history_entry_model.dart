import 'package:torre_de_cartas_movil/models/account/history_entry_entity.dart';

class HistoryEntryModel extends HistoryEntryEntity {
  const HistoryEntryModel({
    required super.matchId,
    required super.tournamentId,
    required super.tournamentName,
    required super.roundNumber,
    required super.roundName,
    super.opponentPlayerId,
    super.opponentName,
    required super.won,
    required super.points,
    required super.endPhase,
    required super.date,
  });

  factory HistoryEntryModel.fromJson(Map<String, dynamic> json) {
    return HistoryEntryModel(
      matchId: (json['matchId'] as num?)?.toInt() ??
          (json['match_id'] as num?)?.toInt() ??
          0,
      tournamentId: (json['tournamentId'] as num?)?.toInt() ??
          (json['tournament_id'] as num?)?.toInt() ??
          0,
      tournamentName: json['tournamentName']?.toString() ??
          json['tournament_name']?.toString() ??
          '',
      roundNumber: (json['roundNumber'] as num?)?.toInt() ??
          (json['round_number'] as num?)?.toInt() ??
          0,
      roundName: json['roundName']?.toString() ??
          json['round_name']?.toString() ??
          '',
      opponentPlayerId: (json['opponentPlayerId'] as num?)?.toInt() ??
          (json['opponent_player_id'] as num?)?.toInt(),
      opponentName:
          json['opponentName']?.toString() ?? json['opponent_name']?.toString(),
      won: json['won'] as bool? ?? false,
      points: (json['points'] as num?)?.toInt() ?? 0,
      endPhase:
          json['endPhase']?.toString() ?? json['end_phase']?.toString() ?? '',
      date: json['date']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'match_id': matchId,
      'tournament_id': tournamentId,
      'tournament_name': tournamentName,
      'round_number': roundNumber,
      'round_name': roundName,
      if (opponentPlayerId != null) 'opponent_player_id': opponentPlayerId,
      if (opponentName != null) 'opponent_name': opponentName,
      'won': won,
      'points': points,
      'end_phase': endPhase,
      'date': date,
    };
  }
}
