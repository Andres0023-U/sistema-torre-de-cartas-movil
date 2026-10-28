import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

const List<String> _monthNames = [
  '', 'ene', 'feb', 'mar', 'abr', 'may', 'jun',
  'jul', 'ago', 'sep', 'oct', 'nov', 'dic',
];

/// Formato "15 ene 2025" con meses abreviados escritos a mano (sin intl).
String formatTournamentDate(DateTime date) {
  return '${date.day} ${_monthNames[date.month]} ${date.year}';
}

/// Texto de estado en español. [finishedLabel] permite "Finalizado" (torneo)
/// o "Finalizada" (ronda). Si el estado es desconocido se muestra tal cual.
String tournamentStatusLabel(String status, {String finishedLabel = 'Finalizado'}) {
  switch (status) {
    case 'pending':
      return 'Pendiente';
    case 'in_progress':
      return 'En curso';
    case 'finished':
      return finishedLabel;
    default:
      return status;
  }
}

Color tournamentStatusColor(String status) {
  switch (status) {
    case 'pending':
      return const Color(0xFF3B6FA0);
    case 'in_progress':
      return AppColors.gold;
    default:
      return AppColors.muted;
  }
}

Color tournamentStatusTextColor(String status) {
  return status == 'in_progress' ? AppColors.navy : Colors.white;
}

