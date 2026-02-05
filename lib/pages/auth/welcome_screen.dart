import 'package:flutter/material.dart';
import '../../utils/app_routes.dart';
import '../../utils/responsive_utils.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox(
        width: ResponsiveUtils.getScreenWidth(context),
        height: ResponsiveUtils.getScreenHeight(context),
        child: Stack(
          children: [
            // Image de fond
            Container(
              width: ResponsiveUtils.getScreenWidth(context),
              height: ResponsiveUtils.getScreenHeight(context),
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/f681350a809b550bf671bd4da879c2555620dd3b.jpg'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            // Gradient overlay
            Container(
              width: ResponsiveUtils.getScreenWidth(context),
              height: ResponsiveUtils.getScreenHeight(context),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black,
                  ],
                ),
              ),
            ),
            // Contenu
            Positioned(
              bottom: ResponsiveUtils.getResponsiveHeight(context, 80),
              left: ResponsiveUtils.getResponsiveWidth(context, 12),
              right: ResponsiveUtils.getResponsiveWidth(context, 12),
              child: Column(
                children: [
                  // Titre SECURELINK
                  SizedBox(
                    width: ResponsiveUtils.getResponsiveWidth(context, 406),
                    height: ResponsiveUtils.getResponsiveHeight(context, 38),
                    child: Text(
                      'SECURELINK',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Sofia Sans',
                        fontWeight: FontWeight.w700,
                        fontSize: ResponsiveUtils.getResponsiveFontSize(context, 32),
                        height: 1.0,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  SizedBox(height: ResponsiveUtils.getResponsiveHeight(context, 16)),
                  // Texte descriptif
                  SizedBox(
                    width: ResponsiveUtils.getResponsiveWidth(context, 406),
                    height: ResponsiveUtils.getResponsiveHeight(context, 56),
                    child: Text(
                      'Lorem Ipsum is simply dummy text of the printing and typesetting industry',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Sofia Sans',
                        fontWeight: FontWeight.w400,
                        fontSize: ResponsiveUtils.getResponsiveFontSize(context, 18),
                        height: 28 / 18,
                        color: Colors.white.withOpacity(0.7),
                      ),
                    ),
                  ),
                  SizedBox(height: ResponsiveUtils.getResponsiveHeight(context, 32)),
                  // Bouton Commencer
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).pushReplacementNamed(AppRoutes.login);
                    },
                    child: Container(
                      width: ResponsiveUtils.getResponsiveWidth(context, 382),
                      height: ResponsiveUtils.getResponsiveHeight(context, 64),
                      padding: EdgeInsets.symmetric(
                        horizontal: ResponsiveUtils.getResponsiveWidth(context, 24),
                        vertical: ResponsiveUtils.getResponsiveHeight(context, 16),
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0B3C5C),
                        borderRadius: BorderRadius.circular(
                          ResponsiveUtils.getResponsiveValue(context, 100),
                        ),
                      ),
                      child: Center(
                        child: Text(
                          'Commencer',
                          style: TextStyle(
                            fontFamily: 'Sofia Sans',
                            fontWeight: FontWeight.w500,
                            fontSize: ResponsiveUtils.getResponsiveFontSize(context, 18),
                            height: 1.0,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}