import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/card_entity.dart';
import '../../domain/entities/deck_card_entity.dart';
import '../bloc/deck_detail_bloc.dart';
import '../bloc/deck_detail_event.dart';
import '../bloc/deck_detail_state.dart';

class DeckDetailPage extends StatelessWidget {
  final String deckId;

  const DeckDetailPage({
    super.key,
    required this.deckId,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider<DeckDetailBloc>(
      create: (_) => sl<DeckDetailBloc>(),
      child: _DeckDetailView(deckId: deckId),
    );
  }
}

class _DeckDetailView extends StatefulWidget {
  final String deckId;

  const _DeckDetailView({required this.deckId});

  @override
  State<_DeckDetailView> createState() => _DeckDetailViewState();
}

class _DeckDetailViewState extends State<_DeckDetailView> {
  int? get _parsedId => int.tryParse(widget.deckId);
  String _catalogQuery = '';

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    final id = _parsedId;
    if (id != null) {
      context.read<DeckDetailBloc>().add(DeckDetailRequested(id));
    }
  }

  @override
  Widget build(BuildContext context) {
    final id = _parsedId;
    if (id == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Mazo')),
        body: const Center(child: Text('Identificador de mazo inválido')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: BlocBuilder<DeckDetailBloc, DeckDetailState>(
          builder: (context, state) {
            if (state is DeckDetailLoaded) {
              return Text(state.deck.name);
            }
            return const Text('Detalle del Mazo');
          },
        ),
      ),
      body: SafeArea(
        child: BlocConsumer<DeckDetailBloc, DeckDetailState>(
          listenWhen: (previous, current) =>
              current is DeckDetailLoaded &&
              (current.successMessage != null || current.errorMessage != null),
          listener: (context, state) {
            if (state is! DeckDetailLoaded) return;
            final isError = state.errorMessage != null;
            final msg = state.errorMessage ?? state.successMessage!;
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                SnackBar(
                  content: Text(msg),
                  backgroundColor:
                      isError ? AppColors.error : AppColors.navy,
                ),
              );
          },
          builder: (context, state) {
            if (state is DeckDetailInitial || state is DeckDetailLoading) {
              return const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.gold),
                ),
              );
            }

            if (state is DeckDetailFailure) {
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
                        onPressed: _load,
                        child: const Text('Reintentar'),
                      ),
                    ],
                  ),
                ),
              );
            }

            if (state is DeckDetailLoaded) {
              return DefaultTabController(
                length: 2,
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                      child: _buildHeader(state),
                    ),
                    TabBar(
                      indicatorColor: AppColors.gold,
                      labelColor: AppColors.navy,
                      unselectedLabelColor: AppColors.muted,
                      labelStyle: GoogleFonts.sourceSans3(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                      tabs: [
                        Tab(
                          text: 'En el mazo (${state.deckCards.length})',
                        ),
                        Tab(
                          text: 'Catálogo (${state.catalog.length})',
                        ),
                      ],
                    ),
                    Expanded(
                      child: TabBarView(
                        children: [
                          _buildDeckCardsTab(state),
                          _buildCatalogTab(state),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget _buildHeader(DeckDetailLoaded state) {
    final total = state.totalCards;
    final isValid = state.isValidForTournament;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.parchment,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isValid
              ? AppColors.gold
              : AppColors.line.withValues(alpha: 0.8),
          width: isValid ? 1.5 : 1.0,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  state.deck.name,
                  style: GoogleFonts.sourceSans3(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.ink,
                  ),
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: isValid ? AppColors.gold : Colors.grey.shade400,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  isValid ? 'Válido para torneo' : 'Incompleto',
                  style: GoogleFonts.sourceSans3(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isValid ? AppColors.navy : Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(Icons.layers, size: 16, color: AppColors.muted),
              const SizedBox(width: 6),
              Text(
                'Total: $total de 20 cartas mínimas',
                style: GoogleFonts.sourceSans3(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isValid ? AppColors.navy : AppColors.muted,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: (total / 20.0).clamp(0.0, 1.0),
              backgroundColor: AppColors.line.withValues(alpha: 0.5),
              valueColor: AlwaysStoppedAnimation<Color>(
                isValid ? AppColors.gold : Colors.amber.shade700,
              ),
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeckCardsTab(DeckDetailLoaded state) {
    if (state.deckCards.isEmpty) {
      return RefreshIndicator(
        color: AppColors.gold,
        onRefresh: () async => _load(),
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(24),
          children: [
            const SizedBox(height: 40),
            const Icon(Icons.style_outlined, size: 56, color: AppColors.muted),
            const SizedBox(height: 12),
            Text(
              'Este mazo no tiene cartas aún',
              textAlign: TextAlign.center,
              style: GoogleFonts.sourceSans3(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.ink,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Pasa a la pestaña "Catálogo" para agregar cartas.',
              textAlign: TextAlign.center,
              style: GoogleFonts.sourceSans3(
                fontSize: 13,
                color: AppColors.muted,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      color: AppColors.gold,
      onRefresh: () async => _load(),
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        itemCount: state.deckCards.length,
        itemBuilder: (context, index) {
          final dc = state.deckCards[index];
          return _buildDeckCardRow(context, state, dc);
        },
      ),
    );
  }

  Widget _buildDeckCardRow(
    BuildContext context,
    DeckDetailLoaded state,
    DeckCardEntity dc,
  ) {
    final card = state.catalogMap[dc.cardId];
    final cardName = card?.name ?? 'Carta #${dc.cardId}';
    final cardType = card?.type ?? '';
    final cardValue = card?.value ?? 0;
    final maxQty = card?.copiesAvailable ?? 3;
    final canIncrement = dc.quantity < maxQty;

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: AppColors.line.withValues(alpha: 0.6),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.navy,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  '$cardValue',
                  style: GoogleFonts.sourceSans3(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.gold,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    cardName,
                    style: GoogleFonts.sourceSans3(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.ink,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Tipo: $cardType · Máx: $maxQty',
                    style: GoogleFonts.sourceSans3(
                      fontSize: 12,
                      color: AppColors.muted,
                    ),
                  ),
                ],
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.remove_circle_outline, size: 22),
                  color: AppColors.error,
                  tooltip: dc.quantity == 1 ? 'Eliminar' : 'Reducir',
                  onPressed: state.isUpdating
                      ? null
                      : () {
                          context.read<DeckDetailBloc>().add(
                                DeckUpdateCardQuantityRequested(
                                  cardId: dc.cardId,
                                  quantity: dc.quantity - 1,
                                ),
                              );
                        },
                ),
                Text(
                  '${dc.quantity}',
                  style: GoogleFonts.sourceSans3(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.ink,
                  ),
                ),
                IconButton(
                  icon: Icon(
                    Icons.add_circle_outline,
                    size: 22,
                    color: canIncrement
                        ? AppColors.navy
                        : Colors.grey.shade300,
                  ),
                  tooltip: canIncrement ? 'Aumentar' : 'Máximo alcanzado',
                  onPressed: canIncrement && !state.isUpdating
                      ? () {
                          context.read<DeckDetailBloc>().add(
                                DeckUpdateCardQuantityRequested(
                                  cardId: dc.cardId,
                                  quantity: dc.quantity + 1,
                                ),
                              );
                        }
                      : null,
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline,
                      size: 20, color: AppColors.muted),
                  tooltip: 'Quitar del mazo',
                  onPressed: state.isUpdating
                      ? null
                      : () {
                          context.read<DeckDetailBloc>().add(
                                DeckRemoveCardRequested(dc.cardId),
                              );
                        },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCatalogTab(DeckDetailLoaded state) {
    final filtered = state.catalog.where((card) {
      if (_catalogQuery.isEmpty) return true;
      final q = _catalogQuery.toLowerCase();
      return card.name.toLowerCase().contains(q) ||
          card.type.toLowerCase().contains(q) ||
          card.rarity.toLowerCase().contains(q);
    }).toList();

    return RefreshIndicator(
      color: AppColors.gold,
      onRefresh: () async => _load(),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
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
                  _catalogQuery = val.trim();
                });
              },
            ),
          ),
          Expanded(
            child: filtered.isEmpty
                ? Center(
                    child: Text(
                      'No se encontraron cartas en el catálogo',
                      style: GoogleFonts.sourceSans3(
                        fontSize: 15,
                        color: AppColors.muted,
                      ),
                    ),
                  )
                : ListView.builder(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final card = filtered[index];
                      return _buildCatalogCardItem(context, state, card);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildCatalogCardItem(
    BuildContext context,
    DeckDetailLoaded state,
    CardEntity card,
  ) {
    final currentQty = state.getQuantityFor(card.id);
    final maxQty = card.copiesAvailable;
    final canAddMore = currentQty < maxQty;

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: currentQty > 0
              ? AppColors.gold
              : AppColors.line.withValues(alpha: 0.6),
          width: currentQty > 0 ? 1.4 : 1.0,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.navy,
                borderRadius: BorderRadius.circular(8),
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          card.name,
                          style: GoogleFonts.sourceSans3(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.ink,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.goldSoft.withValues(alpha: 0.6),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          card.rarity.toUpperCase(),
                          style: GoogleFonts.sourceSans3(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: AppColors.goldDark,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Tipo: ${card.type} · En mazo: $currentQty/$maxQty',
                    style: GoogleFonts.sourceSans3(
                      fontSize: 12,
                      color: currentQty > 0 ? AppColors.navy : AppColors.muted,
                      fontWeight:
                          currentQty > 0 ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                  if (card.effect != null && card.effect!.isNotEmpty) ...[
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
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (currentQty > 0)
                  IconButton(
                    icon: const Icon(Icons.remove_circle_outline, size: 22),
                    color: AppColors.error,
                    tooltip: 'Reducir',
                    onPressed: state.isUpdating
                        ? null
                        : () {
                            context.read<DeckDetailBloc>().add(
                                  DeckUpdateCardQuantityRequested(
                                    cardId: card.id,
                                    quantity: currentQty - 1,
                                  ),
                                );
                          },
                  ),
                IconButton(
                  icon: Icon(
                    Icons.add_circle,
                    color: canAddMore ? AppColors.goldDark : Colors.grey.shade300,
                    size: 30,
                  ),
                  tooltip: canAddMore ? 'Agregar al mazo' : 'Máximo alcanzado',
                  onPressed: canAddMore && !state.isUpdating
                      ? () {
                          if (currentQty == 0) {
                            context.read<DeckDetailBloc>().add(
                                  DeckAddCardRequested(
                                    cardId: card.id,
                                    quantity: 1,
                                  ),
                                );
                          } else {
                            context.read<DeckDetailBloc>().add(
                                  DeckUpdateCardQuantityRequested(
                                    cardId: card.id,
                                    quantity: currentQty + 1,
                                  ),
                                );
                          }
                        }
                      : null,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
