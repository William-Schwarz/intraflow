import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intraflow/controllers/menus_reviews_controller.dart';
import 'package:intraflow/utils/theme/custom_colors.dart';
import 'package:intraflow/widgets/custom_app_bar_bottom_sheet.dart';
import 'package:intraflow/widgets/custom_modal_bottom_sheet.dart';
import 'package:intraflow/widgets/custom_snack_bar.dart';
import 'package:intraflow/widgets/custom_text_field.dart';
import 'package:intraflow/widgets/custom_warning_messaging.dart';

class AvaluateMenu extends StatefulWidget {
  final String idMenu;
  final String descriptionMenu;

  const AvaluateMenu({
    super.key,
    required this.descriptionMenu,
    required this.idMenu,
  });

  @override
  AvaluateMenuState createState() => AvaluateMenuState();
}

class AvaluateMenuState extends State<AvaluateMenu> {
  final MenusReviewsController _menusReviewsController =
      MenusReviewsController();
  late int _rating = 0;
  late String _comment = '';

  @override
  Widget build(BuildContext context) {
    return Wrap(
      children: [
        const CustomAppBarBottomSheet(),
        SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.only(
              right: 16,
              left: 16,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: SizedBox(
                    height: 250,
                    width: 250,
                    child: SvgPicture.asset(
                      'assets/images/svgs/feedback_485156.svg',
                    ),
                  ),
                ),
                const SizedBox(
                  height: 16,
                ),
                Center(
                  child: Text(
                    widget.descriptionMenu,
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 24,
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: Icon(
                        Icons.star,
                        color: _rating >= 1 ? Colors.orange : Colors.grey,
                      ),
                      onPressed: () => setState(() => _rating = 1),
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.star,
                        color: _rating >= 2 ? Colors.orange : Colors.grey,
                      ),
                      onPressed: () => setState(() => _rating = 2),
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.star,
                        color: _rating >= 3 ? Colors.orange : Colors.grey,
                      ),
                      onPressed: () => setState(() => _rating = 3),
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.star,
                        color: _rating >= 4 ? Colors.orange : Colors.grey,
                      ),
                      onPressed: () => setState(() => _rating = 4),
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.star,
                        color: _rating >= 5 ? Colors.orange : Colors.grey,
                      ),
                      onPressed: () => setState(() => _rating = 5),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 20,
                ),
                ListTile(
                  title: CustomTextField(
                    onChanged: (value) => _comment = value,
                    labelText: 'Comentário (opcional)',
                    hintText: 'Ex: estava ótimo',
                    maxLength: 80,
                  ),
                  trailing: IconButton(
                    onPressed: () {
                      BuildContext currentContext = context;
                      _menusReviewsController
                          .postMenusReviews(
                        idCardapio: widget.idMenu,
                        nota: _rating,
                        comentario: _comment,
                      )
                          .then((errorMessage) {
                        if (errorMessage == null) {
                          ScaffoldMessenger.of(currentContext).clearSnackBars();
                          CustomSnackBar.showDefault(
                            currentContext,
                            'Avaliação enviada com sucesso!',
                          );
                          Navigator.of(currentContext).pop();
                        } else {
                          CustomWarningMessaging.showWarningDialog(
                            currentContext,
                            errorMessage,
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
                  height: 16,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(child: Container()),
                    Container(
                      padding: const EdgeInsets.only(left: 10, right: 10),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: CustomColors.secondaryColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

Future<String?> showAvaliarCardapioBottomSheet(
  BuildContext context,
  String descriptionMenu,
  String idMenu,
) async {
  return await CustomModalBottomSheet(
    child: AvaluateMenu(
      descriptionMenu: descriptionMenu,
      idMenu: idMenu,
    ),
  ).show(context);
}
