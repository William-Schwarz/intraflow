import 'package:flutter/material.dart';
import 'package:intraflow/utils/helpers/formatting.dart';
import 'package:intraflow/utils/theme/custom_colors.dart';
import 'package:intraflow/views/pages/shipments/options_view.dart';
import 'package:intraflow/widgets/custom_empty_list_text.dart';
import 'package:intraflow/widgets/custom_gestor_detector_list.dart';
import 'package:intraflow/widgets/custom_image_thumb_list.dart';
import 'package:intraflow/widgets/custom_list_view.dart';
import 'package:intraflow/widgets/custom_slidable.dart';
import 'package:intraflow/widgets/custom_snack_bar.dart';
import 'package:intraflow/widgets/custom_warning_messaging.dart';

class ListViewMenusWeek<T> extends StatefulWidget {
  final Future<List<T>> dataFuture;
  final Function(dynamic) itemConverter;
  final Function(String, String) updateItem;
  final Function(String) deleteItem;
  final String route;
  final String titleOptionEdit;

  const ListViewMenusWeek({
    super.key,
    required this.dataFuture,
    required this.itemConverter,
    required this.updateItem,
    required this.deleteItem,
    required this.route,
    required this.titleOptionEdit,
  });

  @override
  ListViewMenusWeekState<T> createState() => ListViewMenusWeekState<T>();
}

class ListViewMenusWeekState<T> extends State<ListViewMenusWeek<T>> {
  List<T> _data = [];
  late BuildContext _currentContext;

  @override
  void initState() {
    super.initState();
    widget.dataFuture.then((data) {
      _data = data;
      return data;
    });
    _currentContext = context;
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
          if (_data.isEmpty) {
            return const CustomEmptyListText(text: 'empty');
          }

          return CustomListView(
            itemCount: _data.length,
            itemBuilder: (BuildContext context, int index) {
              final T item = _data[index];
              final convertedItem = widget.itemConverter(item);

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: CustomSlidable(
                  onPressed: (BuildContext context) async {
                    await showOptionsBottomSheet(
                      context,
                      widget.titleOptionEdit,
                      convertedItem.descricao,
                    ).then((value) async {
                      if (value == 'deletar') {
                        await widget.deleteItem(convertedItem.id).then((error) {
                          if (error == null) {
                            ScaffoldMessenger.of(_currentContext)
                                .clearSnackBars();
                            CustomSnackBar.showDefault(
                              _currentContext,
                              'Exclusão feita com sucesso!',
                            );
                            setState(() {
                              _data.removeAt(index);
                            });
                          } else {
                            CustomWarningMessaging.showWarningDialog(
                                _currentContext, error);
                          }
                        });
                      } else if (value != null &&
                          value != convertedItem.descricao) {
                        await widget
                            .updateItem(convertedItem.id, value)
                            .then((error) {
                          if (error == null) {
                            ScaffoldMessenger.of(_currentContext)
                                .clearSnackBars();
                            CustomSnackBar.showDefault(
                              _currentContext,
                              'Edição feita com sucesso!',
                            );
                            setState(() {
                              convertedItem.descricao = value;
                            });
                          } else {
                            CustomWarningMessaging.showWarningDialog(
                                _currentContext, error);
                          }
                        });
                      }
                    });
                  },
                  icon: Icons.ballot_outlined,
                  label: 'Opções',
                  enable: true,
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
                    tilePadding: const EdgeInsets.symmetric(horizontal: 16),
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
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              CustomGestureDetectorList(
                                imagePath: convertedItem.imagemURL[i],
                                child: ListTile(
                                  title: SizedBox(
                                    width: 50,
                                    height: 50,
                                    child: CustomImageThumbList(
                                      thumbURL: convertedItem.thumbURL[i],
                                    ),
                                  ),
                                ),
                              ),
                              if (convertedItem.imagemURL[i] == null)
                                const CircularProgressIndicator(),
                            ],
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
