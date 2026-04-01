import 'package:flutter/material.dart';
import 'package:app_ecommerce/screens/home_screen.dart';
import 'package:app_ecommerce/screens/reels_screen.dart';
import 'package:app_ecommerce/screens/services_screen.dart';
import 'package:app_ecommerce/screens/profile_screen.dart';
import 'package:app_ecommerce/widgets/global_header.dart';

class MainNavigation extends StatefulWidget {
  final int initialIndex;

  const MainNavigation({super.key, this.initialIndex = 0});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  late int _currentIndex;
  String _searchQuery = "";

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  void _handleSearch(String query) {
    setState(() {
      _searchQuery = query;
      // Switch to Home tab (index 0) if searching from elsewhere
      if (_currentIndex != 0) {
        _currentIndex = 0;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          GlobalHeader(
            onSearch: _handleSearch,
            initialSearchQuery: _searchQuery,
          ),
          Expanded(
            child: IndexedStack(
              index: _currentIndex,
              children: [
                HomeScreen(searchQuery: _searchQuery),
                ReelsScreen(searchQuery: _searchQuery),
                const ServicesScreen(),
                const ProfileScreen(),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 5),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(
            top: BorderSide(color: Colors.grey.shade200, width: 1.0),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(Icons.home_filled, 'ACCUEIL', 0),
            _buildNavItem(Icons.play_circle_rounded, 'DÉCOUVRIR', 1),
            _buildNavItem(Icons.smart_display_rounded, 'SERVICES', 2),
            _buildNavItem(Icons.person_outline_rounded, 'PROFIL', 3),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    final isActive = _currentIndex == index;
    return GestureDetector(
      onTap: () {
        FocusManager.instance.primaryFocus?.unfocus();
        setState(() {
          _currentIndex = index;
        });
      },
      child: Container(
        color: Colors.transparent, // For better hit testing
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isActive ? const Color(0xFFFF6F00) : Colors.grey.shade600,
              size: 26,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isActive
                    ? const Color(0xFFFF6F00)
                    : Colors.grey.shade600,
                fontSize: 12,
                fontFamily: 'Roboto',
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
