import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';

class LoginBrand extends StatelessWidget {
  const LoginBrand({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Semantics(
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
        ),
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
