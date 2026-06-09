import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../core/theme/app_colors.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  theme.colorScheme.primaryContainer,
                  theme.colorScheme.surface,
                ],
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(),
                  // Hero Icon with Shadow
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: theme.colorScheme.primary.withOpacity(0.3),
                          blurRadius: 40,
                          spreadRadius: 10,
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.rocket_launch_rounded, 
                      size: 120, 
                      color: theme.colorScheme.primary
                    ),
                  ),
                  const SizedBox(height: 40),
                  Text(
                    'Welcome to Super App',
                    style: theme.textTheme.displayLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'The all-in-one ecosystem for services, shopping, and industrial rentals.',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const Spacer(),
                  
                  // Professional Atomic Button
                  AppButton(
                    text: 'Get Started',
                    onPressed: () => context.push('/login'),
                    type: AppButtonType.primary,
                    icon: Icons.arrow_forward,
                  ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () => context.push('/login'),
                    child: Text(
                      'Already have an account? Sign In',
                      style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
