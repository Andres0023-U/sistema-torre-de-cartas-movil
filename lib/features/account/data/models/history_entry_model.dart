import '../../domain/entities/history_entry_entity.dart';

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
      matchId: json['matchId'] as int? ?? 0,
      tournamentId: json['tournamentId'] as int? ?? 0,
      tournamentName: json['tournamentName'] as String? ?? '',
      roundNumber: json['roundNumber'] as int? ?? 0,
      roundName: json['roundName'] as String? ?? '',
      opponentPlayerId: json['opponentPlayerId'] as int?,
      opponentName: json['opponentName'] as String?,
      won: json['won'] as bool? ?? false,
      points: json['points'] as int? ?? 0,
      endPhase: json['endPhase'] as String? ?? '',
      date: json['date'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'matchId': matchId,
      'tournamentId': tournamentId,
      'tournamentName': tournamentName,
      'roundNumber': roundNumber,
      'roundName': roundName,
      if (opponentPlayerId != null) 'opponentPlayerId': opponentPlayerId,
      if (opponentName != null) 'opponentName': opponentName,
      'won': won,
      'points': points,
      'endPhase': endPhase,
      'date': date,
    };
  }
}
