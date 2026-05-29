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
  // Simpan halaman yang sudah pernah dibuka agar tidak rebuild ulang
  final Map<int, Widget> _pageCache = {};

  Widget _buildPage(int index) {
    if (!_pageCache.containsKey(index)) {
      switch (index) {
        case 0:
          _pageCache[index] = const DashboardView();
          break;
        case 1:
          _pageCache[index] = const ServiceView();
          break;
        case 2:
          _pageCache[index] = const CustomerView();
          break;
        case 3:
          _pageCache[index] = const BillView();
          break;
        case 4:
          _pageCache[index] = const ProfileView();
          break;
      }
    }
    return _pageCache[index]!;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      // Pakai Offstage agar halaman tidak di-rebuild saat pindah tab
      // tapi tetap hidup di memory (tidak reset state)
      body: Stack(
        children: List.generate(5, (i) {
          return Offstage(
            offstage: _selectedIndex != i,
            child: _buildPage(i),
          );
        }),
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Color(0xFF0D1526),
          border: Border(
            top: BorderSide(color: AppColors.border, width: 1),
          ),
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
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.dashboard_outlined),
              activeIcon: Icon(Icons.dashboard),
              label: 'Dashboard',
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
              label: 'Profil',
            ),
          ],
        ),
      ),
    );
  }
}
