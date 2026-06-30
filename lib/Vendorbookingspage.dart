import 'package:flutter/material.dart';
import 'farha_shared.dart';
import 'VendorNav.dart';
import 'vendor_bookings_api.dart';

// ── Data Model ────────────────────────────────────────────────────────────────
enum BookingStatus { pending, approved, rejected }

class BookingModel {
  final String id;
  final String customerName;
  final String serviceName;
  final String date;   // e.g. "2026-07-12"
  final String time;   // e.g. "6:00 PM"
  final int guests;
  final double price;
  final String notes;
  BookingStatus status;

  BookingModel({
    required this.id,
    required this.customerName,
    required this.serviceName,
    required this.date,
    required this.time,
    this.guests = 0,
    required this.price,
    this.notes = '',
    this.status = BookingStatus.pending,
  });

  factory BookingModel.fromJson(Map<String, dynamic> json) {
    return BookingModel(
      id: json['id']?.toString() ?? '',
      customerName: json['customer_name'] ?? json['name'] ?? '',
      serviceName: json['service_name'] ?? json['service'] ?? '',
      date: json['date'] ?? '',
      time: json['time'] ?? '',
      guests: (json['guests'] ?? 0) is int ? json['guests'] ?? 0 : int.tryParse(json['guests'].toString()) ?? 0,
      price: (json['price'] ?? 0).toDouble(),
      notes: json['notes'] ?? '',
      status: _statusFromString(json['status']?.toString()),
    );
  }

  static BookingStatus _statusFromString(String? value) {
    switch ((value ?? '').toLowerCase()) {
      case 'approved':
        return BookingStatus.approved;
      case 'rejected':
        return BookingStatus.rejected;
      default:
        return BookingStatus.pending;
    }
  }
}

// ── Bookings Page ─────────────────────────────────────────────────────────────
class VendorBookingsPage extends StatefulWidget {
  const VendorBookingsPage({super.key});

  @override
  State<VendorBookingsPage> createState() => _VendorBookingsPageState();
}

class _VendorBookingsPageState extends State<VendorBookingsPage> {
  bool _isLoading = false;
  List<BookingModel> _bookings = [];

  // Tabs: 0 = Pending, 1 = Approved, 2 = Rejected, 3 = All
  int _selectedTab = 0;

  @override
  void initState() {
    super.initState();
    _loadBookings();
  }

  // ── Load Bookings ──────────────────────────────
  Future<void> _loadBookings() async {
    setState(() => _isLoading = true);

    try {
      _bookings = (await VendorBookingsApi.getBookings()).cast<BookingModel>();
    } catch (e) {
      _showSnack('Failed to load bookings. Check your connection.', isError: true);
    }

    if (mounted) setState(() => _isLoading = false);
  }

  // ── Filtering ──────────────────────────────────
  List<BookingModel> get _filteredBookings {
    switch (_selectedTab) {
      case 0:
        return _bookings.where((b) => b.status == BookingStatus.pending).toList();
      case 1:
        return _bookings.where((b) => b.status == BookingStatus.approved).toList();
      case 2:
        return _bookings.where((b) => b.status == BookingStatus.rejected).toList();
      default:
        return _bookings;
    }
  }

  int _countFor(int tabIndex) {
    switch (tabIndex) {
      case 0:
        return _bookings.where((b) => b.status == BookingStatus.pending).length;
      case 1:
        return _bookings.where((b) => b.status == BookingStatus.approved).length;
      case 2:
        return _bookings.where((b) => b.status == BookingStatus.rejected).length;
      default:
        return _bookings.length;
    }
  }

  // ── Approve / Reject ───────────────────────────
  Future<void> _approveBooking(BookingModel booking) async {
    final previous = booking.status;
    setState(() => booking.status = BookingStatus.approved); // optimistic

    try {
      await VendorBookingsApi.approveBooking(booking.id);
      _showSnack('Booking approved.');
    } catch (e) {
      setState(() => booking.status = previous); // rollback
      _showSnack('Failed to approve booking.', isError: true);
    }
  }

  Future<void> _rejectBooking(BookingModel booking) async {
    final confirmed = await _showConfirmDialog(
      title: 'Reject Booking',
      message: 'Are you sure you want to reject this booking from "${booking.customerName}"?',
      confirmLabel: 'Reject',
      isDestructive: true,
    );
    if (!confirmed) return;

    final previous = booking.status;
    setState(() => booking.status = BookingStatus.rejected); // optimistic

    try {
      await VendorBookingsApi.rejectBooking(booking.id);
      _showSnack('Booking rejected.');
    } catch (e) {
      setState(() => booking.status = previous); // rollback
      _showSnack('Failed to reject booking.', isError: true);
    }
  }

  // ── Confirm Dialog ─────────────────────────────
  Future<bool> _showConfirmDialog({
    required String title,
    required String message,
    required String confirmLabel,
    bool isDestructive = false,
  }) async {
    return await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          title,
          style: const TextStyle(color: kNavy, fontWeight: FontWeight.w800, fontSize: 18),
        ),
        content: Text(
          message,
          style: const TextStyle(color: kGray, fontSize: 14, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel', style: TextStyle(color: kGray, fontWeight: FontWeight.w600)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              confirmLabel,
              style: TextStyle(
                color: isDestructive ? Colors.red : kGold,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    ) ??
        false;
  }

  void _showSnack(String message, {bool isError = false}) {
    final overlay = Overlay.of(context);
    final entry = OverlayEntry(
      builder: (_) => Positioned(
        top: MediaQuery.of(context).padding.top + 10,
        right: 16,
        child: _ToastBubble(message: message, isError: isError),
      ),
    );
    overlay.insert(entry);
    Future.delayed(const Duration(seconds: 2), () => entry.remove());
  }

  // ── Build ──────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: const VendorNav(activeTab: 'Bookings'),
      body: Column(
        children: [
          _buildPageHeader(),
          _buildTabs(),
          const SizedBox(height: 12),
          Expanded(child: _buildBody()),
        ],
      ),
    );
  }

  // ── Page Header ────────────────────────────────
  Widget _buildPageHeader() {
    return const Padding(
      padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Bookings',
            style: TextStyle(color: kNavy, fontWeight: FontWeight.w900, fontSize: 22),
          ),
          SizedBox(height: 2),
          Text(
            'Manage booking requests and review their status.',
            style: TextStyle(color: kGray, fontSize: 13),
          ),
        ],
      ),
    );
  }

  // ── Tabs ───────────────────────────────────────
  Widget _buildTabs() {
    final labels = ['Pending', 'Approved', 'Rejected', 'All'];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: List.generate(labels.length, (i) {
          final isSelected = _selectedTab == i;
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: GestureDetector(
              onTap: () => setState(() => _selectedTab = i),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFFFFF8E7) : kWhite,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: isSelected ? kGold : Colors.transparent),
                  boxShadow: isSelected
                      ? []
                      : [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.03),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    '${labels[i]} (${_countFor(i)})',
                    style: TextStyle(
                      color: isSelected ? kGold : kNavy,
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  // ── Body ───────────────────────────────────────
  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: kGold));
    }
    if (_filteredBookings.isEmpty) return _buildEmptyState();

    return RefreshIndicator(
      color: kGold,
      onRefresh: _loadBookings,
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        itemCount: _filteredBookings.length,
        separatorBuilder: (_, __) => const SizedBox(height: 14),
        itemBuilder: (_, i) => _BookingCard(
          booking: _filteredBookings[i],
          onApprove: () => _approveBooking(_filteredBookings[i]),
          onReject: () => _rejectBooking(_filteredBookings[i]),
        ),
      ),
    );
  }

  // ── Empty State ────────────────────────────────
  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 20),
        decoration: BoxDecoration(
          color: kWhite,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Text(
              'No bookings found',
              style: TextStyle(color: kNavy, fontWeight: FontWeight.w800, fontSize: 16),
            ),
            SizedBox(height: 6),
            Text(
              'There are no bookings in this section right now.',
              textAlign: TextAlign.center,
              style: TextStyle(color: kGray, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Booking Card ───────────────────────────────────────────────────────────────
class _BookingCard extends StatelessWidget {
  final BookingModel booking;
  final VoidCallback onApprove;
  final VoidCallback onReject;

  const _BookingCard({
    required this.booking,
    required this.onApprove,
    required this.onReject,
  });

  Color get _statusColor {
    switch (booking.status) {
      case BookingStatus.approved:
        return const Color(0xFF2E7D32);
      case BookingStatus.rejected:
        return Colors.red;
      case BookingStatus.pending:
        return const Color(0xFFB8860B);
    }
  }

  String get _statusLabel {
    switch (booking.status) {
      case BookingStatus.approved:
        return 'approved';
      case BookingStatus.rejected:
        return 'rejected';
      case BookingStatus.pending:
        return 'pending';
    }
  }

  @override
  Widget build(BuildContext context) {
    return FarhaCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                decoration: BoxDecoration(
                  color: _statusColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  _statusLabel,
                  style: const TextStyle(color: kWhite, fontSize: 12, fontWeight: FontWeight.w600),
                ),
              ),
              const Spacer(),
              Text(
                '\$${booking.price.toStringAsFixed(0)}',
                style: const TextStyle(color: kGold, fontWeight: FontWeight.w800, fontSize: 15),
              ),
            ],
          ),
          const SizedBox(height: 12),

          Text(
            booking.customerName,
            style: const TextStyle(color: kNavy, fontWeight: FontWeight.w800, fontSize: 17),
          ),
          const SizedBox(height: 4),
          Text(
            booking.serviceName,
            style: const TextStyle(color: kGray, fontSize: 13.5),
          ),
          const SizedBox(height: 10),

          Row(
            children: [
              const Icon(Icons.calendar_today_outlined, color: kGray, size: 14),
              const SizedBox(width: 5),
              Text(booking.date, style: const TextStyle(color: kGray, fontSize: 13)),
              const SizedBox(width: 14),
              const Icon(Icons.access_time, color: kGray, size: 14),
              const SizedBox(width: 5),
              Text(booking.time, style: const TextStyle(color: kGray, fontSize: 13)),
              if (booking.guests > 0) ...[
                const SizedBox(width: 14),
                const Icon(Icons.people_outline, color: kGray, size: 14),
                const SizedBox(width: 5),
                Text('${booking.guests}', style: const TextStyle(color: kGray, fontSize: 13)),
              ],
            ],
          ),

          if (booking.notes.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              booking.notes,
              style: const TextStyle(color: kGray, fontSize: 12.5, height: 1.4, fontStyle: FontStyle.italic),
            ),
          ],

          if (booking.status == BookingStatus.pending) ...[
            const SizedBox(height: 16),
            const Divider(color: kBorder, height: 1),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: _ActionButton(
                    label: 'Approve',
                    icon: Icons.check_circle_outline,
                    textColor: const Color(0xFF2E7D32),
                    fillColor: const Color(0xFFEAF7EC),
                    borderColor: const Color(0xFFA9DDB4),
                    onTap: onApprove,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _ActionButton(
                    label: 'Reject',
                    icon: Icons.cancel_outlined,
                    textColor: Colors.red,
                    fillColor: const Color(0xFFFFF0F0),
                    borderColor: const Color(0xFFFFCDD2),
                    onTap: onReject,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

// ── Action Button ─────────────────────────────────────────────────────────────
class _ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color textColor;
  final Color? fillColor;
  final Color borderColor;
  final VoidCallback onTap;

  const _ActionButton({
    required this.label,
    required this.icon,
    required this.textColor,
    this.fillColor,
    required this.borderColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: fillColor ?? kWhite,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: borderColor),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: textColor, size: 16),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(color: textColor, fontWeight: FontWeight.w700, fontSize: 13.5),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Toast Bubble (top success/error notification) ─────────────────────────────
class _ToastBubble extends StatelessWidget {
  final String message;
  final bool isError;

  const _ToastBubble({required this.message, required this.isError});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: kWhite,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.12),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isError ? Icons.cancel : Icons.check_circle,
              color: isError ? Colors.red : const Color(0xFF2E7D32),
              size: 18,
            ),
            const SizedBox(width: 8),
            Text(
              message,
              style: const TextStyle(
                color: kNavy,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}