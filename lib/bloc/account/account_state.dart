import 'package:equatable/equatable.dart';
import 'package:torre_de_cartas_movil/models/account/history_entry_entity.dart';
import 'package:torre_de_cartas_movil/models/account/my_stats_entity.dart';

class AccountState extends Equatable {
  final bool isUpdatingName;
  final String? updatedName;
  final String? successMessage;
  final String? errorMessage;
  final bool isChangingPassword;
  final bool passwordChangedSuccessfully;
  final String? passwordErrorMessage;
  final String? passwordSuccessMessage;

  // Estadísticas del jugador
  final bool isLoadingStats;
  final MyStatsEntity? stats;
  final List<HistoryEntryEntity> history;
  final String? statsErrorMessage;

  const AccountState({
    this.isUpdatingName = false,
    this.updatedName,
    this.successMessage,
    this.errorMessage,
    this.isChangingPassword = false,
    this.passwordChangedSuccessfully = false,
    this.passwordErrorMessage,
    this.passwordSuccessMessage,
    this.isLoadingStats = false,
    this.stats,
    this.history = const [],
    this.statsErrorMessage,
  });

  AccountState copyWith({
    bool? isUpdatingName,
    String? updatedName,
    bool clearUpdatedName = false,
    String? successMessage,
    bool clearSuccess = false,
    String? errorMessage,
    bool clearError = false,
    bool? isChangingPassword,
    bool? passwordChangedSuccessfully,
    String? passwordErrorMessage,
    bool clearPasswordError = false,
    String? passwordSuccessMessage,
    bool clearPasswordSuccess = false,
    bool? isLoadingStats,
    MyStatsEntity? stats,
    bool clearStats = false,
    List<HistoryEntryEntity>? history,
    String? statsErrorMessage,
    bool clearStatsError = false,
  }) {
    return AccountState(
      isUpdatingName: isUpdatingName ?? this.isUpdatingName,
      updatedName:
          clearUpdatedName ? null : (updatedName ?? this.updatedName),
      successMessage:
          clearSuccess ? null : (successMessage ?? this.successMessage),
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      isChangingPassword: isChangingPassword ?? this.isChangingPassword,
      passwordChangedSuccessfully:
          passwordChangedSuccessfully ?? this.passwordChangedSuccessfully,
      passwordErrorMessage: clearPasswordError
          ? null
          : (passwordErrorMessage ?? this.passwordErrorMessage),
      passwordSuccessMessage: clearPasswordSuccess
          ? null
          : (passwordSuccessMessage ?? this.passwordSuccessMessage),
      isLoadingStats: isLoadingStats ?? this.isLoadingStats,
      stats: clearStats ? null : (stats ?? this.stats),
      history: history ?? this.history,
      statsErrorMessage:
          clearStatsError ? null : (statsErrorMessage ?? this.statsErrorMessage),
    );
  }

  @override
  List<Object?> get props => [
        isUpdatingName,
        updatedName,
        successMessage,
        errorMessage,
        isChangingPassword,
        passwordChangedSuccessfully,
        passwordErrorMessage,
        passwordSuccessMessage,
        isLoadingStats,
        stats,
        history,
        statsErrorMessage,
      ];
}
