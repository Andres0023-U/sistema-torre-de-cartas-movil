import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/tournament_create_entity.dart';
import '../bloc/create_tournament_bloc.dart';
import '../bloc/create_tournament_event.dart';
import '../bloc/create_tournament_state.dart';
import '../bloc/tournaments_bloc.dart';
import '../bloc/tournaments_event.dart';
import '../utils/tournament_formatters.dart';

class CreateTournamentPage extends StatelessWidget {
  const CreateTournamentPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<CreateTournamentBloc>(
      create: (_) => sl<CreateTournamentBloc>(),
      child: const _CreateTournamentForm(),
    );
  }
}

class _CreateTournamentForm extends StatefulWidget {
  const _CreateTournamentForm();

  @override
  State<_CreateTournamentForm> createState() => _CreateTournamentFormState();
}

class _CreateTournamentFormState extends State<_CreateTournamentForm> {
  static const List<int> _playerOptions = [4, 8, 16, 32];

  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();

  late DateTime _date;
  int _numPlayers = 8;

  DateTime get _today {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  @override
  void initState() {
    super.initState();
    _date = _today;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  String _two(int n) => n.toString().padLeft(2, '0');

  String _apiDate(DateTime d) => '${d.year}-${_two(d.month)}-${_two(d.day)}';

  Future<void> _pickDate() async {
    final today = _today;
    final picked = await showDatePicker(
      context: context,
      initialDate: _date.isBefore(today) ? today : _date,
      firstDate: today,
      lastDate: DateTime(today.year + 5, today.month, today.day),
    );
    if (picked != null) {
      setState(() {
        _date = picked;
      });
    }
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    context.read<CreateTournamentBloc>().add(
          CreateTournamentSubmitted(
            TournamentCreateEntity(
              name: _nameController.text.trim(),
              date: _apiDate(_date),
              format: 'Eliminación Directa',
              numPlayers: _numPlayers,
            ),
          ),
        );
  }

  void _onSuccess(BuildContext context, CreateTournamentSuccess state) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(
          content: Text('Torneo creado'),
          backgroundColor: AppColors.navy,
        ),
      );
    context.read<TournamentsBloc>().add(const TournamentsRequested());
    context.pushReplacement('/tournaments/${state.tournament.tournamentId}');
  }

  InputDecoration _decoration(String label) {
    return InputDecoration(
      labelText: label,
      border: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Crear torneo'),
      ),
      body: SafeArea(
        child: BlocConsumer<CreateTournamentBloc, CreateTournamentState>(
          listener: (context, state) {
            if (state is CreateTournamentSuccess) {
              _onSuccess(context, state);
            }
          },
          builder: (context, state) {
            final submitting = state is CreateTournamentSubmitting;

            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (state is CreateTournamentFailure) ...[
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.error.withValues(alpha: 0.08),
                          border: Border.all(color: AppColors.error),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.error_outline,
                              color: AppColors.error,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                state.message,
                                style: GoogleFonts.sourceSans3(
                                  fontSize: 14,
                                  color: AppColors.error,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                    TextFormField(
                      controller: _nameController,
                      enabled: !submitting,
                      textCapitalization: TextCapitalization.sentences,
                      decoration: _decoration('Nombre'),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'El nombre es obligatorio';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: submitting ? null : _pickDate,
                      child: InputDecorator(
                        decoration: _decoration('Fecha').copyWith(
                          suffixIcon: const Icon(Icons.calendar_today),
                        ),
                        child: Text(
                          formatTournamentDate(_date),
                          style: GoogleFonts.sourceSans3(
                            fontSize: 16,
                            color: AppColors.ink,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Número de jugadores',
                      style: GoogleFonts.sourceSans3(
                        fontSize: 14,
                        color: AppColors.muted,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: [
                        for (final option in _playerOptions)
                          ChoiceChip(
                            label: Text('$option'),
                            selected: _numPlayers == option,
                            onSelected: submitting
                                ? null
                                : (selected) {
                                    if (selected) {
                                      setState(() {
                                        _numPlayers = option;
                                      });
                                    }
                                  },
                          ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.gold,
                        foregroundColor: AppColors.navy,
                        minimumSize: const Size.fromHeight(48),
                      ),
                      onPressed: submitting ? null : _submit,
                      child: submitting
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  AppColors.gold,
                                ),
                              ),
                            )
                          : const Text('Crear torneo'),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
