import 'package:flutter/material.dart';
import 'package:intraflow/controllers/events_controller.dart';
import 'package:intraflow/models/events_model.dart';
import 'package:intraflow/utils/helpers/app_config.dart';
import 'package:intraflow/views/lists/previous/list_view_images.dart';
import 'package:intraflow/widgets/custom_elevated_button_list.dart';
import 'package:intraflow/widgets/custom_empty_list_text.dart';
import 'package:intraflow/widgets/custom_page_view.dart';
import 'package:intraflow/widgets/custom_refresh_indicator.dart';

class EventsView extends StatefulWidget {
  const EventsView({super.key});

  @override
  State<EventsView> createState() => _EventsViewState();
}

class _EventsViewState extends State<EventsView> {
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _buttonKey = GlobalKey();
  final EventsController _eventsController = EventsController();
  Future<List<EventsModel>>? _eventsDataFuture;
  List<EventsModel> eventsData = [];
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

    List<EventsModel> events =
        await _eventsController.getEvents(option: 'atuais');

    if (mounted) {
      setState(() {
        if (events.isNotEmpty) {
          events.sort((a, b) => b.data.compareTo(a.data));
          _images = events.map((evento) => evento.imagemURL).toList();
        }
        _isLoading = false;
      });
    }
  }

  Future<void> _toggleListView() async {
    setState(() {
      _showListView = !_showListView;
      if (_showListView && _eventsDataFuture == null) {
        _eventsDataFuture = _loadEventsData();
      }
    });
  }

  Future<List<EventsModel>> _loadEventsData() async {
    List<EventsModel> data =
        await _eventsController.getEvents(option: 'anteriores');
    setState(() {
      eventsData = data;
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
                        text: 'Visualizar Eventos Anteriores',
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
                        child: ListViewImagesPrevious<EventsModel>(
                          dataFuture: _eventsDataFuture!,
                          itemConverter: (dynamic item) {
                            if (item is EventsModel) {
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
