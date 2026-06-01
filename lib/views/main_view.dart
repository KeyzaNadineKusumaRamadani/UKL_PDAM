import 'package:alirin/service/app_collors.dart';
import 'package:flutter/material.dart';
import 'dashboard_view.dart';
import 'service_view.dart';
import 'customer_view.dart';
import 'bill_view.dart';
import 'profile_view.dart';

class MainView extends StatefulWidget {
  const MainView({super.key});

  @override
  State<MainView> createState() => _MainViewState();
}

class _MainViewState extends State<MainView> {
  int _selectedIndex = 0;
  final Map<int, Widget> _pageCache = {};

  void _switchTab(int index) {
    setState(() {
      _selectedIndex = index;
      // Invalidate cache so tab rebuilds fresh when navigated from dashboard
      _pageCache.remove(index);
    });
  }

  Widget _buildPage(int index) {
    if (!_pageCache.containsKey(index)) {
      switch (index) {
        case 0: _pageCache[index] = DashboardView(onNavigate: _switchTab); break;
        case 1: _pageCache[index] = const ServiceView(); break;
        case 2: _pageCache[index] = const CustomerView(); break;
        case 3: _pageCache[index] = const BillView(); break;
        case 4: _pageCache[index] = const ProfileView(); break;
      }
    }
    return _pageCache[index]!;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Stack(
        children: List.generate(5,
          (i) => Offstage(offstage: _selectedIndex != i, child: _buildPage(i))),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppColors.bgCard,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: (i) => setState(() => _selectedIndex = i),
          backgroundColor: Colors.transparent,
          elevation: 0,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: AppColors.textMuted,
          selectedFontSize: 11,
          unselectedFontSize: 11,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.dashboard_outlined),
              activeIcon: Icon(Icons.dashboard_rounded),
              label: 'Dash board',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.water_drop_outlined),
              activeIcon: Icon(Icons.water_drop),
              label: 'Layanan',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.people_outline),
              activeIcon: Icon(Icons.people),
              label: 'Customer',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.receipt_long_outlined),
              activeIcon: Icon(Icons.receipt_long),
              label: 'Tagihan',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}