import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/di/injection_container.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_dialog.dart';
import '../../../core/widgets/app_text_field.dart';
import '../presentation/bloc/auth_bloc.dart';
import '../presentation/bloc/auth_event.dart';
import '../presentation/bloc/auth_state.dart';

class RegistrationScreen extends StatefulWidget {
  final AuthBloc? authBloc;

  const RegistrationScreen({super.key, this.authBloc});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  late final AuthBloc _bloc;

  @override
  void initState() {
    super.initState();
    if (!GetIt.I.isRegistered<AuthBloc>()) {
      initCoreDependencies();
    }
    _bloc =
        widget.authBloc ??
        (GetIt.I.isRegistered<AuthBloc>()
            ? GetIt.I<AuthBloc>()
            : context.read<AuthBloc>());
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _handleRegister() {
    if (!_formKey.currentState!.validate()) return;

    _bloc.add(
      AuthRegisterSubmitted(
        name: _fullNameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text,
        phone: _phoneController.text.trim().isNotEmpty
            ? _phoneController.text.trim()
            : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      bloc: _bloc,
      listener: (context, state) async {
        if (state is AuthAuthenticated) {
          await AppDialog.showSuccess(
            context: context,
            title: 'تم إنشاء الحساب بنجاح',
            message:
                'أهلاً بك في منصة شكوى! يمكنك الآن تقديم ومتابعة بلاغاتك بكل يسر وسهولة.',
            buttonText: 'الانتقال للرئيسية',
            onDismiss: () {
              context.go('/user-dashboard');
            },
          );
        }
      },
      builder: (context, state) {
        final isLoading =
            state is AuthLoading &&
            state.operation == AuthOperation.registration;
        final errorMessage =
            state is AuthError && state.operation == AuthOperation.registration
            ? state.message
            : null;

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(
                Icons.arrow_back_ios_rounded,
                color: AppColors.primary,
              ),
              onPressed: () => context.pop(),
            ),
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.p24,
                vertical: AppDimensions.p10,
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(
                      child: Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: AppDimensions.borderRadiusLG,
                          boxShadow: AppDimensions.cardShadow,
                        ),
                        padding: const EdgeInsets.all(8),
                        child: Image.asset(
                          'assets/images/logo.png',
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppDimensions.p16),
                    const Center(
                      child: Text(
                        AppStrings.registerTitle,
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                          fontFamily: 'Cairo',
                        ),
                      ),
                    ),
                    const SizedBox(height: AppDimensions.p4),
                    const Center(
                      child: Text(
                        AppStrings.registerSubtitle,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                          fontFamily: 'Cairo',
                        ),
                      ),
                    ),
                    const SizedBox(height: AppDimensions.p24),

                    if (errorMessage != null) ...[
                      Container(
                        padding: const EdgeInsets.all(AppDimensions.p12),
                        decoration: BoxDecoration(
                          color: AppColors.errorBg,
                          borderRadius: AppDimensions.borderRadiusMD,
                        ),
                        child: Text(
                          errorMessage,
                          style: const TextStyle(
                            color: AppColors.error,
                            fontSize: 13,
                            fontFamily: 'Cairo',
                          ),
                        ),
                      ),
                      const SizedBox(height: AppDimensions.p16),
                    ],

                    // Full Name
                    AppTextField(
                      label: AppStrings.fullName,
                      hintText: 'مثال: محمد بن عبدالله',
                      controller: _fullNameController,
                      prefixIcon: Icons.person_outline_rounded,
                      validator: (val) {
                        if (val == null || val.trim().isEmpty)
                          return AppStrings.requiredField;
                        return null;
                      },
                    ),
                    const SizedBox(height: AppDimensions.p16),

                    // Email
                    AppTextField(
                      label: AppStrings.email,
                      hintText: 'name@example.com',
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      prefixIcon: Icons.email_outlined,
                      validator: (val) {
                        if (val == null || val.trim().isEmpty)
                          return AppStrings.requiredField;
                        if (!val.contains('@') || !val.contains('.'))
                          return AppStrings.invalidEmail;
                        return null;
                      },
                    ),
                    const SizedBox(height: AppDimensions.p16),

                    // Phone
                    AppTextField(
                      label: 'رقم الجوال',
                      hintText: '05xxxxxxxx',
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      prefixIcon: Icons.phone_outlined,
                    ),
                    const SizedBox(height: AppDimensions.p16),

                    // Password
                    AppTextField(
                      label: AppStrings.password,
                      hintText: '••••••••',
                      controller: _passwordController,
                      isPassword: true,
                      prefixIcon: Icons.lock_outline_rounded,
                      validator: (val) {
                        if (val == null || val.trim().isEmpty)
                          return AppStrings.requiredField;
                        if (val.length < 6) return AppStrings.shortPassword;
                        return null;
                      },
                    ),
                    const SizedBox(height: AppDimensions.p16),

                    // Confirm Password
                    AppTextField(
                      label: AppStrings.confirmPassword,
                      hintText: '••••••••',
                      controller: _confirmPasswordController,
                      isPassword: true,
                      prefixIcon: Icons.lock_outline_rounded,
                      validator: (val) {
                        if (val == null || val.trim().isEmpty)
                          return AppStrings.requiredField;
                        if (val != _passwordController.text)
                          return AppStrings.passwordMismatch;
                        return null;
                      },
                    ),
                    const SizedBox(height: AppDimensions.p24),

                    AppButton(
                      text: AppStrings.registerButton,
                      isLoading: isLoading,
                      onPressed: _handleRegister,
                    ),
                    const SizedBox(height: AppDimensions.p16),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          AppStrings.haveAccount,
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                            fontFamily: 'Cairo',
                          ),
                        ),
                        TextButton(
                          onPressed: () => context.pop(),
                          child: const Text(
                            AppStrings.loginButton,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                              fontFamily: 'Cairo',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
