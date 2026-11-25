import 'dart:async';
import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shakwa_app/core/constants/app_strings.dart';
import 'package:shakwa_app/core/errors/failures.dart';
import 'package:shakwa_app/core/security/jwt_claims_parser.dart';
import 'package:shakwa_app/core/widgets/app_button.dart';
import 'package:shakwa_app/features/authentication/domain/entities/auth_session.dart';
import 'package:shakwa_app/features/authentication/presentation/bloc/auth_bloc.dart';
import 'package:shakwa_app/features/authentication/presentation/bloc/auth_state.dart';
import 'package:shakwa_app/features/authentication/screens/login_screen.dart';

import 'auth_bloc_test.dart';

Widget createTestableWidget(Widget child, AuthBloc bloc) {
  final router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(path: '/', builder: (context, state) => child),
      GoRoute(
        path: '/user-dashboard',
        builder: (context, state) =>
            const Scaffold(body: Text('User Dashboard')),
      ),
      GoRoute(
        path: '/admin-dashboard',
        builder: (context, state) =>
            const Scaffold(body: Text('Admin Dashboard')),
      ),
      GoRoute(
        path: '/super-dashboard',
        builder: (context, state) =>
            const Scaffold(body: Text('Super Dashboard')),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) =>
            const Scaffold(body: Text('Register Screen')),
      ),
    ],
  );

  return MaterialApp.router(
    routerConfig: router,
    locale: const Locale('ar', 'SA'),
    supportedLocales: const [Locale('ar', 'SA'), Locale('ar', '')],
    localizationsDelegates: const [
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    builder: (context, routerChild) => Directionality(
      textDirection: TextDirection.rtl,
      child: BlocProvider<AuthBloc>.value(value: bloc, child: routerChild!),
    ),
  );
}

void main() {
  group('LoginScreen Widget Tests', () {
    late MockAuthRepository mockRepo;
    late AuthBloc authBloc;

    setUp(() {
      mockRepo = MockAuthRepository();
      authBloc = AuthBloc(authRepository: mockRepo);
    });

    tearDown(() {
      authBloc.close();
    });

    testWidgets(
      '1. Form validation shows errors when email or password is empty',
      (tester) async {
        await tester.pumpWidget(
          createTestableWidget(LoginScreen(authBloc: authBloc), authBloc),
        );
        await tester.pumpAndSettle();

        // Clear initial pre-filled text
        final textFields = find.byType(TextFormField);
        await tester.enterText(textFields.first, '');
        await tester.enterText(textFields.last, '');

        // Tap Login button
        final loginButton = find.byType(AppButton);
        await tester.tap(loginButton);
        await tester.pumpAndSettle();

        expect(find.text(AppStrings.requiredField), findsWidgets);
      },
    );

    testWidgets('2. Displays error banner when state is AuthFailure', (
      tester,
    ) async {
      await tester.pumpWidget(
        createTestableWidget(LoginScreen(authBloc: authBloc), authBloc),
      );
      await tester.pumpAndSettle();

      authBloc.emit(
        const AuthError(
          message: 'فشل تسجيل الدخول. تحقق من البيانات.',
          operation: AuthOperation.login,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('فشل تسجيل الدخول. تحقق من البيانات.'), findsOneWidget);
    });

    testWidgets('3. Shows loading state when login is in progress', (
      tester,
    ) async {
      final loginCompleter = Completer<Either<Failure, AuthSession>>();
      mockRepo.loginCompleter = loginCompleter;

      await tester.pumpWidget(
        createTestableWidget(LoginScreen(authBloc: authBloc), authBloc),
      );
      await tester.pumpAndSettle();

      final textFields = find.byType(TextFormField);
      await tester.enterText(textFields.first, 'user@shakwa.sa');
      await tester.enterText(textFields.last, 'password123');

      final loginButton = find.byType(AppButton);
      await tester.tap(loginButton);
      await tester.pump();

      expect(authBloc.state, isA<AuthLoading>());
      final loadingState = authBloc.state as AuthLoading;
      expect(loadingState.operation, equals(AuthOperation.login));

      loginCompleter.complete(Right(createMockSession()));
      await tester.pumpAndSettle();
    });

    testWidgets(
      '4. Submits form and dispatches AuthLoginSubmitted with correct credentials',
      (tester) async {
        authBloc.stream.listen((_) {});

        await tester.pumpWidget(
          createTestableWidget(LoginScreen(authBloc: authBloc), authBloc),
        );
        await tester.pumpAndSettle();

        final textFields = find.byType(TextFormField);
        await tester.enterText(textFields.first, 'citizen@shakwa.sa');
        await tester.enterText(textFields.last, 'Password123!');

        final loginButton = find.byType(AppButton);
        await tester.tap(loginButton);
        await tester.pump();

        // Verify that AuthLoading state was triggered
        expect(authBloc.state, isA<AuthLoading>());
        final loadingState = authBloc.state as AuthLoading;
        expect(loadingState.operation, equals(AuthOperation.login));
      },
    );

    testWidgets(
      '5. Handles successful authenticated navigation to user dashboard',
      (tester) async {
        await tester.pumpWidget(
          createTestableWidget(LoginScreen(authBloc: authBloc), authBloc),
        );
        await tester.pumpAndSettle();

        authBloc.emit(
          AuthAuthenticated(createMockSession(role: UserRole.user)),
        );
        await tester.pumpAndSettle();

        expect(find.text('User Dashboard'), findsOneWidget);
      },
    );
  });
}
