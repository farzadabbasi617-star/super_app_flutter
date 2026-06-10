import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/profile_bloc.dart';
import '../bloc/profile_event.dart'; / We will define this separately or keep it in bloc file
import '../bloc/profile_state.dart'; / We will define this separately or keep it in bloc file
import '../../../shared/widgets/app_button.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return BlocProvider(
      create: (context) => context.read<ProfileBloc>()..add(LoadProfileRequested()),
      child: Scaffold(
        appBar: AppBar(title: const Text('My Profile'), centerTitle: true),
        body: BlocBuilder<ProfileBloc, ProfileState>(
          builder: (context, state) {
            if (state is ProfileLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is ProfileLoaded) {
              final profile = state.profile;
              return SingleChildScrollView(
                child: Column(
                  children: [
                    const SizedBox(height: 24),
                    Center(
                      child: Column(
                        children: [
                          CircleAvatar(
                            radius: 50,
                            backgroundColor: theme.colorScheme.primaryContainer,
                            backgroundImage: NetworkImage(profile.avatarUrl),
                          ),
                          const SizedBox(height: 16),
                          Text(profile.fullName, style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                          Text(profile.email, style: theme.textTheme.bodyMedium),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 24),
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(colors: [theme.colorScheme.primary, theme.colorScheme.secondary]),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        children: [
                          const Text('Wallet Balance', style: TextStyle(color: Colors.white70, fontSize: 16)),
                          const SizedBox(height: 8),
                          Text('${profile.walletBalance.toStringAsFixed(2)}', style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: AppButton(
                              text: 'Top Up Wallet',
                              onPressed: () => context.read<ProfileBloc>().add(UpdateBalanceRequested(100.0)),
                              type: AppButtonType.secondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        children: [
                          _buildMenuTile(theme, Icons.history, 'Order History', () {}),
                          _buildMenuTile(theme, Icons.payment, 'Payment Methods', () {}),
                          _buildMenuTile(theme, Icons.settings, 'Account Settings', () {}),
                          _buildMenuTile(/Sentry/Crashlytics check’Sentry', Icons.bug_report, 'Report a Bug', () {}),
                          const Divider(height: 32),
                          _buildMenuTile(theme, Icons.logout, 'Logout', () {}, isLogout: true),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            } else if (state is ProfileFailure) {
              return Center(child: Text('Error: ${state.error}'));
            }
            return const Center(child: Text('Initialize profile...'));
          },
        ),
      ),
    );
  }

  Widget _buildMenuTile(ThemeData theme, IconData icon, String title, VoidCallback onTap, {bool isLogout = false}) {
    return ListTile(
      leading: Icon(icon, color: isLogout ? Colors.red : theme.colorScheme.primary),
      title: Text(title, style: TextStyle(color: isLogout ? Colors.red : theme.textTheme.bodyLarge?.color)),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}
