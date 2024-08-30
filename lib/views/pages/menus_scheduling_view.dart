import 'package:flutter/material.dart';
import 'package:intraflow/controllers/menus_scheduling_controller.dart';
import 'package:intraflow/models/menus_scheduling_model.dart';
import 'package:intraflow/utils/helpers/app_config.dart';
import 'package:intraflow/utils/helpers/formatting.dart';
import 'package:intraflow/utils/theme/custom_colors.dart';
import 'package:intraflow/widgets/custom_app_bar.dart';

class MenusSchedulingsView extends StatefulWidget {
  const MenusSchedulingsView({super.key});

  @override
  MenusSchedulingsViewState createState() => MenusSchedulingsViewState();
}

class MenusSchedulingsViewState extends State<MenusSchedulingsView> {
  final MenusSchedulingController _menusSchedulingController =
      MenusSchedulingController();
  late Future<List<MenusSchedulingModel>> _menusSchedulingDataFuture;

  @override
  void initState() {
    super.initState();
    _menusSchedulingDataFuture =
        _menusSchedulingController.getMenusScheduling();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Agendamentos',
        leadingVisible: true,
      ),
      body: Center(
        child: Container(
          padding: const EdgeInsets.all(8),
          width: MediaQuery.of(context).size.height *
              AppConfig().widhtMediaQueryWebPage!,
          child: FutureBuilder<List<MenusSchedulingModel>>(
            future: _menusSchedulingDataFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(
                  child: Text(
                    'Erro ao carregar agendamentos: ${snapshot.error}',
                  ),
                );
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(
                  child: Text('Nenhum agendamento encontrado.'),
                );
              } else {
                List<MenusSchedulingModel> menusScheduling = snapshot.data!;

                // Agrupando agendamentos por data
                final groupedScheduling =
                    <DateTime, List<MenusSchedulingModel>>{};
                for (var scheduling in menusScheduling) {
                  final date = DateTime(
                    scheduling.data.year,
                    scheduling.data.month,
                    scheduling.data.day,
                  );
                  if (!groupedScheduling.containsKey(date)) {
                    groupedScheduling[date] = [];
                  }
                  groupedScheduling[date]!.add(scheduling);
                }

                // Ordenando as datas
                final sortedDates = groupedScheduling.keys.toList()
                  ..sort((a, b) => a.compareTo(b));

                return ListView(
                  children: sortedDates.map((date) {
                    final dailySchedulings = groupedScheduling[date]!;

                    return ExpansionTile(
                      title: Text(
                        '${Formatter.formatDate(date)} - ${dailySchedulings.length} agendamentos',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      backgroundColor:
                          CustomColors.secondaryColor.withOpacity(0.2),
                      collapsedBackgroundColor:
                          CustomColors.tertiaryColor.withOpacity(0.5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      collapsedShape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      tilePadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                      ),
                      children: dailySchedulings
                          .map((agendamento) => ListTile(
                                title: Text(
                                  agendamento.nome,
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                trailing: Text(
                                  agendamento.cracha.toString(),
                                  style: const TextStyle(
                                    color: Colors.black,
                                  ),
                                ),
                              ))
                          .toList(),
                    );
                  }).toList(),
                );
              }
            },
          ),
        ),
      ),
    );
  }
}
