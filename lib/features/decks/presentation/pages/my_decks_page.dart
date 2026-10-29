import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/deck_entity.dart';
import '../bloc/decks_bloc.dart';
import '../bloc/decks_event.dart';
import '../bloc/decks_state.dart';

class MyDecksPage extends StatefulWidget {
  const MyDecksPage({super.key});

  @override
  State<MyDecksPage> createState() => _MyDecksPageState();
}

class _MyDecksPageState extends State<MyDecksPage> {
  @override
  void initState() {
    super.initState();
    context.read<DecksBloc>().add(const DecksRequested());
  }

  void _showCreateDeckDialog(BuildContext context) {
    final textController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Crear nuevo mazo'),
          content: Form(
            key: formKey,
            child: TextFormField(
              controller: textController,
              autofocus: true,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                labelText: 'Nombre del mazo',
                hintText: 'Ej. Mazo Fuego, Control...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                ),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'El nombre es obligatorio';
                }
                return null;
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.gold,
                foregroundColor: AppColors.navy,
              ),
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  final name = textController.text.trim();
                  Navigator.of(dialogContext).pop();
                  context.read<DecksBloc>().add(DeckCreateRequested(name));
                }
              },
              child: const Text('Crear'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Mazos'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Crear mazo',
            onPressed: () => _showCreateDeckDialog(context),
          ),
        ],
      ),
      body: SafeArea(
        child: BlocConsumer<DecksBloc, DecksState>(
          listenWhen: (previous, current) =>
              current is DecksLoaded &&
              (current.successMessage != null || current.errorMessage != null),
          listener: (context, state) {
            if (state is! DecksLoaded) return;
            final isError = state.errorMessage != null;
            final message = state.errorMessage ?? state.successMessage!;
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                SnackBar(
                  content: Text(message),
                  backgroundColor:
                      isError ? AppColors.error : AppColors.navy,
                ),
              );
          },
          builder: (context, state) {
            if (state is DecksInitial || state is DecksLoading) {
              return const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.gold),
                ),
              );
            }

            if (state is DecksFailure) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        color: AppColors.error,
                        size: 48,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        state.message,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.sourceSans3(
                          fontSize: 15,
                          color: AppColors.ink,
                        ),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.navy,
                          foregroundColor: Colors.white,
                        ),
                        onPressed: () {
                          context.read<DecksBloc>().add(const DecksRequested());
                        },
                        child: const Text('Reintentar'),
                      ),
                    ],
                  ),
                ),
              );
            }

            if (state is DecksLoaded) {
              if (state.decks.isEmpty) {
                return RefreshIndicator(
                  color: AppColors.gold,
                  onRefresh: () async {
                    context.read<DecksBloc>().add(const DecksRequested());
                  },
                  child: LayoutBuilder(
                    builder: (context, constraints) => SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: ConstrainedBox(
                        constraints:
                            BoxConstraints(minHeight: constraints.maxHeight),
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.all(24),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.style_outlined,
                                  size: 64,
                                  color: AppColors.muted,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'Aún no tienes mazos creados',
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.sourceSans3(
                                    fontSize: 16,
                                    color: AppColors.muted,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.gold,
                                    foregroundColor: AppColors.navy,
                                  ),
                                  onPressed: () =>
                                      _showCreateDeckDialog(context),
                                  icon: const Icon(Icons.add),
                                  label: const Text('Crear mi primer mazo'),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }

              return RefreshIndicator(
                color: AppColors.gold,
                onRefresh: () async {
                  context.read<DecksBloc>().add(const DecksRequested());
                },
                child: ListView.builder(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                  itemCount: state.decks.length,
                  itemBuilder: (context, index) {
                    final deck = state.decks[index];
                    return _DeckCardItem(
                      deck: deck,
                      onTap: () {
                        context.push('/decks/${deck.deckId}');
                      },
                    );
                  },
                ),
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.gold,
        foregroundColor: AppColors.navy,
        tooltip: 'Crear mazo',
        onPressed: () => _showCreateDeckDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _DeckCardItem extends StatelessWidget {
  final DeckEntity deck;
  final VoidCallback onTap;

  const _DeckCardItem({
    required this.deck,
    required this.onTap,
  });

  static final _titleStyle = GoogleFonts.sourceSans3(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.ink,
  );

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: AppColors.parchment,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: AppColors.line.withValues(alpha: 0.6),
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.navy,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.style,
                  color: AppColors.gold,
                  size: 24,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      deck.name,
                      style: _titleStyle,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Toca para ver o editar cartas',
                      style: GoogleFonts.sourceSans3(
                        fontSize: 13,
                        color: AppColors.muted,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right,
                color: AppColors.muted,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
