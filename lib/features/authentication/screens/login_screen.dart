import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/di/injection_container.dart';
import '../../../core/security/jwt_claims_parser.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_text_field.dart';
import '../presentation/bloc/auth_bloc.dart';
import '../presentation/bloc/auth_event.dart';
import '../presentation/bloc/auth_state.dart';

class LoginScreen extends StatefulWidget {
  final AuthBloc? authBloc;

  const LoginScreen({super.key, this.authBloc});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController(
    text: kDebugMode ? 'user@shakwa.sa' : '',
  );
  final _passwordController = TextEditingController(
    text: kDebugMode ? 'password123' : '',
  );

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
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() {
    if (!_formKey.currentState!.validate()) return;

    _bloc.add(
      AuthLoginSubmitted(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      ),
    );
  }

  void _navigateBasedOnRole(UserRole role) {
    switch (role) {
      case UserRole.user:
        context.go('/user-dashboard');
        break;
      case UserRole.admin:
        context.go('/admin-dashboard');
        break;
      case UserRole.superAdmin:
        context.go('/super-dashboard');
        break;
    }
  }

  void _quickFill(String email, UserRole role) {
    _emailController.text = email;
    _passwordController.text = 'password123';
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      bloc: _bloc,
      listener: (context, state) {
        if (state is AuthAuthenticated) {
          _navigateBasedOnRole(state.session.role);
        }
      },
      builder: (context, state) {
        final isLoading =
            state is AuthLoading && state.operation == AuthOperation.login;
        final errorMessage =
            state is AuthError && state.operation == AuthOperation.login
            ? state.message
            : null;

        return Scaffold(
          backgroundColor: AppColors.background,
          body: SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.p24,
                  vertical: AppDimensions.p20,
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // App Brand Logo
                      Center(
                        child: Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: AppDimensions.borderRadiusXL,
                            boxShadow: AppDimensions.cardShadow,
                          ),
                          padding: const EdgeInsets.all(12),
                          child: Image.asset(
                            'assets/images/logo.png',
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                      const SizedBox(height: AppDimensions.p20),
                      // App Title & Subtitle
                      const Center(
                        child: Text(
                          AppStrings.appName,
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                            fontFamily: 'Cairo',
                          ),
                        ),
                      ),
                      const SizedBox(height: AppDimensions.p4),
                      const Center(
                        child: Text(
                          AppStrings.loginSubtitle,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                            fontFamily: 'Cairo',
                          ),
                        ),
                      ),
                      const SizedBox(height: AppDimensions.p32),

                      // Error Message Banner
                      if (errorMessage != null) ...[
                        Container(
                          padding: const EdgeInsets.all(AppDimensions.p12),
                          decoration: BoxDecoration(
                            color: AppColors.errorBg,
                            borderRadius: AppDimensions.borderRadiusMD,
                            border: Border.all(
                              color: AppColors.error.withValues(alpha: 0.3),
                            ),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.error_outline_rounded,
                                color: AppColors.error,
                                size: 20,
                              ),
                              const SizedBox(width: AppDimensions.p8),
                              Expanded(
                                child: Text(
                                  errorMessage,
                                  style: const TextStyle(
                                    color: AppColors.error,
                                    fontSize: 13,
                                    fontFamily: 'Cairo',
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: AppDimensions.p16),
                      ],

                      // Email Field
                      AppTextField(
                        label: AppStrings.emailOrUsername,
                        hintText: 'user@shakwa.sa',
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        prefixIcon: Icons.email_outlined,
                        validator: (val) {
                          if (val == null || val.trim().isEmpty) {
                            return AppStrings.requiredField;
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: AppDimensions.p16),

                      // Password Field
                      AppTextField(
                        label: AppStrings.password,
                        hintText: '••••••••',
                        controller: _passwordController,
                        isPassword: true,
                        prefixIcon: Icons.lock_outline_rounded,
                        validator: (val) {
                          if (val == null || val.trim().isEmpty) {
                            return AppStrings.requiredField;
                          }
                          if (val.length < 6) {
                            return AppStrings.shortPassword;
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: AppDimensions.p24),

                      // Login Button
                      AppButton(
                        text: AppStrings.loginButton,
                        isLoading: isLoading,
                        onPressed: _handleLogin,
                      ),
                      const SizedBox(height: AppDimensions.p16),

                      // Register Link
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            AppStrings.noAccount,
                            style: TextStyle(
                              fontSize: 13,
                              color: AppColors.textSecondary,
                              fontFamily: 'Cairo',
                            ),
                          ),
                          TextButton(
                            onPressed: () => context.push('/register'),
                            child: const Text(
                              AppStrings.registerButton,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: AppColors.secondaryDark,
                                fontFamily: 'Cairo',
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppDimensions.p24),

                      // Quick Demo Accounts Section
                      Container(
                        padding: const EdgeInsets.all(AppDimensions.p16),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceVariant,
                          borderRadius: AppDimensions.borderRadiusMD,
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Row(
                              children: [
                                Icon(
                                  Icons.bolt_rounded,
                                  size: 18,
                                  color: AppColors.secondary,
                                ),
                                SizedBox(width: 6),
                                Text(
                                  AppStrings.quickMockLogin,
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textPrimary,
                                    fontFamily: 'Cairo',
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: AppDimensions.p10),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                ActionChip(
                                  avatar: const Icon(
                                    Icons.person,
                                    size: 16,
                                    color: AppColors.primary,
                                  ),
                                  label: const Text(
                                    'مواطن (User)',
                                    style: TextStyle(
                                      fontFamily: 'Cairo',
                                      fontSize: 11,
                                    ),
                                  ),
                                  backgroundColor: Colors.white,
                                  onPressed: () => _quickFill(
                                    'user@shakwa.sa',
                                    UserRole.user,
                                  ),
                                ),
                                ActionChip(
                                  avatar: const Icon(
                                    Icons.engineering,
                                    size: 16,
                                    color: AppColors.primary,
                                  ),
                                  label: const Text(
                                    'مشرف (Admin)',
                                    style: TextStyle(
                                      fontFamily: 'Cairo',
                                      fontSize: 11,
                                    ),
                                  ),
                                  backgroundColor: Colors.white,
                                  onPressed: () => _quickFill(
                                    'admin@shakwa.sa',
                                    UserRole.admin,
                                  ),
                                ),
                                ActionChip(
                                  avatar: const Icon(
                                    Icons.security,
                                    size: 16,
                                    color: AppColors.primary,
                                  ),
                                  label: const Text(
                                    'مسؤول (SuperAdmin)',
                                    style: TextStyle(
                                      fontFamily: 'Cairo',
                                      fontSize: 11,
                                    ),
                                  ),
                                  backgroundColor: Colors.white,
                                  onPressed: () => _quickFill(
                                    'super@shakwa.sa',
                                    UserRole.superAdmin,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
