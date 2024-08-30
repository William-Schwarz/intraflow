import 'package:flutter/material.dart';
import 'package:intraflow/controllers/menus_controller.dart';
import 'package:intraflow/models/menus_model.dart';
import 'package:intraflow/utils/helpers/app_config.dart';
import 'package:intraflow/views/lists/previous/list_view_cardapios.dart';
import 'package:intraflow/widgets/custom_elevated_button_list.dart';
import 'package:intraflow/widgets/custom_empty_list_text.dart';
import 'package:intraflow/widgets/custom_page_view.dart';
import 'package:intraflow/widgets/custom_refresh_indicator.dart';

class MenuView extends StatefulWidget {
  const MenuView({super.key});

  @override
  State<MenuView> createState() => _MenuViewState();
}

class _MenuViewState extends State<MenuView> {
  final GlobalKey _buttonKey = GlobalKey();
  final MenusController _menusController = MenusController();
  final ScrollController _scrollController = ScrollController();
  Future<List<MenusModel>>? _menusDataFuture;
  List<MenusModel> menusData = [];
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

    List<MenusModel> menu = await _menusController.getMenus(option: 'atuais');

    if (mounted) {
      setState(() {
        if (menu.isNotEmpty) {
          menu.sort((a, b) => b.data.compareTo(a.data));
          _images = menu.map((cardapio) => cardapio.imagemURL).toList();
        }
        _isLoading = false;
      });
    }
  }

  Future<void> _toggleListView() async {
    setState(() {
      _showListView = !_showListView;
      if (_showListView && _menusDataFuture == null) {
        _menusDataFuture = _loadCardapiosData();
      }
    });
  }

  Future<List<MenusModel>> _loadCardapiosData() async {
    List<MenusModel> data =
        await _menusController.getMenus(option: 'anteriores');
    setState(() {
      menusData = data;
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
                        text: 'Visualizar Cardápios Anteriores',
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
                        child: ListViewMenusPrevious<MenusModel>(
                          dataFuture: _menusDataFuture!,
                          itemConverter: (dynamic item) {
                            if (item is MenusModel) {
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
        /*
        floatingActionButtonAnimator: FloatingActionButtonAnimator.scaling,
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
        floatingActionButton: !_showListView
            ? FloatingActionButton(
                shape: const StadiumBorder(),
                backgroundColor: CustomColors.tertiaryColor,
                tooltip: 'Abrir avaliações dos cardápios',
                onPressed: () {
                  Navigator.push(
                    context,
                    SlideUpPageRoute(
                      route: '/avaliacoes',
                      routes: Routes.secundarias,
                    ),
                  );
                },
                child: const Icon(
                  Icons.assessment,
                  size: 35,
                ),
              )
            : null,
            */
        // floatingActionButtonAnimator: FloatingActionButtonAnimator.scaling,
        // floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
        // floatingActionButton: !_showListView
        //     ? FloatingActionButton(
        //         shape: const StadiumBorder(),
        //         backgroundColor: CustomColors.tertiaryColor,
        //         tooltip: 'Agendar lanche especial',
        //         onPressed: () {
        //           showAgendarLancheEspecialBottomSheet(context);
        //         },
        //         child: const Icon(
        //           Icons.assignment_add,
        //           size: 35,
        //         ),
        //       )
        //     : null,
      ),
    );
  }
}
