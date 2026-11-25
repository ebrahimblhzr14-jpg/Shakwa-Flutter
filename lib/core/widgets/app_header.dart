import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../constants/app_colors.dart';
import '../constants/app_dimensions.dart';
import '../../data/models/user_model.dart';
import '../../features/authentication/controllers/auth_controller.dart';

class AppHeader extends ConsumerWidget implements PreferredSizeWidget {
  final String title;
  final String? subtitle;
  final bool showBack;
  final bool showRoleSwitcher;
  final List<Widget>? actions;

  const AppHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.showBack = false,
    this.showRoleSwitcher = true,
    this.actions,
  });

  @override
  Size get preferredSize => const Size.fromHeight(68.0);

  void _showRoleSwitcherDialog(
    BuildContext context,
    WidgetRef ref,
    UserModel? currentUser,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: Container(
          padding: const EdgeInsets.all(AppDimensions.p20),
          decoration: const BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(AppDimensions.radiusXL),
              topRight: Radius.circular(AppDimensions.radiusXL),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: AppDimensions.borderRadiusFull,
                  ),
                ),
              ),
              const SizedBox(height: AppDimensions.p16),
              const Text(
                'التبديل بين الحسابات التجريبية (الأدوار)',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                  fontFamily: 'Cairo',
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'اختر الدور الذي ترغب في استعراض واجهاته وصلاحياته:',
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                  fontFamily: 'Cairo',
                ),
              ),
              const SizedBox(height: AppDimensions.p16),
              _buildRoleTile(
                context: ctx,
                ref: ref,
                title: 'مواطن / مستخدم (User)',
                subtitle: 'أحمد محمد الشمري — تقديم ومتابعة الشكاوى',
                role: UserRole.user,
                isSelected: currentUser?.role == UserRole.user,
                icon: Icons.person_rounded,
                targetRoute: '/user-dashboard',
              ),
              _buildRoleTile(
                context: ctx,
                ref: ref,
                title: 'مشرف معالجة (Admin)',
                subtitle: 'م. سارة العتيبي — معالجة الشكاوى وإدارة النظام',
                role: UserRole.admin,
                isSelected: currentUser?.role == UserRole.admin,
                icon: Icons.engineering_rounded,
                targetRoute: '/admin-dashboard',
              ),
              _buildRoleTile(
                context: ctx,
                ref: ref,
                title: 'مسؤول عام (SuperAdmin)',
                subtitle: 'د. فيصل المقرن — الإسناد، المستخدمين، والسجل',
                role: UserRole.superAdmin,
                isSelected: currentUser?.role == UserRole.superAdmin,
                icon: Icons.admin_panel_settings_rounded,
                targetRoute: '/super-dashboard',
              ),
              const SizedBox(height: AppDimensions.p12),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRoleTile({
    required BuildContext context,
    required WidgetRef ref,
    required String title,
    required String subtitle,
    required UserRole role,
    required bool isSelected,
    required IconData icon,
    required String targetRoute,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isSelected ? AppColors.primarySurface : AppColors.surface,
        border: Border.all(
          color: isSelected ? AppColors.primary : AppColors.border,
          width: isSelected ? 1.5 : 1.0,
        ),
        borderRadius: AppDimensions.borderRadiusMD,
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: isSelected
              ? AppColors.primary
              : AppColors.surfaceVariant,
          foregroundColor: isSelected ? Colors.white : AppColors.primary,
          child: Icon(icon, size: 20),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
            color: AppColors.textPrimary,
            fontFamily: 'Cairo',
          ),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(
            fontSize: 11,
            color: AppColors.textSecondary,
            fontFamily: 'Cairo',
          ),
        ),
        trailing: isSelected
            ? const Icon(Icons.check_circle_rounded, color: AppColors.primary)
            : null,
        onTap: () async {
          Navigator.of(context).pop();
          await ref.read(authProvider.notifier).switchRole(role);
          if (context.mounted) {
            context.go(targetRoute);
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final user = authState.user;

    return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: AppColors.surface,
      elevation: 0,
      scrolledUnderElevation: 1,
      titleSpacing: AppDimensions.p16,
      title: Row(
        children: [
          if (showBack)
            Padding(
              padding: const EdgeInsets.only(left: 8),
              child: IconButton(
                icon: const Icon(
                  Icons.arrow_back_ios_rounded,
                  size: 20,
                  color: AppColors.primary,
                ),
                onPressed: () => context.pop(),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ),
          // Logo Icon
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.asset(
              'assets/images/app_icon.png',
              width: 32,
              height: 32,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: AppDimensions.p12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                    fontFamily: 'Cairo',
                  ),
                ),
                if (subtitle != null)
                  Text(
                    subtitle!,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textMuted,
                      fontFamily: 'Cairo',
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        if (showRoleSwitcher)
          Container(
            margin: const EdgeInsets.symmetric(vertical: 14, horizontal: 4),
            child: OutlinedButton.icon(
              onPressed: () => _showRoleSwitcherDialog(context, ref, user),
              icon: const Icon(
                Icons.swap_horiz_rounded,
                size: 16,
                color: AppColors.primary,
              ),
              label: Text(
                user?.role.shortNameArabic ?? 'تبديل الدور',
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                  fontFamily: 'Cairo',
                ),
              ),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.border, width: 1.2),
                backgroundColor: AppColors.primarySurface,
                shape: RoundedRectangleBorder(
                  borderRadius: AppDimensions.borderRadiusFull,
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 0,
                ),
              ),
            ),
          ),
        if (actions != null) ...actions!,
        const SizedBox(width: AppDimensions.p8),
      ],
    );
  }
}
