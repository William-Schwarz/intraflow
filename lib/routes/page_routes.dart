import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import 'package:intraflow/views/home_view.dart';
import 'package:intraflow/widgets/custom_loading_splash_screen.dart';

class PageRoutes extends StatelessWidget {
  const PageRoutes({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CustomLoadingSplashscreen();
        } else if (snapshot.hasData) {
          final User user = snapshot.data!;
          // Verifica se o email foi verificado
          if (!user.emailVerified) {
            // Navega para a página de verificação de email se ainda não for verificado
            WidgetsBinding.instance.addPostFrameCallback((_) {
              GoRouter.of(context).go('/verificacao-de-email');
            });
            return const SizedBox
                .shrink(); // Retorna um widget vazio enquanto navega
          }
          // Navega para a página inicial se o email já estiver verificado
          WidgetsBinding.instance.addPostFrameCallback((_) {
            GoRouter.of(context).go('/');
          });
          return const HomeView(); // Mostra a página inicial enquanto navega
        } else {
          // Navega para a página de login se não houver usuário
          WidgetsBinding.instance.addPostFrameCallback((_) {
            GoRouter.of(context).go('/entrar');
          });
          return const SizedBox
              .shrink(); // Retorna um widget vazio enquanto navega
        }
      },
    );
  }
}
