import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/config/app_config.dart';
import 'core/theme/app_theme.dart';
import 'core/settings/settings_providers.dart';
import 'features/auth/application/auth_providers.dart';
import 'features/auth/application/auth_state.dart';
import 'features/auth/presentation/pages/login_page.dart';
import 'features/auth/presentation/pages/register_page.dart';
import 'features/project/application/project_providers.dart';
import 'features/editor/presentation/pages/editor_page.dart';
import 'features/project/presentation/pages/welcome_screen.dart';
import 'features/onboarding/presentation/pages/introduction_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProviderScope(child: RapLyricsIDE()));
}

class RapLyricsIDE extends ConsumerStatefulWidget {
  const RapLyricsIDE({super.key});

  @override
  ConsumerState<RapLyricsIDE> createState() => _RapLyricsIDEState();
}

class _RapLyricsIDEState extends ConsumerState<RapLyricsIDE> {
  bool _initialized = false;
  bool _showOnboarding = false;

  @override
  void initState() {
    super.initState();
    _initApp();
  }

  Future<void> _initApp() async {
    final onboardingDone = await IntroductionPage.isCompleted();
    await ref.read(settingsNotifierProvider.notifier).init();
    if (!kOfflineOnly) {
      await ref.read(authNotifierProvider.notifier).init();
    }
    await ref.read(projectNotifierProvider.notifier).init();

    if (!kOfflineOnly) {
      
      final authState = ref.read(authNotifierProvider);
      if (authState is AuthAuthenticated) {
        triggerSync(ref);
      }
    }

    if (mounted) {
      setState(() {
        _showOnboarding = !onboardingDone;
        _initialized = true;
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    if (!kOfflineOnly) {
      ref.listen<AuthState>(authNotifierProvider, (previous, next) {
        if (previous is! AuthAuthenticated && next is AuthAuthenticated) {
          triggerSync(ref);
        }
      });

      ref.listen<bool>(sessionExpiredProvider, (previous, next) {
        if (next) {
          ref.read(authNotifierProvider.notifier).forceSessionExpired();
          ref.read(sessionExpiredProvider.notifier).reset();
          WidgetsBinding.instance.addPostFrameCallback((_) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Sesja wygasła — zaloguj się ponownie'),
                behavior: SnackBarBehavior.floating,
                duration: Duration(seconds: 4),
              ),
            );
          });
        }
      });
    }

    final currentProject = _initialized ? ref.watch(currentProjectProvider) : null;
    final appTitle = currentProject != null
        ? '${currentProject.name} - SyllApp'
        : 'SyllApp';

    return MaterialApp(
      title: appTitle,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: _buildHome(currentProject),
      routes: {
        '/editor': (context) => const EditorPage(),
        if (!kOfflineOnly) '/login': (context) => const LoginPage(),
        if (!kOfflineOnly) '/register': (context) => const RegisterPage(),
      },
    );
  }

  Widget _buildHome(dynamic currentProject) {
    if (!_initialized) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    if (_showOnboarding) {
      return IntroductionPage(
        onComplete: () => setState(() => _showOnboarding = false),
      );
    }
    return currentProject != null
        ? const EditorPage()
        : const WelcomeScreen();
  }
}
