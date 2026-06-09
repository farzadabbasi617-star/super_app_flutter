import 'package:flutter/material.dart';
import 'map_page.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/map_bloc.dart';
import '../../../core/di/service_locator.dart';
import '../../marketplace/presentation/pages/explore_page.dart';
import '../../marketplace/presentation/bloc/product_bloc.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    BlocProvider(
      create: (context) => sl<MapBloc>(),
      child: const MapPage(),
    ),
    BlocProvider(
      create: (context) => sl<ProductBloc>(),
      child: const ExplorePage(),
    ),
    const Center(child: Text('Rental Booking Page (Coming Soon)')),
    const Center(child: Text('Profile Page (Coming Soon)')),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Theme.of(context).colorScheme.primary,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.map), label: 'Map'),
          BottomNavigationBarItem(icon: Icon(Icons.explore), label: 'Explore'),
          BottomNavigationBarItem(icon: Icon(Icons.build), label: 'Rental'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}
