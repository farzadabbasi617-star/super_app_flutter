import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';
import '../../domain/entities/user.dart';
import 'package:go_router/go_router.dart';
import 'package:super_app_flutter/shared/widgets/app_button.dart';
import 'package:super_app_flutter/shared/widgets/app_text_field.dart';
import 'package:super_app_flutter/core/utils/validators.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();

  UserRole _selectedRole = UserRole.customer;

  String? _nameError, _emailError, _phoneError, _passwordError;

  void _handleRegister() {
    final name = _nameController.text;
    final email = _emailController.text;
    final phone = _phoneController.text;
    final password = _passwordController.text;

    setState(() {
      _nameError = Validators.validateFullName(name);
      _emailError = Validators.validateEmail(email);
      _phoneError = Validators.validatePhone(phone);
      _passwordError = Validators.validatePassword(password);
    });

    if (_nameError == null &&
        _emailError == null &&
        _phoneError == null &&
        _passwordError == null) {
      context.read<AuthBloc>().add(
            AuthRegisterRequested(email, password, name, phone, _selectedRole),
          );
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Create Account')),
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthAuthenticated) {
            context.go('/home');
          } else if (state is AuthFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.error),
                backgroundColor: theme.colorScheme.error,
              ),
            );
          }
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Join Our Community',
                  style: theme.textTheme.displayLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 32,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Create an account to start using our services',
                  style: theme.textTheme.bodyLarge,
                ),
                const SizedBox(height: 32),

                // Role Selection
                Text(
                  'I want to join as a:',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: ChoiceChip(
                        label: const Text('Customer'),
                        selected: _selectedRole == UserRole.customer,
                        onSelected: (_) =>
                            setState(() => _selectedRole = UserRole.customer),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ChoiceChip(
                        label: const Text('Professional'),
                        selected: _selectedRole == UserRole.professional,
                        onSelected: (_) => setState(
                          () => _selectedRole = UserRole.professional,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                AppTextField(
                  label: 'Full Name',
                  controller: _nameController,
                  errorText: _nameError,
                  prefixIcon: const Icon(Icons.person_outline),
                  onChanged: (val) => setState(
                    () => _nameError = Validators.validateFullName(val),
                  ),
                ),
                const SizedBox(height: 20),
                AppTextField(
                  label: 'Email Address',
                  controller: _emailController,
                  errorText: _emailError,
                  prefixIcon: const Icon(Icons.email_outlined),
                  onChanged: (val) => setState(
                    () => _emailError = Validators.validateEmail(val),
                  ),
                ),
                const SizedBox(height: 20),
                AppTextField(
                  label: 'Phone Number',
                  controller: _phoneController,
                  errorText: _phoneError,
                  prefixIcon: const Icon(Icons.phone_android),
                  keyboardType: TextInputType.phone,
                  onChanged: (val) => setState(
                    () => _phoneError = Validators.validatePhone(val),
                  ),
                ),
                const SizedBox(height: 20),
                AppTextField(
                  label: 'Password',
                  controller: _passwordController,
                  isPassword: true,
                  errorText: _passwordError,
                  prefixIcon: const Icon(Icons.lock_outline),
                  onChanged: (val) => setState(
                    () => _passwordError = Validators.validatePassword(val),
                  ),
                ),
                const SizedBox(height: 32),
                BlocBuilder<AuthBloc, AuthState>(
                  builder: (context, state) {
                    return AppButton(
                      text: 'Register Now',
                      onPressed: _handleRegister,
                      isLoading: state is AuthLoading,
                      type: AppButtonType.primary,
                    );
                  },
                ),
                const SizedBox(height: 24),
                Center(
                  child: TextButton(
                    onPressed: () => context.pop(),
                    child: Text(
                      'Already have an account? Login',
                      style: TextStyle(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
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
