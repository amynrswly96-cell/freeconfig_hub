import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// اسکلت اصلی برنامه شامل Bottom Navigation
/// خانه / دسته‌بندی‌ها / سرورهای من / درباره ما
class RootShell extends StatelessWidget {
  final Widget child;
  final String location;

  const RootShell({super.key, required this.child, required this.location});

  int get _currentIndex {
    if (location.startsWith('/categories')) return 1;
    if (location.startsWith('/my-servers')) return 2;
    if (location.startsWith('/about')) return 3;
    return 0;
  }

  void _onTap(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.go('/home');
        break;
      case 1:
        context.go('/categories');
        break;
      case 2:
        context.go('/my-servers');
        break;
      case 3:
        context.go('/about');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (i) => _onTap(context, i),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_rounded),
            label: 'خانه',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.category_rounded),
            label: 'دسته‌بندی‌ها',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.dns_rounded),
            label: 'سرورهای من',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.info_rounded),
            label: 'درباره ما',
          ),
        ],
      ),
    );
  }
}
