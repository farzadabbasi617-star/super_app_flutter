import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_text_field.dart';
import '../../../core/utils/validators.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String? _emailError;
  String? _passwordError;

  void _handleLogin() {
    final email = _emailController.text;
    final password = _passwordController.text;

    setState(() {
      _emailError = Validators.validateEmail(email);
      _passwordError = Validators.validatePassword(password);
    });

    if (_emailError == null && _passwordError == null) {
      context.read<AuthBloc>().add(AuthLoginRequested(email, password));
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthAuthenticated) {
            context.go('/home');
          } else if (state is AuthFailure) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.error), backgroundColor: theme.colorScheme.error));
          }
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                Text('Welcome Back', style: theme.textTheme.displayLarge?.copyWith(fontWeight: FontWeight.bold, fontSize: 32)),
                const SizedBox(height: 8),
                Text('Sign in to your account to continue', style: theme.textTheme.bodyLarge),
                const SizedBox(height: 40),
                AppTextField(
                  label: 'Email Address',
                  controller: _emailController,
                  errorText: _emailError,
                  prefixIcon: const Icon(Icons.email_outlined),
                  onChanged: (val) => setState(() => _emailError = Validators.validateEmail(val)),
                ),
                const SizedBox(height: 20),
                AppTextField(
                  label: 'Password',
                  controller: _passwordController,
                  isPassword: true,
                  errorText: _passwordError,
                  prefixIcon: const Icon(Icons.lock_outline),
                  onChanged: (val) => setState(() => _passwordError = Validators.validatePassword(val)),
                ),
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {},
                    child: Text('Forgot Password?', style: TextStyle(color: theme.colorScheme.primary)),
                  ),
                ),
                const SizedBox(height: 32),
                BlocBuilder<AuthBloc, AuthState>(
                  builder: (context, state) {
                    return AppButton(
                      text: 'Login',
                      onPressed: _handleLogin,
                      isLoading: state is AuthLoading,
                      type: AppButtonType.primary,
                    );
                  },
                ),
                const SizedBox(height: 24),
                Center(
                  child: TextButton(
                    onPressed: () => context.push('/register'),
                    child: Text('Don\'t have an account? Register Now', style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
