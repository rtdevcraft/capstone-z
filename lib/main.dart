import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:zenigo/src/core/auth/auth_state_provider.dart';
import 'package:zenigo/src/core/routing/app_router.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:zenigo/src/shared/theme/color_schemes.g.dart';
import 'package:google_fonts/google_fonts.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: ".env");

  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
  );

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  @override
  void initState() {
    super.initState();
    // Listen to auth changes and force navigation.
    ref.listenManual(authStateProvider, (previous, next) {
      // This ensures that when the auth state changes (e.g., after a sign-out),
      // the router is forced to re-evaluate and navigate to the correct screen.
      if (next.valueOrNull?.session != previous?.valueOrNull?.session) {
        ref.read(appRouterProvider).refresh();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      title: 'Zenigo',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: lightColorScheme,
        textTheme: GoogleFonts.lexendExaTextTheme().copyWith(
          displayLarge: GoogleFonts.lexendExa(fontWeight: FontWeight.bold),
          displayMedium: GoogleFonts.lexendExa(fontWeight: FontWeight.bold),
          displaySmall: GoogleFonts.lexendExa(fontWeight: FontWeight.bold),
          headlineLarge: GoogleFonts.lexendExa(fontWeight: FontWeight.w500),
          headlineMedium: GoogleFonts.lexendExa(fontWeight: FontWeight.w500),
          headlineSmall: GoogleFonts.lexendExa(fontWeight: FontWeight.w500),
          titleLarge: GoogleFonts.lexendExa(fontWeight: FontWeight.w500),
          titleMedium: GoogleFonts.lexendExa(fontWeight: FontWeight.w500),
          titleSmall: GoogleFonts.lexendExa(fontWeight: FontWeight.w500),
          bodyLarge: GoogleFonts.lexendExa(fontWeight: FontWeight.w300),
          bodyMedium: GoogleFonts.lexendExa(fontWeight: FontWeight.w300),
          bodySmall: GoogleFonts.lexendExa(fontWeight: FontWeight.w300),
          labelLarge: GoogleFonts.lexendExa(fontWeight: FontWeight.w300),
          labelMedium: GoogleFonts.lexendExa(fontWeight: FontWeight.w300),
          labelSmall: GoogleFonts.lexendExa(fontWeight: FontWeight.w300),
        ),
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: Color.fromARGB(255, 110, 183, 197),
          foregroundColor: lightColorScheme.onSecondary,
        ),
        iconTheme: const IconThemeData(
          fill: 0.0,
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: darkColorScheme,
        textTheme: GoogleFonts.lexendExaTextTheme().copyWith(
          displayLarge: GoogleFonts.lexendExa(fontWeight: FontWeight.bold),
          displayMedium: GoogleFonts.lexendExa(fontWeight: FontWeight.bold),
          displaySmall: GoogleFonts.lexendExa(fontWeight: FontWeight.bold),
          headlineLarge: GoogleFonts.lexendExa(fontWeight: FontWeight.w500),
          headlineMedium: GoogleFonts.lexendExa(fontWeight: FontWeight.w500),
          headlineSmall: GoogleFonts.lexendExa(fontWeight: FontWeight.w500),
          titleLarge: GoogleFonts.lexendExa(fontWeight: FontWeight.w500),
          titleMedium: GoogleFonts.lexendExa(fontWeight: FontWeight.w500),
          titleSmall: GoogleFonts.lexendExa(fontWeight: FontWeight.w500),
          bodyLarge: GoogleFonts.lexendExa(fontWeight: FontWeight.w300),
          bodyMedium: GoogleFonts.lexendExa(fontWeight: FontWeight.w300),
          bodySmall: GoogleFonts.lexendExa(fontWeight: FontWeight.w300),
          labelLarge: GoogleFonts.lexendExa(fontWeight: FontWeight.w300),
          labelMedium: GoogleFonts.lexendExa(fontWeight: FontWeight.w300),
          labelSmall: GoogleFonts.lexendExa(fontWeight: FontWeight.w300),
        ),
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: darkColorScheme.secondary,
          foregroundColor: darkColorScheme.onSecondary,
        ),
        iconTheme: const IconThemeData(
          fill: 0.0,
        ),
      ),
      routerConfig: router,
    );
  }
}
