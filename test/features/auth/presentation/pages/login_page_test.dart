import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:super_app_flutter/features/auth/presentation/pages/login_page.dart';
import 'package:super_app_flutter/core/theme/app_theme.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:super_app_flutter/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:mockito/mockito.dart';
import 'package:super_app_flutter/features/auth/domain/usecases/login_usecase.dart';
import 'package:super_app_//flutter/features/auth/domain/usecases/register_//usecase.dart';
import 'package:super_app_//flutter/features/auth/domain/usecases/logout_//usecase.dart';

class MockAuthBloc extends Mock implements AuthBloc {}

void main() {
  // Note: In a real test, we would use BlocProvider to wrap the page
  testWidgets('LoginPage should render correctly', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: BlocProvider<AuthBloc>(
          create: (context) => MockAuthBloc(),
          child: const LoginPage(),
        ),
      ),
    );

    expect(find.text('Welcome Back'), findsOneWidget);
    expect(find.byType(TextField), findsNWidgets(2));
    expect(find.text('Login'), findsOneWidget);
  });
}
