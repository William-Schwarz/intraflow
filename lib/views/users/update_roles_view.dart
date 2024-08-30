import 'package:flutter/material.dart';
import 'package:intraflow/models/users_model.dart';
import 'package:intraflow/utils/theme/custom_colors.dart';
import 'package:intraflow/widgets/custom_divider.dart';

const Map<String, String> permissionTranslations = {
  'eventos': 'Eventos',
  'cardapios': 'Cardápios',
  'comunicados': 'Comunicados',
  'revistas': 'Revistas',
  'lgpd': 'LGPD',
  'codigoEtica': 'Código de Ética',
  'notificacoes': 'Notificações',
  'usuarios': 'Usuários',
};

class UpdateRolesView extends StatefulWidget {
  final UsersModel users;
  final VoidCallback onUpdate;

  const UpdateRolesView({
    super.key,
    required this.users,
    required this.onUpdate,
  });

  @override
  UpdateRolesViewState createState() => UpdateRolesViewState();
}

class UpdateRolesViewState extends State<UpdateRolesView> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              widget.users.nome,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(
              height: 24,
            ),
            const Text(
              'Roles',
              style: TextStyle(
                fontSize: 20,
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(
              height: 16,
            ),
            const Text(
              'Administrador',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            ..._buildRoleSwitches(
                rolePermissions: widget.users.roles['administrador'] ?? {}),
            const CustomDivider(),
            const Text(
              'Visualizador',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            ..._buildRoleSwitches(
                rolePermissions: widget.users.roles['visualizador'] ?? {}),
            const CustomDivider(),
            const Text(
              'Editor',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            ..._buildRoleSwitches(
                rolePermissions: widget.users.roles['editor'] ?? {}),
            const CustomDivider(),
            const SizedBox(
              height: 16,
            ),
            ElevatedButton(
              onPressed: () {
                _confirmUpdate(context: context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: CustomColors.secondaryColor,
              ),
              child: const Text(
                'Confirmar',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildRoleSwitches({
    required Map<String, dynamic> rolePermissions,
  }) {
    final sortedKeys = rolePermissions.keys.toList()
      ..sort((a, b) => a.compareTo(b));

    return sortedKeys.where((key) => rolePermissions[key] is bool).map((key) {
      return Column(
        children: [
          ListTile(
            title: Text(_translatePermission(permission: key)),
            trailing: Switch(
              value: rolePermissions[key] as bool,
              onChanged: (value) {
                setState(() {
                  _setRoleValue(
                    permission: key,
                    value: value,
                    rolePermissions: rolePermissions,
                  );
                });
              },
              activeColor: CustomColors.secondaryColor,
              inactiveThumbColor: CustomColors.tertiaryColor,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ),
        ],
      );
    }).toList();
  }

  void _setRoleValue({
    required String permission,
    required bool value,
    required Map<String, dynamic> rolePermissions,
  }) {
    setState(() {
      rolePermissions[permission] = value;
    });
  }

  String _translatePermission({
    required String permission,
  }) {
    return permissionTranslations[permission] ?? _capitalize(s: permission);
  }

  String _capitalize({
    required String s,
  }) {
    if (s.isEmpty) return '';
    return s.substring(0, 1).toUpperCase() + s.substring(1).toLowerCase();
  }

  void _confirmUpdate({
    required BuildContext context,
  }) {
    widget.onUpdate();
    Navigator.of(context).pop();
  }
}
