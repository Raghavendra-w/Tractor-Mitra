import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'payment_screen.dart';

class TractorDetailsScreen extends StatefulWidget {
  final Map tractor;

  const TractorDetailsScreen({super.key, required this.tractor});

  @override
  State<TractorDetailsScreen> createState() => _TractorDetailsScreenState();
}

class _TractorDetailsScreenState extends State<TractorDetailsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Booking state
  int hours = 1;
  bool isBooking = false;

  // Equipment state
  int totalEquipmentPrice = 0;
  final List<int> selectedEquipments = [];

  // Review state
  int rating = 0;
  final TextEditingController reviewController = TextEditingController();
  late Future<List<dynamic>> reviewsFuture;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    reviewsFuture = ApiService.getReviews(widget.tractor['id']);
  }

  @override
  void dispose() {
    _tabController.dispose();
    reviewController.dispose();
    super.dispose();
  }

  // ================= IMAGE =================
  Widget _buildImage(String image) {
    if (image.isEmpty) {
      return Image.asset(
        "assets/images/tractor1.jpg",
        fit: BoxFit.cover,
        width: double.infinity,
      );
    }

    return Image.network(
      "http://localhost:8000$image",
      fit: BoxFit.cover,
      width: double.infinity,
      errorBuilder: (_, __, ___) =>
          Image.asset("assets/images/tractor1.jpg", fit: BoxFit.cover),
    );
  }

  // ================= EQUIPMENT TOGGLE =================
  void toggleEquipment(int price, int id, bool selected) {
    setState(() {
      if (selected) {
        selectedEquipments.add(id);
        totalEquipmentPrice += price;
      } else {
        selectedEquipments.remove(id);
        totalEquipmentPrice -= price;
      }
    });
  }

  // ================= EQUIPMENT UI =================
  Widget buildEquipmentSelection(List equipments) {
    if (equipments.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Text(
          "No equipments added by owner",
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    return Column(
      children: equipments.map<Widget>((e) {
        return Card(
          child: CheckboxListTile(
            title: Text(e['name']),
            subtitle: Text("₹${e['price_per_hour']} / hr"),
            value: selectedEquipments.contains(e['id']),
            onChanged: (val) {
              toggleEquipment(e['price_per_hour'], e['id'], val!);
            },
          ),
        );
      }).toList(),
    );
  }

  // ================= REVIEW UI =================
  Widget buildStars() {
    return Row(
      children: List.generate(
        5,
        (i) => IconButton(
          icon: Icon(
            i < rating ? Icons.star : Icons.star_border,
            color: Colors.orange,
          ),
          onPressed: () => setState(() => rating = i + 1),
        ),
      ),
    );
  }

  Future<void> submitReview() async {
    if (rating == 0 || reviewController.text.isEmpty) return;

    await ApiService.addReview(
      tractorId: widget.tractor['id'],
      rating: rating,
      comment: reviewController.text,
    );

    setState(() {
      rating = 0;
      reviewController.clear();
      reviewsFuture = ApiService.getReviews(widget.tractor['id']);
    });
  }

  Widget buildReviews() {
    return FutureBuilder<List<dynamic>>(
      future: reviewsFuture,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        return ListView.builder(
          itemCount: snapshot.data!.length,
          itemBuilder: (context, index) {
            final r = snapshot.data![index];
            return Card(
              child: ListTile(
                title: Row(
                  children: List.generate(
                    r['rating'],
                    (_) =>
                        const Icon(Icons.star, size: 16, color: Colors.orange),
                  ),
                ),
                subtitle: Text(r['comment']),
              ),
            );
          },
        );
      },
    );
  }

  // ================= CONFIRM BOOKING =================
  Future<void> _confirmBooking() async {
    if (isBooking) return;

    setState(() => isBooking = true);

    final tractorPrice = widget.tractor['price_per_hour'] as int;
    final totalAmount = (tractorPrice + totalEquipmentPrice) * hours;

    try {
      final success = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => PaymentScreen(
            tractor: widget.tractor,
            hours: hours,
            totalAmount: totalAmount,
          ),
        ),
      );

      if (success == true) {
        await ApiService.createBooking(
          tractorId: widget.tractor['id'],
          hours: hours,
          totalAmount: totalAmount,
        );

        Navigator.pop(context, true);
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) setState(() => isBooking = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final tractor = widget.tractor;
    final List images = tractor['images'] ?? [];
    final List equipments = tractor['equipments'] ?? [];

    final tractorPrice = tractor['price_per_hour'] as int;
    final totalPrice = (tractorPrice + totalEquipmentPrice) * hours;

    return Scaffold(
      appBar: AppBar(title: Text(tractor['name'])),

      // ================= BOTTOM BAR =================
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                const Text("Hours"),
                const Spacer(),
                DropdownButton<int>(
                  value: hours,
                  items: List.generate(
                    12,
                    (i) =>
                        DropdownMenuItem(value: i + 1, child: Text("${i + 1}")),
                  ),
                  onChanged: (v) => setState(() => hours = v!),
                ),
              ],
            ),
            Text(
              "Total: ₹$totalPrice",
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            ElevatedButton(
              onPressed: isBooking ? null : _confirmBooking,
              child: const Text("Confirm Booking"),
            ),
          ],
        ),
      ),

      // ================= BODY =================
      body: Column(
        children: [
          SizedBox(
            height: 220,
            child: PageView.builder(
              itemCount: images.isEmpty ? 1 : images.length,
              itemBuilder: (c, i) =>
                  _buildImage(images.isEmpty ? "" : images[i]),
            ),
          ),

          TabBar(
            controller: _tabController,
            labelColor: Colors.green,
            tabs: const [
              Tab(text: "Details"),
              Tab(text: "Equipments"),
              Tab(text: "Reviews"),
            ],
          ),

          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    tractor['description'] ??
                        "Well maintained tractor suitable for farming.",
                  ),
                ),

                // ✅ EQUIPMENT TAB (FINAL)
                SingleChildScrollView(
                  padding: const EdgeInsets.all(8),
                  child: buildEquipmentSelection(equipments),
                ),

                // ✅ REVIEWS TAB
                Column(
                  children: [
                    buildStars(),
                    Padding(
                      padding: const EdgeInsets.all(8),
                      child: TextField(
                        controller: reviewController,
                        decoration: const InputDecoration(
                          hintText: "Write review",
                        ),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: submitReview,
                      child: const Text("Submit"),
                    ),
                    const Divider(),
                    Expanded(child: buildReviews()),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
