import 'package:flutter/material.dart';
import 'package:intraflow/routes/user_infos.dart';
import 'package:intraflow/views/navigation_view.dart';
import 'package:intraflow/widgets/custom_loading_splash_screen.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  HomViewState createState() => HomViewState();
}

class HomViewState extends State<HomeView> {
  late Future<Map<String, dynamic>> _userInfosFuture;

  @override
  void initState() {
    super.initState();
    _userInfosFuture = userInfos();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: _userInfosFuture,
      builder:
          (BuildContext context, AsyncSnapshot<Map<String, dynamic>> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CustomLoadingSplashscreen();
        } else if (snapshot.hasError) {
          return Center(child: Text('Erro: ${snapshot.error}'));
        } else if (snapshot.hasData) {
          final data = snapshot.data!;
          return NavigationView(
            screens: data['telas'],
            titles: data['titulos'],
            drawerItemsViewer: data['drawerItemsVisualizador'],
            drawerItemsAdministrator: data['drawerItemsAdministrador'],
            bottomNavItems: data['bottomNavItems'],
            index: 0,
          );
        } else {
          return const Center(child: Text('Sem dados disponíveis.'));
        }
      },
    );
  }
}
