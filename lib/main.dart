import 'package:flutter/material.dart';
import 'pages/splash/splash_screen.dart';
import 'pages/auth/welcome_screen.dart';
import 'pages/auth/login_screen.dart';
import 'pages/auth/otp_verification_screen.dart';
import 'pages/auth/success_screen.dart';
import 'pages/client/client_home_screen.dart';
import 'pages/client/client_demandes_screen.dart';
import 'pages/client/client_banques_screen.dart';
import 'pages/client/client_formulaires_screen.dart';
import 'pages/client/client_methode_screen.dart';
import 'pages/client/nouvelle_demande/nouvelle_demande_steps_7_12.dart';
import 'pages/client/nouvelle_demande/nouvelle_demande_step_8.dart';
import 'pages/client/nouvelle_demande/nouvelle_demande_step_9.dart';
import 'utils/app_routes.dart';

void main() {
  runApp(const SecureLinkApp());
}

class SecureLinkApp extends StatelessWidget {
  const SecureLinkApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Secure Link',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: AppRoutes.splash,
      routes: {
        AppRoutes.splash: (context) => const SplashScreen(),
        AppRoutes.welcome: (context) => const WelcomeScreen(),
        AppRoutes.login: (context) => const LoginScreen(),
        AppRoutes.otpVerification: (context) => const OtpVerificationScreen(),
        '/success': (context) => const SuccessScreen(),
        AppRoutes.clientHome: (context) => const ClientHomeScreen(),
        AppRoutes.clientDemandes: (context) => const ClientDemandesScreen(),
        AppRoutes.clientBanques: (context) => const ClientBanquesScreen(),
        AppRoutes.clientFormulaires: (context) => const ClientFormulairesScreen(),
        AppRoutes.clientMethode: (context) => const ClientMethodeScreen(),
        AppRoutes.nouvelleDemandeStep7: (context) => const NouvelleDemandeStep7Screen(),
        AppRoutes.nouvelleDemandeStep8: (context) => const NouvelleDemandeStep8Screen(),
        AppRoutes.nouvelleDemandeStep9: (context) => const NouvelleDemandeStep9Screen(),
      },
    );
  }
}