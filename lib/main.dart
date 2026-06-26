import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'package:flutter_localizations/flutter_localizations.dart';

import 'app_scope.dart';
import 'config/constants.dart';
import 'config/theme.dart';
import 'firebase_options.dart';
import 'l10n/app_localizations.dart';
import 'screens/auth/login_screen.dart';
import 'screens/home/home_screen.dart';
import 'services/auth_service.dart';
import 'services/database_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase with platform-specific options
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint('Firebase init failed: $e');
    // Continue without Firebase - app will still work but auth won't function
  }
  
  // Hive initialization
  Box box;
  try {
    await Hive.initFlutter();
    box = await Hive.openBox('agro_rent');
  } catch (e, stackTrace) {
    debugPrint('Hive initialization failed: $e');
    debugPrint('Stack trace: $stackTrace');
    // Re-throw to see the error
    rethrow;
  }
  
  try {
    final state = AppState(box);
    await state.initialize();
    final auth = AuthService();
    // Check if Firebase is available, if not, show a warning but continue
    if (!auth.isFirebaseAvailable && kIsWeb) {
      debugPrint('Warning: Firebase is not configured for web. Some features may not work.');
    }
    runApp(AgroRentApp(state: state, auth: auth));
  } catch (e, stackTrace) {
    debugPrint('App initialization error: $e');
    debugPrint('Stack trace: $stackTrace');
    // Show error screen instead of white screen
    runApp(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                Text('Error: $e', style: const TextStyle(fontSize: 16)),
                const SizedBox(height: 8),
                Text('Check console for details', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class AgroRentApp extends StatefulWidget {
  const AgroRentApp({super.key, required this.state, required this.auth});

  final AppState state;
  final AuthService auth;

  @override
  State<AgroRentApp> createState() => _AgroRentAppState();
}

class _AgroRentAppState extends State<AgroRentApp> {
  // Global navigator key to maintain navigation state
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.state,
      builder: (context, _) {
        // Get saved language or default to English
        final savedLanguage = widget.state.savedLanguage ?? 'en';
        final locale = Locale(savedLanguage);
        
        return AppScope(
          notifier: widget.state,
          auth: widget.auth,
          child: MaterialApp(
            navigatorKey: navigatorKey,
            title: kAppName,
            theme: buildAgroTheme(),
            locale: locale,
            debugShowCheckedModeBanner: false,
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [
              Locale('en', ''),
              Locale('hi', ''),
              Locale('te', ''),
              Locale('ta', ''),
              Locale('kn', ''),
              Locale('ml', ''),
              Locale('bn', ''),
              Locale('gu', ''),
              Locale('mr', ''),
            ],
            home: widget.state.loggedIn ? const HomeScreen() : const LoginScreen(),
          ),
        );
      },
    );
  }
}

