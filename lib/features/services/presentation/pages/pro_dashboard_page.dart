import 'package:flutter/material.dart';

class ProDashboardPage extends StatelessWidget {
  const ProDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Professional Hub')),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: 3,
        itemBuilder: (context, index) {
          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            child: ListTile(
              title: Text('Request \#${index + 1}: Plumbing'),
              subtitle: const Text('Location: North Tehran | 2km away'),
              trailing: ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Request Accepted!'),
                      backgroundColor: Colors.green,
                    ),
                  );
                },
                child: const Text('Accept'),
              ),
            ),
          );
        },
      ),
    );
  }
}
