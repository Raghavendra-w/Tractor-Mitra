import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../utils/owner_session.dart';
import 'add_tractor_screen.dart';

class OwnerDashboard extends StatefulWidget {
  const OwnerDashboard({super.key});

  @override
  State<OwnerDashboard> createState() => _OwnerDashboardState();
}

class _OwnerDashboardState extends State<OwnerDashboard> {
  late Future<List<dynamic>> bookingsFuture;
  late Future<Map<String, dynamic>> statsFuture;
  late Future<List<dynamic>> upcomingFuture;
  late Future<Map<String, dynamic>> earningsFuture;

  @override
  void initState() {
    super.initState();
    bookingsFuture = ApiService.getBookings();
    statsFuture = ApiService.getWeeklyStats(OwnerSession.ownerId!);
    upcomingFuture = ApiService.getUpcomingBookings(OwnerSession.ownerId!);
    earningsFuture = ApiService.getOwnerEarnings(OwnerSession.ownerId!);
  }

  void refreshAll() {
    setState(() {
      bookingsFuture = ApiService.getBookings();
      statsFuture = ApiService.getWeeklyStats(OwnerSession.ownerId!);
      upcomingFuture = ApiService.getUpcomingBookings(OwnerSession.ownerId!);
      earningsFuture = ApiService.getOwnerEarnings(OwnerSession.ownerId!);
    });
  }

  @override
  Widget build(BuildContext context) {
    // 🔐 LOGIN GUARD
    if (OwnerSession.ownerId == null) {
      Future.microtask(() => Navigator.pop(context));
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: Colors.green)),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Dashboard"),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.green,
        child: const Icon(Icons.add),
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddTractorScreen()),
          );
          if (result == true) refreshAll();
        },
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// =======================
            /// ROW 1 – ACCEPTED + IN PROGRESS
            /// =======================
            Row(
              children: [
                Expanded(
                  child: _futureStatCard(
                    future: earningsFuture,
                    title: "Accepted Bookings",
                    valueKey: "accepted_jobs",
                    color: const Color(0xFFE6F48F),
                    icon: Icons.check_circle_outline,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _futureStatCard(
                    future: earningsFuture,
                    title: "Work In Progress",
                    valueKey: "in_progress_jobs",
                    color: const Color(0xFFB8F0FF),
                    icon: Icons.timelapse,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            /// =======================
            /// ROW 2 – COMPLETED + EARNINGS
            /// =======================
            Row(
              children: [
                /// ✅ WORK COMPLETED (YOUR REQUIRED CODE)
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFB9F28C),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: FutureBuilder<Map<String, dynamic>>(
                      future: earningsFuture,
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return const Text(
                            "0",
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          );
                        }

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(
                              Icons.assignment_turned_in_outlined,
                              size: 30,
                            ),
                            const SizedBox(height: 12),
                            const Text("Work Completed"),
                            const SizedBox(height: 6),
                            Text(
                              snapshot.data!['completed_jobs'].toString(),
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ),

                const SizedBox(width: 12),

                /// 💰 TOTAL EARNING
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFE0B2),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: FutureBuilder<Map<String, dynamic>>(
                      future: earningsFuture,
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return const Text(
                            "₹ 0",
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          );
                        }

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(
                              Icons.account_balance_wallet_outlined,
                              size: 30,
                            ),
                            const SizedBox(height: 12),
                            const Text("Total Earning"),
                            const SizedBox(height: 6),
                            Text(
                              "₹ ${snapshot.data!['total_earning']}",
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            /// =======================
            /// WEEKLY STATS
            /// =======================
            const Text(
              "Weekly Booking Stats",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            FutureBuilder<Map<String, dynamic>>(
              future: statsFuture,
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const SizedBox(
                    height: 200,
                    child: Center(child: CircularProgressIndicator()),
                  );
                }

                final received = snapshot.data!['received'];
                final accepted = snapshot.data!['accepted'];
                final days = snapshot.data!['days'];

                return Container(
                  height: 220,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: List.generate(7, (i) {
                      return Column(
                        children: [
                          Text(days[i], style: const TextStyle(fontSize: 12)),
                          const SizedBox(height: 6),
                          Container(
                            height: received[i] * 10 + 5,
                            width: 10,
                            color: Colors.lightGreen,
                          ),
                          const SizedBox(height: 4),
                          Container(
                            height: accepted[i] * 10 + 5,
                            width: 10,
                            color: Colors.teal,
                          ),
                        ],
                      );
                    }),
                  ),
                );
              },
            ),

            const SizedBox(height: 24),

            /// =======================
            /// UPCOMING BOOKINGS
            /// =======================
            const Text(
              "Upcoming Bookings",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            FutureBuilder<List<dynamic>>(
              future: upcomingFuture,
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final upcoming = snapshot.data!;
                if (upcoming.isEmpty) {
                  return const Text("No Upcoming Bookings");
                }

                return Column(
                  children: upcoming.map((b) {
                    return Card(
                      child: ListTile(
                        leading: const Icon(
                          Icons.agriculture,
                          color: Colors.green,
                        ),
                        title: Text(b['tractor_name']),
                        subtitle: Text(
                          "Hours: ${b['hours']} | ₹${b['total_price']}",
                        ),
                        trailing: Text(b['created_at']),
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  /// =======================
  /// REUSABLE FUTURE STAT CARD
  /// =======================
  Widget _futureStatCard({
    required Future<Map<String, dynamic>> future,
    required String title,
    required String valueKey,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
      ),
      child: FutureBuilder<Map<String, dynamic>>(
        future: future,
        builder: (context, snapshot) {
          final value = snapshot.hasData
              ? snapshot.data![valueKey].toString()
              : "0";

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, size: 30),
              const SizedBox(height: 12),
              Text(title),
              const SizedBox(height: 6),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
