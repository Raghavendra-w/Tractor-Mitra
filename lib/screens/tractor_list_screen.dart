import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'tractor_details_screen.dart';

class TractorListScreen extends StatefulWidget {
  final String category;

  const TractorListScreen({super.key, required this.category});

  @override
  State<TractorListScreen> createState() => _TractorListScreenState();
}

class _TractorListScreenState extends State<TractorListScreen> {
  List<dynamic> items = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    try {
      final data = await ApiService.getAvailableByCategory(widget.category);

      setState(() {
        items = data;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  Widget _buildImage(String image) {
    if (image.isEmpty) {
      return Image.asset("assets/images/tractor1.jpg", fit: BoxFit.cover);
    }

    return Image.network(
      "http://10.0.2.2:8000$image",
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) {
        return Image.asset("assets/images/tractor1.jpg", fit: BoxFit.cover);
      },
    );
  }

  String _titleFromCategory() {
    switch (widget.category) {
      case "tractor":
        return "Available Tractors";
      case "harvester":
        return "Available Harvesters";
      case "jcb":
        return "Available JCBs";
      case "trolley":
        return "Available Trolleys";
      default:
        return "Available Machines";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_titleFromCategory()), centerTitle: true),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.green))
          : items.isEmpty
          ? const Center(
              child: Text(
                "No machines available",
                style: TextStyle(fontSize: 16),
              ),
            )
          : GridView.builder(
              padding: const EdgeInsets.all(12),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.72,
              ),
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];

                return GestureDetector(
                  onTap: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => TractorDetailsScreen(tractor: item),
                      ),
                    );

                    if (result == true) {
                      loadData();
                    }
                  },
                  child: Card(
                    elevation: 6,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(16),
                            ),
                            child: _buildImage(item['image'] ?? ""),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item['name'],
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text("₹${item['price_per_hour']} / hr"),
                              const SizedBox(height: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.green.shade100,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Text(
                                  "Available",
                                  style: TextStyle(
                                    color: Colors.green,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
