import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class CustomEmptyListText extends StatelessWidget {
  final String text;
  const CustomEmptyListText({Key? key, required this.text}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String message = 'Nenhum registro encontrado';
    switch (text) {
      case 'atuais':
        message = 'Nenhum registro disponível.';
        break;
      case 'anteriores':
        message = 'Nenhum registro encontrado anteriormente.';
        break;
      case 'semana':
        message = 'Nenhum registro lançado hoje.';
        break;
      case 'empty':
        message = message;
        break;
      default:
        break;
    }

    return Center(
      child: Column(
        children: [
          Text(
            message,
            style: const TextStyle(
              fontSize: 18,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(
            height: 16,
          ),
          SizedBox(
            height: 250,
            child: SvgPicture.asset(
              'assets/images/svgs/no_data_485156.svg',
            ),
          ),
        ],
      ),
    );
  }
}
