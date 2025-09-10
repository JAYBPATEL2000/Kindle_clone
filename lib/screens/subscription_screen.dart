import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/billing_provider.dart';

class SubscriptionScreen extends StatelessWidget {
  const SubscriptionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isSubscribed = context.watch<AuthProvider>().isSubscribed;
    final billing = context.watch<BillingProvider>();
    return Scaffold(
      appBar: AppBar(title: const Text('Subscription')),
      body: Center(
        child: isSubscribed
            ? const Text('You are subscribed. Enjoy premium books!')
            : Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Subscribe to unlock premium books'),
                  const SizedBox(height: 12),
                  if (billing.isLoading)
                    const CircularProgressIndicator()
                  else if (!billing.isAvailable)
                    const Text('Billing not available on this device/store')
                  else if (billing.products.isEmpty)
                    const Text('No products found. Configure in Play Console.')
                  else
                    ElevatedButton(
                      onPressed: () {
                        context.read<BillingProvider>().buySubscription();
                      },
                      child: Text('Subscribe - ' + (billing.products.first.price)),
                    ),
                  if (billing.error != null) ...[
                    const SizedBox(height: 12),
                    Text(billing.error!, style: const TextStyle(color: Colors.red)),
                  ]
                ],
              ),
      ),
    );
  }
}


