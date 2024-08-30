import 'package:flutter/material.dart';
import 'package:intraflow/utils/helpers/formatting.dart';
import 'package:intraflow/views/pages/shipments/options_view.dart';
import 'package:intraflow/widgets/custom_box_decoration_list.dart';
import 'package:intraflow/widgets/custom_empty_list_text.dart';
import 'package:intraflow/widgets/custom_gestor_detector_list.dart';
import 'package:intraflow/widgets/custom_list_tile.dart';
import 'package:intraflow/widgets/custom_list_view.dart';
import 'package:intraflow/widgets/custom_slidable.dart';
import 'package:intraflow/widgets/custom_snack_bar.dart';
import 'package:intraflow/widgets/custom_warning_messaging.dart';

class ListViewPdfWeek<T> extends StatefulWidget {
  final Future<List<T>> dataFuture;
  final Function(dynamic) itemConverter;
  final Function(String, String) updateItem;
  final Function(String) deleteItem;
  final String route;
  final String titleOptionEdit;

  const ListViewPdfWeek({
    super.key,
    required this.dataFuture,
    required this.itemConverter,
    required this.updateItem,
    required this.deleteItem,
    required this.route,
    required this.titleOptionEdit,
  });

  @override
  ListViewPdfWeekState<T> createState() => ListViewPdfWeekState<T>();
}

class ListViewPdfWeekState<T> extends State<ListViewPdfWeek<T>> {
  late BuildContext _currentContext;
  List<T> _data = [];

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
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: CustomGestureDetectorList(
                  title: convertedItem.descricao,
                  pdfPath: convertedItem.pdfURL,
                  child: CustomSlidable(
                    onPressed: (BuildContext context) async {
                      await showOptionsBottomSheet(
                        context,
                        widget.titleOptionEdit,
                        convertedItem.descricao,
                      ).then((value) async {
                        if (value == 'deletar') {
                          await widget
                              .deleteItem(convertedItem.id)
                              .then((error) {
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
                    child: Container(
                      decoration:
                          CustomBoxDecorationList.defaultBoxDecoration(),
                      child: Column(
                        children: [
                          CustomListTile(
                            thumbURL: convertedItem.thumbURL,
                            title: convertedItem.descricao,
                            trailingText:
                                Formatter.formatDate(convertedItem.data),
                          )
                        ],
                      ),
                    ),
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
