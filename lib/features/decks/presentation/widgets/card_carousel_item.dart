import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/card_entity.dart';

/// Carta grande (ilustración + datos + controles de cantidad) pensada para
/// mostrarse como página de un carrusel horizontal.
class CardCarouselItem extends StatelessWidget {
  final int cardId;
  final CardEntity? card;

  /// Copias de esta carta que ya están en el mazo.
  final int quantity;

  /// Máximo de copias permitidas de esta carta.
  final int maxQuantity;

  /// Si el mazo todavía admite más cartas (límite global).
  final bool deckHasRoom;
  final bool isUpdating;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;

  const CardCarouselItem({
    super.key,
    required this.cardId,
    required this.card,
    required this.quantity,
    required this.maxQuantity,
    required this.deckHasRoom,
    required this.isUpdating,
    required this.onIncrement,
    required this.onDecrement,
  });

  static const double _aspect = 765 / 1024;

  bool get _canIncrement => quantity < maxQuantity && deckHasRoom;

  String get _incrementTooltip {
    if (quantity >= maxQuantity) return 'Máximo de copias alcanzado';
    if (!deckHasRoom) return 'El mazo ya tiene 20 cartas';
    return 'Agregar al mazo';
  }

  @override
  Widget build(BuildContext context) {
    final name = card?.name ?? 'Carta #$cardId';
    final value = card?.value ?? 0;
    final effect = card?.effect;
    final hasEffect = effect != null &&
        effect.trim().isNotEmpty &&
        effect.trim().toLowerCase() != 'ninguno';
    final description = card?.description ?? '';

    return LayoutBuilder(
      builder: (context, constraints) {
        var imageHeight = (constraints.maxHeight * 0.58).clamp(180.0, 420.0);
        var imageWidth = imageHeight * _aspect;
        final maxWidth = constraints.maxWidth - 8;
        if (imageWidth > maxWidth) {
          imageWidth = maxWidth;
          imageHeight = imageWidth / _aspect;
        }

        return SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildImage(imageWidth, imageHeight, value),
                const SizedBox(height: 10),
                Text(
                  name,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.sourceSans3(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.ink,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${card?.type ?? ''} · ${(card?.rarity ?? '').toUpperCase()}',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.sourceSans3(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.goldDark,
                  ),
                ),
                if (description.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    description,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.sourceSans3(
                      fontSize: 13,
                      color: AppColors.ink,
                    ),
                  ),
                ],
                if (hasEffect) ...[
                  const SizedBox(height: 2),
                  Text(
                    effect.trim(),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.sourceSans3(
                      fontSize: 12,
                      fontStyle: FontStyle.italic,
                      color: AppColors.muted,
                    ),
                  ),
                ],
                const SizedBox(height: 6),
                _buildControls(),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildImage(double width, double height, int value) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.navy,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: quantity > 0 ? AppColors.gold : AppColors.line,
          width: quantity > 0 ? 2.0 : 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(
              'assets/images/cards/$cardId.webp',
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => const Center(
                child: Icon(Icons.style, color: AppColors.gold, size: 48),
              ),
            ),
            Positioned(
              top: 8,
              left: 8,
              child: _Badge(text: '$value'),
            ),
            if (quantity > 0)
              Positioned(
                top: 8,
                right: 8,
                child: _Badge(text: 'x$quantity'),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildControls() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          icon: const Icon(Icons.remove_circle, size: 34),
          color: AppColors.error,
          disabledColor: Colors.grey.shade300,
          tooltip: quantity <= 1 ? 'Quitar del mazo' : 'Reducir',
          onPressed: quantity > 0 && !isUpdating ? onDecrement : null,
        ),
        SizedBox(
          width: 90,
          child: Text(
            'En mazo: $quantity/$maxQuantity',
            textAlign: TextAlign.center,
            style: GoogleFonts.sourceSans3(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: quantity > 0 ? AppColors.navy : AppColors.muted,
            ),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.add_circle, size: 34),
          color: AppColors.goldDark,
          disabledColor: Colors.grey.shade300,
          tooltip: _incrementTooltip,
          onPressed: _canIncrement && !isUpdating ? onIncrement : null,
        ),
      ],
    );
  }
}

class _Badge extends StatelessWidget {
  final String text;

  const _Badge({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.navy.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.gold, width: 1),
      ),
      child: Text(
        text,
        style: GoogleFonts.sourceSans3(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: AppColors.gold,
        ),
      ),
    );
  }
}

