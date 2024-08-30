import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intraflow/routes/page_routes.dart';
import 'package:intraflow/services/local/local_auth_service.dart';
import 'package:intraflow/utils/theme/custom_colors.dart';
import 'package:intraflow/widgets/custom_slider_center_page.dart';
import 'package:intraflow/widgets/custom_snack_bar.dart';
import 'package:local_auth/error_codes.dart' as auth_error;

class LocalAuthView extends StatefulWidget {
  const LocalAuthView({super.key});

  @override
  LocalAuthViewState createState() => LocalAuthViewState();
}

class LocalAuthViewState extends State<LocalAuthView> {
  final LocalAuthService _localAuthService = LocalAuthService();

  @override
  void initState() {
    super.initState();
    _checkSupportAndAuthenticate();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          children: [
            const Spacer(),
            SizedBox(
              height: 200,
              child: Image.asset(
                'assets/images/logos/K1_logo_cinza.png',
              ),
            ),
            const Spacer(),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                elevation: 5,
                backgroundColor: CustomColors.secondaryColor,
                padding: const EdgeInsets.all(25.0),
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(
                    Radius.circular(12.0),
                  ),
                ),
              ),
              onPressed: _authenticate,
              child: const Text(
                'Usar senha do celular',
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(
              height: 20,
            )
          ],
        ),
      ),
    );
  }

  Future<void> _checkSupportAndAuthenticate() async {
    try {
      // Verifica se há suporte para biometria ou qualquer outro tipo de autenticação
      bool supportAvailable =
          await _localAuthService.hasSupport(biometricOnly: false);

      if (supportAvailable) {
        // Se há suporte, tente autenticar
        await _authenticate();
      } else {
        // Se não há suporte, navegue para a PageRoutes
        if (mounted) {
          Navigator.push(
            context,
            CustomSlideCenterPage(
              page: const PageRoutes(),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        Navigator.push(
          context,
          CustomSlideCenterPage(
            page: const PageRoutes(),
          ),
        );
      }
    }
  }

  Future<void> _authenticate() async {
    try {
      final bool isAuthenticated = await _localAuthService.authenticate(
        message: 'Por favor, realize a autenticação',
        biometricOnly: false,
      );

      if (mounted) {
        if (!isAuthenticated) {
          ScaffoldMessenger.of(context).clearSnackBars();
          CustomSnackBar.showDefault(
            context,
            'Autenticação não reconhecida',
          );
        } else {
          // Se o usuário estiver autenticado, navegue para PageRoutes
          Navigator.push(
            context,
            CustomSlideCenterPage(
              page: const PageRoutes(),
            ),
          );
        }
      }
    } on PlatformException catch (err) {
      // Verifique erros específicos de autenticação
      if (mounted) {
        if (err.code == auth_error.notAvailable ||
            err.code == auth_error.notEnrolled) {
          // Se não há biometria cadastrada, navegue para PageRoutes
          Navigator.push(
            context,
            CustomSlideCenterPage(
              page: const PageRoutes(),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).clearSnackBars();
          CustomSnackBar.showDefault(
            context,
            'Erro ao realizar autenticação: ${err.message}',
          );
        }
      }
    } catch (e) {
      // Trate outros erros que possam ocorrer
      if (mounted) {
        ScaffoldMessenger.of(context).clearSnackBars();
        CustomSnackBar.showDefault(
          context,
          'Erro desconhecido ao autenticar: $e',
        );
      }
    }
  }
}
