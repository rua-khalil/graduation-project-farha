import 'package:flutter/material.dart';
import 'farha_shared.dart';
import 'VendorNav.dart';

// ── Dashboard Data Model ──────────────────────────────
class VendorDashboardData {
  final int totalBookings;
  final int pendingRequests;
  final double netEarnings;
  final int myServices;
  final String vendorFirstName;
  final List<int> monthlyBookings; // 6 values, Jan..Jun (or last 6 months)
  final List<String> monthLabels;

  const VendorDashboardData({
    required this.totalBookings,
    required this.pendingRequests,
    required this.netEarnings,
    required this.myServices,
    required this.vendorFirstName,
    required this.monthlyBookings,
    required this.monthLabels,
  });

  factory VendorDashboardData.fromJson(Map<String, dynamic> json) {
    final trends = (json['booking_trends'] ?? json['bookingTrends'] ?? []) as List;
    return VendorDashboardData(
      totalBookings:   json['total_bookings'] ?? json['totalBookings'] ?? 0,
      pendingRequests: json['pending_requests'] ?? json['pendingRequests'] ?? 0,
      netEarnings: ((json['net_earnings'] ?? json['netEarnings'] ?? 0) as num).toDouble(),
      myServices:      json['my_services'] ?? json['myServices'] ?? 0,
      vendorFirstName: json['vendor_first_name'] ?? json['vendorFirstName'] ?? '',
      monthlyBookings: trends.map<int>((e) => (e['count'] ?? e['value'] ?? 0) as int).toList(),
      monthLabels:     trends.map<String>((e) => (e['month'] ?? e['label'] ?? '').toString()).toList(),
    );
  }

  factory VendorDashboardData.empty() {
    return const VendorDashboardData(
      totalBookings: 0,
      pendingRequests: 0,
      netEarnings: 0,
      myServices: 0,
      vendorFirstName: '',
      monthlyBookings: [0, 0, 0, 0, 0, 0],
      monthLabels: ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun'],
    );
  }
}

// ── Vendor Dashboard Page ─────────────────────────────
class VendorDashboardPage extends StatefulWidget {
  const VendorDashboardPage({super.key});

  @override
  State<VendorDashboardPage> createState() => _VendorDashboardPageState();
}

class _VendorDashboardPageState extends State<VendorDashboardPage> {
  bool _loading = true;
  String? _error;
  VendorDashboardData _data = VendorDashboardData.empty();

  // ── API Endpoint ──────────────────────────────────
  // TODO: Replace with your real dashboard endpoint
  static const String _dashboardUrl = 'https://your-api.com/api/vendor/dashboard';

  @override
  void initState() {
    super.initState();
    _fetchDashboard();
  }

  Future<void> _fetchDashboard() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      // TODO: Replace with your real API call
      // final prefs = await SharedPreferences.getInstance();
      // final token = prefs.getString('userToken') ?? '';
      // final response = await http.get(
      //   Uri.parse(_dashboardUrl),
      //   headers: {'Authorization': 'Bearer $token'},
      // );
      // if (response.statusCode == 200) {
      //   _data = VendorDashboardData.fromJson(jsonDecode(response.body));
      // } else {
      //   _error = 'Failed to load dashboard data.';
      // }

      await Future.delayed(const Duration(milliseconds: 700));
      _data = VendorDashboardData.empty(); // placeholder until API is wired

    } catch (e) {
      _error = 'Connection error. Please try again.';
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      appBar: const VendorNav(activeTab: 'Dashboard'),
      body: RefreshIndicator(
        color: kGold,
        onRefresh: _fetchDashboard,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // ── Page Title ────────────────────────
              const Padding(
                padding: EdgeInsets.fromLTRB(20, 24, 20, 4),
                child: Text(
                  'Vendor Dashboard',
                  style: TextStyle(
                    color: kNavy,
                    fontWeight: FontWeight.w900,
                    fontSize: 26,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                child: Text(
                  _data.vendorFirstName.isNotEmpty
                      ? "Welcome back, ${_data.vendorFirstName}! Here's your performance summary."
                      : "Welcome back! Here's your performance summary.",
                  style: const TextStyle(color: kGray, fontSize: 13),
                ),
              ),

              if (_loading)
                _buildLoading()
              else if (_error != null)
                _buildError()
              else
                _buildContent(),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoading() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 60),
      child: Center(
        child: CircularProgressIndicator(color: kGold, strokeWidth: 2.5),
      ),
    );
  }

  Widget _buildError() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
      child: Column(
        children: [
          const Icon(Icons.wifi_off_outlined, color: kGray, size: 36),
          const SizedBox(height: 10),
          Text(_error!, style: const TextStyle(color: kGray, fontSize: 13), textAlign: TextAlign.center),
          const SizedBox(height: 14),
          OutlinedButton(
            onPressed: _fetchDashboard,
            style: OutlinedButton.styleFrom(
              foregroundColor: kNavy,
              side: const BorderSide(color: kBorder),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Try Again'),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return Column(
      children: [
        // ── Stats Cards ───────────────────────
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              _StatCard(
                label: 'Total Bookings',
                value: '${_data.totalBookings}',
                icon: Icons.calendar_month_outlined,
                iconColor: const Color(0xFF5B8CFF),
                iconBg: const Color(0xFFEEF3FF),
              ),
              const SizedBox(height: 12),
              _StatCard(
                label: 'Pending Requests',
                value: '${_data.pendingRequests}',
                icon: Icons.assignment_outlined,
                iconColor: const Color(0xFFD5A217),
                iconBg: const Color(0xFFFFF4DE),
              ),
              const SizedBox(height: 12),
              _StatCard(
                label: 'Net Earnings',
                value: '\$${_data.netEarnings.toStringAsFixed(0)}',
                icon: Icons.attach_money_rounded,
                iconColor: const Color(0xFF22C55E),
                iconBg: const Color(0xFFECFDF5),
                valueColor: const Color(0xFF22C55E),
              ),
              const SizedBox(height: 12),
              _StatCard(
                label: 'My Services',
                value: '${_data.myServices}',
                icon: Icons.star_outline_rounded,
                iconColor: const Color(0xFFD5A217),
                iconBg: const Color(0xFFFFF4DE),
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        // ── Booking Trends ────────────────────
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: FarhaCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Booking Trends',
                  style: TextStyle(
                    color: kNavy,
                    fontWeight: FontWeight.w800,
                    fontSize: 17,
                  ),
                ),
                const SizedBox(height: 20),
                _BookingChart(
                  months: _data.monthLabels,
                  values: _data.monthlyBookings,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ── Stat Card ─────────────────────────────────────────
class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final Color? valueColor;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return FarhaCard(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(color: kGray, fontSize: 13),
                ),
                const SizedBox(height: 8),
                Text(
                  value,
                  style: TextStyle(
                    color: valueColor ?? kNavy,
                    fontWeight: FontWeight.w900,
                    fontSize: 28,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: iconColor, size: 24),
          ),
        ],
      ),
    );
  }
}

// ── Booking Chart (simple bar chart) ─────────────────
class _BookingChart extends StatelessWidget {
  final List<String> months;
  final List<int> values;

  const _BookingChart({required this.months, required this.values});

  @override
  Widget build(BuildContext context) {
    final maxVal = values.isEmpty
        ? 4
        : (values.reduce((a, b) => a > b ? a : b) == 0
        ? 4
        : values.reduce((a, b) => a > b ? a : b));

    return SizedBox(
      height: 160,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: List.generate(months.length, (i) {
          final v = i < values.length ? values[i] : 0;
          final barHeight = v == 0 ? 4.0 : (v / maxVal) * 120;
          final isActive = v > 0;
          return Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (isActive)
                  Text(
                    '$v',
                    style: const TextStyle(
                      color: kNavy,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                const SizedBox(height: 4),
                Container(
                  height: barHeight,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    color: isActive ? kGold : kBorder,
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  months[i],
                  style: const TextStyle(
                    color: kGray,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}