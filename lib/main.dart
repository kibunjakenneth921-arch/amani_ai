import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'src/core/app_theme.dart';
import 'src/core/router_provider.dart';
import 'src/core/theme_notifier.dart';
import 'src/core/constants.dart';
import 'firebase_options.dart';

late final FirebaseAnalytics analytics;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    analytics = FirebaseAnalytics.instance;
  } catch (e) {
    rethrow;
  }

  runApp(const ProviderScope(child: AmaniApp()));
}

class AmaniApp extends ConsumerWidget {
  const AmaniApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final themeMode = ref.watch(themeNotifierProvider);

    return MaterialApp.router(
      title: AppConstants.appName,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      routerConfig: router,
      navigatorObservers: [FirebaseAnalyticsObserver(analytics: analytics)],
    );
  }
}
