import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/theme/app_colors.dart';
import '../bloc/deck_detail_bloc.dart';
import '../bloc/deck_detail_event.dart';
import '../bloc/deck_detail_state.dart';
import '../widgets/card_carousel_item.dart';

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
  final PageController _deckController = PageController(viewportFraction: 0.8);
  final PageController _catalogController =
      PageController(viewportFraction: 0.8);

  int _deckPage = 0;
  int _catalogPage = 0;
  String _catalogQuery = '';

  int? get _parsedId => int.tryParse(widget.deckId);

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _deckController.dispose();
    _catalogController.dispose();
    super.dispose();
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
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
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
                        Tab(text: 'En el mazo (${state.deckCards.length})'),
                        Tab(text: 'Catálogo (${state.catalog.length})'),
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
    const max = DeckDetailLoaded.maxDeckCards;
    final isValid = state.isValidForTournament;

    return Container(
      padding: const EdgeInsets.all(12),
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
            children: [
              const Icon(Icons.layers, size: 16, color: AppColors.muted),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  'Cartas: $total / $max',
                  style: GoogleFonts.sourceSans3(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: isValid ? AppColors.navy : AppColors.ink,
                  ),
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
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
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: (total / max).clamp(0.0, 1.0),
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

  Widget _buildPageIndicator(int current, int total) {
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Text(
        total == 0 ? '' : '${current + 1} / $total · desliza para ver más',
        style: GoogleFonts.sourceSans3(fontSize: 12, color: AppColors.muted),
      ),
    );
  }

  Widget _buildDeckCardsTab(DeckDetailLoaded state) {
    final items = state.deckCards;

    if (items.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.style_outlined,
                  size: 56, color: AppColors.muted),
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
        ),
      );
    }

    final shownPage = _deckPage.clamp(0, items.length - 1);

    return Column(
      children: [
        _buildPageIndicator(shownPage, items.length),
        Expanded(
          child: PageView.builder(
            controller: _deckController,
            itemCount: items.length,
            onPageChanged: (page) => setState(() => _deckPage = page),
            itemBuilder: (context, index) {
              final dc = items[index];
              final card = state.catalogMap[dc.cardId];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
                child: CardCarouselItem(
                  cardId: dc.cardId,
                  card: card,
                  quantity: dc.quantity,
                  maxQuantity: card?.copiesAvailable ?? 3,
                  deckHasRoom: !state.isFull,
                  isUpdating: state.isUpdating,
                  onIncrement: () => _changeQuantity(dc.cardId, dc.quantity + 1),
                  onDecrement: () => _changeQuantity(dc.cardId, dc.quantity - 1),
                ),
              );
            },
          ),
        ),
      ],
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

    final shownPage =
        filtered.isEmpty ? 0 : _catalogPage.clamp(0, filtered.length - 1);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
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
                _catalogPage = 0;
              });
              if (_catalogController.hasClients) {
                _catalogController.jumpToPage(0);
              }
            },
          ),
        ),
        _buildPageIndicator(shownPage, filtered.length),
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
              : PageView.builder(
                  controller: _catalogController,
                  itemCount: filtered.length,
                  onPageChanged: (page) => setState(() => _catalogPage = page),
                  itemBuilder: (context, index) {
                    final card = filtered[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 8,
                      ),
                      child: CardCarouselItem(
                        cardId: card.id,
                        card: card,
                        quantity: state.getQuantityFor(card.id),
                        maxQuantity: card.copiesAvailable,
                        deckHasRoom: !state.isFull,
                        isUpdating: state.isUpdating,
                        onIncrement: () => _addOne(state, card.id),
                        onDecrement: () => _changeQuantity(
                          card.id,
                          state.getQuantityFor(card.id) - 1,
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  void _addOne(DeckDetailLoaded state, int cardId) {
    final bloc = context.read<DeckDetailBloc>();
    final current = state.getQuantityFor(cardId);
    if (current == 0) {
      bloc.add(DeckAddCardRequested(cardId: cardId, quantity: 1));
    } else {
      bloc.add(DeckUpdateCardQuantityRequested(
        cardId: cardId,
        quantity: current + 1,
      ));
    }
  }

  void _changeQuantity(int cardId, int quantity) {
    context.read<DeckDetailBloc>().add(
          DeckUpdateCardQuantityRequested(
            cardId: cardId,
            quantity: quantity,
          ),
        );
  }
}
