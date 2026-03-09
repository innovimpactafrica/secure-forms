import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:app_links/app_links.dart';
import 'package:secure_link/features/auth/presentation/pages/login_screen.dart';
import 'package:secure_link/features/auth/presentation/pages/create_password_screen.dart';
import 'package:secure_link/features/client/domain/bloc/profile_bloc.dart';
import 'features/splash/presentation/pages/splash_screen.dart';
import 'features/auth/presentation/pages/welcome_screen.dart';
import 'features/auth/presentation/pages/otp_verification_screen.dart';
import 'features/auth/presentation/widgets/success_screen.dart';
import 'features/client/presentation/pages/client_home_screen.dart';
import 'features/client/presentation/pages/client_demandes_screen.dart';
import 'features/client/presentation/pages/client_banques_screen.dart';
import 'features/client/presentation/pages/client_formulaires_screen.dart';
import 'features/client/presentation/pages/client_methode_screen.dart';
import 'features/client/presentation/pages/nouvelle_demande/nouvelle_demande_steps_7_12.dart';
import 'features/client/presentation/pages/nouvelle_demande/nouvelle_demande_step_8.dart';
import 'features/client/presentation/pages/nouvelle_demande/nouvelle_demande_step_9.dart';
import 'features/client/presentation/pages/detail_demande/detail_demande_screen.dart';
import 'features/client/presentation/pages/detail_demande/detail_virement_screen.dart';
import 'features/client/presentation/pages/detail_demande/detail_acte_vente_screen.dart';
import 'features/client/presentation/pages/detail_demande/detail_pret_screen.dart';
import 'features/client/presentation/pages/detail_demande/detail_ouverture_compte_screen.dart';
import 'features/client/presentation/pages/client_demande_detail_screen.dart';
import 'features/client/presentation/pages/detail_demande/detail_ouverture_compte_brouillon_screen.dart';
import 'features/client/presentation/pages/client_profil_screen.dart';
import 'features/client/presentation/pages/detail_demande/detail_ouverture_compte_continuer_screen.dart';
import 'package:secure_link/core/utils/app_routes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();

  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('fr'), Locale('en')],
      path: 'assets/translations',
      fallbackLocale: const Locale('fr'),
      child: const SecureLinkApp(),
    ),
  );
}

class SecureLinkApp extends StatefulWidget {
  const SecureLinkApp({super.key});

  @override
  State<SecureLinkApp> createState() => _SecureLinkAppState();
}

class _SecureLinkAppState extends State<SecureLinkApp> {
  final _navigatorKey = GlobalKey<NavigatorState>();
  late final AppLinks _appLinks;

  @override
  void initState() {
    super.initState();
    _initDeepLinks();
  }

  Future<void> _initDeepLinks() async {
    _appLinks = AppLinks();

    // Cas 1 : app déjà ouverte en arrière-plan → lien reçu
    _appLinks.uriLinkStream.listen((uri) {
      _handleDeepLink(uri);
    });

    // Cas 2 : app était fermée → lien qui l'a ouverte
    final initialUri = await _appLinks.getInitialLink();
    if (initialUri != null) {
      // Petit délai pour laisser le temps à MaterialApp de s'initialiser
      await Future.delayed(const Duration(milliseconds: 500));
      _handleDeepLink(initialUri);
    }
  }

  void _handleDeepLink(Uri uri) {
    String? token;

    // ── Format 1 : custom scheme ──────────────────────────────────
    // securelink://create-password?token=pwd-setup-xxxx
    if (uri.scheme == 'securelink' && uri.host == 'create-password') {
      token = uri.queryParameters['token'];
    }

    // ── Format 2 : lien HTTP backend (localhost:4200 ou prod) ─────
    // http://localhost:4200/create-password?token=pwd-setup-xxxx
    // https://monapp.com/create-password?token=pwd-setup-xxxx
    else if (uri.path.contains('create-password') ||
             uri.path.contains('setup-password')) {
      token = uri.queryParameters['token'];
    }

    // ── Navigation si token trouvé ────────────────────────────────
    if (token != null && token.isNotEmpty) {
      _navigatorKey.currentState?.pushNamed(
        AppRoutes.createPassword,
        arguments: token,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ProfileBloc(),
      child: MaterialApp(
        title: 'Secure Link',
        navigatorKey: _navigatorKey,
        debugShowCheckedModeBanner: false,
        localizationsDelegates: context.localizationDelegates,
        supportedLocales: context.supportedLocales,
        locale: context.locale,
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        initialRoute: AppRoutes.splash,
        onGenerateRoute: (settings) {
          if (settings.name == AppRoutes.otpVerification) {
            final args = settings.arguments as Map<String, String>? ?? {};
            return MaterialPageRoute(
              builder: (_) => OtpVerificationScreen(
                email: args['email'] ?? '',
                sessionToken: args['sessionToken'] ?? '',
              ),
            );
          }
          if (settings.name == AppRoutes.createPassword) {
            final token = settings.arguments as String? ?? '';
            return MaterialPageRoute(
              builder: (_) => CreatePasswordScreen(token: token),
            );
          }
          return null;
        },
        routes: {
          AppRoutes.splash: (context) => const SplashScreen(),
          AppRoutes.welcome: (context) => const WelcomeScreen(),
          AppRoutes.login: (context) => const LoginScreen(),
          '/success': (context) => const SuccessScreen(),
          AppRoutes.clientHome: (context) => const ClientHomeScreen(),
          AppRoutes.clientDemandes: (context) => const ClientDemandesScreen(),
          AppRoutes.clientBanques: (context) => const ClientBanquesScreen(),
          AppRoutes.clientFormulaires: (context) => const ClientFormulairesScreen(),
          AppRoutes.clientMethode: (context) => const ClientMethodeScreen(),
          AppRoutes.nouvelleDemandeStep7: (context) => const NouvelleDemandeStep7Screen(),
          AppRoutes.nouvelleDemandeStep8: (context) => const NouvelleDemandeStep8Screen(),
          AppRoutes.nouvelleDemandeStep9: (context) => const NouvelleDemandeStep9Screen(),
          AppRoutes.detailDemande: (context) => const DetailDemandeScreen(),
          AppRoutes.detailVirement: (context) => const DetailVirementScreen(),
          AppRoutes.detailActeVente: (context) => const DetailActeVenteScreen(),
          AppRoutes.detailPret: (context) => const DetailPretScreen(),
          AppRoutes.detailOuvertureCompte: (context) => const DetailOuvertureCompteScreen(),
          AppRoutes.detailOuvertureCompteBrouillon: (context) => const DetailOuvertureCompteBrouillonScreen(),
          AppRoutes.clientProfil: (context) => const ClientProfilScreen(),
          '/detail-ouverture-compte-continuer': (context) => const DetailOuvertureCompteContinuerScreen(),
          AppRoutes.clientDemandeDetail: (context) => const ClientDemandeDetailScreen(),
        },
      ),
    );
  }
}