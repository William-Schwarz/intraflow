import 'package:flutter/material.dart';
import 'package:intraflow/services/auth/auth_service.dart';
import 'package:intraflow/utils/helpers/field_validator.dart';
import 'package:intraflow/utils/theme/custom_colors.dart';
import 'package:intraflow/widgets/custom_app_bar_bottom_sheet.dart';
import 'package:intraflow/widgets/custom_modal_bottom_sheet.dart';
import 'package:intraflow/widgets/custom_snack_bar.dart';

class ForgetPasswordView extends StatefulWidget {
  final String email;

  const ForgetPasswordView({
    required this.email,
    super.key,
  });

  @override
  ForgetPasswordViewState createState() => ForgetPasswordViewState();
}

class ForgetPasswordViewState extends State<ForgetPasswordView> {
  final AuthService _authService = AuthService();
  late TextEditingController _resetPasswordController;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _resetPasswordController = TextEditingController(text: widget.email);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _resetPasswordController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBarBottomSheet(),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 36),
          child: Column(
            children: [
              const Text(
                'Confirme o e-mail para redefinir a senha',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(
                height: 16,
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: TextFormField(
                  controller: _resetPasswordController,
                  focusNode: _focusNode,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(
                      Icons.email,
                      color: CustomColors.secondaryColor,
                    ),
                    labelText: "E-mail",
                    labelStyle: TextStyle(
                      color: Colors.black,
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value == "") {
                      return "O e-mail deve ser preenchido";
                    }
                    if (!FieldValidator.validateEmail(
                      value: value.trim(),
                    )) {
                      return "Insira um e-mail válido";
                    }
                    return null;
                  },
                ),
                trailing: IconButton(
                  onPressed: () async {
                    await _authService.resetPassword(email: _resetPasswordController.text).then((String? value) {
                      if (value == null) {
                        ScaffoldMessenger.of(context).clearSnackBars();
                        CustomSnackBar.showDefault(
                          context,
                          'E-mail para redefinição de senha enviado!',
                        );
                      }
                    });
                  },
                  icon: const Icon(
                    Icons.send_rounded,
                    size: 32,
                    color: CustomColors.secondaryColor,
                  ),
                ),
              ),
              const SizedBox(
                height: 36,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Future<String?> showForgetPasswordBottomSheet(
  BuildContext context,
  String email,
) async {
  return await CustomModalBottomSheet(
    child: ForgetPasswordView(
      email: email,
    ),
  ).show(context);
}
