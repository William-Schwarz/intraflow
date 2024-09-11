import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intraflow/controllers/files_controller.dart';
import 'package:intraflow/utils/theme/custom_colors.dart';
import 'package:intraflow/widgets/custom_full_screen_image.dart';
import 'package:intraflow/widgets/custom_full_screen_image_web.dart';

class CustomReorderableListView extends StatefulWidget {
  final FilesController filesController;
  final Function(List<Uint8List>) onRemoveItem;

  const CustomReorderableListView({
    super.key,
    required this.filesController,
    required this.onRemoveItem,
  });

  @override
  State<CustomReorderableListView> createState() =>
      _CustomReorderableListViewState();
}

class _CustomReorderableListViewState extends State<CustomReorderableListView> {
  late FilesController _filesController;
  final double itemHeight = 75;

  @override
  void initState() {
    super.initState();
    _filesController = widget.filesController;
  }

  @override
  Widget build(BuildContext context) {
    double totalHeight = itemHeight * _filesController.imageDataList.length;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: CustomColors.tertiaryColor.withOpacity(0.5),
      ),
      height: totalHeight,
      child: ReorderableListView(
        physics: const NeverScrollableScrollPhysics(),
        scrollDirection: Axis.vertical,
        onReorder: (oldIndex, newIndex) {
          setState(() {
            final newIdx = newIndex > oldIndex ? newIndex - 1 : newIndex;
            final item = _filesController.imageDataList.removeAt(oldIndex);
            _filesController.imageDataList.insert(newIdx, item);
            widget.onRemoveItem(_filesController.imageDataList);
          });
        },
        children: _filesController.imageDataList.asMap().entries.map((entry) {
          final imageData = entry.value;

          return ListTile(
            key: ValueKey(imageData),
            leading: GestureDetector(
              onTap: () {
                if (kIsWeb) {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => CustomFullScreenImageWeb(
                        imageData: imageData,
                      ),
                    ),
                  );
                } else {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => CustomFullScreenImage(
                        imageData: imageData,
                      ),
                    ),
                  );
                }
              },
              child: Image.memory(
                imageData,
                fit: BoxFit.cover,
                width: 50,
                height: 50,
              ),
            ),
            title: Text('Imagem ${entry.key + 1}'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () {
                    setState(() {
                      _filesController.imageDataList.removeAt(entry.key);
                      widget.onRemoveItem(_filesController.imageDataList);
                    });
                  },
                ),
                const Icon(Icons.drag_handle),
              ],
            ),
            contentPadding: const EdgeInsets.symmetric(vertical: 10),
          );
        }).toList(),
      ),
    );
  }
}
