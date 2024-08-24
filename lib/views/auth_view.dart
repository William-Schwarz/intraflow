import 'package:flutter/material.dart';
import 'package:intraflow/services/auth/auth_service.dart';
import 'package:intraflow/utils/helpers/app_config.dart';
import 'package:intraflow/utils/helpers/field_validator.dart';
import 'package:intraflow/utils/theme/custom_colors.dart';
import 'package:intraflow/views/forget_password_view.dart';
import 'package:intraflow/widgets/custom_snack_bar.dart';

class AuthView extends StatefulWidget {
  const AuthView({super.key});

  @override
  State<AuthView> createState() => _AuthViewState();
}

class _AuthViewState extends State<AuthView> {
  final _key = GlobalKey<FormState>();
  final AuthService _authService = AuthService();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  bool _isEnter = true;
  bool _passwordObscureText = true;
  bool _passwordConfirmObscureText = true;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Container(
              width: MediaQuery.of(context).size.height * AppConfig().widhtMediaQueryWebPageLogin!,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
              ),
              padding: const EdgeInsets.all(8),
              child: Form(
                key: _key,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(
                      height: 200,
                      child: Image.asset('assets/images/endomarketing.png'),
                    ),
                    const SizedBox(
                      height: 8,
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        (_isEnter) ? "Bem vindo ao IntraFlow!" : "Vamos começar?",
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 8,
                    ),
                    Text(
                      (_isEnter) ? "Faça login para acessar." : "Faça seu cadastro para começar a usar o IntraFlow.",
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.black,
                      ),
                    ),
                    TextFormField(
                      controller: _emailController,
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
                    TextFormField(
                      controller: _passwordController,
                      keyboardType: TextInputType.visiblePassword,
                      obscureText: _passwordObscureText,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(
                          Icons.lock,
                          color: CustomColors.secondaryColor,
                        ),
                        suffixIcon: IconButton(
                          onPressed: () {
                            setState(() {
                              _passwordObscureText = !_passwordObscureText;
                            });
                          },
                          icon: Icon(
                            _passwordObscureText ? Icons.visibility_off : Icons.visibility,
                            color: CustomColors.secondaryColor,
                          ),
                        ),
                        labelText: "Senha",
                        labelStyle: const TextStyle(
                          color: Colors.black,
                        ),
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
                    Visibility(
                      visible: _isEnter,
                      child: TextButton(
                        onPressed: () {
                          showForgetPasswordBottomSheet(
                            context,
                            _emailController.text,
                          );
                        },
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(
                              "Esqueci minha senha.",
                              style: TextStyle(
                                fontSize: 12,
                                color: CustomColors.primaryColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Visibility(
                      visible: !_isEnter,
                      child: Column(
                        children: [
                          TextFormField(
                            controller: _confirmController,
                            keyboardType: TextInputType.visiblePassword,
                            obscureText: _passwordConfirmObscureText,
                            decoration: InputDecoration(
                              prefixIcon: const Icon(
                                Icons.lock,
                                color: CustomColors.secondaryColor,
                              ),
                              suffixIcon: IconButton(
                                onPressed: () {
                                  setState(() {
                                    _passwordConfirmObscureText = !_passwordConfirmObscureText;
                                  });
                                },
                                icon: Icon(
                                  _passwordConfirmObscureText ? Icons.visibility_off : Icons.visibility,
                                  color: CustomColors.secondaryColor,
                                ),
                              ),
                              labelText: "Confirme a senha",
                              labelStyle: const TextStyle(
                                color: Colors.black,
                              ),
                            ),
                            validator: (value) {
                              if (value != _passwordController.text) {
                                return "As senhas devem ser iguais.";
                              }
                              if (value == null || value == "") {
                                return "Preencha a confirmação da senha";
                              }
                              if (!FieldValidator.validatePassword(
                                value: value.trim(),
                              )) {
                                return "Insira uma senha válida";
                              }
                              return null;
                            },
                          ),
                          TextFormField(
                            controller: _nameController,
                            keyboardType: TextInputType.name,
                            decoration: const InputDecoration(
                              prefixIcon: Icon(
                                Icons.edit,
                                color: CustomColors.secondaryColor,
                              ),
                              labelText: "Nome",
                              labelStyle: TextStyle(
                                color: Colors.black,
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "Insira seu nome.";
                              }
                              if (!FieldValidator.validateName(
                                value: value.trim(),
                              )) {
                                return "Insira seu nome e sobrenome.";
                              }
                              return null;
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 16,
                    ),
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
                      onPressed: () {
                        _loginRegisterButtonClick();
                      },
                      child: _isLoading
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                              ),
                            )
                          : Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                              child: Text(
                                (_isEnter) ? "Entrar" : "Cadastrar",
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                    ),
                    const SizedBox(
                      height: 8,
                    ),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _isEnter = !_isEnter;
                        });
                      },
                      child: Text(
                        (_isEnter)
                            ? "Ainda não tem uma conta?\nClique aqui para cadastrar."
                            : "Já tem uma conta?\nClique aqui para entrar",
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 12,
                          color: CustomColors.primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 8,
                    ),
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        // Version(),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _loginRegisterButtonClick() async {
    String email = _emailController.text;
    String password = _passwordController.text;
    String name = _nameController.text;

    if (_key.currentState!.validate()) {
      if (_isEnter) {
        _loginUser(email: email, password: password);
      } else {
        _regiterUser(
          email: email,
          password: password,
          name: name,
        );
      }
    }
  }

  Future<void> _loginUser({
    required String email,
    required String password,
  }) async {
    setState(() {
      _isLoading = true;
    });
    await _authService
        .loginUser(
      email: email,
      password: password,
    )
        .then((String? error) {
      if (error != null) {
        if (mounted) {
          ScaffoldMessenger.of(context).clearSnackBars();
          CustomSnackBar.showDefault(
            context,
            error,
          );
          setState(() {
            _isLoading = false;
          });
        }
      }
    }).whenComplete(
      () => setState(() {
        _isLoading = false;
      }),
    );
  }

  Future<void> _regiterUser({
    required String email,
    required String password,
    required String name,
  }) async {
    setState(() {
      _isLoading = true;
    });
    await _authService
        .registerUser(
      email: email,
      password: password,
      name: name,
    )
        .then(
      (String? error) {
        if (error != null) {
          if (mounted) {
            ScaffoldMessenger.of(context).clearSnackBars();
            CustomSnackBar.showDefault(
              context,
              error,
            );
            setState(() {
              _isLoading = false;
            });
          }
        }
      },
    ).whenComplete(
      () => setState(() {
        _isLoading = false;
      }),
    );
  }
}
