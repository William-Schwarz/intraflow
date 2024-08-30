import 'package:flutter/material.dart';
import 'package:intraflow/utils/theme/custom_colors.dart';

class CustomTabScaffold extends StatelessWidget {
  final String title;
  final List<Widget> tabs;
  final TabController controller;
  final List<Widget> tabViews;

  const CustomTabScaffold({
    super.key,
    required this.title,
    required this.tabs,
    required this.controller,
    required this.tabViews,
  });

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: tabs.length,
      child: Scaffold(
        appBar: AppBar(
          elevation: 0,
          title: Center(
            child: Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
              ),
            ),
          ),
          bottom: TabBar(
            tabs: tabs,
            controller: controller,
            indicatorPadding: const EdgeInsets.only(
              bottom: 8,
            ),
            indicatorWeight: 4,
            labelColor: Colors.white,
          ),
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.vertical(
                bottom: Radius.circular(12),
              ),
              gradient: CustomColors.primaryGradient,
            ),
          ),
        ),
        body: TabBarView(
          controller: controller,
          children: tabViews,
        ),
      ),
    );
  }
}
