import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'reviews_screen.dart';

class BookingsScreen extends StatefulWidget {
  final int tractorId;
  final String tractorName;
  final String imageUrl; // backend image path
  final int pricePerHour;

  const BookingsScreen({
    super.key,
    required this.tractorId,
    required this.tractorName,
    required this.imageUrl,
    required this.pricePerHour,
  });

  @override
  State<BookingsScreen> createState() => _BookingsScreenState();
}

class _BookingsScreenState extends State<BookingsScreen> {
  int hours = 1;

  @override
  Widget build(BuildContext context) {
    final int totalPrice = widget.pricePerHour * hours;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Book Tractor"),
        centerTitle: true,
        backgroundColor: Colors.green,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🖼 TRACTOR IMAGE
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: widget.imageUrl.isNotEmpty
                  ? Image.network(
                      "http://127.0.0.1:8000${widget.imageUrl}",
                      height: 180,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Container(
                          height: 180,
                          color: Colors.grey[200],
                          child: const Center(
                            child: CircularProgressIndicator(
                              color: Colors.green,
                            ),
                          ),
                        );
                      },
                      errorBuilder: (_, __, ___) {
                        return _fallbackImage();
                      },
                    )
                  : _fallbackImage(),
            ),

            const SizedBox(height: 16),

            // 🚜 TRACTOR NAME
            Text(
              widget.tractorName,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 12),

            // ⏱ HOURS SELECTOR
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Select Hours", style: TextStyle(fontSize: 16)),
                DropdownButton<int>(
                  value: hours,
                  items: List.generate(
                    10,
                    (i) => DropdownMenuItem(
                      value: i + 1,
                      child: Text("${i + 1} hrs"),
                    ),
                  ),
                  onChanged: (value) {
                    setState(() => hours = value!);
                  },
                ),
              ],
            ),

            const SizedBox(height: 12),

            // 💰 TOTAL PRICE
            Text(
              "Total Price: ₹$totalPrice",
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 20),

            // ⭐ REVIEWS
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          ReviewsScreen(tractorId: widget.tractorId),
                    ),
                  );
                },
                child: const Text("View / Add Reviews"),
              ),
            ),

            const SizedBox(height: 12),

            // ✅ CONFIRM BOOKING
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () async {
                  try {
                    await ApiService.createBooking(
                      tractorId: widget.tractorId,
                      hours: hours,
                      totalAmount: totalPrice,
                    );

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Booking confirmed 🚜"),
                        backgroundColor: Colors.green,
                      ),
                    );

                    Navigator.pop(context, true);
                  } on ConnectionException catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(e.message),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                },
                child: const Text(
                  "Confirm Booking",
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 🔁 FALLBACK IMAGE
  Widget _fallbackImage() {
    return Container(
      height: 180,
      color: Colors.grey[200],
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.agriculture, size: 60, color: Colors.grey),
          SizedBox(height: 8),
          Text("Image not available", style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}
