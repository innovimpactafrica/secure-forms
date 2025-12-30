import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../utils/app_routes.dart';

class SuccessScreen extends StatefulWidget {
  const SuccessScreen({super.key});

  @override
  State<SuccessScreen> createState() => _SuccessScreenState();
}

class _SuccessScreenState extends State<SuccessScreen> {
  @override
  void initState() {
    super.initState();
    // Redirection automatique après 3 secondes
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.of(context).pushReplacementNamed(AppRoutes.clientHome);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF424242),
      body: Center(
        child: Container(
          width: 390,
          height: 264,
          padding: const EdgeInsets.fromLTRB(24, 50, 24, 50),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icône de validation
              SvgPicture.asset(
                'assets/icons/Vector (16).svg',
                width: 64,
                height: 64,
              ),
              const SizedBox(height: 32),
              // Titre "Compte créé"
              SizedBox(
                width: 112,
                height: 26,
                child: Text(
                  'Compte créé',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Sofia Sans',
                    fontWeight: FontWeight.w600,
                    fontSize: 20,
                    height: 1.3,
                    color: const Color(0xFF212121),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Sous-titre "Bienvenue sur votre espace"
              SizedBox(
                width: 342,
                height: 24,
                child: Text(
                  'Bienvenue sur votre espace',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Sofia Sans',
                    fontWeight: FontWeight.w400,
                    fontSize: 18,
                    height: 24 / 18,
                    color: const Color(0xFF0F1A14),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}