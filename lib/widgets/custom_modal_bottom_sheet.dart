import 'package:flutter/material.dart';

class CustomModalBottomSheet extends StatelessWidget {
  final Widget child;

  const CustomModalBottomSheet({
    super.key,
    required this.child,
  });

  Future<String?> show(BuildContext context) async {
    return await showModalBottomSheet<String?>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      transitionAnimationController: AnimationController(
        vsync: Navigator.of(context),
        duration: const Duration(milliseconds: 800),
        reverseDuration: const Duration(milliseconds: 200),
      ),
      builder: (BuildContext context) {
        return ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(32),
            topRight: Radius.circular(32),
          ),
          child: Container(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.8,
            ),
            color: Colors.white,
            child: child,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
