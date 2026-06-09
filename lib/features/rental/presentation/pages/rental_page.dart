import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../marketplace/presentation/bloc/product_bloc.dart';
import '../../marketplace/presentation/bloc/product_state.dart';

class RentalPage extends StatelessWidget {
  const RentalPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(title: const Text('Industrial Rental')),
      body: BlocBuilder<ProductBloc, ProductState>(
        builder: (context, state) {
          if (state is ProductLoaded) {
            final rentals = state.products.where((p) => p.isRental).toList();
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text('Heavy Machinery & Tools', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                ),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: rentals.length,
                    itemBuilder: (context, index) {
                      final item = rentals[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 16),
                        child: ListTile(
                          leading: Image.network(item.imageUrl, width: 60, height: 60, fit: BoxFit.cover),
                          title: Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text('${item.rentalPricePerDay}/day'),
                          trailing: ElevatedButton(
                            onPressed: () {
                              // Navigate to Rental Booking Calendar (Simplified)
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Booking ${item.name}...'))
 l);
                            },
                            child: const Text('Rent'),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}
