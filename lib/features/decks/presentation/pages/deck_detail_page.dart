import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:torre_de_cartas_movil/core/di/injection_container.dart';
import 'package:torre_de_cartas_movil/core/theme/app_colors.dart';
import 'package:torre_de_cartas_movil/models/decks/card_entity.dart';
import 'package:torre_de_cartas_movil/features/decks/presentation/bloc/deck_detail_bloc.dart';
import 'package:torre_de_cartas_movil/features/decks/presentation/bloc/deck_detail_event.dart';
import 'package:torre_de_cartas_movil/features/decks/presentation/bloc/deck_detail_state.dart';
import 'package:torre_de_cartas_movil/features/decks/presentation/widgets/card_carousel_item.dart';

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
  static const int _kVirtualPageCount = 1000;
  static const int _kCenterPage = 500;
  static const double _kViewportFraction = 0.68;

  static const List<String> _typeFilters = <String>[
    'Todos',
    'Ataque',
    'Defensa',
    'Especial',
  ];

  late final PageController _deckController = PageController(
    viewportFraction: _kViewportFraction,
    initialPage: _kCenterPage,
  );
  late final PageController _catalogController = PageController(
    viewportFraction: _kViewportFraction,
    initialPage: _kCenterPage,
  );

  int _deckRawPage = _kCenterPage;
  int _catalogRawPage = _kCenterPage;
  String _catalogQuery = '';
  String _deckTypeFilter = 'Todos';
  String _catalogTypeFilter = 'Todos';
  bool _isListView = false;

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

  int _realIndex(int rawPage, int length) {
    if (length <= 0) return 0;
    return ((rawPage - _kCenterPage) % length + length) % length;
  }

  bool _matchesType(CardEntity? card, String selectedType) {
    if (selectedType == 'Todos') return true;
    if (card == null) return false;
    return card.type.trim().toLowerCase() == selectedType.toLowerCase();
  }

  IconData _iconForType(String type) {
    switch (type.toLowerCase()) {
      case 'ataque':
        return Icons.flash_on_rounded;
      case 'defensa':
        return Icons.shield_rounded;
      case 'especial':
        return Icons.auto_awesome_rounded;
      default:
        return Icons.apps_rounded;
    }
  }

  void _resetCarousel(PageController controller, {required bool isCatalog}) {
    setState(() {
      if (isCatalog) {
        _catalogRawPage = _kCenterPage;
      } else {
        _deckRawPage = _kCenterPage;
      }
    });
    if (controller.hasClients) {
      controller.jumpToPage(_kCenterPage);
    }
  }

  void _stepCarousel(PageController controller, int currentRawPage, int delta) {
    if (!controller.hasClients) return;
    final target = (currentRawPage + delta).clamp(0, _kVirtualPageCount - 1);
    controller.animateToPage(
      target,
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOutCubic,
    );
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

  Widget _buildTypeFilterRow({
    required String selectedType,
    required ValueChanged<String> onSelected,
  }) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 2),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: _typeFilters.map((type) {
            final isSelected = selectedType == type;
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: ChoiceChip(
                avatar: Icon(
                  _iconForType(type),
                  size: 16,
                  color: isSelected ? AppColors.gold : AppColors.muted,
                ),
                label: Text(
                  type,
                  style: GoogleFonts.sourceSans3(
                    fontSize: 13,
                    fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.w600,
                    color: isSelected ? Colors.white : AppColors.ink,
                  ),
                ),
                selected: isSelected,
                selectedColor: AppColors.navy,
                backgroundColor: AppColors.parchment,
                side: BorderSide(
                  color: isSelected ? AppColors.gold : AppColors.line,
                  width: isSelected ? 1.4 : 1.0,
                ),
                showCheckmark: false,
                visualDensity: VisualDensity.compact,
                onSelected: (_) {
                  if (selectedType != type) {
                    onSelected(type);
                  }
                },
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildPageIndicator({
    required int current,
    required int total,
    required VoidCallback? onPrevious,
    required VoidCallback? onNext,
  }) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 2, 16, 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (total == 0)
            const SizedBox.shrink()
          else if (_isListView)
            Text(
              'Mostrando $total ${total == 1 ? 'carta' : 'cartas'}',
              style: GoogleFonts.sourceSans3(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.muted,
              ),
            )
          else
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left_rounded, size: 22),
                  color: AppColors.navy,
                  disabledColor: AppColors.line,
                  visualDensity: VisualDensity.compact,
                  padding: EdgeInsets.zero,
                  constraints:
                      const BoxConstraints(minWidth: 32, minHeight: 28),
                  tooltip: 'Carta anterior',
                  onPressed: total > 1 ? onPrevious : null,
                ),
                const SizedBox(width: 4),
                Text(
                  '${current + 1} / $total',
                  style: GoogleFonts.sourceSans3(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.muted,
                  ),
                ),
                const SizedBox(width: 4),
                IconButton(
                  icon: const Icon(Icons.chevron_right_rounded, size: 22),
                  color: AppColors.navy,
                  disabledColor: AppColors.line,
                  visualDensity: VisualDensity.compact,
                  padding: EdgeInsets.zero,
                  constraints:
                      const BoxConstraints(minWidth: 32, minHeight: 28),
                  tooltip: 'Siguiente carta',
                  onPressed: total > 1 ? onNext : null,
                ),
              ],
            ),
          _buildListToggleButton(),
        ],
      ),
    );
  }

  Widget _buildListToggleButton() {
    return Material(
      color: _isListView ? AppColors.navy : AppColors.parchment,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(
          color: _isListView ? AppColors.gold : AppColors.line,
          width: _isListView ? 1.4 : 1.0,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: () => setState(() => _isListView = !_isListView),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.dehaze_rounded,
                size: 16,
                color: _isListView ? AppColors.gold : AppColors.ink,
              ),
              const SizedBox(width: 6),
              Text(
                'Lista',
                style: GoogleFonts.sourceSans3(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: _isListView ? Colors.white : AppColors.ink,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCardListItem({
    required int cardId,
    required CardEntity? card,
    required int quantity,
    required int maxQuantity,
    required bool deckHasRoom,
    required bool isUpdating,
    required VoidCallback onIncrement,
    required VoidCallback onDecrement,
    VoidCallback? onRemoveAll,
  }) {
    final name = card?.name ?? 'Carta #$cardId';
    final type = card?.type ?? '';
    final value = card?.value ?? 0;
    final rarity = card?.rarity ?? '';
    final description = card?.description ?? '';
    final effect = card?.effect;
    final hasEffect = effect != null &&
        effect.trim().isNotEmpty &&
        effect.trim().toLowerCase() != 'ninguno';
    final style = RarityStyle.of(rarity);
    final canIncrement = quantity < maxQuantity && deckHasRoom;

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      color: Colors.white,
      elevation: 1.5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: quantity > 0
              ? style.color
              : style.color.withValues(alpha: 0.45),
          width: quantity > 0 ? 1.6 : 1.0,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _CardMiniThumbnail(
              cardId: cardId,
              value: value,
              style: style,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.sourceSans3(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: AppColors.ink,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      if (rarity.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 7,
                            vertical: 1,
                          ),
                          decoration: BoxDecoration(
                            color: style.color.withValues(alpha: 0.14),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: style.color, width: 1),
                          ),
                          child: Text(
                            rarity.toUpperCase(),
                            style: GoogleFonts.sourceSans3(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: style.color,
                            ),
                          ),
                        ),
                      Text(
                        'Tipo: $type · Máx: $maxQuantity',
                        style: GoogleFonts.sourceSans3(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.muted,
                        ),
                      ),
                    ],
                  ),
                  if (description.isNotEmpty) ...[
                    const SizedBox(height: 3),
                    Text(
                      description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.sourceSans3(
                        fontSize: 12,
                        color: AppColors.ink,
                      ),
                    ),
                  ],
                  if (hasEffect) ...[
                    const SizedBox(height: 2),
                    Text(
                      'Efecto: ${effect.trim()}',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.sourceSans3(
                        fontSize: 11,
                        fontStyle: FontStyle.italic,
                        color: AppColors.muted,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 6),
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove_circle_outline, size: 22),
                      color: AppColors.error,
                      disabledColor: Colors.grey.shade300,
                      visualDensity: VisualDensity.compact,
                      padding: EdgeInsets.zero,
                      constraints:
                          const BoxConstraints(minWidth: 30, minHeight: 30),
                      tooltip: quantity <= 1 ? 'Quitar del mazo' : 'Reducir',
                      onPressed:
                          quantity > 0 && !isUpdating ? onDecrement : null,
                    ),
                    SizedBox(
                      width: 22,
                      child: Text(
                        '$quantity',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.sourceSans3(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: quantity > 0 ? AppColors.navy : AppColors.muted,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add_circle_outline, size: 22),
                      color: style.color,
                      disabledColor: Colors.grey.shade300,
                      visualDensity: VisualDensity.compact,
                      padding: EdgeInsets.zero,
                      constraints:
                          const BoxConstraints(minWidth: 30, minHeight: 30),
                      tooltip: canIncrement
                          ? 'Agregar al mazo'
                          : (!deckHasRoom
                              ? 'El mazo ya tiene 20 cartas'
                              : 'Máximo alcanzado'),
                      onPressed:
                          canIncrement && !isUpdating ? onIncrement : null,
                    ),
                  ],
                ),
                if (onRemoveAll != null)
                  IconButton(
                    icon: const Icon(
                      Icons.delete_outline,
                      size: 18,
                      color: AppColors.muted,
                    ),
                    visualDensity: VisualDensity.compact,
                    padding: EdgeInsets.zero,
                    constraints:
                        const BoxConstraints(minWidth: 28, minHeight: 24),
                    tooltip: 'Eliminar del mazo',
                    onPressed: !isUpdating ? onRemoveAll : null,
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCircularCarousel({
    required PageController controller,
    required int currentRawPage,
    required int itemCount,
    required ValueChanged<int> onRawPageChanged,
    required Widget Function(int realIndex) itemBuilder,
  }) {
    if (itemCount == 1) {
      return Center(
        child: SizedBox(
          width: 300,
          height: double.infinity,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: itemBuilder(0),
          ),
        ),
      );
    }

    return Center(
      child: SizedBox(
        width: 440,
        height: double.infinity,
        child: Stack(
          fit: StackFit.expand,
          alignment: Alignment.center,
          children: [
            PageView.builder(
              controller: controller,
              itemCount: _kVirtualPageCount,
              onPageChanged: onRawPageChanged,
              itemBuilder: (context, virtualIndex) {
                final realIndex = _realIndex(virtualIndex, itemCount);
                final isCenter = virtualIndex == currentRawPage;

                return AnimatedScale(
                  scale: isCenter ? 1.0 : 0.85,
                  duration: const Duration(milliseconds: 220),
                  curve: Curves.easeOutCubic,
                  child: AnimatedOpacity(
                    opacity: isCenter ? 1.0 : 0.62,
                    duration: const Duration(milliseconds: 220),
                    child: GestureDetector(
                      behavior: HitTestBehavior.translucent,
                      onTap: isCenter
                          ? null
                          : () {
                              if (controller.hasClients) {
                                controller.animateToPage(
                                  virtualIndex,
                                  duration: const Duration(milliseconds: 260),
                                  curve: Curves.easeOutCubic,
                                );
                              }
                            },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 4,
                          vertical: 8,
                        ),
                        child: itemBuilder(realIndex),
                      ),
                    ),
                  ),
                );
              },
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.only(left: 4),
                child: _CarouselNavButton(
                  icon: Icons.chevron_left_rounded,
                  tooltip: 'Anterior',
                  onTap: () => _stepCarousel(controller, currentRawPage, -1),
                ),
              ),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: const EdgeInsets.only(right: 4),
                child: _CarouselNavButton(
                  icon: Icons.chevron_right_rounded,
                  tooltip: 'Siguiente',
                  onTap: () => _stepCarousel(controller, currentRawPage, 1),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDeckCardsTab(DeckDetailLoaded state) {
    final allDeckItems = state.deckCards;

    if (allDeckItems.isEmpty) {
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

    final items = allDeckItems.where((dc) {
      final card = state.catalogMap[dc.cardId];
      return _matchesType(card, _deckTypeFilter);
    }).toList();

    final shownPage =
        items.isEmpty ? 0 : _realIndex(_deckRawPage, items.length);

    return Column(
      children: [
        _buildTypeFilterRow(
          selectedType: _deckTypeFilter,
          onSelected: (type) {
            _deckTypeFilter = type;
            _resetCarousel(_deckController, isCatalog: false);
          },
        ),
        _buildPageIndicator(
          current: shownPage,
          total: items.length,
          onPrevious: () => _stepCarousel(_deckController, _deckRawPage, -1),
          onNext: () => _stepCarousel(_deckController, _deckRawPage, 1),
        ),
        Expanded(
          child: items.isEmpty
              ? Center(
                  child: Text(
                    'No hay cartas de tipo "$_deckTypeFilter" en este mazo',
                    style: GoogleFonts.sourceSans3(
                      fontSize: 15,
                      color: AppColors.muted,
                    ),
                  ),
                )
              : _isListView
                  ? ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 6, 16, 16),
                      itemCount: items.length,
                      itemBuilder: (context, index) {
                        final dc = items[index];
                        final card = state.catalogMap[dc.cardId];
                        return _buildCardListItem(
                          cardId: dc.cardId,
                          card: card,
                          quantity: dc.quantity,
                          maxQuantity: card?.copiesAvailable ?? 3,
                          deckHasRoom: !state.isFull,
                          isUpdating: state.isUpdating,
                          onIncrement: () =>
                              _changeQuantity(dc.cardId, dc.quantity + 1),
                          onDecrement: () =>
                              _changeQuantity(dc.cardId, dc.quantity - 1),
                          onRemoveAll: () => context
                              .read<DeckDetailBloc>()
                              .add(DeckRemoveCardRequested(dc.cardId)),
                        );
                      },
                    )
                  : _buildCircularCarousel(
                      controller: _deckController,
                      currentRawPage: _deckRawPage,
                      itemCount: items.length,
                      onRawPageChanged: (page) =>
                          setState(() => _deckRawPage = page),
                      itemBuilder: (realIndex) {
                        final dc = items[realIndex];
                        final card = state.catalogMap[dc.cardId];
                        return CardCarouselItem(
                          cardId: dc.cardId,
                          card: card,
                          quantity: dc.quantity,
                          maxQuantity: card?.copiesAvailable ?? 3,
                          deckHasRoom: !state.isFull,
                          isUpdating: state.isUpdating,
                          onIncrement: () =>
                              _changeQuantity(dc.cardId, dc.quantity + 1),
                          onDecrement: () =>
                              _changeQuantity(dc.cardId, dc.quantity - 1),
                        );
                      },
                    ),
        ),
      ],
    );
  }

  Widget _buildCatalogTab(DeckDetailLoaded state) {
    final filtered = state.catalog.where((card) {
      if (!_matchesType(card, _catalogTypeFilter)) return false;
      if (_catalogQuery.isEmpty) return true;
      final q = _catalogQuery.toLowerCase();
      return card.name.toLowerCase().contains(q) ||
          card.type.toLowerCase().contains(q) ||
          card.rarity.toLowerCase().contains(q);
    }).toList();

    final shownPage =
        filtered.isEmpty ? 0 : _realIndex(_catalogRawPage, filtered.length);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          child: TextField(
            decoration: const InputDecoration(
              hintText: 'Buscar por nombre, tipo o rareza',
              prefixIcon: Icon(Icons.search),
              isDense: true,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(12)),
              ),
              contentPadding: EdgeInsets.symmetric(
                vertical: 10,
                horizontal: 14,
              ),
            ),
            onChanged: (val) {
              _catalogQuery = val.trim();
              _resetCarousel(_catalogController, isCatalog: true);
            },
          ),
        ),
        _buildTypeFilterRow(
          selectedType: _catalogTypeFilter,
          onSelected: (type) {
            _catalogTypeFilter = type;
            _resetCarousel(_catalogController, isCatalog: true);
          },
        ),
        _buildPageIndicator(
          current: shownPage,
          total: filtered.length,
          onPrevious: () =>
              _stepCarousel(_catalogController, _catalogRawPage, -1),
          onNext: () => _stepCarousel(_catalogController, _catalogRawPage, 1),
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
              : _isListView
                  ? ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 6, 16, 16),
                      itemCount: filtered.length,
                      itemBuilder: (context, index) {
                        final card = filtered[index];
                        final qty = state.getQuantityFor(card.id);
                        return _buildCardListItem(
                          cardId: card.id,
                          card: card,
                          quantity: qty,
                          maxQuantity: card.copiesAvailable,
                          deckHasRoom: !state.isFull,
                          isUpdating: state.isUpdating,
                          onIncrement: () => _addOne(state, card.id),
                          onDecrement: () => _changeQuantity(
                            card.id,
                            qty - 1,
                          ),
                        );
                      },
                    )
                  : _buildCircularCarousel(
                      controller: _catalogController,
                      currentRawPage: _catalogRawPage,
                      itemCount: filtered.length,
                      onRawPageChanged: (page) =>
                          setState(() => _catalogRawPage = page),
                      itemBuilder: (realIndex) {
                        final card = filtered[realIndex];
                        return CardCarouselItem(
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

class _CardMiniThumbnail extends StatelessWidget {
  final int cardId;
  final int value;
  final RarityStyle style;

  const _CardMiniThumbnail({
    required this.cardId,
    required this.value,
    required this.style,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 50,
      height: 68,
      decoration: BoxDecoration(
        color: AppColors.navy,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: style.color, width: 1.6),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(6.4),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(
              'assets/images/cards/$cardId.webp',
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Center(
                child: Text(
                  '$value',
                  style: GoogleFonts.sourceSans3(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: style.color,
                  ),
                ),
              ),
            ),
            Positioned(
              top: 2,
              left: 2,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                decoration: BoxDecoration(
                  color: AppColors.navy.withValues(alpha: 0.88),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: style.color, width: 1),
                ),
                child: Text(
                  '$value',
                  style: GoogleFonts.sourceSans3(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: style.color,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CarouselNavButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  const _CarouselNavButton({
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.navy.withValues(alpha: 0.82),
      shape: const CircleBorder(
        side: BorderSide(color: AppColors.gold, width: 1.2),
      ),
      elevation: 4,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Tooltip(
          message: tooltip,
          child: Padding(
            padding: const EdgeInsets.all(6),
            child: Icon(
              icon,
              size: 26,
              color: AppColors.gold,
            ),
          ),
        ),
      ),
    );
  }
}
