import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';


class AuthHeader extends StatelessWidget {
  const AuthHeader({
    super.key,
    required this.logoSlide,
    required this.logoFade,
    required this.titleSlide,
    required this.titleFade,
    required this.title,
    required this.subtitle,
  });

  final Animation<Offset> logoSlide;
  final Animation<double> logoFade;
  final Animation<Offset> titleSlide;
  final Animation<double> titleFade;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildLogo(),
        const SizedBox(height: 12),
        _buildTitle(),
      ],
    );
  }

  Widget _buildLogo() {
    return SlideTransition(
      position: logoSlide,
      child: FadeTransition(
        opacity: logoFade,
        child: Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppTheme.accent,
                AppTheme.accent.withValues(alpha: 0.6),
                const Color(0xFF6C63FF),
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: AppTheme.accent.withValues(alpha: 0.4),
                blurRadius: 30,
                spreadRadius: 2,
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: Image.asset(
              'assets/logo.png',
              width: 80,
              height: 80,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => const Icon(
                Icons.music_note_rounded,
                size: 40,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTitle() {
    return SlideTransition(
      position: titleSlide,
      child: FadeTransition(
        opacity: titleFade,
        child: Column(
          children: [
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.w700,
                fontFamily: 'SF Pro Display',
                letterSpacing: -0.8,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: TextStyle(
                color: AppTheme.appleSystemGray.withValues(alpha: 0.8),
                fontSize: 16,
                fontWeight: FontWeight.w400,
                fontFamily: 'SF Pro Text',
                letterSpacing: -0.3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
