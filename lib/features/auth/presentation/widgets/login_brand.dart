import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import 'crest_badge.dart';

class LoginBrand extends StatelessWidget {
  const LoginBrand({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const CrestBadge(),
        const SizedBox(height: 20),
        Text(
          'TORRE',
          style: GoogleFonts.cinzel(
            fontSize: 40,
            fontWeight: FontWeight.bold,
            letterSpacing: 5.6,
            color: AppColors.goldSoft,
          ),
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 48,
              height: 1,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.transparent, AppColors.gold],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: Text(
                'de Cartas',
                style: GoogleFonts.cinzel(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 4.8,
                  color: AppColors.gold,
                ),
              ),
            ),
            Container(
              width: 48,
              height: 1,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.gold, Colors.transparent],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'Tus torneos, mazos y partidas',
          style: GoogleFonts.sourceSans3(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: AppColors.muted.withValues(alpha: 0.9),
          ),
        ),
      ],
    );
  }
}
