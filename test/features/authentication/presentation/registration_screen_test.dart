import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shakwa_app/core/constants/app_strings.dart';
import 'package:shakwa_app/core/widgets/app_button.dart';
import 'package:shakwa_app/features/authentication/presentation/bloc/auth_bloc.dart';
import 'package:shakwa_app/features/authentication/presentation/bloc/auth_state.dart';
import 'package:shakwa_app/features/authentication/screens/registration_screen.dart';

import 'auth_bloc_test.dart';

Widget createTestableWidget(Widget child, AuthBloc bloc) {
  return MaterialApp(
    locale: const Locale('ar', 'SA'),
    supportedLocales: const [Locale('ar', 'SA'), Locale('ar', '')],
    localizationsDelegates: const [
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    home: Directionality(
      textDirection: TextDirection.rtl,
      child: BlocProvider<AuthBloc>.value(value: bloc, child: child),
    ),
  );
}

void main() {
  group('RegistrationScreen Widget Tests', () {
    late MockAuthRepository mockRepo;
    late AuthBloc authBloc;

    setUp(() {
      mockRepo = MockAuthRepository();
      authBloc = AuthBloc(authRepository: mockRepo);
    });

    tearDown(() {
      authBloc.close();
    });

    testWidgets('1. Shows validation error when required fields are empty', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        createTestableWidget(RegistrationScreen(authBloc: authBloc), authBloc),
      );
      await tester.pumpAndSettle();

      final registerButton = find.byType(AppButton);
      await tester.tap(registerButton);
      await tester.pumpAndSettle();

      expect(find.text(AppStrings.requiredField), findsWidgets);
    });

    testWidgets('2. Shows password mismatch error when passwords differ', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        createTestableWidget(RegistrationScreen(authBloc: authBloc), authBloc),
      );
      await tester.pumpAndSettle();

      final textFields = find.byType(TextFormField);
      // Name
      await tester.enterText(textFields.at(0), 'خالد الأحمد');
      // Email
      await tester.enterText(textFields.at(1), 'khaled@shakwa.sa');
      // Phone
      await tester.enterText(textFields.at(2), '0555555555');
      // Password
      await tester.enterText(textFields.at(3), 'Password123');
      // Confirm Password (different)
      await tester.enterText(textFields.at(4), 'Mismatch999');

      final registerButton = find.byType(AppButton);
      await tester.tap(registerButton);
      await tester.pumpAndSettle();

      expect(find.text(AppStrings.passwordMismatch), findsOneWidget);
    });

    testWidgets(
      '3. Displays error banner when state is AuthFailure during registration',
      (tester) async {
        tester.view.physicalSize = const Size(800, 1200);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);

        await tester.pumpWidget(
          createTestableWidget(
            RegistrationScreen(authBloc: authBloc),
            authBloc,
          ),
        );
        await tester.pumpAndSettle();

        authBloc.emit(
          const AuthError(
            message: 'البريد الإلكتروني مسجل مسبقاً في النظام.',
            operation: AuthOperation.registration,
          ),
        );
        await tester.pumpAndSettle();

        expect(
          find.text('البريد الإلكتروني مسجل مسبقاً في النظام.'),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      '4. Submits valid registration and dispatches AuthRegisterSubmitted',
      (tester) async {
        tester.view.physicalSize = const Size(800, 1200);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);

        await tester.pumpWidget(
          createTestableWidget(
            RegistrationScreen(authBloc: authBloc),
            authBloc,
          ),
        );
        await tester.pumpAndSettle();

        final textFields = find.byType(TextFormField);
        await tester.enterText(textFields.at(0), 'خالد الأحمد');
        await tester.enterText(textFields.at(1), 'khaled@shakwa.sa');
        await tester.enterText(textFields.at(2), '0555555555');
        await tester.enterText(textFields.at(3), 'Password123');
        await tester.enterText(textFields.at(4), 'Password123');

        final registerButton = find.byType(AppButton);
        await tester.tap(registerButton);
        await tester.pump();

        expect(authBloc.state, isA<AuthLoading>());
        final loadingState = authBloc.state as AuthLoading;
        expect(loadingState.operation, equals(AuthOperation.registration));
      },
    );
  });
}
