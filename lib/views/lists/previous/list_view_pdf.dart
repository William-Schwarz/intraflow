import 'package:flutter/material.dart';
import 'package:intraflow/utils/helpers/formatting.dart';
import 'package:intraflow/utils/theme/custom_colors.dart';
import 'package:intraflow/widgets/custom_empty_list_text.dart';
import 'package:intraflow/widgets/custom_gestor_detector_list.dart';
import 'package:intraflow/widgets/custom_list_tile.dart';
import 'package:intraflow/widgets/custom_list_view.dart';

class ListViewPdfPrevious<T> extends StatefulWidget {
  final Future<List<T>> dataFuture;
  final Function(dynamic) itemConverter;

  const ListViewPdfPrevious({
    super.key,
    required this.dataFuture,
    required this.itemConverter,
  });

  @override
  ListViewPdfPreviousState<T> createState() => ListViewPdfPreviousState<T>();
}

class ListViewPdfPreviousState<T> extends State<ListViewPdfPrevious<T>> {
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
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: CustomGestureDetectorList(
                  docID: convertedItem.id,
                  title: convertedItem.descricao,
                  pdfPath: convertedItem.pdfURL,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: CustomColors.tertiaryColor.withOpacity(0.5),
                    ),
                    child: CustomListTile(
                      thumbURL: convertedItem.thumbURL,
                      title: convertedItem.descricao,
                      trailingText: Formatter.formatDate(convertedItem.data),
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
