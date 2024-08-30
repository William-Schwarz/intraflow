import 'package:flutter/material.dart';
import 'package:intraflow/controllers/magazines_controller.dart';
import 'package:intraflow/models/magazines_model.dart';
import 'package:intraflow/utils/helpers/app_config.dart';
import 'package:intraflow/views/lists/previous/list_view_pdf.dart';
import 'package:intraflow/widgets/custom_elevated_button_list.dart';
import 'package:intraflow/widgets/custom_empty_list_text.dart';
import 'package:intraflow/widgets/custom_page_view.dart';
import 'package:intraflow/widgets/custom_refresh_indicator.dart';

class MagazinesView extends StatefulWidget {
  const MagazinesView({super.key});

  @override
  State<MagazinesView> createState() => _MagazinesViewState();
}

class _MagazinesViewState extends State<MagazinesView> {
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _buttonKey = GlobalKey();
  final MagazinesController _magazinesController = MagazinesController();
  Future<List<MagazinesModel>>? _magazinesDataFuture;
  List<MagazinesModel> magazinesData = [];
  Map<String, String> images = {};
  Map<String, String> ids = {};
  Map<String, String> pdfs = {};
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

    List<MagazinesModel> magazines =
        await _magazinesController.getMagazines(option: 'atuais');

    if (mounted) {
      setState(() {
        if (magazines.isNotEmpty) {
          magazines.sort((a, b) => b.data.compareTo(a.data));
          for (var magazine in magazines) {
            images[magazine.id] = magazine.imagemURL;
            ids[magazine.id] = magazine.id;
            pdfs[magazine.id] = magazine.pdfURL;
            description[magazine.id] = magazine.descricao;
          }
        }
        _isLoading = false;
      });
    }
  }

  Future<void> _toggleListView() async {
    setState(() {
      _showListView = !_showListView;
      if (_showListView && _magazinesDataFuture == null) {
        _magazinesDataFuture = _loadMagazinesData();
      }
    });
  }

  Future<List<MagazinesModel>> _loadMagazinesData() async {
    List<MagazinesModel> data =
        await _magazinesController.getMagazines(option: 'semana');
    setState(() {
      magazinesData = data;
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
                    if (images.isEmpty && _isLoading == false && !_showListView)
                      const CustomEmptyListText(text: 'atuais'),
                    if (!_showListView && images.isNotEmpty)
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.80,
                        child: CustomPageView(
                          images: images.values.toList(),
                          onPageChanged: (int index) {},
                          docIds: ids.values.toList(),
                          pdfs: pdfs.values.toList(),
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
                        text: 'Visualizar Revistas Anteriores',
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
                        child: ListViewPdfPrevious<MagazinesModel>(
                          dataFuture: _magazinesDataFuture!,
                          itemConverter: (dynamic item) {
                            if (item is MagazinesModel) {
                              return item;
                            }
                          },
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
