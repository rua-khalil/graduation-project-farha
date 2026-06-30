import 'package:flutter/material.dart';
import 'farha_shared.dart';
import 'UserBookinghistorypage.dart';
import 'UserFavoritespage.dart';
import 'UserNav.dart';
import 'booking_service.dart';
import 'user_service.dart';
import 'api_service.dart';

class UserDashboardPage extends StatefulWidget {
  const UserDashboardPage({super.key});

  @override
  State<UserDashboardPage> createState() => _UserDashboardPageState();
}

class _UserDashboardPageState extends State<UserDashboardPage> {
  bool _loading = true;
  String _firstName = 'User';
  List<BookingModel> _bookings = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _loading = true);
    try {
      final results = await Future.wait([
        UserService.getCurrentUser(),
        BookingService.getUserBookings(),
      ]);
      final profile = results[0] as UserProfile;
      final bookings = results[1] as List<BookingModel>;

      setState(() {
        _firstName = profile.firstName;
        _bookings = bookings;
      });
    } catch (_) {
      // لو فشل، منخلي القيم الافتراضية
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  int get _totalBookings => _bookings.length;

  int get _upcomingCount => _bookings.where((b) {
    if (b.rawDate == null) return false;
    final isFuture = b.rawDate!.isAfter(DateTime.now().subtract(const Duration(days: 1)));
    return isFuture && (b.status == 'Confirmed' || b.status == 'Pending');
  }).length;

  double get _totalSpent => _bookings
      .where((b) => b.status == 'Completed')
      .fold(0.0, (sum, b) => sum + b.rawPrice);

  List<BookingModel> get _upcomingBookings {
    final list = _bookings.where((b) {
      if (b.rawDate == null) return false;
      final isFuture = b.rawDate!.isAfter(DateTime.now().subtract(const Duration(days: 1)));
      return isFuture && (b.status == 'Confirmed' || b.status == 'Pending');
    }).toList();
    list.sort((a, b) => a.rawDate!.compareTo(b.rawDate!));
    return list.take(2).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F7),
      appBar: const UserNav(),
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),

              // ── Welcome Header ────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Welcome back,\n$_firstName!',
                      style: const TextStyle(
                        color: Color(0xFF1A1F3C),
                        fontWeight: FontWeight.w800,
                        fontSize: 26,
                        height: 1.25,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      "Here's what's happening with your events and bookings.",
                      style: TextStyle(color: Color(0xFF8A8FA8), fontSize: 13),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // ── Stats Cards ───────────────────────
              if (_loading)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 40),
                  child: Center(child: CircularProgressIndicator(color: kGold)),
                )
              else
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: [
                      _StatCard(
                        label: 'Total Bookings',
                        value: '$_totalBookings',
                        icon: Icons.calendar_today_outlined,
                        iconColor: const Color(0xFFE6B44C),
                        iconBgColor: const Color(0xFFFFF3D6),
                      ),
                      const SizedBox(height: 12),
                      _StatCard(
                        label: 'Upcoming Events',
                        value: '$_upcomingCount',
                        icon: Icons.access_time_outlined,
                        iconColor: const Color(0xFF7B8CDE),
                        iconBgColor: const Color(0xFFEEF0FB),
                      ),
                      const SizedBox(height: 12),
                      const _StatCard(
                        label: 'Favorite Venues',
                        value: '0', // TODO: اربطها لما يجهز endpoint الـ favorites
                        icon: Icons.favorite_border,
                        iconColor: Color(0xFFD87BA0),
                        iconBgColor: Color(0xFFFCEEF4),
                      ),
                      const SizedBox(height: 12),
                      _StatCard(
                        label: 'Total Spent',
                        value: '\$${_totalSpent.toStringAsFixed(0)}',
                        icon: Icons.receipt_long_outlined,
                        iconColor: const Color(0xFF4CAF8E),
                        iconBgColor: const Color(0xFFE6F6F0),
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: 20),

              // ── Upcoming Bookings ─────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _SectionCard(
                  title: 'Upcoming Bookings',
                  subtitle: 'Track your next confirmed and pending reservations.',
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const BookingHistoryPage()),
                        ),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                          decoration: BoxDecoration(
                            border: Border.all(color: const Color(0xFFE5E7EF)),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Row(
                            children: [
                              Text('View All', style: TextStyle(color: Color(0xFF1A1F3C), fontWeight: FontWeight.w600, fontSize: 14)),
                              SizedBox(width: 4),
                              Icon(Icons.chevron_right, size: 18, color: Color(0xFF1A1F3C)),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      if (_upcomingBookings.isEmpty)
                        const Text('No upcoming bookings yet.', style: TextStyle(color: Color(0xFF8A8FA8), fontSize: 13))
                      else
                        ..._upcomingBookings.map((b) => Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  b.venueName,
                                  style: const TextStyle(color: Color(0xFF1A1F3C), fontWeight: FontWeight.w700, fontSize: 13),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Text(b.date, style: const TextStyle(color: Color(0xFF8A8FA8), fontSize: 12)),
                            ],
                          ),
                        )),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // ── Quick Actions ─────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _SectionCard(
                  title: 'Quick Actions',
                  subtitle: 'Jump directly to the most used customer actions.',
                  child: Column(
                    children: [
                      _QuickActionRow(
                        icon: Icons.search,
                        iconColor: const Color(0xFFE6B44C),
                        iconBgColor: const Color(0xFFFFF3D6),
                        title: 'Browse Venues',
                        subtitle: 'Discover wedding halls and event spaces',
                        onTap: () {},
                      ),
                      const SizedBox(height: 12),
                      _QuickActionRow(
                        icon: Icons.favorite_border,
                        iconColor: const Color(0xFFD87BA0),
                        iconBgColor: const Color(0xFFFCEEF4),
                        title: 'View Favorites',
                        subtitle: 'See your saved vendors and venues',
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const FavoritesPage())),
                      ),
                      const SizedBox(height: 12),
                      _QuickActionRow(
                        icon: Icons.calendar_today_outlined,
                        iconColor: const Color(0xFFE6B44C),
                        iconBgColor: const Color(0xFFFFF3D6),
                        title: 'My Bookings',
                        subtitle: 'Manage reservations and payments',
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const BookingHistoryPage())),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 28),
              const FarhaFooter(),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Widgets ───────────────────────────────────────────

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color iconColor;
  final Color iconBgColor;

  const _StatCard({required this.label, required this.value, required this.icon, required this.iconColor, required this.iconBgColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 2))],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(color: Color(0xFF8A8FA8), fontSize: 13, fontWeight: FontWeight.w500)),
              const SizedBox(height: 6),
              Text(value, style: const TextStyle(color: Color(0xFF1A1F3C), fontWeight: FontWeight.w800, fontSize: 26)),
            ],
          ),
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(color: iconBgColor, borderRadius: BorderRadius.circular(14)),
            child: Icon(icon, color: iconColor, size: 22),
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget child;

  const _SectionCard({required this.title, required this.subtitle, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(color: Color(0xFF1A1F3C), fontWeight: FontWeight.w800, fontSize: 17)),
          const SizedBox(height: 4),
          Text(subtitle, style: const TextStyle(color: Color(0xFF8A8FA8), fontSize: 12)),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}

class _QuickActionRow extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color iconBgColor;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _QuickActionRow({required this.icon, required this.iconColor, required this.iconBgColor, required this.title, required this.subtitle, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 14),
        decoration: BoxDecoration(
          color: const Color(0xFFF9F9FB),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFEEEFF4)),
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(color: iconBgColor, borderRadius: BorderRadius.circular(12)),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(color: Color(0xFF1A1F3C), fontWeight: FontWeight.w700, fontSize: 14)),
                  const SizedBox(height: 3),
                  Text(subtitle, style: const TextStyle(color: Color(0xFF8A8FA8), fontSize: 12)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}