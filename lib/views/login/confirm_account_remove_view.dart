import 'package:flutter/material.dart';
import 'package:intraflow/services/auth/auth_service.dart';
import 'package:intraflow/utils/helpers/field_validator.dart';
import 'package:intraflow/utils/theme/custom_colors.dart';
import 'package:intraflow/widgets/custom_snack_bar.dart';

class ConfirmAccountRemoveDialog extends StatefulWidget {
  final String email;

  const ConfirmAccountRemoveDialog({
    super.key,
    required this.email,
  });

  @override
  ConfirmAccountRemoveDialogState createState() =>
      ConfirmAccountRemoveDialogState();
}

class ConfirmAccountRemoveDialogState
    extends State<ConfirmAccountRemoveDialog> {
  final AuthService _authService = AuthService();
  final TextEditingController _passwordConfirmController =
      TextEditingController();
  bool _isLoading = false;
  String? _error;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        'Deseja remover a conta com o e-mail: ${widget.email}?',
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
        textAlign: TextAlign.center,
      ),
      content: SizedBox(
        height: 200,
        child: Column(
          children: [
            const Text(
              'Para confirmar a remoção da conta, insira sua senha:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _passwordConfirmController,
              keyboardType: TextInputType.visiblePassword,
              obscureText: true,
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.lock),
                label: Text('Senha'),
              ),
              validator: (value) {
                if (value == null || value == "") {
                  return "Preencha a senha";
                }
                if (!FieldValidator.validatePassword(
                  value: value.trim(),
                )) {
                  return "Insira uma senha válida";
                }
                return null;
              },
            ),
            if (_error != null)
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: Text(
                  _error!,
                  style: const TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
              ),
          ],
        ),
      ),
      actions: [
        Container(
          decoration: BoxDecoration(
            color: CustomColors.secondaryColor,
            borderRadius: BorderRadius.circular(8),
          ),
          child: TextButton(
            onPressed: () {
              setState(() {
                _isLoading = true;
              });
              _authService
                  .removeAccount(password: _passwordConfirmController.text)
                  .then((String? erro) {
                if (erro != null) {
                  setState(() {
                    _error = erro;
                    _isLoading = false;
                  });
                } else {
                  Navigator.pop(context);
                  CustomSnackBar.showDefault(
                    context,
                    'Conta removida com sucesso!',
                  );
                  _authService.logoutUser();
                }
              });
            },
            child: _isLoading
                ? const SizedBox(
                    height: 24,
                    width: 24,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : const Text(
                    'Excluir conta',
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
          ),
        ),
      ],
    );
  }
}
