import 'package:flutter/material.dart';
import 'package:intraflow/utils/theme/custom_colors.dart';
import 'package:intraflow/widgets/custom_app_bar_bottom_sheet.dart';
import 'package:intraflow/widgets/custom_modal_bottom_sheet.dart';
import 'package:intraflow/widgets/custom_text_field.dart';

class OptionEditDescriptionView extends StatefulWidget {
  final String description;

  const OptionEditDescriptionView({
    super.key,
    required this.description,
  });

  @override
  OptionEditDescriptionViewState createState() =>
      OptionEditDescriptionViewState();
}

class OptionEditDescriptionViewState extends State<OptionEditDescriptionView> {
  late TextEditingController _descriptionController;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _descriptionController = TextEditingController(text: widget.description);
    _descriptionController.selection = TextSelection.fromPosition(
      TextPosition(offset: _descriptionController.text.length),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });

    _descriptionController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBarBottomSheet(),
      body: Padding(
        padding: const EdgeInsets.only(
          left: 24,
          right: 24,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Qual descrição você quer dar?',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Text(
                'Você pode colocar uma descrição que identifique o tema relacionado.',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                ),
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: CustomTextField(
                  controller: _descriptionController,
                  focusNode: _focusNode,
                  labelText: '',
                  hintText: '',
                  maxLength: 50,
                ),
                trailing: IconButton(
                  onPressed: () {
                    Navigator.pop(context, _descriptionController.text.trim());
                  },
                  icon: const Icon(
                    Icons.send_rounded,
                    size: 32,
                    color: CustomColors.secondaryColor,
                  ),
                ),
              ),
              const SizedBox(
                height: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Future<String?> showOptionEditDescriptionBottomSheet(
  BuildContext context,
  String description,
) async {
  return await CustomModalBottomSheet(
    child: OptionEditDescriptionView(
      description: description,
    ),
  ).show(context);
}
