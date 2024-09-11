import 'package:flutter/material.dart';
import 'package:intraflow/controllers/lgpd_controller.dart';
import 'package:intraflow/models/lgpd_model.dart';
import 'package:intraflow/utils/helpers/app_config.dart';
import 'package:intraflow/views/lists/previous/list_view.dart';
import 'package:intraflow/widgets/custom_elevated_button_list.dart';
import 'package:intraflow/widgets/custom_empty_list_text.dart';
import 'package:intraflow/widgets/custom_page_view.dart';
import 'package:intraflow/widgets/custom_refresh_indicator.dart';

class LgpdView extends StatefulWidget {
  const LgpdView({super.key});

  @override
  State<LgpdView> createState() => _LgpdViewState();
}

class _LgpdViewState extends State<LgpdView> {
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _buttonKey = GlobalKey();
  final LgpdController _lgpdController = LgpdController();
  Future<List<LgpdModel>>? _lgpdDataFuture;
  List<LgpdModel> lgpdData = [];
  Map<String, List<String>> images = {};
  Map<String, String> ids = {};
  Map<String, String?> pdfs = {};
  Map<String, String> description = {};
  bool _isLoading = true;
  bool _showListView = false;

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  Future<void> _refresh() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
        images.clear();
        ids.clear();
        pdfs.clear();
        description.clear();
        _showListView = false;
      });
    }

    List<LgpdModel> lgpd = await _lgpdController.getLgpd(option: 'atuais');

    if (mounted) {
      setState(() {
        if (lgpd.isNotEmpty) {
          lgpd.sort((a, b) => b.data.compareTo(a.data));
          for (var lgpd in lgpd) {
            images[lgpd.id] = lgpd.imagemURL;
            ids[lgpd.id] = lgpd.id;
            pdfs[lgpd.id] = lgpd.pdfURL;
            description[lgpd.id] = lgpd.descricao;
          }
        }
        _isLoading = false;
      });
    }
  }

  Future<void> _toggleListView() async {
    setState(() {
      _showListView = !_showListView;
      if (_showListView && _lgpdDataFuture == null) {
        _lgpdDataFuture = _loadLgpdData();
      }
    });
  }

  Future<List<LgpdModel>> _loadLgpdData() async {
    List<LgpdModel> data = await _lgpdController.getLgpd(option: 'anteriores');
    setState(() {
      lgpdData = data;
    });
    return data;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: CustomRefreshIndicator(
          onRefresh: _refresh,
          child: SingleChildScrollView(
            controller: _scrollController,
            physics: const AlwaysScrollableScrollPhysics(),
            child: Center(
              child: SizedBox(
                width: MediaQuery.of(context).size.height *
                    AppConfig().widhtMediaQueryWebPage!,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(
                      height: 8,
                    ),
                    if (_isLoading) const LinearProgressIndicator(),
                    if (images.isEmpty && !_isLoading && !_showListView)
                      const CustomEmptyListText(text: 'atuais'),
                    if (!_showListView && images.isNotEmpty)
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.80,
                        child: CustomPageView(
                          images: images.values.expand((i) => i).toList(),
                          onPageChanged: (int index) {},
                          docIds: ids.values.toList(),
                          pdfs: pdfs.values.whereType<String>().toList(),
                          titles: description.values.toList(),
                        ),
                      ),
                    if (images.isEmpty)
                      const SizedBox(
                        height: 8,
                      ),
                    Padding(
                      padding: const EdgeInsets.only(
                        left: 10,
                        right: 10,
                      ),
                      child: CustomElevatedButtonList(
                        buttonkey: _buttonKey,
                        onPressed: _toggleListView,
                        listIsOpen: _showListView,
                        text: 'Visualizar Privacidades e Seguranças Anteriores',
                      ),
                    ),
                    SizedBox(
                      height: _showListView ? 8 : 32,
                    ),
                    if (_showListView)
                      Padding(
                        padding: const EdgeInsets.only(
                          left: 10,
                          right: 10,
                        ),
                        child: ListViewPrevious<LgpdModel>(
                          dataFuture: _lgpdDataFuture!,
                          itemConverter: (dynamic item) {
                            if (item is LgpdModel) {
                              return item;
                            }
                          },
                          enableSlidable: false,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
