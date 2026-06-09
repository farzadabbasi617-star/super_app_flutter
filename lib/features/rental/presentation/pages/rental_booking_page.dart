import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../marketplace/presentation/bloc/rental_bloc.dart';
import '../../marketplace/domain/entities/product.dart';
import '../../../shared/widgets/app_button.dart';

class RentalBookingPage extends StatefulWidget {
  final Product product;
  const RentalBookingPage({super.key, required this.product});

  @override
  State<RentalBookingPage> createState() => _RentalBookingPageState();
}

class _RentalBookingPageState extends State<RentalBookingPage> {
  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now().add(const Duration(days: 1));

  Future<void> _selectDate(BuildContext context, bool isStart) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: isStart ? _startDate : _endDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        if (isStart) _startDate = picked; else _endDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final days = _endDate.difference(_startDate).inDays + 1;
    final totalCost = days * widget.product.rentalPricePerDay;

    return Scaffold(
      appBar: AppBar(title: const Text('Book Equipment')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.product.name, style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
            Text(widget.product.description, style: theme.textTheme.bodyLarge),
            const SizedBox(height: 32),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Start Date', style: TextStyle(fontWeight: FontWeight.bold)),
                      TextButton(onPressed: () => _selectDate(context, true), child: Text('${_startDate.toString().split(\' \')[0]}')),
                    ],
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('End Date', style: TextStyle(fontWeight: FontWeight.bold)),
                      TextButton(onPressed: () => _selectDate(context, false), child: Text('${_endDate.toString().split(\' \')[0]}')),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: theme.colorScheme.primaryContainer, borderRadius: BorderRadius.circular(12)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('$ {days} days x $ {widget.product.rentalPricePerDay}/day', style: theme.textTheme.bodyMedium),
                  Text('$ {totalCost}', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: theme.colorScheme.primary)),
                ],
              ),
            ),
            const Spacer(),
            BlocConsumer<RentalBloc, RentalState>(
              listener: (context, state) {
                if (state is RentalBookingSuccess) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Booking Confirmed!'), backgroundColor: Colors.green));
                  Navigator.of(context).pop();
                } else if (state is RentalBookingFailure) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.error), backgroundColor: Colors.red));
                }
              },
              builder: (context, state) {
                return AppButton(
                  text: 'Confirm Booking',
                  onPressed: () {
                    if (_endDate.isBefore(_startDate)) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('End date must be after start date')));
                      return;
                    }
                    context.read<RentalBloc>().add(BookRentalRequested(widget.product.id, _startDate, _endDate));
                  },
                  isLoading: state is RentalBookingLoading,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
