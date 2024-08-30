import 'package:flutter/material.dart';
import 'package:intraflow/controllers/announcements_controller.dart';
import 'package:intraflow/models/announcements_model.dart';
import 'package:intraflow/utils/helpers/app_config.dart';
import 'package:intraflow/views/lists/previous/list_view_images.dart';
import 'package:intraflow/widgets/custom_elevated_button_list.dart';
import 'package:intraflow/widgets/custom_empty_list_text.dart';
import 'package:intraflow/widgets/custom_page_view.dart';
import 'package:intraflow/widgets/custom_refresh_indicator.dart';

class AnnouncementsView extends StatefulWidget {
  const AnnouncementsView({super.key});

  @override
  State<AnnouncementsView> createState() => _AnnouncementsViewState();
}

class _AnnouncementsViewState extends State<AnnouncementsView> {
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _buttonKey = GlobalKey();
  final AnnouncementsController _announcementsController =
      AnnouncementsController();
  Future<List<AnnouncementsModel>>? _announcementsDataFuture;
  List<AnnouncementsModel> announcementsData = [];
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

    List<AnnouncementsModel> announcements =
        await _announcementsController.getAnnouncements(option: 'atuais');

    if (mounted) {
      setState(() {
        if (announcements.isNotEmpty) {
          announcements.sort((a, b) => b.data.compareTo(a.data));
          _images =
              announcements.map((comunicado) => comunicado.imagemURL).toList();
        }
        _isLoading = false;
      });
    }
  }

  Future<void> _toggleListView() async {
    setState(() {
      _showListView = !_showListView;
      if (_showListView && _announcementsDataFuture == null) {
        _announcementsDataFuture = _loadAnnouncementsData();
      }
    });
  }

  Future<List<AnnouncementsModel>> _loadAnnouncementsData() async {
    List<AnnouncementsModel> data =
        await _announcementsController.getAnnouncements(option: 'anteriores');
    setState(() {
      announcementsData = data;
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
                        text: 'Visualizar Comunicados Anteriores',
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
                        child: ListViewImagesPrevious<AnnouncementsModel>(
                          dataFuture: _announcementsDataFuture!,
                          itemConverter: (dynamic item) {
                            if (item is AnnouncementsModel) {
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
