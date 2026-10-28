import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class CrestBadge extends StatelessWidget {
  const CrestBadge({super.key});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Escudo de Torre de Cartas',
      image: true,
      child: Container(
        width: 128,
        height: 128,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.parchment,
          border: Border.all(
            color: AppColors.gold,
            width: 2.0,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.gold.withValues(alpha: 0.30),
              blurRadius: 32,
              spreadRadius: 1,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        alignment: Alignment.center,
        child: Image.asset(
          'assets/images/crest.png',
          width: 84,
          height: 84,
          fit: BoxFit.contain,
          filterQuality: FilterQuality.high,
          errorBuilder: (context, error, stackTrace) {
            return const Icon(
              Icons.shield,
              size: 72,
              color: AppColors.gold,
            );
          },
        ),
      ),
    );
  }
}
