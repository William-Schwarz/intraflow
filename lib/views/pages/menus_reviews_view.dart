import 'package:flutter/material.dart';
import 'package:intraflow/controllers/menus_reviews_controller.dart';
import 'package:intraflow/models/menus_reviews_model.dart';
import 'package:intraflow/utils/helpers/app_config.dart';
import 'package:intraflow/utils/theme/custom_colors.dart';
import 'package:intraflow/widgets/custom_app_bar.dart';
import 'package:intraflow/widgets/custom_empty_list_text.dart';
import 'package:intraflow/widgets/custom_full_screen_image.dart';
import 'package:intraflow/widgets/custom_image_thumb_page.dart';
import 'package:intraflow/widgets/custom_refresh_indicator.dart';

class MenusReviewsView extends StatefulWidget {
  const MenusReviewsView({super.key});

  @override
  State<MenusReviewsView> createState() => _MenusReviewsViewState();
}

class _MenusReviewsViewState extends State<MenusReviewsView> {
  final MenusReviewsController _menusReviewsController =
      MenusReviewsController();
  late Future<List<MenusReviewsModel>> _menusReviewsDataFuture;

  @override
  void initState() {
    super.initState();
    _menusReviewsDataFuture = _menusReviewsController.getMenusReviews();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Avaliações',
        leadingVisible: true,
      ),
      body: CustomRefreshIndicator(
        onRefresh: _refresh,
        child: FutureBuilder<List<MenusReviewsModel>>(
          future: _menusReviewsDataFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Erro: ${snapshot.error}'));
            } else {
              List<MenusReviewsModel> reviews = snapshot.data ?? [];
              if (reviews.isEmpty) {
                return const CustomEmptyListText(text: 'empty');
              }
              double media = calculateGeneralAverage(reviews);
              reviews.sort((a, b) => b.dataCardapio.compareTo(a.dataCardapio));
              Map<Object, double> mediaMenu = calculateAverageMenu(reviews);
              Map<String, List<MenusReviewsModel>> groupedReviews =
                  groupReviewsMenu(reviews);
              return SafeArea(
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Column(
                    children: [
                      Container(
                        alignment: Alignment.center,
                        padding: const EdgeInsets.symmetric(vertical: 20.0),
                        child: _buildStarRating(media),
                      ),
                      SizedBox(
                        width: MediaQuery.of(context).size.height *
                            AppConfig().widhtMediaQueryWebPage!,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 10, right: 10),
                          child: ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: groupedReviews.length,
                            itemBuilder: (context, index) {
                              String cardapioId =
                                  groupedReviews.keys.elementAt(index);
                              List<MenusReviewsModel> menuReview =
                                  groupedReviews[cardapioId] ?? [];
                              calculateGeneralAverage(menuReview);
                              return Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 4),
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    boxShadow: [
                                      BoxShadow(
                                        color: CustomColors.boxShadowColor,
                                        spreadRadius: 2,
                                        blurRadius: 5,
                                        offset: const Offset(0, 3),
                                      ),
                                    ],
                                  ),
                                  child: ExpansionTile(
                                    childrenPadding: const EdgeInsets.only(
                                      right: 24,
                                      left: 24,
                                      bottom: 8,
                                    ),
                                    leading: GestureDetector(
                                      onTap: () {
                                        Navigator.of(context).push(
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                CustomFullScreenImage(
                                              imagePath: menuReview
                                                  .first.imagemURLCardapio,
                                            ),
                                          ),
                                        );
                                      },
                                      child: CustomImageThumbPage(
                                        thumbURL:
                                            menuReview.first.thumbURLCardapio,
                                      ),
                                    ),
                                    title: Text(
                                      menuReview.first.descricaoCardapio,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                      ),
                                    ),
                                    trailing: Text(
                                      'Média: ${mediaMenu[cardapioId]?.toStringAsFixed(1) ?? 'N/A'}',
                                      style: const TextStyle(
                                          fontSize: 14, color: Colors.black),
                                    ),
                                    children: [
                                      const Padding(
                                        padding:
                                            EdgeInsets.symmetric(vertical: 4),
                                        child: Text(
                                          'Comentários:',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black,
                                          ),
                                        ),
                                      ),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: menuReview
                                            .where((avaliacao) =>
                                                avaliacao.comentario.isNotEmpty)
                                            .map((avaliacao) {
                                          return Padding(
                                            padding: const EdgeInsets.symmetric(
                                              vertical: 4,
                                            ),
                                            child: Card(
                                              color:
                                                  CustomColors.secondaryColor,
                                              elevation: 2,
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                                side: BorderSide.none,
                                              ),
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Row(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        const Icon(
                                                          Icons.chat_sharp,
                                                          color: Colors.white,
                                                          size: 20,
                                                        ),
                                                        const SizedBox(
                                                            width: 4),
                                                        Expanded(
                                                          child: Text(
                                                            '- ${avaliacao.comentario}',
                                                            style:
                                                                const TextStyle(
                                                              color:
                                                                  Colors.white,
                                                              fontSize: 14,
                                                              fontStyle:
                                                                  FontStyle
                                                                      .italic,
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    Row(
                                                      children: [
                                                        const Icon(
                                                          Icons.star,
                                                          color: Colors.white,
                                                          size: 18,
                                                        ),
                                                        Text(
                                                          ' - ${avaliacao.nota.toString()}',
                                                          style:
                                                              const TextStyle(
                                                            color: Colors.white,
                                                            fontSize: 14,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          );
                                        }).toList(),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }
          },
        ),
      ),
    );
  }

  Widget _buildStarRating(double rating) {
    int numberOfStars = rating.round();
    List<Widget> stars = List.generate(
      5,
      (index) => Icon(
        index < numberOfStars ? Icons.star : Icons.star_border,
        size: 30,
        color: CustomColors.secondaryColor,
      ),
    );
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Column(
          children: [
            Row(
              children: stars,
            ),
            Text(
              'Média Geral: ${rating.toStringAsFixed(1)}',
              style: const TextStyle(fontSize: 20, color: Colors.black),
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _refresh() async {
    if (mounted) {
      setState(() {
        _menusReviewsDataFuture = _menusReviewsController.getMenusReviews();
      });
    }
  }

  Map<String, List<MenusReviewsModel>> groupReviewsMenu(
      List<MenusReviewsModel> avaliacoes) {
    return MenusReviewsController().groupReviewsMenu(
      menusReviews: avaliacoes,
    );
  }

  Map<Object, double> calculateAverageMenu(List<MenusReviewsModel> avaliacoes) {
    return MenusReviewsController().calculateAverageMenu(
      menusReviews: avaliacoes,
    );
  }

  double calculateGeneralAverage(List<MenusReviewsModel> avaliacoes) {
    return MenusReviewsController().calculateGeneralAverage(
      menusReviews: avaliacoes,
    );
  }
}
