import 'package:flutter/material.dart';
import 'SearchVenues.dart';
import 'farha_shared.dart';
import 'UserNav.dart';
import 'booking_service.dart';
import 'api_service.dart';

// ── Booking Model ─────────────────────────────────────────────────────────────
class BookingModel {
  final String id;
  final String venueName;
  final String date;
  final String time;
  final String price;
  final String status; // 'Pending' | 'Confirmed' | 'Completed' | 'Declined'
  final String image;
  final DateTime? rawDate;
  final double rawPrice;

  const BookingModel({
    required this.id,
    required this.venueName,
    required this.date,
    required this.time,
    required this.price,
    required this.status,
    required this.image,
    this.rawDate,
    this.rawPrice = 0,
  });

  factory BookingModel.fromJson(Map<String, dynamic> json) {
    final rawStatus = (json['status'] ?? 'pending').toString().toLowerCase();
    const statusMap = {
      'pending': 'Pending',
      'confirmed': 'Confirmed',
      'completed': 'Completed',
      'cancelled': 'Declined',
    };

    DateTime? parsedDate;
    String dateStr = '';
    String timeStr = '';
    final rawDateStr = json['booking_date']?.toString();
    if (rawDateStr != null && rawDateStr.isNotEmpty) {
      parsedDate = DateTime.tryParse(rawDateStr);
      if (parsedDate != null) {
        dateStr =
        '${parsedDate.year}-${parsedDate.month.toString().padLeft(2, '0')}-${parsedDate.day.toString().padLeft(2, '0')}';
        timeStr =
        '${parsedDate.hour.toString().padLeft(2, '0')}:${parsedDate.minute.toString().padLeft(2, '0')}';
      }
    }

    final priceValue =
        double.tryParse(json['sum_total']?.toString() ?? '') ?? 0;

    return BookingModel(
      id: json['b_id']?.toString() ?? json['id']?.toString() ?? '',
      venueName: json['service_name']?.toString() ??
          json['vendor_name']?.toString() ??
          'Venue',
      date: dateStr,
      time: timeStr,
      price: '\$${priceValue.toStringAsFixed(0)}',
      status: statusMap[rawStatus] ?? 'Pending',
      image: json['image']?.toString() ?? '',
      rawDate: parsedDate,
      rawPrice: priceValue,
    );
  }
}
// ── Booking History Page ──────────────────────────────────────────────────────
class BookingHistoryPage extends StatefulWidget {
  const BookingHistoryPage({super.key});

  @override
  State<BookingHistoryPage> createState() => _BookingHistoryPageState();
}

class _BookingHistoryPageState extends State<BookingHistoryPage> {
  String _activeFilter = 'All';
  bool _loading = true;
  String? _error;
  List<BookingModel> _bookings = [];

  final List<String> _filters = [
    'All',
    'Pending',
    'Confirmed',
    'Completed',
    'Declined',
  ];

  @override
  void initState() {
    super.initState();
    _fetchBookings();
  }

  // ── Fetch from API ────────────────────────────────
  Future<void> _fetchBookings() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      _bookings = await BookingService.getUserBookings();
    } on ApiException catch (e) {
      _error = e.message;
    } catch (e) {
      _error = 'Failed to load bookings. Please try again.';
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }
  List<BookingModel> get _filtered {
    if (_activeFilter == 'All') return _bookings;
    return _bookings
        .where((b) => b.status == _activeFilter)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      appBar: const UserNav(activeTab: 'My Bookings'),
      body: RefreshIndicator(
        color: kGold,
        onRefresh: _fetchBookings,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 28, 20, 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // ── Title ─────────────────────────────
              const Text(
                'My Bookings',
                style: TextStyle(
                  color: kNavy,
                  fontWeight: FontWeight.w900,
                  fontSize: 28,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Manage all your reservations, payment status, and event details.',
                style: TextStyle(color: kGray, fontSize: 14, height: 1.5),
              ),

              const SizedBox(height: 24),

              // ── Booking Overview Card ──────────────
              FarhaCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    // Card header
                    const Text(
                      'Booking Overview',
                      style: TextStyle(
                        color: kNavy,
                        fontWeight: FontWeight.w800,
                        fontSize: 17,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Filter your bookings by status and open each reservation quickly.',
                      style: TextStyle(color: kGray, fontSize: 13, height: 1.5),
                    ),

                    const SizedBox(height: 16),

                    // Filter label
                    Row(
                      children: const [
                        Icon(Icons.filter_list_rounded, color: kGray, size: 16),
                        SizedBox(width: 6),
                        Text(
                          'Filter',
                          style: TextStyle(
                            color: kGray,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 10),

                    // Filter chips
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _filters.map((f) {
                        final isActive = _activeFilter == f;
                        return GestureDetector(
                          onTap: () => setState(() => _activeFilter = f),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 7,
                            ),
                            decoration: BoxDecoration(
                              color: isActive ? kGoldBg : Colors.transparent,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: isActive ? kGold : kBorder,
                                width: isActive ? 1.5 : 1,
                              ),
                            ),
                            child: Text(
                              f,
                              style: TextStyle(
                                color: isActive ? kGold : kGray,
                                fontWeight: FontWeight.w700,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: 20),

                    // ── Content ───────────────────────
                    if (_loading)
                      _buildLoading()
                    else if (_error != null)
                      _buildError()
                    else if (_filtered.isEmpty)
                        _buildEmpty()
                      else
                        _buildList(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Loading State ─────────────────────────────────
  Widget _buildLoading() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 24),
      child: Center(
        child: CircularProgressIndicator(color: kGold, strokeWidth: 2.5),
      ),
    );
  }

  // ── Error State ───────────────────────────────────
  Widget _buildError() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        children: [
          const Icon(Icons.wifi_off_outlined, color: kGray, size: 36),
          const SizedBox(height: 10),
          Text(
            _error!,
            style: const TextStyle(color: kGray, fontSize: 13),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 14),
          OutlinedButton(
            onPressed: _fetchBookings,
            style: OutlinedButton.styleFrom(
              foregroundColor: kNavy,
              side: const BorderSide(color: kBorder),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text('Try Again'),
          ),
        ],
      ),
    );
  }

  // ── Empty State ───────────────────────────────────
  Widget _buildEmpty() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'No bookings found.',
          style: TextStyle(color: kGray, fontSize: 14),
        ),
        const SizedBox(height: 14),
        OutlinedButton(
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const SearchPage()),
          ),
          style: OutlinedButton.styleFrom(
            foregroundColor: kNavy,
            side: const BorderSide(color: kBorder),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Browse More Venues',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
              ),
              SizedBox(width: 6),
              Icon(Icons.arrow_forward_rounded, size: 14),
            ],
          ),
        ),
      ],
    );
  }

  // ── Booking List ──────────────────────────────────
  Widget _buildList() {
    return Column(
      children: _filtered.map((booking) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: _BookingItem(booking: booking),
        );
      }).toList(),
    );
  }
}

// ── Booking Item ──────────────────────────────────────────────────────────────
class _BookingItem extends StatelessWidget {
  final BookingModel booking;
  const _BookingItem({required this.booking});

  Color get _statusColor {
    switch (booking.status) {
      case 'Confirmed':
        return const Color(0xFF16A34A);
      case 'Pending':
        return const Color(0xFFD97706);
      case 'Completed':
        return kNavy;
      case 'Declined':
        return const Color(0xFFDC2626);
      default:
        return kGray;
    }
  }

  Color get _statusBg {
    switch (booking.status) {
      case 'Confirmed':
        return const Color(0xFFDCFCE7);
      case 'Pending':
        return const Color(0xFFFEF3C7);
      case 'Completed':
        return const Color(0xFFEEF2FF);
      case 'Declined':
        return const Color(0xFFFEE2E2);
      default:
        return kBg;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: kWhite,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: kBorder),
      ),
      child: Row(
        children: [
          // Image
          ClipRRect(
            borderRadius: const BorderRadius.horizontal(left: Radius.circular(14)),
            child: booking.image.isNotEmpty
                ? Image.network(
              booking.image,
              width: 90,
              height: 90,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => _placeholder(),
            )
                : _placeholder(),
          ),

          // Info
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Venue name + status
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          booking.venueName,
                          style: const TextStyle(
                            color: kNavy,
                            fontWeight: FontWeight.w800,
                            fontSize: 14,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: _statusBg,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          booking.status,
                          style: TextStyle(
                            color: _statusColor,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),

                  // Date
                  Row(
                    children: [
                      const Icon(Icons.calendar_today_outlined,
                          color: kGray, size: 13),
                      const SizedBox(width: 4),
                      Text(
                        booking.date,
                        style: const TextStyle(color: kGray, fontSize: 12),
                      ),
                      const SizedBox(width: 10),
                      const Icon(Icons.access_time_outlined,
                          color: kGray, size: 13),
                      const SizedBox(width: 4),
                      Text(
                        booking.time,
                        style: const TextStyle(color: kGray, fontSize: 12),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),

                  // Price
                  Text(
                    booking.price,
                    style: const TextStyle(
                      color: kNavy,
                      fontWeight: FontWeight.w900,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _placeholder() {
    return Container(
      width: 90,
      height: 90,
      color: kGoldBg,
      child: const Icon(Icons.image_outlined, color: kGold, size: 28),
    );
  }
}