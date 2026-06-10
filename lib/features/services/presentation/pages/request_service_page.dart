import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../bloc/service_bloc.dart';
import '../bloc/service_event.dart';
import '../bloc/service_state.dart';
import '../../domain/entities/service_request.dart';
import '../../../shared/widgets/app_button.dart';
import 'customer_offers_view.dart';

class RequestServicePage extends StatelessWidget {
  const RequestServicePage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Request Expert'),
        centerTitle: true,
        elevation: 0,
      ),
      body: BlocConsumer<ServiceBloc, ServiceState>(
        listener: (context, state) {
          if (state is ServiceProfessionalAssigned) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Expert ${state.request.assignedProfessionalName} successfully assigned!'), 
                backgroundColor: Colors.green,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is ServiceSearching) {
            return CustomerOffersView(request: state.request);
          } else if (state is ServiceProfessionalAssigned || state is ServiceOnTheWay) {
            return _buildTrackingUI(context, theme, state);
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
          Text(
            'What do you need help with?', 
            style: theme.textTheme.displayLarge?.copyWith(
              fontWeight: FontWeight.bold, 
              fontSize: 28,
              color: theme.colorScheme.onBackground,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Select a category to request a verified real-time expert near you.', 
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onBackground.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 32),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: ['Plumbing', 'Electricity', 'Painting', 'AC Repair', 'Cleaning'].map((service) {
              return ActionChip(
                elevation: 2,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                label: Text(
                  service, 
                  style: TextStyle(fontWeight: FontWeight.w600, color: theme.colorScheme.onPrimaryContainer),
                ),
                backgroundColor: theme.colorScheme.primaryContainer.withOpacity(0.4),
                avatar: Icon(_getServiceIcon(service), size: 18, color: theme.colorScheme.primary),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
          const Spacer(),
          Center(
            child: Icon(
              Icons.home_repair_service_outlined, 
              size: 100, 
              color: theme.colorScheme.primary.withOpacity(0.1),
            ),
          ),
          const Spacer(),
        ],
      ),
    );
  }

  IconData _getServiceIcon(String service) {
    switch (service.toLowerCase()) {
      case 'plumbing':
        return Icons.water_drop_outlined;
      case 'electricity':
        return Icons.bolt_outlined;
      case 'painting':
        return Icons.format_paint_outlined;
      case 'ac repair':
        return Icons.ac_unit_outlined;
      case 'cleaning':
        return Icons.cleaning_services_outlined;
      default:
        return Icons.build_outlined;
    }
  }

  Widget _buildTrackingUI(BuildContext context, ThemeData theme, ServiceState state) {
    final request = (state is ServiceProfessionalAssigned) ? state.request : (state as ServiceOnTheWay).request;
    
    final expertName = request.assignedProfessionalName ?? 'Ali Rezaei';
    final expertSpecialty = request.assignedProfessionalSpecialty ?? 'Senior Plumbing Specialist';
    final expertRating = request.assignedProfessionalRating ?? 4.9;
    final confirmedPrice = request.confirmedPrice ?? 350000;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 16),
          const Center(
            child: CircleAvatar(
              radius: 40,
              backgroundColor: Colors.greenContainer, // fall back gracefully
              child: Icon(Icons.check_circle, size: 54, color: Colors.green),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Expert Assigned & On The Way!', 
            style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold, fontSize: 24),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Your service request has been confirmed. The expert is heading to your location.',
            style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onBackground.withOpacity(0.6)),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          
          // Expert Details Card
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundColor: theme.colorScheme.primaryContainer,
                        child: Text(
                          expertName[0], 
                          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: theme.colorScheme.onPrimaryContainer),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              expertName, 
                              style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              expertSpecialty,
                              style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurface.withOpacity(0.6)),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.star, color: Colors.amber, size: 20),
                          const SizedBox(width: 6),
                          Text(
                            '$expertRating', 
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          const SizedBox(width: 4),
                          const Text('(Verified Expert)', style: TextStyle(color: Colors.grey, fontSize: 12)),
                        ],
                      ),
                      Row(
                        children: [
                          const Icon(Icons.access_time, color: Colors.blue, size: 20),
                          const SizedBox(width: 6),
                          Text(
                            'ETA: ${request.estimatedArrivalTime} mins', 
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.blue),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Confirmed Price:', 
                        style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                      ),
                      Text(
                        '${confirmedPrice.toStringAsFixed(0).replaceAllMapped(RegExp(r"(\d{1,3})(?=(\d{3})+(?!\d))"), (Match m) => "${m[1]},")} Tomans', 
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: theme.colorScheme.primary),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 40),
          SizedBox(
            width: double.infinity,
            child: AppButton(
              text: 'Message $expertName',
              onPressed: () {
                // Navigate back or show a chat snackbar
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Opening live chat with $expertName...')),
                );
              },
              type: AppButtonType.primary,
              icon: Icons.chat_bubble_outline,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: AppButton(
              text: 'Call Expert',
              onPressed: () {},
              type: AppButtonType.outline,
              icon: Icons.phone_outlined,
            ),
          ),
          const SizedBox(height: 24),
          TextButton(
            onPressed: () {
              // Go back to initial selection
              context.read<ServiceBloc>().add(ServiceStatusUpdated(
                ServiceRequest(
                  id: 'req_${DateTime.now().millisecondsSinceEpoch}',
                  customerId: 'user123',
                  serviceType: request.serviceType,
                  location: const LatLng(35.6892, 51.3890),
                  status: ServiceStatus.pending,
                  createdAt: DateTime.now(),
                )
              ));
            },
            child: const Text('Cancel Request', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
