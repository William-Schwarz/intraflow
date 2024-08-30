import 'package:flutter/material.dart';
import 'package:intraflow/controllers/users_controller.dart';
import 'package:intraflow/models/users_model.dart';
import 'package:intraflow/utils/helpers/app_config.dart';
import 'package:intraflow/views/users/update_roles_view.dart';
import 'package:intraflow/widgets/custom_app_bar.dart';
import 'package:intraflow/widgets/custom_divider.dart';
import 'package:intraflow/widgets/custom_modal_bottom_sheet.dart';

class UsersView extends StatefulWidget {
  const UsersView({super.key});

  @override
  UsersViewState createState() => UsersViewState();
}

class UsersViewState extends State<UsersView> {
  late Future<List<UsersModel>> _users;
  final UsersController _usersController = UsersController();
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _users = _usersController.getUsers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Usuários',
        leadingVisible: true,
      ),
      body: Center(
        child: Container(
          width: MediaQuery.of(context).size.height *
              AppConfig().widhtMediaQueryWebPage!,
          padding: const EdgeInsets.all(8),
          alignment: Alignment.topCenter,
          child: Column(
            children: [
              _buildSearchField(),
              Expanded(
                child: SingleChildScrollView(
                  child: FutureBuilder<List<UsersModel>>(
                    future: _users,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      }

                      if (snapshot.hasError) {
                        return Center(
                          child: Text(
                            'Erro ao carregar usuários: ${snapshot.error}',
                            style: const TextStyle(
                              color: Colors.white,
                            ),
                          ),
                        );
                      }

                      final usuarios = snapshot.data ?? [];

                      // Apply filtering based on search text
                      final filteredUsuarios = usuarios
                          .where((usuario) => usuario.nome
                              .toLowerCase()
                              .contains(_searchController.text.toLowerCase()))
                          .toList();

                      return ListView.separated(
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        separatorBuilder: (context, index) =>
                            const CustomDivider(),
                        itemCount: filteredUsuarios.length,
                        itemBuilder: (context, index) {
                          final usuario = filteredUsuarios[index];
                          return ListTile(
                            title: SelectableText(
                              usuario.nome,
                              style: const TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                SelectableText(
                                  usuario.email,
                                  style: const TextStyle(
                                    color: Colors.black,
                                  ),
                                ),
                              ],
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.admin_panel_settings),
                              onPressed: () {
                                _showBottomSheet(
                                  context: context,
                                  user: usuario,
                                );
                              },
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchField() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Buscar por nome...',
          prefixIcon: const Icon(Icons.search),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
        ),
        onChanged: (value) {
          setState(() {
            // Trigger rebuild with filtered users
            _users = _usersController.getUsers();
          });
        },
      ),
    );
  }

  Future<String?> _showBottomSheet({
    required BuildContext context,
    required UsersModel user,
  }) async {
    return await CustomModalBottomSheet(
      child: UpdateRolesView(
        users: user,
        onUpdate: () async {
          await _updateRole(
            uid: user.id,
            roles: user.roles,
          );
          setState(() {
            // Update user list after role update
            _users = _usersController.getUsers();
          });
        },
      ),
    ).show(context);
  }

  Future<void> _updateRole({
    required String uid,
    required Map<String, dynamic> roles,
  }) async {
    await _usersController.updateUser(
      uid: uid,
      roles: roles,
    );
  }
}
