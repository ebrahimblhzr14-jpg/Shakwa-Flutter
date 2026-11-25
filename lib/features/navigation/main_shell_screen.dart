import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../data/models/user_model.dart';
import '../authentication/controllers/auth_controller.dart';

class MainShellScreen extends ConsumerWidget {
  final Widget child;

  const MainShellScreen({super.key, required this.child});

  int _calculateSelectedIndex(BuildContext context, UserRole role) {
    final location = GoRouterState.of(context).uri.toString();

    switch (role) {
      case UserRole.user:
        if (location.startsWith('/user-dashboard')) return 0;
        if (location.startsWith('/my-complaints')) return 1;
        if (location.startsWith('/create-complaint')) return 2;
        if (location.startsWith('/profile')) return 3;
        return 0;

      case UserRole.admin:
        if (location.startsWith('/admin-dashboard')) return 0;
        if (location.startsWith('/assigned-complaints')) return 1;
        if (location.startsWith('/management')) return 2;
        if (location.startsWith('/profile')) return 3;
        return 0;

      case UserRole.superAdmin:
        if (location.startsWith('/super-dashboard')) return 0;
        if (location.startsWith('/all-complaints')) return 1;
        if (location.startsWith('/users')) return 2;
        if (location.startsWith('/history')) return 3;
        if (location.startsWith('/profile')) return 4;
        return 0;
    }
  }

  void _onItemTapped(int index, BuildContext context, UserRole role) {
    switch (role) {
      case UserRole.user:
        switch (index) {
          case 0:
            context.go('/user-dashboard');
            break;
          case 1:
            context.go('/my-complaints');
            break;
          case 2:
            context.go('/create-complaint');
            break;
          case 3:
            context.go('/profile');
            break;
        }
        break;

      case UserRole.admin:
        switch (index) {
          case 0:
            context.go('/admin-dashboard');
            break;
          case 1:
            context.go('/assigned-complaints');
            break;
          case 2:
            context.go('/management');
            break;
          case 3:
            context.go('/profile');
            break;
        }
        break;

      case UserRole.superAdmin:
        switch (index) {
          case 0:
            context.go('/super-dashboard');
            break;
          case 1:
            context.go('/all-complaints');
            break;
          case 2:
            context.go('/users');
            break;
          case 3:
            context.go('/history');
            break;
          case 4:
            context.go('/profile');
            break;
        }
        break;
    }
  }

  List<BottomNavigationBarItem> _buildNavItems(UserRole role) {
    switch (role) {
      case UserRole.user:
        return const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_outlined),
            activeIcon: Icon(Icons.dashboard_rounded),
            label: 'الرئيسية',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.assignment_outlined),
            activeIcon: Icon(Icons.assignment_rounded),
            label: 'شكاواي',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_circle_outline_rounded),
            activeIcon: Icon(Icons.add_circle_rounded),
            label: 'تقديم شكوى',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline_rounded),
            activeIcon: Icon(Icons.person_rounded),
            label: 'حسابي',
          ),
        ];

      case UserRole.admin:
        return const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_outlined),
            activeIcon: Icon(Icons.dashboard_rounded),
            label: 'لوحة التحكم',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.assignment_turned_in_outlined),
            activeIcon: Icon(Icons.assignment_turned_in_rounded),
            label: 'المعينة لي',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.tune_outlined),
            activeIcon: Icon(Icons.tune_rounded),
            label: 'إدارة النظام',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline_rounded),
            activeIcon: Icon(Icons.person_rounded),
            label: 'حسابي',
          ),
        ];

      case UserRole.superAdmin:
        return const [
          BottomNavigationBarItem(
            icon: Icon(Icons.analytics_outlined),
            activeIcon: Icon(Icons.analytics_rounded),
            label: 'اللوحة المركزية',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.folder_shared_outlined),
            activeIcon: Icon(Icons.folder_shared_rounded),
            label: 'كل الشكاوى',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people_outline_rounded),
            activeIcon: Icon(Icons.people_rounded),
            label: 'المستخدمين',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history_outlined),
            activeIcon: Icon(Icons.history_rounded),
            label: 'السجل',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline_rounded),
            activeIcon: Icon(Icons.person_rounded),
            label: 'حسابي',
          ),
        ];
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final user = authState.user;
    final role = user?.role ?? UserRole.user;

    final selectedIndex = _calculateSelectedIndex(context, role);
    final navItems = _buildNavItems(role);

    return Scaffold(
      body: child,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              offset: const Offset(0, -2),
              blurRadius: 10,
            ),
          ],
        ),
        child: SafeArea(
          child: BottomNavigationBar(
            currentIndex: selectedIndex >= navItems.length ? 0 : selectedIndex,
            onTap: (index) => _onItemTapped(index, context, role),
            items: navItems,
            selectedItemColor: AppColors.primary,
            unselectedItemColor: AppColors.textMuted,
            backgroundColor: AppColors.surface,
            elevation: 0,
            type: BottomNavigationBarType.fixed,
            selectedFontSize: 11,
            unselectedFontSize: 11,
          ),
        ),
      ),
    );
  }
}
