import 'package:flutter/material.dart';
import 'package:intraflow/utils/theme/custom_colors.dart';
import 'package:intraflow/widgets/custom_app_bar_bottom_sheet.dart';
import 'package:intraflow/widgets/custom_modal_bottom_sheet.dart';

class OptionDeleteView extends StatelessWidget {
  const OptionDeleteView({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      children: [
        const CustomAppBarBottomSheet(),
        Padding(
          padding: const EdgeInsets.only(
            left: 24,
            right: 24,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Quer mesmo deletar?',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Text(
                'Ao deletar, será preciso lançar novamente',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                ),
              ),
              const SizedBox(
                height: 32,
              ),
              Center(
                child: Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context, 'deletar');
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red[400],
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(32),
                          ),
                        ),
                        child: const Padding(
                          padding: EdgeInsets.only(
                            top: 8,
                            bottom: 8,
                          ),
                          child: Text(
                            'Deletar',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 8,
                    ),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: CustomColors.secondaryColor,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(32),
                          ),
                        ),
                        child: const Padding(
                          padding: EdgeInsets.only(
                            top: 8,
                            bottom: 8,
                          ),
                          child: Text(
                            'Manter',
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
              const SizedBox(
                height: 32,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

Future<String?> showOptionDeleteBottomSheet(
  BuildContext context,
) async {
  return await const CustomModalBottomSheet(
    child: OptionDeleteView(),
  ).show(context);
}
