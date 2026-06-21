import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../bloc/service_bloc.dart';
import '../bloc/service_event.dart';
import '../bloc/service_state.dart';
import '../../domain/entities/service_request.dart';
import 'package:super_app_flutter/shared/widgets/app_button.dart';
import 'customer_offers_view.dart';

class RequestServicePage extends StatefulWidget {
  const RequestServicePage({super.key});

  @override
  State<RequestServicePage> createState() => _RequestServicePageState();
}

class _RequestServicePageState extends State<RequestServicePage> {
  String? _clickedCategory; // Selected category (e.g. 'AC Repair')
  final _problemController = TextEditingController();
  String _selectedBrand = 'جی‌پلاس (Gplus)';
  double _estimatedBudget = 300000; // in Tomans
  String _techLevel = 'استادکار ارشد (با تجربه)';

  final List<String> _brands = [
    'جی‌پلاس (Gplus)',
    'سامسونگ (Samsung)',
    'ال‌جی (LG)',
    'اسنوا (Snowa)',
    'اج‌جنرال (O’General)',
    'سایر برندها / متفرقه',
  ];

  @override
  void dispose() {
    _problemController.dispose();
    super.dispose();
  }

  // Check if a category requires brand selection (appliances/devices)
  bool _requiresBrand(String category) {
    final catLower = category.toLowerCase();
    return catLower == 'ac repair' ||
        catLower == 'electricity' ||
        catLower == 'cooling' ||
        catLower == 'برق‌کاری' ||
        catLower == 'سرویس کولر';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('درخواست متخصص آنلاین'),
        centerTitle: true,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (_clickedCategory != null) {
              setState(() {
                _clickedCategory = null;
              });
            } else {
              Navigator.of(context).pop();
            }
          },
        ),
      ),
      body: BlocConsumer<ServiceBloc, ServiceState>(
        listener: (context, state) {
          if (state is ServiceProfessionalAssigned) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'متخصص ${state.request.assignedProfessionalName} با موفقیت تخصیص داده شد!',
                ),
                backgroundColor: Colors.green,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is ServiceSearching) {
            return CustomerOffersView(request: state.request);
          } else if (state is ServiceProfessionalAssigned ||
              state is ServiceOnTheWay) {
            return _buildTrackingUI(context, theme, state);
          }

          // If a category is selected but request not started yet, show the custom request form!
          if (_clickedCategory != null) {
            return _buildRequestFormUI(context, theme);
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
            'به چه متخصصی نیاز دارید؟',
            style: theme.textTheme.displayLarge?.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: 26,
              color: theme.colorScheme.onBackground,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'دسته‌بندی مورد نیاز خود را جهت تکمیل جزئیات عیب‌یابی انتخاب کنید.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onBackground.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 32),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              'Plumbing',
              'Electricity',
              'Painting',
              'AC Repair',
              'Cleaning',
            ].map((service) {
              final faName = _getServiceFaName(service);
              return ActionChip(
                elevation: 2,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                label: Text(
                  faName,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
                ),
                backgroundColor:
                    theme.colorScheme.primaryContainer.withOpacity(0.4),
                avatar: Icon(
                  _getServiceIcon(service),
                  size: 18,
                  color: theme.colorScheme.primary,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                onPressed: () {
                  setState(() {
                    _clickedCategory = service;
                  });
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

  // 1. GORGEOUS DISPATCH FORM VIEW (فرم ثبت درخواست متخصص با برند، توضیحات و بودجه)
  Widget _buildRequestFormUI(BuildContext context, ThemeData theme) {
    final showBrandDropdown = _requiresBrand(_clickedCategory!);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.assignment_outlined,
                color: theme.colorScheme.primary,
                size: 28,
              ),
              const SizedBox(width: 8),
              Text(
                'جزئیات درخواست ${_getServiceFaName(_clickedCategory!)}',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'لطفاً جهت هماهنگی بهتر با استادکار، فرم عیب‌یابی زیر را تکمیل فرمایید.',
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
          const SizedBox(height: 24),

          // Problem Description Input
          const Text(
            'توضیح خلاصه مشکل ساختمان / دستگاه',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _problemController,
            maxLines: 3,
            decoration: const InputDecoration(
              hintText: 'مثلاً: کولر لرزش شدید دارد و باد آن خنک نیست...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(12)),
              ),
              contentPadding: EdgeInsets.all(12),
            ),
          ),
          const SizedBox(height: 20),

          // Brand Selection (Conditional: only visible if related to devices/appliances)
          if (showBrandDropdown) ...[
            const Text(
              'برند دستگاه شما',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                border: Border.all(color: theme.colorScheme.outline),
                borderRadius: BorderRadius.circular(12),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedBrand,
                  isExpanded: true,
                  items: _brands
                      .map((b) => DropdownMenuItem(value: b, child: Text(b)))
                      .toList(),
                  onChanged: (val) {
                    if (val != null) {
                      setState(() {
                        _selectedBrand = val;
                      });
                    }
                  },
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],

          // Estimated budget Slider
          Text(
            'حدود بودجه / قیمت پیشنهادی: ${_estimatedBudget.toStringAsFixed(0).replaceAllMapped(RegExp(r"(\d{1,3})(?=(\d{3})+(?!\d))"), (Match m) => "${m[1]},")} تومان',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          const SizedBox(height: 4),
          Slider(
            value: _estimatedBudget,
            min: 100000,
            max: 1500000,
            divisions: 14,
            label: '${(_estimatedBudget / 1000).toStringAsFixed(0)} هزار تومان',
            activeColor: theme.colorScheme.primary,
            onChanged: (val) {
              setState(() {
                _estimatedBudget = val;
              });
            },
          ),
          const SizedBox(height: 20),

          // Technician Level Choice Chips
          const Text(
            'سطح مهارت استادکار درخواستی',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: ChoiceChip(
                  label: const Center(child: Text('استادکار ارشد')),
                  selected: _techLevel == 'استادکار ارشد (با تجربه)',
                  onSelected: (selected) {
                    if (selected) {
                      setState(() => _techLevel = 'استادکار ارشد (با تجربه)');
                    }
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ChoiceChip(
                  label: const Center(child: Text('تکنسین معمولی')),
                  selected: _techLevel == 'تکنسین معمولی (پایه)',
                  onSelected: (selected) {
                    if (selected) {
                      setState(() => _techLevel = 'تکنسین معمولی (پایه)');
                    }
                  },
                ),
              ),
            ],
          ),

          const SizedBox(height: 40),

          // Submit & Broadcast Request
          SizedBox(
            width: double.infinity,
            child: AppButton(
              text: 'ثبت و ارسال درخواست متخصص',
              onPressed: () {
                final text = _problemController.text.trim();
                if (text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('لطفاً توضیح خلاصه مشکل را بنویسید.'),
                    ),
                  );
                  return;
                }

                // Dispatch Request to Bloc!
                context.read<ServiceBloc>().add(
                      RequestServiceStarted(
                        ServiceRequest(
                          id: 'req_${DateTime.now().millisecondsSinceEpoch}',
                          customerId: 'user123',
                          serviceType: _clickedCategory!,
                          location: const LatLng(35.6892, 51.3890),
                          status: ServiceStatus.pending,
                          createdAt: DateTime.now(),
                          problemDescription: text,
                          productBrand:
                              showBrandDropdown ? _selectedBrand : 'N/A',
                          budgetRange:
                              '${_estimatedBudget.toStringAsFixed(0)} تومان',
                          preferredTechnicianLevel: _techLevel,
                        ),
                      ),
                    );
              },
              type: AppButtonType.primary,
              icon: Icons.rocket_launch_outlined,
            ),
          ),
        ],
      ),
    );
  }

  String _getServiceFaName(String service) {
    switch (service.toLowerCase()) {
      case 'plumbing':
        return 'لوله‌کشی و تاسیسات';
      case 'electricity':
        return 'برق‌کاری و سیم‌کشی';
      case 'painting':
        return 'نقاشی ساختمان';
      case 'ac repair':
        return 'سرویس کولر و تهویه';
      case 'cleaning':
        return 'نظافت و تمیزکاری';
      default:
        return service;
    }
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

  Widget _buildTrackingUI(
    BuildContext context,
    ThemeData theme,
    ServiceState state,
  ) {
    final request = (state is ServiceProfessionalAssigned)
        ? state.request
        : (state as ServiceOnTheWay).request;

    final expertName = request.assignedProfessionalName ?? 'علی رضایی';
    final expertSpecialty = request.assignedProfessionalSpecialty ??
        'متخصص ارشد تاسیسات و لوله‌کشی';
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
              backgroundColor: Colors.green,
              child: Icon(Icons.check_circle, size: 54, color: Colors.white),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'متخصص تایید شده و در راه است!',
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: 22,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'درخواست لوله‌کشی شما با موفقیت ثبت شد. متخصص در حال حرکت به لوکیشن شماست.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onBackground.withOpacity(0.6),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),

          // Expert Details Card
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
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
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.onPrimaryContainer,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              expertName,
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              expertSpecialty,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.onSurface.withOpacity(
                                  0.6,
                                ),
                                fontSize: 13,
                              ),
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
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Text(
                            '(متخصص برتر)',
                            style: TextStyle(color: Colors.grey, fontSize: 11),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          const Icon(
                            Icons.access_time,
                            color: Colors.blue,
                            size: 20,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'ETA: ${request.estimatedArrivalTime} دقیقه',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              color: Colors.blue,
                            ),
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
                        'قیمت نهایی توافق شده:',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                      ),
                      Text(
                        '${confirmedPrice.toStringAsFixed(0).replaceAllMapped(RegExp(r"(\d{1,3})(?=(\d{3})+(?!\d))"), (Match m) => "${m[1]},")} تومان',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: theme.colorScheme.primary,
                        ),
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
              text: 'ارسال پیام به $expertName',
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'در حال باز کردن چت مستقیم با $expertName...',
                    ),
                  ),
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
              text: 'تماس تلفنی با متخصص',
              onPressed: () {},
              type: AppButtonType.outline,
              icon: Icons.phone_outlined,
            ),
          ),
          const SizedBox(height: 24),
          TextButton(
            onPressed: () {
              context.read<ServiceBloc>().add(
                    ServiceStatusUpdated(
                      ServiceRequest(
                        id: 'req_${DateTime.now().millisecondsSinceEpoch}',
                        customerId: 'user123',
                        serviceType: request.serviceType,
                        location: const LatLng(35.6892, 51.3890),
                        status: ServiceStatus.pending,
                        createdAt: DateTime.now(),
                      ),
                    ),
                  );
            },
            child: const Text(
              'لغو درخواست سرویس',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}
