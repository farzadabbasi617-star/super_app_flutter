import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../marketplace/presentation/bloc/rental_bloc.dart';
import '../../marketplace/domain/entities/product.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../../core/utils/monetization_manager.dart';

class RentalBookingPage extends StatefulWidget {
  final Product product;
  const RentalBookingPage({super.key, required this.product});

  @override
  State<RentalBookingPage> createState() => _RentalBookingPageState();
}

class _RentalBookingPageState extends State<RentalBookingPage> {
  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now().add(const Duration(days: 1));
  final _monetization = MonetizationManager();

  Future<void> _selectDate(BuildContext context, bool isStart) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: isStart ? _startDate : _endDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      locale: const Locale('fa', 'IR'), // Fallback directionality
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _startDate = picked;
          if (_endDate.isBefore(_startDate)) {
            _endDate = _startDate.add(const Duration(days: 1));
          }
        } else {
          if (picked.isAfter(_startDate) || picked.isAtSameMomentAs(_startDate)) {
            _endDate = picked;
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('تاریخ پایان باید بعد از تاریخ شروع باشد!'), backgroundColor: Colors.red),
            );
          }
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final days = _endDate.difference(_startDate).inDays + 1;
    final totalRentCost = days * widget.product.rentalPricePerDay;
    final securityDeposit = totalRentCost * 0.20; // 20% security deposit
    final grandTotal = totalRentCost + securityDeposit;

    final formattedPricePerDay = widget.product.rentalPricePerDay
        .toStringAsFixed(0)
        .replaceAllMapped(RegExp(r"(\d{1,3})(?=(\d{3})+(?!\d))"), (Match m) => "${m[1]},");

    final formattedTotalRent = totalRentCost
        .toStringAsFixed(0)
        .replaceAllMapped(RegExp(r"(\d{1,3})(?=(\d{3})+(?!\d))"), (Match m) => "${m[1]},");

    final formattedDeposit = securityDeposit
        .toStringAsFixed(0)
        .replaceAllMapped(RegExp(r"(\d{1,3})(?=(\d{3})+(?!\d))"), (Match m) => "${m[1]},");

    final formattedGrandTotal = grandTotal
        .toStringAsFixed(0)
        .replaceAllMapped(RegExp(r"(\d{1,3})(?=(\d{3})+(?!\d))"), (Match m) => "${m[1]},");

    final formattedWallet = _monetization.walletBalance
        .toStringAsFixed(0)
        .replaceAllMapped(RegExp(r"(\d{1,3})(?=(\d{3})+(?!\d))"), (Match m) => "${m[1]},");

    return Scaffold(
      appBar: AppBar(
        title: const Text('ثبت درخواست و اجاره ماشین‌آلات', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
        centerTitle: true,
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Product Name and Category Badge
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      widget.product.name, 
                      style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      widget.product.category == 'Industrial' ? 'صنعتی' : 'کشاورزی',
                      style: TextStyle(color: Colors.red.shade800, fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                widget.product.description, 
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const SizedBox(height: 24),
              const Divider(),
              const SizedBox(height: 12),

              // Date Selectors
              const Text('بازه زمانی اجاره ادوات سنگین', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5)),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: Card(
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.grey.shade300)),
                      child: InkWell(
                        onTap: () => _selectDate(context, true),
                        borderRadius: BorderRadius.circular(12),
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('شروع اجاره', style: TextStyle(color: Colors.grey, fontSize: 10.5)),
                              const SizedBox(height: 4),
                              Text(
                                '${_startDate.year}/${_startDate.month}/${_startDate.day}',
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Card(
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.grey.shade300)),
                      child: InkWell(
                        onTap: () => _selectDate(context, false),
                        borderRadius: BorderRadius.circular(12),
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('پایان اجاره', style: TextStyle(color: Colors.grey, fontSize: 10.5)),
                              const SizedBox(height: 4),
                              Text(
                                '${_endDate.year}/${_endDate.month}/${_endDate.day}',
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Financial Calculation Details Box
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: theme.colorScheme.primary.withOpacity(0.15)),
                ),
                child: Column(
                  children: [
                    _buildCalcRow('تعرفه اجاره روزانه:', '$formattedPricePerDay تومان / روز'),
                    const SizedBox(height: 10),
                    _buildCalcRow('مدت زمان اجاره:', '$days روز'),
                    const Divider(height: 20),
                    _buildCalcRow('مجموع هزینه اجاره:', '$formattedTotalRent تومان'),
                    const SizedBox(height: 6),
                    _buildCalcRow('وثیقه و سپرده سلامت (۲۰٪):', '$formattedDeposit تومان'),
                    const Divider(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('مجموع مبلغ ضمانت و اجاره:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                        Text('$formattedGrandTotal تومان', style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.bold, fontSize: 15)),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('موجودی کیف پول شما:', style: TextStyle(color: Colors.grey, fontSize: 12)),
                  Text('$formattedWallet تومان', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey, fontSize: 12)),
                ],
              ),

              const Spacer(),

              // Booking Button connected to Bloc / Wallet
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.check_circle_outline),
                  label: const Text('تایید و پرداخت ضمانت اجاره 🚜', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  onPressed: () {
                    if (_endDate.isBefore(_startDate)) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('تاریخ پایان نمی‌تواند قبل از تاریخ شروع باشد!')),
                      );
                      return;
                    }

                    if (_monetization.walletBalance >= grandTotal) {
                      setState(() {
                        _monetization.walletBalance -= grandTotal;
                        _monetization.addTransaction(
                          'اجاره ادوات سنگین: ${widget.product.name} (به مدت $days روز)',
                          -grandTotal,
                          false,
                          '🚜',
                        );
                      });
                      
                      _showBookingSuccessDialog(context, days, formattedGrandTotal);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('❌ موجودی کیف پول کافی نیست! ابتدا حساب خود را شارژ کنید.'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCalcRow(String lead, String val) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(lead, style: const TextStyle(fontSize: 12, color: Colors.black87)),
        Text(val, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12.5)),
      ],
    );
  }

  void _showBookingSuccessDialog(BuildContext context, int days, String totalPrice) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircleAvatar(
                radius: 36,
                backgroundColor: Colors.green,
                child: Icon(Icons.check, size: 48, color: Colors.white),
              ),
              const SizedBox(height: 16),
              const Text(
                'درخواست اجاره تایید شد! 🎉',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.green),
              ),
              const SizedBox(height: 8),
              Text(
                'ماشین‌آلات درخواستی به مدت $days روز از تاریخ ${_startDate.year}/${_startDate.month}/${_startDate.day} برای شما رزرو شد. فاکتور و وثیقه از کیف پول دیجیتال پرداخت گردید.',
                style: const TextStyle(fontSize: 11.5, color: Colors.black87, height: 1.5),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context); // Close dialog
                    Navigator.pop(context); // Go back to rental page
                  },
                  child: const Text('بازگشت به مرکز اجاره'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
