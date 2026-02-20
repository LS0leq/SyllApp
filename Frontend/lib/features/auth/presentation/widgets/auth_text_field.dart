import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';


class AuthTextField extends StatelessWidget {
  const AuthTextField({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.label,
    required this.hint,
    required this.icon,
    this.keyboardType = TextInputType.text,
    this.obscure = false,
    this.suffixIcon,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final String label;
  final String hint;
  final IconData icon;
  final TextInputType keyboardType;
  final bool obscure;
  final Widget? suffixIcon;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: focusNode,
      builder: (context, child) {
        final hasFocus = focusNode.hasFocus;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                color: hasFocus
                    ? AppTheme.accentLight
                    : AppTheme.appleSystemGray,
                fontSize: 13,
                fontWeight: FontWeight.w600,
                fontFamily: 'SF Pro Text',
                letterSpacing: 0.3,
              ),
            ),
            const SizedBox(height: 8),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOut,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                color: hasFocus
                    ? Colors.white.withValues(alpha: 0.08)
                    : Colors.white.withValues(alpha: 0.04),
                border: Border.all(
                  color: hasFocus
                      ? AppTheme.accent.withValues(alpha: 0.6)
                      : Colors.white.withValues(alpha: 0.08),
                  width: hasFocus ? 1.5 : 1,
                ),
                boxShadow: hasFocus
                    ? [
                        BoxShadow(
                          color: AppTheme.accent.withValues(alpha: 0.15),
                          blurRadius: 12,
                          spreadRadius: 0,
                        ),
                      ]
                    : [],
              ),
              child: TextField(
                controller: controller,
                focusNode: focusNode,
                keyboardType: keyboardType,
                obscureText: obscure,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontFamily: 'SF Pro Text',
                  letterSpacing: -0.2,
                ),
                decoration: InputDecoration(
                  hintText: hint,
                  hintStyle: TextStyle(
                    color: AppTheme.appleSystemGray.withValues(alpha: 0.4),
                    fontSize: 15,
                    fontFamily: 'SF Pro Text',
                  ),
                  prefixIcon: Padding(
                    padding: const EdgeInsets.only(left: 14, right: 10),
                    child: Icon(
                      icon,
                      size: 20,
                      color: hasFocus
                          ? AppTheme.accentLight
                          : AppTheme.appleSystemGray,
                    ),
                  ),
                  prefixIconConstraints: const BoxConstraints(
                    minWidth: 44,
                    minHeight: 44,
                  ),
                  suffixIcon: suffixIcon,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
