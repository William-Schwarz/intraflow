import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intraflow/controllers/menus_scheduling_controller.dart';
import 'package:intraflow/controllers/users_controller.dart';
import 'package:intraflow/models/menus_scheduling_model.dart';
import 'package:intraflow/utils/helpers/formatting.dart';
import 'package:intraflow/utils/theme/custom_colors.dart';
import 'package:intraflow/widgets/custom_app_bar_bottom_sheet.dart';
import 'package:intraflow/widgets/custom_error_messaging.dart';
import 'package:intraflow/widgets/custom_modal_bottom_sheet.dart';
import 'package:intraflow/widgets/custom_snack_bar.dart';
import 'package:intraflow/widgets/custom_warning_messaging.dart';

class SpecialFoodScheduling extends StatefulWidget {
  const SpecialFoodScheduling({
    super.key,
  });

  @override
  SpecialFoodSchedulingState createState() => SpecialFoodSchedulingState();
}

class SpecialFoodSchedulingState extends State<SpecialFoodScheduling> {
  final UsersController _usersController = UsersController();
  final MenusSchedulingController _menusSchedulingController =
      MenusSchedulingController();
  late DateTime _date;
  Future<List<MenusSchedulingModel>>? _menusSchedulingDataFuture;
  List<MenusSchedulingModel> _menusSchedulingData = [];
  User? _user;
  int? _badge;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _user = FirebaseAuth.instance.currentUser;
    _date = DateTime.now().add(const Duration(days: 1));
    _toggleListView();
    _fetchUserBadge();
  }

  Future<void> _toggleListView() async {
    setState(() {
      _menusSchedulingDataFuture ??= _loadMenusData();
    });
  }

  Future<List<MenusSchedulingModel>> _loadMenusData() async {
    List<MenusSchedulingModel> data =
        await _menusSchedulingController.getMenuScheduling(
      uid: _user!.uid,
    );
    setState(() {
      _menusSchedulingData = data;
    });
    return data;
  }

  Future<void> _fetchUserBadge() async {
    if (_user != null) {
      int? badge = await _usersController.getUserBadge(uid: _user!.uid);
      setState(() {
        _badge = badge;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      children: [
        const CustomAppBarBottomSheet(),
        SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.only(
              right: 16,
              left: 16,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(
                      Icons.calendar_month_outlined,
                    ),
                    SizedBox(
                      width: 8,
                    ),
                    Text(
                      'Agendamento atual:',
                    ),
                  ],
                ),
                SizedBox(
                  height: 88,
                  child: FutureBuilder<List<MenusSchedulingModel>>(
                    future: _menusSchedulingDataFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return Center(
                          child: Text(
                            'Erro ao carregar agendamento: ${snapshot.error}',
                          ),
                        );
                      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return const Center(
                          child: Text('Você não possui agendamento'),
                        );
                      } else {
                        List<MenusSchedulingModel> agendamentos =
                            snapshot.data!;
                        return ListView.builder(
                          itemCount: agendamentos.length,
                          itemBuilder: (context, index) {
                            final agendamento = agendamentos[index];
                            return ListTile(
                              contentPadding: EdgeInsets.zero,
                              title: Text(
                                agendamento.nome,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Text(
                                agendamento.cracha.toString(),
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              trailing: Text(
                                Formatter.formatDate(agendamento.data),
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            );
                          },
                        );
                      }
                    },
                  ),
                ),
                Center(
                  child: SizedBox(
                    height: 250,
                    width: 250,
                    child: SvgPicture.asset(
                      'assets/images/svgs/date_picker_485156.svg',
                    ),
                  ),
                ),
                Center(
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      _selectDate(context: context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: CustomColors.tertiaryColor,
                    ),
                    icon: const Icon(
                      Icons.calendar_today,
                      color: CustomColors.secondaryColor,
                    ),
                    label: Text(
                      Formatter.formatDate(_date),
                      style: const TextStyle(
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 8,
                ),
                Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: ElevatedButton(
                        onPressed: () {
                          _postScheduling();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: CustomColors.secondaryColor,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(32),
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.only(
                            top: 8,
                            bottom: 8,
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  height: 24,
                                  width: 24,
                                  child: CircularProgressIndicator(),
                                )
                              : Text(
                                  _menusSchedulingData.isNotEmpty
                                      ? 'Reagendar'
                                      : 'Agendar',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                  ),
                                ),
                        ),
                      ),
                    ),
                    const SizedBox(
                      width: 8,
                    ),
                    Expanded(
                      flex: 1,
                      child: IconButton(
                        onPressed: () {
                          _deleteScheduling();
                        },
                        icon: const Icon(
                          Icons.delete_forever,
                          color: CustomColors.primaryColor,
                          size: 32,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 32,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _selectDate({
    required BuildContext context,
  }) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime.now().subtract(const Duration(days: 0)),
      lastDate: DateTime.now().add(const Duration(days: 14)),
    );
    if (picked != null && mounted) {
      setState(() {
        _date = picked;
      });
    }
  }

  Future<void> _postScheduling() async {
    // Verifica se já existe um agendamento para a data selecionada
    bool exists =
        _menusSchedulingData.any((agendamento) => agendamento.data == _date);
    if (exists) {
      CustomWarningMessaging.showWarningDialog(
        context,
        'Você já possui um agendamento para este dia.',
      );
      setState(() {
        _isLoading = false;
      });
      return;
    }

    setState(() {
      _isLoading = true;
    });

    if ((_user != null &&
            _user!.displayName != null &&
            _user!.displayName!.isNotEmpty) &&
        _badge != null) {
      DateTime scheduledDate = _menusSchedulingData.isNotEmpty
          ? _menusSchedulingData[0].data
          : DateTime.now().add(const Duration(days: 1));
      DateTime rescheduleLimit = DateTime(
          scheduledDate.year, scheduledDate.month, scheduledDate.day, 8);

      if (DateTime.now().isBefore(rescheduleLimit)) {
        MenusSchedulingModel scheduling = MenusSchedulingModel(
          uid: _user!.uid,
          nome: _user!.displayName!,
          cracha: _badge!,
          data: _date,
        );

        await _menusSchedulingController
            .postMenusScheduling(
          menusScheduling: scheduling,
        )
            .then((String? error) {
          if (error == null) {
            if (_menusSchedulingData.isEmpty) {
              setState(() {
                _menusSchedulingData.add(scheduling);
              });
            } else {
              setState(() {
                _menusSchedulingData.clear();
                _menusSchedulingData.add(scheduling);
              });
            }
            // Navigator.pop(context);
            // ScaffoldMessenger.of(context).clearSnackBars();
            // CustomSnackBar.showDefault(
            //   context,
            //   meuAgendamentoData.isNotEmpty
            //       ? 'Reagendamento realizado com sucesso.'
            //       : 'Agendamento realizado com sucesso.',
            // );
          } else {
            CustomErrorMessaging(
              message: error,
            );
          }
        }).whenComplete(() {
          setState(() {
            _isLoading = false;
          });
        });
      } else {
        CustomWarningMessaging.showWarningDialog(
          context,
          'Não é possível reagendar após as 08:00 do dia do agendamento.',
        );
        setState(() {
          _isLoading = false;
        });
      }
    } else {
      CustomWarningMessaging.showWarningDialog(
        context,
        _menusSchedulingData.isNotEmpty
            ? 'Erro ao reagendar.'
            : 'Erro ao agendar.',
      );
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteScheduling() async {
    DateTime scheduledDate = _menusSchedulingData.isNotEmpty
        ? _menusSchedulingData[0].data
        : DateTime.now().add(const Duration(days: 1));
    DateTime rescheduleLimit =
        DateTime(scheduledDate.year, scheduledDate.month, scheduledDate.day, 8);

    if (DateTime.now().isBefore(rescheduleLimit)) {
      await _menusSchedulingController
          .deleteMenuScheduling(
        uid: _user!.uid,
      )
          .then((String? error) {
        if (error == null) {
          setState(() {
            _menusSchedulingData.clear();
          });
          // Navigator.pop(context);
          // ScaffoldMessenger.of(context).clearSnackBars();
          // CustomSnackBar.showDefault(
          //   context,
          //   'Agendamento excluído com sucesso.',
          // );
        } else {
          ScaffoldMessenger.of(context).clearSnackBars();
          CustomSnackBar.showDefault(
            context,
            error,
          );
        }
      });
    } else {
      CustomWarningMessaging.showWarningDialog(
        context,
        'Não é possível excluir após as 08:00 do dia do agendamento.',
      );
    }
  }
}

Future<String?> showAgendarLancheEspecialBottomSheet(
  BuildContext context,
) async {
  return await const CustomModalBottomSheet(
    child: SpecialFoodScheduling(),
  ).show(context);
}
