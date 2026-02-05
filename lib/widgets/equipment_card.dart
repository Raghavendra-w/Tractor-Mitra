class EquipmentCard extends StatelessWidget {
  final Map equipment;

  const EquipmentCard({super.key, required this.equipment});

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          Expanded(
            child: Image.network(
              "http://127.0.0.1:8000${equipment['image']}",
              fit: BoxFit.cover,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              children: [
                Text(
                  equipment['name'],
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text("₹${equipment['price_per_hour']} / hr"),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
