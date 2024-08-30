import 'package:flutter/material.dart';
import 'package:intraflow/utils/helpers/formatting.dart';
import 'package:intraflow/utils/theme/custom_colors.dart';
import 'package:intraflow/views/pages/menus/avaluate_menu.dart';
import 'package:intraflow/widgets/custom_empty_list_text.dart';
import 'package:intraflow/widgets/custom_gestor_detector_list.dart';
import 'package:intraflow/widgets/custom_image_thumb_list.dart';
import 'package:intraflow/widgets/custom_list_view.dart';
import 'package:intraflow/widgets/custom_slidable.dart';

class ListViewMenusPrevious<T> extends StatefulWidget {
  final Future<List<T>> dataFuture;
  final Function(dynamic) itemConverter;
  final bool enableSlidable;

  const ListViewMenusPrevious({
    super.key,
    required this.dataFuture,
    required this.itemConverter,
    required this.enableSlidable,
  });

  @override
  ListViewMenusPreviousState<T> createState() =>
      ListViewMenusPreviousState<T>();
}

class ListViewMenusPreviousState<T> extends State<ListViewMenusPrevious<T>> {
  @override
  void initState() {
    super.initState();
    widget.dataFuture.then((data) {
      data = data;
      return data;
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<T>>(
      future: widget.dataFuture,
      builder: (BuildContext context, AsyncSnapshot<List<T>> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const LinearProgressIndicator();
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else {
          List<T> data = snapshot.data!;

          if (data.isEmpty) {
            return const CustomEmptyListText(text: 'empty');
          }

          return CustomListView(
            itemCount: data.length,
            itemBuilder: (BuildContext context, int index) {
              final item = data[index];
              final convertedItem = widget.itemConverter(item);

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: CustomSlidable(
                  enable: widget.enableSlidable,
                  onPressed: (BuildContext context) {
                    showAvaliarCardapioBottomSheet(
                        context, convertedItem.descricao, convertedItem.id);
                  },
                  icon: Icons.addchart,
                  label: 'Avaliar',
                  child: ExpansionTile(
                    backgroundColor:
                        CustomColors.secondaryColor.withOpacity(0.2),
                    collapsedBackgroundColor:
                        CustomColors.tertiaryColor.withOpacity(0.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    collapsedShape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    tilePadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                    ),
                    title: Text(
                      convertedItem.descricao,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    subtitle: Text(
                      '${Formatter.formatDate(convertedItem.dataInicial)} até ${Formatter.formatDate(convertedItem.dataFinal)}',
                      style: const TextStyle(
                        fontSize: 12,
                      ),
                    ),
                    trailing: Text(
                      Formatter.formatDate(convertedItem.data),
                      style: const TextStyle(
                        color: Colors.black,
                      ),
                    ),
                    children: [
                      for (var i = 0; i < convertedItem.imagemURL.length; i++)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: CustomGestureDetectorList(
                            imagePath: convertedItem.imagemURL[i],
                            child: Column(
                              children: [
                                ListTile(
                                  title: SizedBox(
                                    width: 50,
                                    height: 50,
                                    child: CustomImageThumbList(
                                      thumbURL: convertedItem.thumbURL[i],
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
              );
            },
          );
        }
      },
    );
  }
}
