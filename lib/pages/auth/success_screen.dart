import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../utils/app_routes.dart';
import '../../utils/responsive_utils.dart';

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
          width: ResponsiveUtils.getResponsiveWidth(context, 390),
          height: ResponsiveUtils.getResponsiveHeight(context, 264),
          padding: EdgeInsets.fromLTRB(
            ResponsiveUtils.getResponsiveWidth(context, 24),
            ResponsiveUtils.getResponsiveHeight(context, 50),
            ResponsiveUtils.getResponsiveWidth(context, 24),
            ResponsiveUtils.getResponsiveHeight(context, 50),
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(
              ResponsiveUtils.getResponsiveValue(context, 16),
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icône de validation
              SvgPicture.asset(
                'assets/icons/Vector (16).svg',
                width: ResponsiveUtils.getResponsiveWidth(context, 64),
                height: ResponsiveUtils.getResponsiveHeight(context, 64),
              ),
              SizedBox(height: ResponsiveUtils.getResponsiveHeight(context, 32)),
              // Titre "Compte créé"
              SizedBox(
                width: ResponsiveUtils.getResponsiveWidth(context, 112),
                height: ResponsiveUtils.getResponsiveHeight(context, 26),
                child: Text(
                  'Compte créé',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Sofia Sans',
                    fontWeight: FontWeight.w600,
                    fontSize: ResponsiveUtils.getResponsiveFontSize(context, 20),
                    height: 1.3,
                    color: const Color(0xFF212121),
                  ),
                ),
              ),
              SizedBox(height: ResponsiveUtils.getResponsiveHeight(context, 16)),
              // Sous-titre "Bienvenue sur votre espace"
              SizedBox(
                width: ResponsiveUtils.getResponsiveWidth(context, 342),
                height: ResponsiveUtils.getResponsiveHeight(context, 24),
                child: Text(
                  'Bienvenue sur votre espace',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Sofia Sans',
                    fontWeight: FontWeight.w400,
                    fontSize: ResponsiveUtils.getResponsiveFontSize(context, 18),
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