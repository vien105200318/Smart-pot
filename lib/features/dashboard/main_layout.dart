import 'package:flutter/material.dart';

import 'home_screen.dart';
import 'devices_tab.dart';
import 'community_tab.dart';
import 'history_tab.dart';
import 'settings_tab.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  bool _isTransitioning = false; 
  late AnimationController _transitionController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  final List<Widget> _screens = [
    const HomeScreen(),     
    const DevicesTab(),     
    const CommunityTab(),   
    const HistoryTab(),     
    const SettingsTab(),    
  ];

  @override
  void initState() {
    super.initState();
    
    _transitionController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    );

    _scaleAnimation = Tween<double>(begin: 0.0, end: 40.0).animate(
      CurvedAnimation(
        parent: _transitionController, 
        curve: const Interval(0.0, 0.5, curve: Curves.easeInCubic) 
      ),
    );

    _fadeAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _transitionController, 
        curve: const Interval(0.5, 1.0, curve: Curves.easeOut)
      ),
    );
  }

  @override
  void dispose() {
    _transitionController.dispose();
    super.dispose();
  }

  Future<void> _onGreenVibeTapped() async {
    if (_currentIndex == 2 || _isTransitioning) return;
    
    setState(() => _isTransitioning = true); 

    void listener() {
      if (_transitionController.value >= 0.5 && _currentIndex != 2) {
        setState(() => _currentIndex = 2);
      }
    }
    _transitionController.addListener(listener);

    await _transitionController.forward();

    _transitionController.removeListener(listener);
    setState(() => _isTransitioning = false);
  }

  Future<void> _onTabTapped(int index) async {
    if (_currentIndex == index || _isTransitioning) return;

    if (_currentIndex == 2) {
      setState(() => _isTransitioning = true);

      void listener() {
        if (_transitionController.value <= 0.5 && _currentIndex == 2) {
          setState(() => _currentIndex = index);
        }
      }
      _transitionController.addListener(listener);

      await _transitionController.reverse();

      _transitionController.removeListener(listener);
      setState(() => _isTransitioning = false);
    } else {
      setState(() => _currentIndex = index);
    }
  }

  BoxDecoration _fabDecoration() {
    return BoxDecoration(
      shape: BoxShape.circle,
      gradient: const LinearGradient(
        colors: [Color(0xFF00C896), Color(0xFF007558)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      boxShadow: [
        BoxShadow(
          color: const Color(0xFF00C896).withOpacity(0.4), 
          blurRadius: 15, 
          offset: const Offset(0, 4),
        ),
      ],
      border: Border.all(color: Colors.white.withOpacity(0.15), width: 1.5), 
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          backgroundColor: const Color(0xFF0D1117), 
          body: IndexedStack(
            index: _currentIndex,
            children: _screens,
          ),

          floatingActionButton: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300), 
            transitionBuilder: (Widget child, Animation<double> animation) {
              return ScaleTransition(
                scale: animation,
                child: FadeTransition(opacity: animation, child: child),
              );
            },
            child: _currentIndex == 2
                ? _buildBareLeaf()      
                : _buildFullActionButton(), 
          ),
          
          floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

          bottomNavigationBar: BottomAppBar(
            color: const Color(0xFF161B22), 
            shape: const CircularNotchedRectangle(),
            notchMargin: 8.0, 
            child: SizedBox(
              height: 60,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      _buildNavItem(icon: Icons.home_outlined, activeIcon: Icons.home, label: 'Home', index: 0),
                      _buildNavItem(icon: Icons.sensors_outlined, activeIcon: Icons.sensors, label: 'Devices', index: 1),
                    ],
                  ),
                  Row(
                    children: [
                      _buildNavItem(icon: Icons.bar_chart_outlined, activeIcon: Icons.bar_chart, label: 'History', index: 3),
                      _buildNavItem(icon: Icons.settings_outlined, activeIcon: Icons.settings, label: 'Settings', index: 4),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),

        // LỚP 2: MÀNG XANH CHUYỂN CẢNH (Chỉ bung ra khi bấm chuyển sang GreenVibe hoặc thoát ra)
        if (_isTransitioning)
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 25.0), 
              child: IgnorePointer(
                child: AnimatedBuilder(
                  animation: _transitionController,
                  builder: (context, child) {
                    return Opacity(
                      opacity: _fadeAnimation.value,
                      child: ScaleTransition(
                        scale: _scaleAnimation,
                        child: Container(
                          width: 65,
                          height: 65,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: [Color(0xFF00C896), Color(0xFF007558)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildBareLeaf() {
    return Container(
      key: const ValueKey('bare_leaf'), 
      margin: const EdgeInsets.only(top: 50),
      height: 65,
      width: 65,
      alignment: Alignment.center,
      child: const Icon(
        Icons.eco, 
        color: Color(0xFF00C896), 
        size: 38,
      ),
    );
  }

  Widget _buildFullActionButton() {
    return Container(
      key: const ValueKey('full_fab'), 
      margin: const EdgeInsets.only(top: 50),
      height: 65,
      width: 65,
      decoration: _fabDecoration(),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(50),
          onTap: _onGreenVibeTapped,
          child: const Icon(Icons.eco, color: Colors.white, size: 36), 
        ),
      ),
    );
  }

  Widget _buildNavItem({required IconData icon, required IconData activeIcon, required String label, required int index}) {
    final isSelected = _currentIndex == index;
    final color = isSelected ? const Color(0xFF00C896) : Colors.white54;

    return MaterialButton(
      minWidth: 75, 
      onPressed: () => _onTabTapped(index),
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(isSelected ? activeIcon : icon, color: color, size: 26),
          const SizedBox(height: 4),
          Text(
            label, 
            style: TextStyle(
              color: color, 
              fontSize: 10, 
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal
            )
          ),
        ],
      ),
    );
  }
}