import 'package:flutter/material.dart';
import 'package:intraflow/controllers/code_ethics_controller.dart';
import 'package:intraflow/models/code_ethics_model.dart';
import 'package:intraflow/utils/helpers/app_config.dart';
import 'package:intraflow/views/lists/previous/list_view_images.dart';
import 'package:intraflow/widgets/custom_elevated_button_list.dart';
import 'package:intraflow/widgets/custom_empty_list_text.dart';
import 'package:intraflow/widgets/custom_page_view.dart';
import 'package:intraflow/widgets/custom_refresh_indicator.dart';

class CodeEthicsView extends StatefulWidget {
  const CodeEthicsView({super.key});

  @override
  State<CodeEthicsView> createState() => _CodeEthicsViewState();
}

class _CodeEthicsViewState extends State<CodeEthicsView> {
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _buttonKey = GlobalKey();
  final CodeEthicsController _codeEthicsController = CodeEthicsController();
  Future<List<CodeEthicsModel>>? _codeEthicsDataFuture;
  List<CodeEthicsModel> codeEthicsData = [];
  List<List<String>> _images = [];
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
        _images = [];
        _showListView = false;
      });
    }

    List<CodeEthicsModel> codeEthics =
        await _codeEthicsController.getCodeEthics(option: 'atuais');

    if (mounted) {
      setState(() {
        if (codeEthics.isNotEmpty) {
          codeEthics.sort((a, b) => b.data.compareTo(a.data));
          _images =
              codeEthics.map((codigoEtica) => codigoEtica.imagemURL).toList();
        }
        _isLoading = false;
      });
    }
  }

  Future<void> _toggleListView() async {
    setState(() {
      _showListView = !_showListView;
      if (_showListView && _codeEthicsDataFuture == null) {
        _codeEthicsDataFuture = _loadCodeEthicsData();
      }
    });
  }

  Future<List<CodeEthicsModel>> _loadCodeEthicsData() async {
    List<CodeEthicsModel> data =
        await _codeEthicsController.getCodeEthics(option: 'anteriores');
    setState(() {
      codeEthicsData = data;
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
                    if (_images.isEmpty &&
                        _isLoading == false &&
                        !_showListView)
                      const CustomEmptyListText(text: 'atuais'),
                    if (!_showListView && _images.isNotEmpty)
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.80,
                        child: CustomPageView(
                          images: _images.expand((i) => i).toList(),
                          onPageChanged: (int index) {},
                        ),
                      ),
                    if (_images.isEmpty)
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
                        text: 'Visualizar Código de Ética Hoje',
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
                        child: ListViewImagesPrevious<CodeEthicsModel>(
                          dataFuture: _codeEthicsDataFuture!,
                          itemConverter: (dynamic item) {
                            if (item is CodeEthicsModel) {
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
