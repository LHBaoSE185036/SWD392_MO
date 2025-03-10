import 'package:flutter/material.dart';
import 'package:amazingym_app/home.dart';

/// Custom AppBar for the app
class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: const Text(
        'Amazing Gym',
        style: TextStyle(fontSize: 24, color: Colors.white),
      ),
      centerTitle: true,
      backgroundColor: Colors.black,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

/// Custom Bottom Navigation Bar
class CustomBottomNavBar extends StatefulWidget {
  final Function(int) onItemSelected;
  final int currentIndex;

  const CustomBottomNavBar({
    super.key,
    required this.onItemSelected,
    required this.currentIndex,
  });

  @override
  State<CustomBottomNavBar> createState() => _CustomBottomNavBarState();
}

class _CustomBottomNavBarState extends State<CustomBottomNavBar> {
  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      onDestinationSelected: (int index) {
        widget.onItemSelected(index);
      },
      indicatorColor: Colors.green,
      backgroundColor: Colors.black,
      selectedIndex: widget.currentIndex,
      destinations: const <NavigationDestination>[
        NavigationDestination(
          selectedIcon: Icon(Icons.home, color: Color.fromARGB(255, 0, 101, 3)),
          icon: Icon(Icons.home_outlined, color: Colors.white),
          label: 'Home',
        ),
        NavigationDestination(
          selectedIcon: Icon(Icons.card_membership_rounded, color: Color.fromARGB(255, 0, 101, 3)),
          icon: Icon(Icons.card_membership_outlined, color: Colors.white),
          label: 'Memberships',
        ),
        NavigationDestination(
          selectedIcon: Icon(Icons.person, color: Color.fromARGB(255, 0, 101, 3)),
          icon: Icon(Icons.person_outline, color: Colors.white),
          label: 'Profile',
        ),
      ],
    );
  }
}
