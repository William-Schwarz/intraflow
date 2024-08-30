import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class NetworkingFailedView extends StatelessWidget {
  const NetworkingFailedView({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    height: 250,
                    child: SvgPicture.asset(
                      'assets/images/svgs/connected_world_ef7239.svg',
                    ),
                  ),
                  const SizedBox(
                    height: 16,
                  ),
                  const CircularProgressIndicator(),
                  const SizedBox(
                    height: 16,
                  ),
                  const Text(
                    'Sem conexão de internet',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(
                    height: 8,
                  ),
                  const Text(
                    'Por favor, verifique sua conexão com a internet e tente novamente.',
                    style: TextStyle(
                      fontSize: 16,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
