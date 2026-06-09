import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../bloc/service_bloc.dart';
import '../bloc/service_event.dart';
import '../bloc/service_state.dart';
import '../../domain/entities/service_request.dart';
import '../../../shared/widgets/app_button.dart';

class RequestServicePage extends StatelessWidget {
  const RequestServicePage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Request Expert')),
      body: BlocConsumer<ServiceBloc, ServiceState>(
        listener: (context, state) {
          if (state is ServiceProfessionalAssigned) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Expert assigned! Checking location...'), backgroundColor: Colors.green),
            );
          }
        },
        builder: (context, state) {
          if (state is ServiceSearching) {
            return _buildSearchingUI(theme);
          } else if (state is ServiceProfessionalAssigned || state is ServiceOnTheWay) {
            return _buildTrackingUI(theme, state);
          }

          return _buildSelectionUI(context, theme);
        },
      ),
    );
  }

  Widget _buildSelectionUI(BuildContext context, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('What do you need help with?', style: theme.textTheme.displayLarge?.copyWith(fontWeight: FontWeight.bold, fontSize: 28)),
          const SizedBox(height: 24),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: ['Plumbing', 'Electricity', 'Painting', 'AC Repair', 'Cleaning'].map((service) {
              return ActionChip(
                label: Text(service),
                onPressed: () {
                  context.read<ServiceBloc>().add(RequestServiceStarted(
                    ServiceRequest(
                      id: 'req_${DateTime.now().millisecondsSinceEpoch}',
                      customerId: 'user123',
                      serviceType: service,
                      location: const LatLng(35.6892, 51.3890),
                      status: ServiceStatus.pending,
                      createdAt: DateTime.now(),
                    ),
                  ));
                },
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchingUI(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 24),
          Text('Broadcasting request to experts...', style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          Text('Please wait a moment', style: theme.textTheme.bodySmall),
        ],
      ),
    );
  }

  Widget _buildTrackingUI(ThemeData theme, ServiceState state) {
    final request = (state is ServiceProfessionalAssigned) ? state.request : (state as ServiceOnTheWay).request;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.directions_car, size: 80, color: Colors.green),
          const SizedBox(height: 24),
          Text('Expert is on the way!', style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Text('ETA: ${request.estimatedArrivalTime} mins', style: theme.textTheme.bodyLarge),
          const SizedBox(height: 32),
          AppButton(
            text: 'Contact Expert',
            onPressed: () {},
            type: AppButtonType.outline,
            icon: Icons.phone,
          ),
        ],
      ),
    );
  }
}
