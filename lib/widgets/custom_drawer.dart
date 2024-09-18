import 'package:flutter/material.dart';
import 'package:intraflow/services/auth/auth_service.dart';
import 'package:intraflow/services/local/local_user_controller.dart';
import 'package:intraflow/utils/theme/custom_colors.dart';
import 'package:intraflow/widgets/custom_snack_bar.dart';
import 'package:intraflow/widgets/custom_warning_messaging.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

class CustomDrawer extends StatefulWidget {
  final Function(int) onItemTapped;
  final List<Map<String, dynamic>> drawerItemsViewer;
  final List<Map<String, dynamic>> drawerItemsAdministrator;

  const CustomDrawer({
    super.key,
    required this.onItemTapped,
    required this.drawerItemsViewer,
    required this.drawerItemsAdministrator,
  });

  @override
  CustomDrawerState createState() => CustomDrawerState();
}

class CustomDrawerState extends State<CustomDrawer> {
  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<LocalUserController>(context, listen: false).loadUser();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: const EdgeInsets.only(top: 0),
        children: [
          Consumer<LocalUserController>(
            builder: (context, userProfileNotifier, child) {
              return UserAccountsDrawerHeader(
                decoration: const BoxDecoration(
                  gradient: CustomColors.primaryGradient,
                ),
                currentAccountPicture: CircleAvatar(
                  backgroundImage: (userProfileNotifier.user?.photoUrl != null)
                      ? NetworkImage(userProfileNotifier.user?.photoUrl ?? "")
                      : null,
                  backgroundColor: CustomColors.tertiaryColor,
                ),
                accountName: Text(userProfileNotifier.user?.name ?? ""),
                accountEmail: Text(userProfileNotifier.user?.email ?? ""),
              );
            },
          ),
          ...widget.drawerItemsViewer.asMap().entries.map((entry) {
            int index = entry.key;
            Map<String, dynamic> item = entry.value;
            return _showListTileDrawerVisualizador(
              item['asset'],
              item['title'],
              index,
            );
          }),
          const Divider(
            color: CustomColors.tertiaryColor,
          ),
          ListTile(
            leading: const Padding(
              padding: EdgeInsets.all(8.0),
              child: Icon(Icons.edit),
            ),
            title: const Text(
              'Editar perfil',
            ),
            onTap: () => context.go('/editar-perfil'),
          ),
          if (widget.drawerItemsAdministrator.isNotEmpty)
            const Divider(
              color: CustomColors.tertiaryColor,
            ),
          ...widget.drawerItemsAdministrator.asMap().entries.map((entry) {
            Map<String, dynamic> item = entry.value;
            return _showListTileDrawerAdministrador(
              item['icon'],
              item['title'],
              item['route'],
            );
          }),
          const Divider(
            color: CustomColors.tertiaryColor,
          ),
          ListTile(
            leading: const Padding(
              padding: EdgeInsets.all(8.0),
              child: Icon(Icons.logout),
            ),
            title: const Text(
              'Sair',
            ),
            onTap: () => _signOut(),
          ),
        ],
      ),
    );
  }

  ListTile _showListTileDrawerVisualizador(
    String asset,
    String title,
    int index,
  ) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: ShapeDecoration(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              32,
            ),
          ),
          gradient: CustomColors.primaryGradient,
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: ImageIcon(
            AssetImage(asset),
            color: Colors.white,
          ),
        ),
      ),
      title: Text(
        title,
      ),
      onTap: () {
        Navigator.pop(context);
        widget.onItemTapped(index);
      },
    );
  }

  ListTile _showListTileDrawerAdministrador(
    Icon icon,
    String title,
    String route,
  ) {
    return ListTile(
      leading: Padding(
        padding: const EdgeInsets.all(8.0),
        child: icon,
      ),
      title: Text(
        title,
      ),
      onTap: () => context.go(route),
    );
  }

  Future<void> _signOut() async {
    await _authService.logoutUser().then((String? error) {
      if (error == null) {
        ScaffoldMessenger.of(context).clearSnackBars();
        CustomSnackBar.showDefault(
          context,
          'Logout realizado com sucesso!',
        );
      } else {
        CustomWarningMessaging.showWarningDialog(context, error);
      }
    });
  }
}
