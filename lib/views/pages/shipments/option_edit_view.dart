import 'package:flutter/material.dart';
import 'package:intraflow/models/update_item_model.dart';
import 'package:intraflow/utils/helpers/app_config.dart';
import 'package:intraflow/utils/theme/custom_colors.dart';
import 'package:intraflow/views/pages/shipments/option_edit_description_view.dart';
import 'package:intraflow/widgets/custom_app_bar.dart';

class OptionEditView extends StatefulWidget {
  final String title;
  final String description;
  const OptionEditView({
    super.key,
    required this.title,
    required this.description,
  });

  @override
  State<OptionEditView> createState() => _OptionEditViewState();
}

class _OptionEditViewState extends State<OptionEditView> {
  late String _descricao;
  late String _originalDescricao;
  bool enableButton = false;

  @override
  void initState() {
    super.initState();
    _descricao = widget.description;
    _originalDescricao = widget.description;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Editando..',
        leadingVisible: true,
      ),
      body: Center(
        child: Container(
          width: MediaQuery.of(context).size.height *
              AppConfig().widhtMediaQueryWebPage!,
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.title,
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      showListTile(
                        icon: Icons.edit,
                        title: 'Descrição',
                        subtitle: _descricao,
                        onPressed: () {
                          showOptionEditDescriptionBottomSheet(
                            context,
                            _descricao,
                          ).then(
                            (value) {
                              if (value == _originalDescricao) {
                                setState(() {
                                  _descricao = _originalDescricao;
                                  enableButton = false;
                                });
                              } else if (value != null) {
                                setState(() {
                                  _descricao = value;
                                  enableButton = true;
                                });
                              }
                            },
                          );
                        },
                        enabled: true,
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: enableButton
                      ? () {
                          Navigator.pop(
                            context,
                            UpdateItemModel(_descricao),
                          );
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: CustomColors.secondaryColor,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(32),
                    ),
                  ),
                  child: const Padding(
                    padding: EdgeInsets.only(top: 12, bottom: 12),
                    child: Text(
                      'Alterar',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  ListTile showListTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onPressed,
    required bool enabled,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        decoration: BoxDecoration(
          color: CustomColors.tertiaryColor,
          borderRadius: BorderRadius.circular(60),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Icon(
            icon,
            color: CustomColors.secondaryColor,
            size: 32,
          ),
        ),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          color: Colors.black,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
      ),
      trailing: ElevatedButton(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: enabled
              ? CustomColors.secondaryColor
              : CustomColors.secondaryColor.withOpacity(0.6),
        ),
        onPressed: onPressed,
        child: const Text(
          'Alterar',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
