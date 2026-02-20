import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/config/app_config.dart';
import '../../../auth/presentation/pages/login_page.dart';
import '../../../auth/presentation/widgets/animated_auth_background.dart';

class IntroductionPage extends StatefulWidget {
  const IntroductionPage({super.key, required this.onComplete});

  final VoidCallback onComplete;
  static const String _prefKey = 'onboarding_completed';

  static Future<bool> isCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_prefKey) ?? false;
  }

  static Future<void> markCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefKey, true);
  }

  @override
  State<IntroductionPage> createState() => _IntroductionPageState();
}

class _IntroductionPageState extends State<IntroductionPage> {
  final _controller = PageController();
  int _currentPage = 0;

  static const _pages = [
    _PageData(
      asset: 'assets/logo.png',
      title: 'Witaj w SyllApp',
      subtitle: 'Twórz i analizuj teksty\nłatwiej niż kiedykolwiek',
    ),
    _PageData(
      icon: Icons.auto_fix_high_rounded,
      title: 'Analiza rymów',
      subtitle: 'Automatyczne wykrywanie i podświetlanie\nwszystkich rymów i asonansów',
    ),
    _PageData(
      icon: Icons.search,
      title: 'Słownik rymów',
      subtitle: 'Sprawdź rymy dla każdego\nistniejącego słowa z poziomu edytora'
    ),
    _PageData(
      icon: Icons.rocket_launch_rounded,
      title: 'Zacznij tworzyć',
      subtitle: 'Stwórz swój pierwszy projekt\ni zacznij pisać',
    ),
  ];

  void _next() {
    if (_currentPage < _pages.length - 1) {
      _controller.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _finish();
    }
  }

  void _finish() async {
    await IntroductionPage.markCompleted();
    if (mounted) {
      if (kOfflineOnly) {
        
        widget.onComplete();
      } else {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            settings: const RouteSettings(name: '/login', arguments: true),
            transitionDuration: const Duration(milliseconds: 600),
            pageBuilder: (_, _, _) => const _DeferredLoginPage(),
            transitionsBuilder: (_, animation, _, child) {
              return FadeTransition(opacity: animation, child: child);
            },
          ),
        );
        
        Future.delayed(const Duration(milliseconds: 600), widget.onComplete);
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLast = _currentPage == _pages.length - 1;
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 600;

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0F),
      body: Stack(
        children: [
          const Positioned.fill(
            child: RepaintBoundary(child: AnimatedAuthBackground()),
          ),
          SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 600),
                child: Column(
                  children: [
                    
                    Align(
                      alignment: Alignment.topRight,
                      child: Padding(
                        padding: EdgeInsets.all(isDesktop ? 24 : 16),
                        child: isLast
                            ? const SizedBox(height: 48)
                            : TextButton(
                                onPressed: _finish,
                                child: Text(
                                  'Pomiń',
                                  style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.5),
                                    fontSize: 15,
                                    fontFamily: 'SF Pro Text',
                                  ),
                                ),
                              ),
                      ),
                    ),
                    
                    Expanded(
                      child: PageView.builder(
                        controller: _controller,
                        itemCount: _pages.length,
                        onPageChanged: (i) => setState(() => _currentPage = i),
                        itemBuilder: (_, i) => _buildPage(_pages[i], isDesktop),
                      ),
                    ),
                    
                    Padding(
                      padding: EdgeInsets.fromLTRB(
                        isDesktop ? 80 : 32,
                        0,
                        isDesktop ? 80 : 32,
                        isDesktop ? 64 : 48,
                      ),
                      child: Column(
                        children: [
                          _buildDots(),
                          const SizedBox(height: 32),
                          _buildButton(isLast, isDesktop),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPage(_PageData data, bool isDesktop) {
    final iconSize = isDesktop ? 120.0 : 100.0;
    final iconRadius = isDesktop ? 36.0 : 30.0;
    final innerIconSize = isDesktop ? 56.0 : 48.0;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: isDesktop ? 80 : 48),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: iconSize,
            height: iconSize,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(iconRadius),
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF007ACC), Color(0xFF6C63FF)],
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF007ACC).withValues(alpha: 0.3),
                  blurRadius: 30,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: data.asset != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(iconRadius),
                    child: Image.asset(data.asset!, width: iconSize, height: iconSize, fit: BoxFit.cover),
                  )
                : Icon(data.icon, size: innerIconSize, color: Colors.white),
          ),
          SizedBox(height: isDesktop ? 48 : 40),
          Text(
            data.title,
            style: TextStyle(
              color: Colors.white,
              fontSize: isDesktop ? 34 : 28,
              fontWeight: FontWeight.w700,
              fontFamily: 'SF Pro Display',
              letterSpacing: -0.8,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            data.subtitle,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.6),
              fontSize: isDesktop ? 18 : 16,
              fontFamily: 'SF Pro Text',
              height: 1.4,
              letterSpacing: -0.3,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildDots() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(_pages.length, (i) {
        final isActive = i == _currentPage;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: isActive ? 24 : 8,
          height: 8,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            color: isActive
                ? const Color(0xFF007ACC)
                : Colors.white.withValues(alpha: 0.2),
          ),
        );
      }),
    );
  }

  Widget _buildButton(bool isLast, bool isDesktop) {
    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: isDesktop ? 320 : double.infinity),
      child: SizedBox(
        width: double.infinity,
        height: 54,
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: const LinearGradient(
              colors: [Color(0xFF007ACC), Color(0xFF6C63FF)],
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF007ACC).withValues(alpha: 0.35),
                blurRadius: 20,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: MaterialButton(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            onPressed: _next,
            child: Text(
              isLast ? 'Rozpocznij' : 'Dalej',
              style: const TextStyle(
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
    );
  }
}


class _DeferredLoginPage extends StatelessWidget {
  const _DeferredLoginPage();

  @override
  Widget build(BuildContext context) => const LoginPage();
}

class _PageData {
  final IconData? icon;
  final String? asset;
  final String title;
  final String subtitle;
  const _PageData({
    this.icon,
    this.asset,
    required this.title,
    required this.subtitle,
  });
}
