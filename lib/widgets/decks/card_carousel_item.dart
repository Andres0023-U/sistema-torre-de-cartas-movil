import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:torre_de_cartas_movil/widgets/theme/app_colors.dart';
import 'package:torre_de_cartas_movil/models/decks/card_entity.dart';

/// Estilo visual asociado a una rareza de carta.
class RarityStyle {
  final Color color;
  final double borderWidth;
  final double glowBlur;
  final double glowOpacity;

  const RarityStyle({
    required this.color,
    required this.borderWidth,
    required this.glowBlur,
    required this.glowOpacity,
  });

  /// Común: verde. Poco común: azul. Rara: morado. Legendaria: amarillo.
  /// Si llega otra rareza, se usa un estilo neutro.
  static RarityStyle of(String? rarity) {
    final key = (rarity ?? '')
        .toLowerCase()
        .replaceAll('í', 'i')
        .replaceAll('ú', 'u')
        .replaceAll('á', 'a')
        .replaceAll('é', 'e')
        .replaceAll('ó', 'o')
        .trim();

    switch (key) {
      case 'comun':
        return const RarityStyle(
          color: Color(0xFF2E9E5B),
          borderWidth: 2.0,
          glowBlur: 6,
          glowOpacity: 0.25,
        );
      case 'poco comun':
        return const RarityStyle(
          color: Color(0xFF2F7FD1),
          borderWidth: 2.5,
          glowBlur: 10,
          glowOpacity: 0.4,
        );
      case 'rara':
        return const RarityStyle(
          color: Color(0xFF8E44C9),
          borderWidth: 3.0,
          glowBlur: 16,
          glowOpacity: 0.55,
        );
      case 'legendaria':
        return const RarityStyle(
          color: Color(0xFFF2B705),
          borderWidth: 3.5,
          glowBlur: 24,
          glowOpacity: 0.75,
        );
      default:
        return const RarityStyle(
          color: AppColors.line,
          borderWidth: 1.5,
          glowBlur: 4,
          glowOpacity: 0.2,
        );
    }
  }
}

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
    final style = RarityStyle.of(card?.rarity);

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
                _buildImage(imageWidth, imageHeight, value, style),
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
                const SizedBox(height: 4),
                _buildTypeAndRarity(style),
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
                _buildControls(style),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTypeAndRarity(RarityStyle style) {
    final rarity = card?.rarity ?? '';
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          card?.type ?? '',
          style: GoogleFonts.sourceSans3(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.muted,
          ),
        ),
        if (rarity.isNotEmpty) ...[
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
            decoration: BoxDecoration(
              color: style.color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: style.color, width: 1.2),
            ),
            child: Text(
              rarity.toUpperCase(),
              style: GoogleFonts.sourceSans3(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: style.color,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildImage(
    double width,
    double height,
    int value,
    RarityStyle style,
  ) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.navy,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: style.color, width: style.borderWidth),
        boxShadow: [
          BoxShadow(
            color: style.color.withValues(alpha: style.glowOpacity),
            blurRadius: style.glowBlur,
            spreadRadius: 1,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14 - style.borderWidth),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(
              'assets/images/cards/$cardId.webp',
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Center(
                child: Icon(Icons.style, color: style.color, size: 48),
              ),
            ),
            Positioned(
              top: 8,
              left: 8,
              child: _Badge(text: '$value', color: style.color),
            ),
            if (quantity > 0)
              Positioned(
                top: 8,
                right: 8,
                child: _Badge(text: 'x$quantity', color: style.color),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildControls(RarityStyle style) {
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
          color: style.color,
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
  final Color color;

  const _Badge({required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.navy.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color, width: 1.5),
      ),
      child: Text(
        text,
        style: GoogleFonts.sourceSans3(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }
}
