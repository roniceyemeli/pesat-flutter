import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../widgets/common/glassmorphic_nav_bar.dart';

class ShellScreen extends StatefulWidget {
  final Widget child;
  final String location;

  const ShellScreen({
    Key? key,
    required this.child,
    required this.location,
  }) : super(key: key);

  @override
  State<ShellScreen> createState() => _ShellScreenState();
}

class _ShellScreenState extends State<ShellScreen> {
  late int _selectedIndex;

  @override
  void initState() {
    super.initState();
    _selectedIndex = _getIndexFromLocation(widget.location);
  }

  @override
  void didUpdateWidget(ShellScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.location != oldWidget.location) {
      _selectedIndex = _getIndexFromLocation(widget.location);
    }
  }

  int _getIndexFromLocation(String location) {
    if (location.startsWith('/events')) {
      return 1;
    } else if (location.startsWith('/profile')) {
      return 2;
    }
    return 0; // home
  }

  void _onNavItemTapped(int index) {
    setState(() => _selectedIndex = index);

    switch (index) {
      case 0:
        context.go('/home');
        break;
      case 1:
        context.go('/events');
        break;
      case 2:
        context.go('/profile');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: widget.child,
      bottomNavigationBar: GlassmorphicNavBar(
        selectedIndex: _selectedIndex,
        onItemSelected: _onNavItemTapped,
        items: [
          NavigationItem(icon: Icons.home, label: 'Home'),
          NavigationItem(icon: Icons.event, label: 'Events'),
          NavigationItem(icon: Icons.person, label: 'Profile'),
        ],
      ),
    );
  }
}
