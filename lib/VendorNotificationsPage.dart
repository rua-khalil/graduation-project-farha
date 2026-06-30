import 'package:flutter/material.dart';
import 'farha_shared.dart';
import 'VendorNav.dart';

// ── Notification Type ─────────────────────────────────────────────────────────
enum VendorNotificationType { booking, message, review, offer, other }

VendorNotificationType _typeFromString(String? value) {
  switch (value) {
    case 'booking':
      return VendorNotificationType.booking;
    case 'message':
      return VendorNotificationType.message;
    case 'review':
      return VendorNotificationType.review;
    case 'offer':
      return VendorNotificationType.offer;
    default:
      return VendorNotificationType.other;
  }
}

// ── Notification Model ────────────────────────────────────────────────────────
class VendorNotificationModel {
  final String id;
  final String title;
  final String body;
  final String time;
  final bool isNew;
  final VendorNotificationType type;
  bool isRead;

  VendorNotificationModel({
    required this.id,
    required this.title,
    required this.body,
    required this.time,
    required this.isNew,
    required this.type,
    required this.isRead,
  });

  factory VendorNotificationModel.fromJson(Map<String, dynamic> json) {
    return VendorNotificationModel(
      id: json['id']?.toString() ?? '',
      title: json['title'] ?? '',
      body: json['body'] ?? json['message'] ?? '',
      time: json['time'] ?? json['created_at'] ?? '',
      isNew: json['is_new'] ?? json['isNew'] ?? false,
      isRead: json['is_read'] ?? json['isRead'] ?? false,
      type: _typeFromString(json['type']),
    );
  }
}

// ── Notifications Page (Vendor) ────────────────────────────────────────────────
class VendorNotificationsPage extends StatefulWidget {
  const VendorNotificationsPage({super.key});

  @override
  State<VendorNotificationsPage> createState() =>
      _VendorNotificationsPageState();
}

class _VendorNotificationsPageState extends State<VendorNotificationsPage> {
  bool _loading = true;
  String? _error;
  List<VendorNotificationModel> _notifications = [];

  @override
  void initState() {
    super.initState();
    _fetchNotifications();
  }

  Future<void> _fetchNotifications() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      // TODO: Replace with your real API endpoint
      // final response = await http.get(Uri.parse('https://your-api.com/vendor/notifications'));
      // final data = jsonDecode(response.body) as List;
      // _notifications = data.map((e) => VendorNotificationModel.fromJson(e)).toList();

      await Future.delayed(const Duration(milliseconds: 800));
      _notifications = [];
    } catch (e) {
      _error = 'Failed to load notifications. Please try again.';
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _markAsRead(String id) {
    // TODO: Call API to mark as read
    // await http.patch(Uri.parse('https://your-api.com/vendor/notifications/$id/read'));
    setState(() {
      final n = _notifications.firstWhere((n) => n.id == id);
      n.isRead = true;
    });
  }

  int get _unreadCount => _notifications.where((n) => !n.isRead).length;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      appBar: const VendorNav(activeTab: 'Notifications'),
      body: RefreshIndicator(
        color: kGold,
        onRefresh: _fetchNotifications,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 28, 20, 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // ── Title ─────────────────────────────
              const Text(
                'Notifications',
                style: TextStyle(
                  color: kNavy,
                  fontWeight: FontWeight.w900,
                  fontSize: 28,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Review alerts, updates, and recent activity from your dashboard..',
                style: TextStyle(color: kGray, fontSize: 14, height: 1.5),
              ),

              const SizedBox(height: 24),

              // ── Recent Activity Card ───────────────
              FarhaCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    const Text(
                      'Recent Activity',
                      style: TextStyle(
                        color: kNavy,
                        fontWeight: FontWeight.w800,
                        fontSize: 17,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Updates about new bookings, client messages, reviews, and offer activity.',
                      style: TextStyle(color: kGray, fontSize: 13, height: 1.5),
                    ),

                    const SizedBox(height: 16),

                    // Unread count badge
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: kWhite,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: kBorder),
                      ),
                      child: Text(
                        '$_unreadCount unread',
                        style: const TextStyle(
                          color: kGray,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // ── Content ───────────────────────
                    if (_loading)
                      _buildLoading()
                    else if (_error != null)
                      _buildError()
                    else if (_notifications.isEmpty)
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

  // ── Loading ───────────────────────────────────────
  Widget _buildLoading() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 24),
      child: Center(
        child: CircularProgressIndicator(color: kGold, strokeWidth: 2.5),
      ),
    );
  }

  // ── Error ─────────────────────────────────────────
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
            onPressed: _fetchNotifications,
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

  // ── Empty ─────────────────────────────────────────
  Widget _buildEmpty() {
    return const Padding(
      padding: EdgeInsets.only(top: 4),
      child: Center(
        child: Text(
          'No notifications found.',
          style: TextStyle(color: kGray, fontSize: 14),
        ),
      ),
    );
  }

  // ── List ──────────────────────────────────────────
  Widget _buildList() {
    return Column(
      children: _notifications.map((n) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _VendorNotificationCard(
            notification: n,
            onMarkRead: () => _markAsRead(n.id),
          ),
        );
      }).toList(),
    );
  }
}

// ── Type → Icon/Color helpers ───────────────────────────────────────────────
IconData _iconForType(VendorNotificationType type) {
  switch (type) {
    case VendorNotificationType.booking:
      return Icons.event_available_outlined;
    case VendorNotificationType.message:
      return Icons.chat_bubble_outline;
    case VendorNotificationType.review:
      return Icons.star_outline_rounded;
    case VendorNotificationType.offer:
      return Icons.local_offer_outlined;
    case VendorNotificationType.other:
      return Icons.notifications_outlined;
  }
}

Color _colorForType(VendorNotificationType type) {
  switch (type) {
    case VendorNotificationType.booking:
      return const Color(0xFF16A34A); // green
    case VendorNotificationType.message:
      return const Color(0xFF3B82F6); // blue
    case VendorNotificationType.review:
      return const Color(0xFFF59E0B); // amber
    case VendorNotificationType.offer:
      return kGold;
    case VendorNotificationType.other:
      return kGold;
  }
}

Color _bgForType(VendorNotificationType type) {
  switch (type) {
    case VendorNotificationType.booking:
      return const Color(0xFFDCFCE7);
    case VendorNotificationType.message:
      return const Color(0xFFDBEAFE);
    case VendorNotificationType.review:
      return const Color(0xFFFEF3C7);
    case VendorNotificationType.offer:
      return kGoldBg;
    case VendorNotificationType.other:
      return kGoldBg;
  }
}

// ── Notification Card ─────────────────────────────────────────────────────────
class _VendorNotificationCard extends StatelessWidget {
  final VendorNotificationModel notification;
  final VoidCallback onMarkRead;

  const _VendorNotificationCard({
    required this.notification,
    required this.onMarkRead,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: kWhite,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: !notification.isRead ? const Color(0xFF3B82F6) : kBorder,
          width: !notification.isRead ? 1.5 : 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // Icon
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: _bgForType(notification.type),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                _iconForType(notification.type),
                color: _colorForType(notification.type),
                size: 20,
              ),
            ),

            const SizedBox(height: 10),

            // Title + New badge
            Row(
              children: [
                Expanded(
                  child: Text(
                    notification.title,
                    style: const TextStyle(
                      color: kNavy,
                      fontWeight: FontWeight.w800,
                      fontSize: 14,
                    ),
                  ),
                ),
                if (notification.isNew) ...[
                  const SizedBox(width: 8),
                  // Green check
                  const Icon(Icons.check_circle, color: Color(0xFF16A34A), size: 16),
                  const SizedBox(width: 6),
                  // New badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEF4444),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text(
                      'New',
                      style: TextStyle(
                        color: kWhite,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ],
            ),

            const SizedBox(height: 6),

            // Time
            Row(
              children: [
                const Icon(Icons.access_time_outlined, color: kGray, size: 13),
                const SizedBox(width: 4),
                Text(
                  notification.time,
                  style: const TextStyle(color: kGray, fontSize: 12),
                ),
              ],
            ),

            const SizedBox(height: 8),

            // Body
            Text(
              notification.body,
              style: const TextStyle(
                color: kGray,
                fontSize: 13,
                height: 1.5,
              ),
            ),

            const SizedBox(height: 12),

            // Mark as read
            if (!notification.isRead)
              GestureDetector(
                onTap: onMarkRead,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(Icons.check_box_outline_blank,
                        color: kGold, size: 15),
                    SizedBox(width: 6),
                    Text(
                      'Mark as read',
                      style: TextStyle(
                        color: kGold,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}