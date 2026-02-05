import 'package:flutter/material.dart';

class PaymentScreen extends StatelessWidget {
  final Map tractor;
  final int hours;
  final int totalAmount;

  const PaymentScreen({
    super.key,
    required this.tractor,
    required this.hours,
    required this.totalAmount,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Payment"), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🚜 TRACTOR SUMMARY
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tractor['name'],
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text("Hours: $hours"),
                    const SizedBox(height: 6),
                    Text(
                      "Total Amount: ₹$totalAmount",
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // 💳 PAYMENT OPTIONS
            const Text(
              "Select Payment Method",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 12),

            ListTile(
              leading: const Icon(Icons.money, color: Colors.green),
              title: const Text("Cash on Work"),
              subtitle: const Text("Pay directly to tractor owner"),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                // ✅ PAYMENT SUCCESS
                Navigator.pop(context, true);
              },
            ),

            const Divider(),

            ListTile(
              leading: const Icon(Icons.payment, color: Colors.blue),
              title: const Text("Online Payment"),
              subtitle: const Text("UPI / Card / Net Banking"),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                // 🔜 Razorpay / Stripe can be added here
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Online payment coming soon")),
                );
              },
            ),

            const Spacer(),

            // ✅ PAY BUTTON
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: () {
                  Navigator.pop(context, true);
                },
                child: const Text(
                  "Pay & Confirm Booking",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
