import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_dialog.dart';
import '../../../core/widgets/app_header.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../authentication/controllers/auth_controller.dart';

class UserProfileScreen extends ConsumerStatefulWidget {
  const UserProfileScreen({super.key});

  @override
  ConsumerState<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends ConsumerState<UserProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _deptController;
  bool _isEditing = false;
  bool _initialized = false;
  bool _isSaving = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _deptController.dispose();
    super.dispose();
  }

  void _initControllers() {
    if (_initialized) return;
    final user = ref.read(authProvider).user;
    _nameController = TextEditingController(text: user?.fullName ?? '');
    _emailController = TextEditingController(text: user?.email ?? '');
    _phoneController = TextEditingController(text: user?.phone ?? '');
    _deptController = TextEditingController(text: user?.department ?? '');
    _initialized = true;
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);
    final success = await ref
        .read(authProvider.notifier)
        .updateProfile(
          fullName: _nameController.text.trim(),
          email: _emailController.text.trim(),
          phone: _phoneController.text.trim(),
          department: _deptController.text.trim(),
        );

    if (mounted) {
      setState(() {
        _isSaving = false;
        _isEditing = false;
      });
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'تم تحديث الملف الشخصي بنجاح',
              style: TextStyle(fontFamily: 'Cairo'),
            ),
            backgroundColor: AppColors.success,
          ),
        );
      }
    }
  }

  void _showChangePasswordDialog() {
    final curPassController = TextEditingController();
    final newPassController = TextEditingController();
    final confirmPassController = TextEditingController();
    final passFormKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: AppDimensions.borderRadiusLG,
          ),
          title: const Text(
            'تغيير كلمة المرور',
            style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold),
          ),
          content: Form(
            key: passFormKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AppTextField(
                    label: 'كلمة المرور الحالية',
                    controller: curPassController,
                    isPassword: true,
                    validator: (v) => v == null || v.isEmpty
                        ? AppStrings.requiredField
                        : null,
                  ),
                  const SizedBox(height: 12),
                  AppTextField(
                    label: 'كلمة المرور الجديدة',
                    controller: newPassController,
                    isPassword: true,
                    validator: (v) => v == null || v.length < 6
                        ? AppStrings.shortPassword
                        : null,
                  ),
                  const SizedBox(height: 12),
                  AppTextField(
                    label: 'تأكيد كلمة المرور الجديدة',
                    controller: confirmPassController,
                    isPassword: true,
                    validator: (v) => v != newPassController.text
                        ? AppStrings.passwordMismatch
                        : null,
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('إلغاء', style: TextStyle(fontFamily: 'Cairo')),
            ),
            ElevatedButton(
              onPressed: () {
                if (passFormKey.currentState!.validate()) {
                  Navigator.of(ctx).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'تم تغيير كلمة المرور بنجاح',
                        style: TextStyle(fontFamily: 'Cairo'),
                      ),
                      backgroundColor: AppColors.success,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
              ),
              child: const Text(
                'تحديث',
                style: TextStyle(fontFamily: 'Cairo', color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleLogout() async {
    final confirm = await AppDialog.showConfirmation(
      context: context,
      title: AppStrings.logout,
      message: AppStrings.logoutConfirmMsg,
      confirmText: 'تسجيل الخروج',
      cancelText: 'إلغاء',
      isDestructive: true,
      icon: Icons.logout_rounded,
    );

    if (confirm == true && mounted) {
      await ref.read(authProvider.notifier).logout();
      if (mounted) {
        context.go('/login');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final user = authState.user;

    _initControllers();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppHeader(
        title: AppStrings.navProfile,
        subtitle: 'إدارة الحساب والمعلومات الشخصية',
        showRoleSwitcher: true,
        actions: [
          IconButton(
            icon: Icon(
              _isEditing ? Icons.close_rounded : Icons.edit_outlined,
              color: AppColors.primary,
            ),
            onPressed: () {
              setState(() {
                _isEditing = !_isEditing;
                if (!_isEditing) {
                  // Reset to original values
                  _nameController.text = user?.fullName ?? '';
                  _emailController.text = user?.email ?? '';
                  _phoneController.text = user?.phone ?? '';
                  _deptController.text = user?.department ?? '';
                }
              });
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimensions.p16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // User Avatar Card
              AppCard(
                padding: const EdgeInsets.all(AppDimensions.p20),
                child: Column(
                  children: [
                    Stack(
                      children: [
                        CircleAvatar(
                          radius: 44,
                          backgroundColor: AppColors.primarySurface,
                          child: Text(
                            user != null && user.fullName.isNotEmpty
                                ? user.fullName.characters.first
                                : 'ش',
                            style: const TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                              fontFamily: 'Cairo',
                            ),
                          ),
                        ),
                        if (_isEditing)
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: const BoxDecoration(
                                color: AppColors.secondary,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.camera_alt,
                                size: 16,
                                color: Colors.white,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: AppDimensions.p12),
                    Text(
                      user?.fullName ?? '',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                        fontFamily: 'Cairo',
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primarySurface,
                        borderRadius: AppDimensions.borderRadiusFull,
                      ),
                      child: Text(
                        user?.role.displayNameArabic ?? '',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                          fontFamily: 'Cairo',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppDimensions.p16),

              // Personal Information Form Card
              AppCard(
                padding: const EdgeInsets.all(AppDimensions.p16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'المعلومات الشخصية',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                            fontFamily: 'Cairo',
                          ),
                        ),
                        if (!_isEditing)
                          TextButton.icon(
                            onPressed: () => setState(() => _isEditing = true),
                            icon: const Icon(Icons.edit, size: 16),
                            label: const Text(
                              'تعديل',
                              style: TextStyle(
                                fontFamily: 'Cairo',
                                fontSize: 12,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: AppDimensions.p12),

                    // Full Name
                    AppTextField(
                      label: AppStrings.fullName,
                      controller: _nameController,
                      readOnly: !_isEditing,
                      prefixIcon: Icons.person_outline_rounded,
                      validator: (v) => v == null || v.isEmpty
                          ? AppStrings.requiredField
                          : null,
                    ),
                    const SizedBox(height: AppDimensions.p14),

                    // Email
                    AppTextField(
                      label: AppStrings.email,
                      controller: _emailController,
                      readOnly: !_isEditing,
                      prefixIcon: Icons.email_outlined,
                      validator: (v) => v == null || !v.contains('@')
                          ? AppStrings.invalidEmail
                          : null,
                    ),
                    const SizedBox(height: AppDimensions.p14),

                    // Phone
                    AppTextField(
                      label: 'رقم الجوال',
                      controller: _phoneController,
                      readOnly: !_isEditing,
                      prefixIcon: Icons.phone_outlined,
                    ),
                    const SizedBox(height: AppDimensions.p14),

                    // Department
                    AppTextField(
                      label: 'الجهة / القسم',
                      controller: _deptController,
                      readOnly: !_isEditing,
                      prefixIcon: Icons.business_outlined,
                    ),

                    if (_isEditing) ...[
                      const SizedBox(height: AppDimensions.p20),
                      Row(
                        children: [
                          Expanded(
                            child: AppButton(
                              text: AppStrings.cancel,
                              variant: AppButtonVariant.outline,
                              height: 44,
                              onPressed: () =>
                                  setState(() => _isEditing = false),
                            ),
                          ),
                          const SizedBox(width: AppDimensions.p12),
                          Expanded(
                            child: AppButton(
                              text: AppStrings.save,
                              isLoading: _isSaving,
                              height: 44,
                              onPressed: _handleSave,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: AppDimensions.p16),

              // Security & Actions Card
              AppCard(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Column(
                  children: [
                    ListTile(
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.primarySurface,
                          borderRadius: AppDimensions.borderRadiusSM,
                        ),
                        child: const Icon(
                          Icons.lock_reset_rounded,
                          color: AppColors.primary,
                          size: 20,
                        ),
                      ),
                      title: const Text(
                        'تغيير كلمة المرور',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Cairo',
                        ),
                      ),
                      trailing: const Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 16,
                        color: AppColors.textMuted,
                      ),
                      onTap: _showChangePasswordDialog,
                    ),
                    const Divider(color: AppColors.divider, height: 1),
                    ListTile(
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.errorBg,
                          borderRadius: AppDimensions.borderRadiusSM,
                        ),
                        child: const Icon(
                          Icons.logout_rounded,
                          color: AppColors.error,
                          size: 20,
                        ),
                      ),
                      title: const Text(
                        AppStrings.logout,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppColors.error,
                          fontFamily: 'Cairo',
                        ),
                      ),
                      onTap: _handleLogout,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppDimensions.p20),
            ],
          ),
        ),
      ),
    );
  }
}
