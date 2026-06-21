import 'package:flutter/material.dart';
import 'map_page.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/map_bloc.dart';
import 'package:super_app_flutter/core/di/service_locator.dart';
import 'package:super_app_flutter/features/marketplace/presentation/pages/explore_page.dart';
import 'package:super_app_flutter/features/marketplace/presentation/bloc/product_bloc.dart';
import 'package:super_app_flutter/features/rental/presentation/pages/rental_page.dart';
import 'package:super_app_flutter/features/profile/presentation/pages/profile_page.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _selectedIndex = 0;

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      BlocProvider(create: (context) => sl<MapBloc>(), child: const MapPage()),
      BlocProvider(
        create: (context) => sl<ProductBloc>(),
        child: const ExplorePage(),
      ),
      BlocProvider(
        create: (context) => sl<ProductBloc>(),
        child: const RentalPage(),
      ),
      const ProfilePage(),
    ];
  }

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
          BottomNavigationBarItem(
            icon: Icon(Icons.map_outlined),
            label: 'نقشه لایو',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_bag_outlined),
            label: 'خرید کالا',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.build_outlined),
            label: 'اجاره ابزار',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_balance_wallet_outlined),
            label: 'کیف پول و مالی',
          ),
        ],
      ),
    );
  }
}
