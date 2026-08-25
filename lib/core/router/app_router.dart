import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_pot/providers/prefs_provider.dart';
import '../../features/auth/welcome_screen.dart';
import '../../features/dashboard/main_layout.dart';
import '../../features/wallet/screens/wallet_screen.dart';
import '../../features/onboarding/onboarding_screen.dart';

final authStateProvider = StreamProvider<User?>((ref) {
  return FirebaseAuth.instance.authStateChanges();
});

final goRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);
  final prefs = ref.read(sharedPreferencesProvider);

  return GoRouter(
    initialLocation: '/welcome',
    debugLogDiagnostics: true,
    redirect: (context, state) {
      if (authState.isLoading) return null;

      final isAuth = authState.value != null;
      final uri = state.uri.toString();
      final isGoingToAuth = uri == '/welcome';
      final isGoingToOnboarding = uri == '/onboarding';
      final seenOnboarding = prefs.getBool('has_seen_onboarding') ?? false;

      if (!isAuth && !isGoingToAuth) {
        return '/welcome';
      }

      if (isAuth && isGoingToAuth) {
        return seenOnboarding ? '/home' : '/onboarding';
      }

      if (isAuth && !isGoingToOnboarding && !seenOnboarding && uri != '/onboarding') {
        return '/onboarding';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/welcome',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const WelcomeScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: CurvedAnimation(
                parent: animation,
                curve: Curves.easeOut,
              ),
              child: child,
            );
          },
        ),
      ),
      GoRoute(
        path: '/home',
        name: 'home',
        builder: (context, state) => const MainLayout(),
      ),
      GoRoute(
        path: '/onboarding',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const OnboardingScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: CurvedAnimation(
                parent: animation,
                curve: Curves.easeOut,
              ),
              child: child,
            );
          },
        ),
      ),
      GoRoute(
        path: '/wallet',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const WalletScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            final curved = CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic,
            );
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 1),
                end: Offset.zero,
              ).animate(curved),
              child: child,
            );
          },
        ),
      ),
    ],
  );
});
