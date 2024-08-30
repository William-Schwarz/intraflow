import 'dart:async';
import 'dart:developer' as developer;
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intraflow/services/auth/auth_service.dart';
import 'package:intraflow/utils/theme/custom_colors.dart';
import 'package:intraflow/views/network_failed_view.dart';
import 'package:intraflow/widgets/custom_bottom_navigation_bar.dart';
import 'package:intraflow/widgets/custom_drawer.dart';

class NavigationView extends StatefulWidget {
  final List<String> titles;
  final List<Widget> screens;
  final List<Map<String, dynamic>> drawerItemsViewer;
  final List<Map<String, dynamic>> drawerItemsAdministrator;
  final List<Map<String, dynamic>> bottomNavItems;
  final int index;

  const NavigationView({
    super.key,
    required this.titles,
    required this.screens,
    required this.drawerItemsViewer,
    required this.drawerItemsAdministrator,
    required this.bottomNavItems,
    required this.index,
  });

  @override
  State<NavigationView> createState() => NavigationViewState();
}

class NavigationViewState extends State<NavigationView> {
  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;
  late AuthService authService = AuthService();
  late int _currentIndex;
  bool connectivityNone = false;

  @override
  void initState() {
    super.initState();
    _initConnectivity();
    _connectivitySubscription =
        _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
    _currentIndex = widget.index;
  }

  @override
  void dispose() {
    _connectivitySubscription.cancel();
    super.dispose();
  }

  Future<void> _initConnectivity() async {
    late List<ConnectivityResult> result;
    try {
      result = await _connectivity.checkConnectivity();
    } on PlatformException catch (e) {
      developer.log('Couldn\'t check connectivity status', error: e);
      return;
    }
    if (!mounted) {
      return Future.value(null);
    }

    return _updateConnectionStatus(result);
  }

  Future<void> _updateConnectionStatus(List<ConnectivityResult> result) async {
    if (result.contains(ConnectivityResult.none)) {
      setState(() {
        connectivityNone = true;
      });
    } else {
      setState(() {
        connectivityNone = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.vertical(
              bottom: Radius.circular(
                12,
              ),
            ),
            gradient: CustomColors.primaryGradient,
          ),
          child: Center(
            child: Text(
              widget.titles[_currentIndex],
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
              ),
            ),
          ),
        ),
      ),
      drawer: CustomDrawer(
        onItemTapped: _onItemTapped,
        drawerItemsViewer: widget.drawerItemsViewer,
        drawerItemsAdministrator: widget.drawerItemsAdministrator,
      ),
      body: connectivityNone
          ? const NetworkingFailedView()
          : widget.screens.elementAt(_currentIndex),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(
              12,
            ),
          ),
          gradient: CustomColors.primaryGradient,
        ),
        child: CustomBottomNavigationBar(
          currentIndex: _currentIndex,
          onItemTapped: _onItemTapped,
          bottomNavItems: widget.bottomNavItems,
        ),
      ),
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }
}
