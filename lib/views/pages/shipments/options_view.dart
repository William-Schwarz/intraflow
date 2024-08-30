import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intraflow/models/update_item_model.dart';
import 'package:intraflow/utils/theme/custom_colors.dart';
import 'package:intraflow/views/pages/shipments/option_delete_view.dart';
import 'package:intraflow/views/pages/shipments/option_edit_view.dart';
import 'package:intraflow/widgets/custom_app_bar_bottom_sheet.dart';
import 'package:intraflow/widgets/custom_divider.dart';
import 'package:intraflow/widgets/custom_modal_bottom_sheet.dart';
import 'package:intraflow/widgets/custom_slide_right_page.dart';

class OptionsView extends StatelessWidget {
  final String titleOptionEdit;
  final String descriptionOptionEdit;

  const OptionsView({
    super.key,
    required this.titleOptionEdit,
    required this.descriptionOptionEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      children: [
        const CustomAppBarBottomSheet(),
        ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              CustomSlideRightPage(
                page: OptionEditView(
                  title: titleOptionEdit,
                  description: descriptionOptionEdit,
                ),
              ),
            ).then((value) {
              if (value != null && value is UpdateItemModel) {
                Navigator.pop(context, value.descricao);
              }
            });
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(0),
            ),
          ),
          child: showListTile(
            icon: Icons.edit,
            color: CustomColors.secondaryColor,
            title: 'Editar',
            svgPicture: 'assets/images/svgs/edit_485156.svg',
          ),
        ),
        const CustomDivider(),
        const SizedBox(
          height: 16,
        ),
        ElevatedButton(
          onPressed: () {
            showOptionDeleteBottomSheet(
              context,
            ).then((value) {
              if (value == 'deletar') {
                Navigator.pop(context, 'deletar');
              }
            });
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(0),
            ),
          ),
          child: showListTile(
            icon: Icons.delete,
            color: Colors.red,
            title: 'Deletar',
            svgPicture: 'assets/images/svgs/throw_away_f44235.svg',
          ),
        ),
        const CustomDivider(),
        const SizedBox(
          height: 32,
        ),
      ],
    );
  }
}

ListTile showListTile({
  required IconData icon,
  required Color color,
  required String title,
  required String svgPicture,
}) {
  return ListTile(
    contentPadding: EdgeInsets.zero,
    leading: Padding(
      padding: const EdgeInsets.all(8.0),
      child: Icon(
        icon,
        color: color,
        size: 32,
      ),
    ),
    title: Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        color: Colors.black,
      ),
    ),
    trailing: SizedBox(
      width: 100,
      child: SvgPicture.asset(svgPicture),
    ),
  );
}

Future<String?> showOptionsBottomSheet(
  BuildContext context,
  String titleOptionEdit,
  String descriptionOptionEdit,
) async {
  return await CustomModalBottomSheet(
    child: OptionsView(
      titleOptionEdit: titleOptionEdit,
      descriptionOptionEdit: descriptionOptionEdit,
    ),
  ).show(context);
}
