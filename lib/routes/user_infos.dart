import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intraflow/controllers/users_controller.dart';
import 'package:intraflow/views/no_permissions_view.dart';
import 'package:intraflow/views/pages/announcements_view.dart';
import 'package:intraflow/views/pages/code_ethics_view.dart';
import 'package:intraflow/views/pages/events_view.dart';
import 'package:intraflow/views/pages/lgpd_view.dart';
import 'package:intraflow/views/pages/magazines_view.dart';
import 'package:intraflow/views/pages/menus/menus_view.dart';
import 'package:intraflow/views/pages/shipments/upload_view.dart';

Future<Map<String, dynamic>> userInfos() async {
  User? user = FirebaseAuth.instance.currentUser;

  Map<String, dynamic>? roles =
      await UsersController().getUserRoles(uid: user!.uid);

  List<Widget> screens = [];
  List<String> titles = [];
  List<Map<String, dynamic>> drawerItemsVisualizador = [];
  List<Map<String, dynamic>> drawerItemsAdministrador = [];
  List<Map<String, dynamic>> bottomNavItems = [];
  List<Map<String, dynamic>> uploadItems = [];

  int roleViewerCount = (roles?['visualizador']?['eventos'] == true ? 1 : 0) +
      (roles?['visualizador']?['cardapios'] == true ? 1 : 0) +
      (roles?['visualizador']?['comunicados'] == true ? 1 : 0) +
      (roles?['visualizador']?['revistas'] == true ? 1 : 0) +
      (roles?['visualizador']?['lgpd'] == true ? 1 : 0);

  if (roles?['visualizador']?['eventos'] == true) {
    screens.add(const EventsView());
    titles.add('Calendário Eventos');
    drawerItemsVisualizador.add({
      'asset': 'assets/images/icons/event.png',
      'title': 'Calendário Eventos',
    });
    bottomNavItems.add({
      'asset': 'assets/images/icons/event.png',
      'label': 'Eventos',
    });
  }
  if (roles?['visualizador']?['cardapios'] == true) {
    screens.add(const MenuView());
    titles.add('Cardápio Refeitório');
    drawerItemsVisualizador.add({
      'asset': 'assets/images/icons/restaurant.png',
      'title': 'Cardápio Refeitório',
    });
    bottomNavItems.add({
      'asset': 'assets/images/icons/restaurant.png',
      'label': 'Cardápios',
    });
  }
  if (roles?['visualizador']?['comunicados'] == true) {
    screens.add(const AnnouncementsView());
    titles.add('Comunicados RH');
    drawerItemsVisualizador.add({
      'asset': 'assets/images/icons/record_voice_over.png',
      'title': 'Comunicados RH',
    });
    bottomNavItems.add({
      'asset': 'assets/images/icons/record_voice_over.png',
      'label': 'Comunicados',
    });
  }
  if (roles?['visualizador']?['revistas'] == true) {
    screens.add(const MagazinesView());
    titles.add('Revista K Entre Nós');
    drawerItemsVisualizador.add({
      'asset': 'assets/images/icons/magazine.png',
      'title': 'Revista K Entre Nós',
    });
    bottomNavItems.add({
      'asset': 'assets/images/icons/magazine.png',
      'label': 'Revistas',
    });
  }
  if (roles?['visualizador']?['lgpd'] == true) {
    screens.add(const LgpdView());
    titles.add('Privacidade e Segurança');
    drawerItemsVisualizador.add({
      'asset': 'assets/images/icons/lock.png',
      'title': 'Privacidade e Segurança',
    });
    bottomNavItems.add({
      'asset': 'assets/images/icons/lock.png',
      'label': 'LGPD',
    });
  }
  if (roles?['visualizador']?['codigoEtica'] == true) {
    screens.add(const CodeEthicsView());
    titles.add('Código de Ética');
    drawerItemsVisualizador.add({
      'asset': 'assets/images/icons/auto_stories.png',
      'title': 'Código de Ética',
    });
    bottomNavItems.add({
      'asset': 'assets/images/icons/auto_stories.png',
      'label': 'Código de Ética',
    });
  }
  if (roles?['editor']?['eventos'] == true) {
    uploadItems.add({
      'route': '/enviar/evento',
      'asset': 'assets/images/icons/event.png',
      'text': 'Calendário Evento',
    });
  }
  if (roles?['editor']?['cardapios'] == true) {
    uploadItems.add({
      'route': '/enviar/cardapio',
      'asset': 'assets/images/icons/restaurant.png',
      'text': 'Cardápio Refeitório',
    });
  }
  if (roles?['editor']?['comunicados'] == true) {
    uploadItems.add({
      'route': '/enviar/comunicado',
      'asset': 'assets/images/icons/record_voice_over.png',
      'text': 'Comunicado RH',
    });
  }
  if (roles?['editor']?['revistas'] == true) {
    uploadItems.add({
      'route': '/enviar/revista',
      'asset': 'assets/images/icons/magazine.png',
      'text': 'Revista K Entre Nós',
    });
  }
  if (roles?['editor']?['lgpd'] == true) {
    uploadItems.add({
      'route': '/enviar/privacidade-e-seguranca',
      'asset': 'assets/images/icons/lock.png',
      'text': 'Privacidade e Segurança',
    });
  }
  if (roles?['editor']?['codigoEtica'] == true) {
    uploadItems.add({
      'route': '/enviar/codigo-de-etica',
      'asset': 'assets/images/icons/auto_stories.png',
      'text': 'Código de Ética',
    });
  }
  if (roles?['editor']?['notificacoes'] == true) {
    uploadItems.add({
      'route': '/enviar/notificacao-personalizada',
      'asset': 'assets/images/icons/campaign.png',
      'text': 'Notificação Personalizada',
    });
  }
  if (roles!.containsKey('editor') &&
      (roles['editor']?['eventos'] == true ||
          roles['editor']?['cardapios'] == true ||
          roles['editor']?['comunicados'] == true ||
          roles['editor']?['revistas'] == true ||
          roles['editor']?['lgpd'] == true ||
          roles['editor']?['codigoEtica'] == true ||
          roles['editor']?['notificacoes'] == true)) {
    screens.add(UploadView(uploadItems: uploadItems));
    titles.add('Enviar');
    drawerItemsVisualizador.add({
      'asset': 'assets/images/icons/upload_file.png',
      'title': 'Enviar',
    });
    bottomNavItems.add({
      'asset': 'assets/images/icons/upload_file.png',
      'label': 'Atualizar',
    });
  }
  if (roles['administrador']?['usuarios'] == true) {
    drawerItemsAdministrador.add({
      'icon': const Icon(Icons.group),
      'title': 'Usuários',
      'route': '/usuarios',
    });
  }
  if (roleViewerCount == 1) {
    screens.add(const NoPermissionsView());
    titles.add('Sem Permissão');
    drawerItemsVisualizador.add({
      'asset': 'assets/images/icons/not_permission.png',
      'title': 'Sem Permissão',
    });
    bottomNavItems.add({
      'asset': 'assets/images/icons/not_permission.png',
      'label': 'Sem Permissão',
    });
  }
  if (roleViewerCount == 0) {
    screens.add(const NoPermissionsView());
    titles.add('Sem Permissão');
    screens.add(const NoPermissionsView());
    titles.add('Sem Permissão');
    drawerItemsVisualizador.add({
      'asset': 'assets/images/icons/not_permission.png',
      'title': 'Sem Permissão',
    });
    drawerItemsVisualizador.add({
      'asset': 'assets/images/icons/not_permission.png',
      'title': 'Sem Permissão',
    });
    bottomNavItems.add({
      'asset': 'assets/images/icons/not_permission.png',
      'label': 'Sem Permissão',
    });
    bottomNavItems.add({
      'asset': 'assets/images/icons/not_permission.png',
      'label': 'Sem Permissão',
    });
  }

  return {
    'user': user,
    'telas': screens,
    'titulos': titles,
    'drawerItemsVisualizador': drawerItemsVisualizador,
    'drawerItemsAdministrador': drawerItemsAdministrador,
    'bottomNavItems': bottomNavItems,
  };
}
