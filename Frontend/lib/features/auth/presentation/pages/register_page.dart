import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/top_toast.dart';
import '../../application/auth_providers.dart';
import '../../application/auth_state.dart';
import '../widgets/animated_auth_background.dart';
import '../widgets/auth_header.dart';
import '../widgets/auth_text_field.dart';
import '../widgets/glassmorphic_card.dart';

class RegisterPage extends ConsumerStatefulWidget {
  const RegisterPage({super.key});

  @override
  ConsumerState<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends ConsumerState<RegisterPage>
    with TickerProviderStateMixin {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  final _usernameFocus = FocusNode();
  final _passwordFocus = FocusNode();
  final _confirmPasswordFocus = FocusNode();

  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _isButtonPressed = false;
  bool _isHovered = false;
  bool _isLoginLinkHovered = false;
  bool _isGuestLinkHovered = false;
  String? _validationError;

  late final AnimationController _entranceController;
  late final AnimationController _pulseController;

  late final Animation<double> _logoFade;
  late final Animation<Offset> _logoSlide;
  late final Animation<double> _titleFade;
  late final Animation<Offset> _titleSlide;
  late final Animation<double> _cardFade;
  late final Animation<Offset> _cardSlide;
  late final Animation<double> _bottomFade;

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _entranceController.forward();
  }

  void _initAnimations() {
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _logoFade = CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0.0, 0.4, curve: Curves.easeOut),
    );
    _logoSlide = Tween<Offset>(
      begin: const Offset(0, -0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0.0, 0.4, curve: Curves.easeOutCubic),
    ));

    _titleFade = CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0.15, 0.5, curve: Curves.easeOut),
    );
    _titleSlide = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0.15, 0.5, curve: Curves.easeOutCubic),
    ));

    _cardFade = CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0.3, 0.7, curve: Curves.easeOut),
    );
    _cardSlide = Tween<Offset>(
      begin: const Offset(0, 0.15),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0.3, 0.7, curve: Curves.easeOutCubic),
    ));

    _bottomFade = CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0.6, 1.0, curve: Curves.easeOut),
    );

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _entranceController.dispose();
    _pulseController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _usernameFocus.dispose();
    _passwordFocus.dispose();
    _confirmPasswordFocus.dispose();
    super.dispose();
  }

  String? _validate() {
    final username = _usernameController.text.trim();
    final password = _passwordController.text;
    final confirm = _confirmPasswordController.text;

    if (username.isEmpty || password.isEmpty) {
      return 'Wypełnij wszystkie pola';
    }
    if (username.length < 3) {
      return 'Nazwa użytkownika musi mieć min. 3 znaki';
    }
    if (password.length < 6) {
      return 'Hasło musi mieć min. 6 znaków';
    }
    if (password != confirm) {
      return 'Hasła nie są identyczne';
    }
    return null;
  }

  void _handleRegister() {
    final error = _validate();
    if (error != null) {
      setState(() => _validationError = error);
      return;
    }
    setState(() => _validationError = null);

    ref.read(authNotifierProvider.notifier).register(
          _usernameController.text.trim(),
          _passwordController.text,
        );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);
    final isMobile = MediaQuery.of(context).size.width < 600;

    ref.listen<AuthState>(authNotifierProvider, (prev, next) {
      if (next is AuthAuthenticated) {
        
        Navigator.of(context).pushNamedAndRemoveUntil('/', (_) => false);
      } else if (next is AuthError) {
        TopToast.show(
          context,
          message: next.message,
          color: AppTheme.errorColor,
          icon: Icons.error_outline_rounded,
        );
        ref.read(authNotifierProvider.notifier).clearError();
      }
    });

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0F),
      body: Stack(
        children: [
          const Positioned.fill(child: AnimatedAuthBackground()),

          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: isMobile ? 24 : 48,
                  vertical: 32,
                ),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 420),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AuthHeader(
                        logoSlide: _logoSlide,
                        logoFade: _logoFade,
                        titleSlide: _titleSlide,
                        titleFade: _titleFade,
                        title: 'Utwórz konto',
                        subtitle: 'Dołącz do SyllApp',
                      ),
                      const SizedBox(height: 36),
                      _buildCard(authState),
                      const SizedBox(height: 24),
                      _buildFooter(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard(AuthState authState) {
    return SlideTransition(
      position: _cardSlide,
      child: FadeTransition(
        opacity: _cardFade,
        child: GlassmorphicCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AuthTextField(
                controller: _usernameController,
                focusNode: _usernameFocus,
                label: 'Nazwa użytkownika',
                hint: 'twoj_nick',
                icon: Icons.person_outline_rounded,
              ),
              const SizedBox(height: 18),
              AuthTextField(
                controller: _passwordController,
                focusNode: _passwordFocus,
                label: 'Hasło',
                hint: '••••••••',
                icon: Icons.lock_outline_rounded,
                obscure: _obscurePassword,
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword
                        ? Icons.visibility_off_rounded
                        : Icons.visibility_rounded,
                    size: 20,
                    color: AppTheme.appleSystemGray,
                  ),
                  onPressed: () =>
                      setState(() => _obscurePassword = !_obscurePassword),
                ),
              ),
              const SizedBox(height: 18),
              AuthTextField(
                controller: _confirmPasswordController,
                focusNode: _confirmPasswordFocus,
                label: 'Potwierdź hasło',
                hint: '••••••••',
                icon: Icons.lock_outline_rounded,
                obscure: _obscureConfirm,
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureConfirm
                        ? Icons.visibility_off_rounded
                        : Icons.visibility_rounded,
                    size: 20,
                    color: AppTheme.appleSystemGray,
                  ),
                  onPressed: () =>
                      setState(() => _obscureConfirm = !_obscureConfirm),
                ),
              ),
              if (_validationError != null) ...[
                const SizedBox(height: 12),
                Text(
                  _validationError!,
                  style: TextStyle(
                    color: Colors.red.shade300,
                    fontSize: 13,
                    fontFamily: 'SF Pro Text',
                  ),
                ),
              ],
              const SizedBox(height: 24),
              _buildRegisterButton(authState),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRegisterButton(AuthState authState) {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, _) {
        final pulse = 0.7 + (_pulseController.value * 0.3);
        return MouseRegion(
          cursor: SystemMouseCursors.click,
          onEnter: (_) => setState(() => _isHovered = true),
          onExit: (_) => setState(() => _isHovered = false),
          child: GestureDetector(
            onTapDown: (_) => setState(() => _isButtonPressed = true),
            onTapUp: (_) => setState(() => _isButtonPressed = false),
            onTapCancel: () => setState(() => _isButtonPressed = false),
            onTap: authState is AuthLoading ? null : _handleRegister,
            child: AnimatedScale(
              scale: _isButtonPressed ? 0.96 : 1.0,
              duration: const Duration(milliseconds: 100),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                height: 54,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: _isHovered
                        ? [
                            Colors.grey.shade700,
                            Colors.grey.shade600,
                          ]
                        : [
                            AppTheme.accent,
                            const Color(0xFF6C63FF),
                          ],
                  ),
                  boxShadow: _isHovered
                      ? [
                          BoxShadow(
                            color: Colors.grey.withValues(alpha: 0.35 * pulse),
                            blurRadius: 20 * pulse,
                            spreadRadius: 0,
                            offset: const Offset(0, 6),
                          ),
                        ]
                      : [
                          BoxShadow(
                            color: AppTheme.accent.withValues(alpha: 0.35 * pulse),
                            blurRadius: 20 * pulse,
                            spreadRadius: 0,
                            offset: const Offset(0, 6),
                          ),
                          BoxShadow(
                            color: const Color(0xFF6C63FF)
                                .withValues(alpha: 0.2 * pulse),
                            blurRadius: 30 * pulse,
                            spreadRadius: 0,
                            offset: const Offset(0, 10),
                          ),
                        ],
                ),
                child: Center(
                  child: authState is AuthLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          'Zarejestruj się',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            fontFamily: 'SF Pro Text',
                            letterSpacing: -0.3,
                          ),
                        ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildFooter() {
    return FadeTransition(
      opacity: _bottomFade,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Masz już konto?  ',
                style: TextStyle(
                  color: AppTheme.appleSystemGray.withValues(alpha: 0.7),
                  fontSize: 15,
                  fontFamily: 'SF Pro Text',
                ),
              ),
              MouseRegion(
                cursor: SystemMouseCursors.click,
                onEnter: (_) => setState(() => _isLoginLinkHovered = true),
                onExit: (_) => setState(() => _isLoginLinkHovered = false),
                child: GestureDetector(
                  onTap: () {
                    Navigator.of(context).pushReplacementNamed('/login');
                  },
                  child: AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 200),
                    style: TextStyle(
                      color: _isLoginLinkHovered
                          ? Colors.white
                          : AppTheme.accentLight,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'SF Pro Text',
                      decoration:
                          _isLoginLinkHovered ? TextDecoration.underline : null,
                      decorationColor: Colors.white,
                    ),
                    child: const Text('Zaloguj się'),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          MouseRegion(
            cursor: SystemMouseCursors.click,
            onEnter: (_) => setState(() => _isGuestLinkHovered = true),
            onExit: (_) => setState(() => _isGuestLinkHovered = false),
            child: GestureDetector(
              onTap: () {
                Navigator.of(context)
                    .pushNamedAndRemoveUntil('/', (_) => false);
              },
              child: AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 200),
                style: TextStyle(
                  color: _isGuestLinkHovered
                      ? Colors.white.withValues(alpha: 0.9)
                      : AppTheme.appleSystemGray.withValues(alpha: 0.5),
                  fontSize: 14,
                  fontFamily: 'SF Pro Text',
                  decoration:
                      _isGuestLinkHovered ? TextDecoration.underline : null,
                  decorationColor: Colors.white.withValues(alpha: 0.9),
                ),
                child: const Text('Kontynuuj bez konta'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
