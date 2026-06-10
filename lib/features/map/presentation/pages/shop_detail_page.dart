import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/widgets/app_button.dart';

class ShopDetailPage extends StatelessWidget {
  final String shopId;
  const ShopDetailPage({super.key, required this.shopId});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: const Text('Store Profile', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              background: Hero(
                tag: 'shop_image_$shopId',
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.network(
                      'https:/via.placeholder.com/400x300', 
                      fit: BoxFit.cover,
                    ),
                    const DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Colors.transparent, Colors.black87],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Tech Hub', 
                            style: theme.textTheme.displayLarge?.copyWith(fontWeight: FontWeight.bold, fontSize: 28),
                          ),
                          Text(
                            'Electronics \& Repair',
                            style: theme.textTheme.titleMedium?.copyWith(color: theme.colorScheme.primary),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.amber.shade100,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.star, color: Colors.amber, size: 20),
                                Text(' 4.8', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
                              ],
                            ),
                            Text('124 reviews', style: theme.textTheme.labelSmall),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  _buildInfoTile(theme, Icons.location_on, 'Address', 'Tehran, Valiasr St, Block 4'),
                  _buildInfoTile(theme, Icons.phone, 'Phone', '+98 21 1234 5678'),
                  _buildInfoTile(theme, Icons.access_time, 'Hours', 'Open: 09:00 - 22:00'),
                  const SizedBox(height: 24),
                  Text('About', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text(
                    'Best electronics in town. We provide the latest gadgets and expert repair services for all your devices. High quality and fast delivery.',
                    style: theme.textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 32),
                  Text('Featured Products', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.8,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                    ),
                    itemCount: 4,
                    itemBuilder: (context, index) {
                      return Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(child: Image.network('https:/via.placeholder.com/150', fit: BoxFit.cover, width: double.infinity)),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Product ${index + 1}', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
                                  Text('${(index + 1) * 150} $', style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.bold)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(24.0),
        child: AppButton(
          text: 'Visit Mini-Site',
          onPressed: () {},
          type: AppButtonType.primary,
          icon: Icons.open_in_browser,
        ),
      ),
    );
  }

  Widget _buildInfoTile(ThemeData theme, IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Icon(icon, color: theme.colorScheme.primary, size: 24),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
              Text(value, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500)),
            ],
          ),
        ],
      ),
    );
  }
}
