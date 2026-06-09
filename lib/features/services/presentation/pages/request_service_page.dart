import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../bloc/service_bloc.dart';
import '../bloc/service_event.dart';
import '../bloc/service_state.dart';
import '../../domain/entities/service_request.dart';

class RequestServicePage extends StatelessWidget {
  const RequestServicePage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Request Expert')),
      body: BlocConsumer<ServiceBloc, ServiceState>(
        listener: (context, state) {
          if (state is ServiceProFound) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('An expert has accepted your request!'), backgroundColor: Colors.green),
            );
          }
        },
        builder: (context, state) {
          if (state is ServiceSearching) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 20),
                  Text('Searching for nearby experts...', style: theme.textTheme.titleMedium),
                ],
              ),
            );
          } else if (state is ServiceProFound || state is ServiceOnTheWay) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.check_circle, color: Colors.green, size: 80),
                  const SizedBox(height: 20),
                  Text('Expert is on the way!', style: theme.textTheme.headlineSmall),
                  const SizedBox(height: 10),
                  const Text('Estimated Arrival: 15 mins'),
                ],
              ),
            );
          }

          return Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('What do you need help with?', style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 24),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
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
        },
      ),
    );
  }
}
