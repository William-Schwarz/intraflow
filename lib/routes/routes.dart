import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intraflow/routes/page_routes.dart';
import 'package:intraflow/views/login/auth_view.dart';
import 'package:intraflow/views/login/email_verification_view.dart';
import 'package:intraflow/views/login/local_auth_view.dart';
import 'package:intraflow/views/pages/menus_reviews_view.dart';
import 'package:intraflow/views/pages/menus_scheduling_view.dart';
import 'package:intraflow/views/pages/shipments/pages/custom_notification.dart';
import 'package:intraflow/views/pages/shipments/pages/lpgd/upload_lgpd_view.dart';
import 'package:intraflow/views/pages/shipments/pages/upldoad_menus_view.dart';
import 'package:intraflow/views/pages/shipments/pages/upload_announcements_view.dart';
import 'package:intraflow/views/pages/shipments/pages/upload_code_ethics_view.dart';
import 'package:intraflow/views/pages/shipments/pages/upload_events_view.dart';
import 'package:intraflow/views/pages/shipments/pages/upload_magazines_view.dart';
import 'package:intraflow/views/users/user_images_view.dart';
import 'package:intraflow/views/users/users_view.dart';

final GoRouter router = GoRouter(
  routes: <RouteBase>[
    GoRoute(
      path: '/',
      builder: (BuildContext context, GoRouterState state) {
        return !kIsWeb ? const LocalAuthView() : const PageRoutes();
      },
      routes: <RouteBase>[
        GoRoute(
          path: 'entrar',
          builder: (BuildContext context, GoRouterState state) {
            return const AuthView();
          },
        ),
        GoRoute(
          path: 'verificacao-de-email',
          builder: (BuildContext context, GoRouterState state) {
            return const EmailVerificationView();
          },
        ),
        GoRoute(
          path: 'editar-perfil',
          pageBuilder: (context, state) {
            return CustomTransitionPage(
              child: const UserImagesView(),
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) {
                return SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(-1, 0),
                    end: Offset.zero,
                  ).animate(CurvedAnimation(
                    parent: animation,
                    curve: Curves.easeInOut,
                  )),
                  child: child,
                );
              },
            );
          },
        ),
        GoRoute(
          path: 'usuarios',
          pageBuilder: (context, state) {
            return CustomTransitionPage(
              child: const UsersView(),
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) {
                return SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(-1, 0),
                    end: Offset.zero,
                  ).animate(CurvedAnimation(
                    parent: animation,
                    curve: Curves.easeInOut,
                  )),
                  child: child,
                );
              },
            );
          },
        ),
        GoRoute(
          path: 'enviar/evento',
          pageBuilder: (context, state) {
            return CustomTransitionPage(
              child: const UploadEvents(),
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) {
                return SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, 1),
                    end: Offset.zero,
                  ).animate(CurvedAnimation(
                    parent: animation,
                    curve: Curves.easeInOut,
                  )),
                  child: child,
                );
              },
            );
          },
        ),
        GoRoute(
          path: 'enviar/cardapio',
          pageBuilder: (context, state) {
            return CustomTransitionPage(
              child: const UploadMenus(),
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) {
                return SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, 1),
                    end: Offset.zero,
                  ).animate(CurvedAnimation(
                    parent: animation,
                    curve: Curves.easeInOut,
                  )),
                  child: child,
                );
              },
            );
          },
        ),
        GoRoute(
          path: 'enviar/comunicado',
          pageBuilder: (context, state) {
            return CustomTransitionPage(
              child: const UploadAnnouncements(),
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) {
                return SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, 1),
                    end: Offset.zero,
                  ).animate(CurvedAnimation(
                    parent: animation,
                    curve: Curves.easeInOut,
                  )),
                  child: child,
                );
              },
            );
          },
        ),
        GoRoute(
          path: 'enviar/revista',
          pageBuilder: (context, state) {
            return CustomTransitionPage(
              child: const UploadMagazinesView(),
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) {
                return SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, 1),
                    end: Offset.zero,
                  ).animate(CurvedAnimation(
                    parent: animation,
                    curve: Curves.easeInOut,
                  )),
                  child: child,
                );
              },
            );
          },
        ),
        GoRoute(
          path: 'enviar/privacidade-e-seguranca',
          pageBuilder: (context, state) {
            return CustomTransitionPage(
              child: const UploadLGPD(),
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) {
                return SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, 1),
                    end: Offset.zero,
                  ).animate(CurvedAnimation(
                    parent: animation,
                    curve: Curves.easeInOut,
                  )),
                  child: child,
                );
              },
            );
          },
        ),
        GoRoute(
          path: 'enviar/codigo-de-etica',
          pageBuilder: (context, state) {
            return CustomTransitionPage(
              child: const UploadCodeEthics(),
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) {
                return SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, 1),
                    end: Offset.zero,
                  ).animate(CurvedAnimation(
                    parent: animation,
                    curve: Curves.easeInOut,
                  )),
                  child: child,
                );
              },
            );
          },
        ),
        GoRoute(
          path: 'enviar/notificacao-personalizada',
          pageBuilder: (context, state) {
            return CustomTransitionPage(
              child: const CustomNotificationView(),
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) {
                return SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, 1),
                    end: Offset.zero,
                  ).animate(CurvedAnimation(
                    parent: animation,
                    curve: Curves.easeInOut,
                  )),
                  child: child,
                );
              },
            );
          },
        ),
        GoRoute(
          path: 'avaliacoes',
          pageBuilder: (context, state) {
            return CustomTransitionPage(
              child: const MenusReviewsView(),
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) {
                return SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(-1, 0),
                    end: Offset.zero,
                  ).animate(CurvedAnimation(
                    parent: animation,
                    curve: Curves.easeInOut,
                  )),
                  child: child,
                );
              },
            );
          },
        ),
        GoRoute(
          path: 'agendamentos',
          pageBuilder: (context, state) {
            return CustomTransitionPage(
              child: const MenusSchedulingsView(),
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) {
                return SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(-1, 0),
                    end: Offset.zero,
                  ).animate(CurvedAnimation(
                    parent: animation,
                    curve: Curves.easeInOut,
                  )),
                  child: child,
                );
              },
            );
          },
        ),
      ],
    ),
  ],
);
