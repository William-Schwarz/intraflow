import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CustomScreenDownload extends StatefulWidget {
  const CustomScreenDownload({super.key});

  @override
  CustomScreenDownloadState createState() => CustomScreenDownloadState();
}

class CustomScreenDownloadState extends State<CustomScreenDownload>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
    _animation = Tween<Offset>(
      begin: const Offset(0, 0),
      end: const Offset(0, -0.1),
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Baixando...',
          style: TextStyle(
            color: Colors.black,
          ),
        ),
        automaticallyImplyLeading: false,
        elevation: 0,
        backgroundColor: Colors.white,
      ),
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            SlideTransition(
              position: _animation,
              child: SvgPicture.asset(
                'assets/images/svgs/export_files_485156.svg',
                width: 300,
                height: 300,
              ),
            ),
            const SizedBox(
              height: 16,
            ),
            const SizedBox(
              height: 100,
              width: 100,
              child: CircularProgressIndicator(),
            ),
          ],
        ),
      ),
    );
  }
}
