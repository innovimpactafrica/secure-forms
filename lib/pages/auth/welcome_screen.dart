import 'package:flutter/material.dart';
import '../../utils/app_routes.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox(
        width: 430,
        height: 932,
        child: Stack(
          children: [
            // Image de fond
            Container(
              width: 430,
              height: 932,
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/f681350a809b550bf671bd4da879c2555620dd3b.jpg'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            // Gradient overlay
            Container(
              width: 430,
              height: 932,
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
              bottom: 80,
              left: 12,
              right: 12,
              child: Column(
                children: [
                  // Titre SECURELINK
                  SizedBox(
                    width: 406,
                    height: 38,
                    child: Text(
                      'SECURELINK',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Sofia Sans',
                        fontWeight: FontWeight.w700,
                        fontSize: 32,
                        height: 1.0,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Texte descriptif
                  SizedBox(
                    width: 406,
                    height: 56,
                    child: Text(
                      'Lorem Ipsum is simply dummy text of the printing and typesetting industry',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Sofia Sans',
                        fontWeight: FontWeight.w400,
                        fontSize: 18,
                        height: 28 / 18,
                        color: Colors.white.withOpacity(0.7),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  // Bouton Commencer
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).pushReplacementNamed(AppRoutes.login);
                    },
                    child: Container(
                      width: 382,
                      height: 64,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0B3C5C),
                        borderRadius: BorderRadius.circular(100),
                      ),
                      child: const Center(
                        child: Text(
                          'Commencer',
                          style: TextStyle(
                            fontFamily: 'Sofia Sans',
                            fontWeight: FontWeight.w500,
                            fontSize: 18,
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