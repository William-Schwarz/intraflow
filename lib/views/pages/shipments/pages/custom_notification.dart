import 'package:flutter/material.dart';
import 'package:intraflow/services/messaging/notification_types.dart';
import 'package:intraflow/utils/helpers/app_config.dart';
import 'package:intraflow/utils/theme/custom_colors.dart';
import 'package:intraflow/widgets/custom_app_bar.dart';
import 'package:intraflow/widgets/custom_snack_bar.dart';

class CustomNotificationView extends StatefulWidget {
  const CustomNotificationView({super.key});

  @override
  State<CustomNotificationView> createState() => _CustomNotificationViewState();
}

class _CustomNotificationViewState extends State<CustomNotificationView> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _bodyController = TextEditingController();
  final _key = GlobalKey<FormState>();
  final NotificationTypes _notificationTypes = NotificationTypes();
  bool _isNotificationCancelled = false;
  bool _isSendingNotification = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Enviar Notificação',
        leadingVisible: !_isSendingNotification,
      ),
      body: Center(
        child: Container(
          width: MediaQuery.of(context).size.height *
              AppConfig().widhtMediaQueryWebPage!,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          alignment: Alignment.topCenter,
          child: SingleChildScrollView(
            child: Column(
              children: [
                _buildPreviewCard(),
                const SizedBox(height: 20),
                Container(
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
                        TextFormField(
                          controller: _titleController,
                          keyboardType: TextInputType.text,
                          maxLines: null,
                          textAlign: TextAlign.left,
                          decoration: const InputDecoration(
                            prefixIcon: Icon(
                              Icons.title,
                              color: CustomColors.secondaryColor,
                            ),
                            labelText: 'Título',
                            labelStyle: TextStyle(
                              color: Colors.black,
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "O título deve ser preenchido.";
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 40),
                        TextFormField(
                          controller: _bodyController,
                          keyboardType: TextInputType.text,
                          maxLines: null,
                          textAlign: TextAlign.left,
                          decoration: const InputDecoration(
                            prefixIcon: Icon(
                              Icons.edit_notifications,
                              color: CustomColors.secondaryColor,
                            ),
                            labelText: 'Corpo',
                            labelStyle: TextStyle(
                              color: Colors.black,
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "O corpo deve ser preenchido.";
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 56),
                        ElevatedButton(
                          onPressed: _send,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: CustomColors.secondaryColor,
                          ),
                          child: const Text(
                            'Enviar',
                            style: TextStyle(
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPreviewCard() {
    return ValueListenableBuilder(
      valueListenable: _titleController,
      builder: (context, title, _) {
        return ValueListenableBuilder(
          valueListenable: _bodyController,
          builder: (context, body, _) {
            return Container(
              width: 300,
              margin: const EdgeInsets.only(top: 20),
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    spreadRadius: 1,
                    blurRadius: 5,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.notifications,
                          color: CustomColors.secondaryColor),
                      SizedBox(width: 8),
                      Text(
                        'App Name',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Spacer(),
                      Text(
                        'Agora',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _titleController.text.isEmpty
                        ? 'Título da Notificação'
                        : _titleController.text,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _bodyController.text.isEmpty
                        ? 'Corpo da Notificação'
                        : _bodyController.text,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _send() async {
    if (_isSendingNotification) {
      return;
    }

    if (_key.currentState?.validate() ?? false) {
      String title = _titleController.text;
      String body = _bodyController.text;

      setState(() {
        _isNotificationCancelled = false;
        _isSendingNotification = true;
      });

      void showCancelSnackbar() {
        ScaffoldMessenger.of(context).clearSnackBars();
        CustomSnackBar.showDefault(
          context,
          'Envio da notificação cancelado.',
        );
        setState(() {
          _isSendingNotification = false;
        });
      }

      ScaffoldMessenger.of(context).clearSnackBars();
      CustomSnackBar.showWithUndo(
        context,
        'Enviando notificação...',
        () {
          setState(() {
            _isNotificationCancelled = true;
          });

          showCancelSnackbar();
        },
      );

      await Future.delayed(const Duration(seconds: 5)).then((value) {
        if (!_isNotificationCancelled) {
          _notificationTypes.newCustomNotification(title: title, body: body);
          ScaffoldMessenger.of(context).clearSnackBars();
          CustomSnackBar.showDefault(
            context,
            'Notificação enviada com sucesso!',
          );
        }

        _titleController.clear();
        _bodyController.clear();
      });

      setState(() {
        _isSendingNotification = false;
      });
    }
  }
}
