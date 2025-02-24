import 'package:flutter/material.dart';

/// Flutter code sample for [NavigationBar].

class NavigationBarApp extends StatelessWidget {
  const NavigationBarApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(useMaterial3: true),
      home: const NavigationExample(),
    );
  }
}

class NavigationExample extends StatefulWidget {
  const NavigationExample({super.key});

  @override
  State<NavigationExample> createState() => _NavigationExampleState();
}

class _NavigationExampleState extends State<NavigationExample> {
  int currentPageIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Amazing Gym',
          style: TextStyle(fontSize: 24, color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 245, 2, 2),
      ),
      bottomNavigationBar: NavigationBar(
        onDestinationSelected: (int index) {
          setState(() {
            currentPageIndex = index;
          });
        },
        indicatorColor: Colors.blue,
        selectedIndex: currentPageIndex,
        destinations: const <NavigationDestination>[
          NavigationDestination(
            selectedIcon: Icon(Icons.home),
            icon: Icon(Icons.home_outlined),
            label: 'Home',
          ),
          NavigationDestination(
            selectedIcon: Icon(Icons.card_membership_rounded),
            icon: Icon(Icons.card_membership_outlined),
            label: 'Memberships',
          ),
          NavigationDestination(
            selectedIcon: Icon(Icons.person),
            icon: Icon(Icons.person_outline),
            label: 'Profile',
          ),
        ],
      ),
      body: <Widget>[
        HomeContent(),
        WorkoutsContent(),
        ProfileContent(),
      ][currentPageIndex],
    );
  }
}

class HomeContent extends StatelessWidget {
  const HomeContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'Home Page Content',
        style: TextStyle(fontSize: 24, color: Colors.redAccent),
      ),
    );
  }
}

class WorkoutsContent extends StatelessWidget {
  const WorkoutsContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'Workouts Page Content',
        style: TextStyle(fontSize: 24, color: Colors.redAccent),
      ),
    );
  }
}

class ProfileContent extends StatelessWidget {
  const ProfileContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'Profile Page Content',
        style: TextStyle(fontSize: 24, color: Colors.redAccent),
      ),
    );
  }
}