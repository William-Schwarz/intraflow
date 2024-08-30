import 'package:flutter/material.dart';
import 'package:intraflow/utils/helpers/app_config.dart';
import 'package:intraflow/widgets/custom_elevated_button_upload_view.dart';

class UploadView extends StatefulWidget {
  final List<Map<String, dynamic>> uploadItems;

  const UploadView({
    super.key,
    required this.uploadItems,
  });

  @override
  State<UploadView> createState() => _UploadViewState();
}

class _UploadViewState extends State<UploadView> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Builder(
          builder: (BuildContext context) {
            return SingleChildScrollView(
              child: Center(
                child: Container(
                  width: MediaQuery.of(context).size.height *
                      AppConfig().widhtMediaQueryWebPage!,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 16,
                  ),
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    alignment: WrapAlignment.center,
                    children: widget.uploadItems
                        .map((item) => CustomElevatedButtonUploadView(
                              route: item['route'],
                              asset: item['asset'],
                              text: item['text'],
                            ))
                        .toList(),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
