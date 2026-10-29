import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_colors.dart';
import '../bloc/deck_detail_bloc.dart';
import '../bloc/deck_detail_event.dart';
import '../bloc/deck_detail_state.dart';

class AddCardSheet extends StatefulWidget {
  const AddCardSheet({super.key});

  static Future<void> show(BuildContext context) {
    final bloc = context.read<DeckDetailBloc>();
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.parchment,
      clipBehavior: Clip.antiAlias,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => BlocProvider<DeckDetailBloc>.value(
        value: bloc,
        child: const AddCardSheet(),
      ),
    );
  }

  @override
  State<AddCardSheet> createState() => _AddCardSheetState();
}

class _AddCardSheetState extends State<AddCardSheet> {
  String _query = '';

  static final _titleStyle = GoogleFonts.sourceSans3(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.ink,
  );

  static final _metaStyle = GoogleFonts.sourceSans3(
    fontSize: 13,
    color: AppColors.muted,
  );

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height * 0.85;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: SizedBox(
        height: height,
        child: Scaffold(
          backgroundColor: AppColors.parchment,
          body: SafeArea(
            child: BlocBuilder<DeckDetailBloc, DeckDetailState>(
              builder: (context, state) {
                if (state is! DeckDetailLoaded) {
                  return const SizedBox.shrink();
                }

                final filtered = state.catalog.where((card) {
                  if (_query.isEmpty) return true;
                  final q = _query.toLowerCase();
                  return card.name.toLowerCase().contains(q) ||
                      card.type.toLowerCase().contains(q) ||
                      card.rarity.toLowerCase().contains(q);
                }).toList();

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Catálogo de Cartas',
                              style: GoogleFonts.sourceSans3(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: AppColors.ink,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () => Navigator.of(context).pop(),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: TextField(
                        decoration: const InputDecoration(
                          hintText: 'Buscar por nombre, tipo o rareza',
                          prefixIcon: Icon(Icons.search),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(12)),
                          ),
                          contentPadding: EdgeInsets.symmetric(
                            vertical: 0,
                            horizontal: 16,
                          ),
                        ),
                        onChanged: (val) {
                          setState(() {
                            _query = val.trim();
                          });
                        },
                      ),
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: filtered.isEmpty
                          ? Center(
                              child: Text(
                                'No se encontraron cartas',
                                style: GoogleFonts.sourceSans3(
                                  fontSize: 16,
                                  color: AppColors.muted,
                                ),
                              ),
                            )
                          : ListView.builder(
                              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                              itemCount: filtered.length,
                              itemBuilder: (context, index) {
                                final card = filtered[index];
                                final currentQty =
                                    state.getQuantityFor(card.id);
                                final maxQty = card.copiesAvailable;
                                final canAddMore = currentQty < maxQty;

                                return Card(
                                  margin: const EdgeInsets.only(bottom: 10),
                                  color: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    side: BorderSide(
                                      color:
                                          AppColors.line.withValues(alpha: 0.6),
                                    ),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(12),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          width: 44,
                                          height: 44,
                                          decoration: BoxDecoration(
                                            color: AppColors.navy,
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                          child: Center(
                                            child: Text(
                                              '${card.value}',
                                              style: GoogleFonts.sourceSans3(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                                color: AppColors.gold,
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: [
                                                  Expanded(
                                                    child: Text(
                                                      card.name,
                                                      style: _titleStyle,
                                                    ),
                                                  ),
                                                  Container(
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                      horizontal: 8,
                                                      vertical: 2,
                                                    ),
                                                    decoration: BoxDecoration(
                                                      color: AppColors
                                                          .goldSoft
                                                          .withValues(
                                                              alpha: 0.6),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              8),
                                                    ),
                                                    child: Text(
                                                      card.rarity.toUpperCase(),
                                                      style: GoogleFonts
                                                          .sourceSans3(
                                                        fontSize: 11,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color:
                                                            AppColors.goldDark,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 2),
                                              Text(
                                                'Tipo: ${card.type} · En mazo: $currentQty/$maxQty',
                                                style: _metaStyle,
                                              ),
                                              if (card.effect != null &&
                                                  card.effect!.isNotEmpty) ...[
                                                const SizedBox(height: 4),
                                                Text(
                                                  card.effect!,
                                                  style: GoogleFonts.sourceSans3(
                                                    fontSize: 12,
                                                    fontStyle: FontStyle.italic,
                                                    color: AppColors.ink,
                                                  ),
                                                ),
                                              ],
                                            ],
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        IconButton(
                                          icon: Icon(
                                            Icons.add_circle,
                                            color: canAddMore
                                                ? AppColors.goldDark
                                                : Colors.grey.shade300,
                                            size: 32,
                                          ),
                                          tooltip: canAddMore
                                              ? 'Agregar'
                                              : 'Máximo alcanzado',
                                          onPressed: canAddMore &&
                                                  !state.isUpdating
                                              ? () {
                                                  if (currentQty == 0) {
                                                    context
                                                        .read<DeckDetailBloc>()
                                                        .add(
                                                          DeckAddCardRequested(
                                                            cardId: card.id,
                                                            quantity: 1,
                                                          ),
                                                        );
                                                  } else {
                                                    context
                                                        .read<DeckDetailBloc>()
                                                        .add(
                                                          DeckUpdateCardQuantityRequested(
                                                            cardId: card.id,
                                                            quantity:
                                                                currentQty + 1,
                                                          ),
                                                        );
                                                  }
                                                }
                                              : null,
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

