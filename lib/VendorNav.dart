import 'package:farha/VendorDashboardPage.dart';
import 'package:farha/VendorMessagesPage.dart';
import 'package:farha/LoginPage.dart';
import 'package:farha/Vendormyservicespage.dart';
import 'package:flutter/material.dart';
import 'package:farha/UserHomePage.dart';
import 'Vendormyservicespage.dart';
import 'VendorBookingsPage.dart';
import 'VendorPaymentsPage.dart';
import 'VendorNotificationsPage.dart';
import 'LoginPage.dart';

class VendorNav extends StatefulWidget implements PreferredSizeWidget {
  final String activeTab;

  const VendorNav({super.key, this.activeTab = 'Dashboard'});

  @override
  Size get preferredSize => Size.fromHeight(
    kToolbarHeight +
        90 +
        MediaQueryData.fromView(
          WidgetsBinding.instance.platformDispatcher.views.first,
        ).padding.top,
  );

  @override
  State<VendorNav> createState() => _VendorNavState();
}

class _VendorNavState extends State<VendorNav> {
  String _initials = 'MN';

  @override
  void initState() {
    super.initState();
    _fetchVendorInitials();
  }

  Future<void> _fetchVendorInitials() async {
    try {
      // TODO: Replace with your real API endpoint
      // final response = await http.get(Uri.parse('https://your-api.com/vendor/profile'));
      // final data = jsonDecode(response.body);
      // final first = data['first_name'] ?? '';
      // final last = data['last_name'] ?? '';

      final first = 'Mohammad'; // مؤقت لين تربط الـ API
      final last = 'Nasir';

      String result = 'MN';
      if (first.isNotEmpty && last.isNotEmpty) {
        result = '${first[0]}${last[0]}'.toUpperCase();
      } else if (first.isNotEmpty) {
        result = first[0].toUpperCase();
      }

      if (mounted) setState(() => _initials = result);
    } catch (e) {
      // يبقى MN كقيمة افتراضية
    }
  }

  // ── Avatar dropdown menu ──────────────────
  void _showAvatarMenu(BuildContext context) {
    final RenderBox button = context.findRenderObject() as RenderBox;
    final RenderBox overlay =
    Overlay.of(context).context.findRenderObject() as RenderBox;
    final RelativeRect position = RelativeRect.fromRect(
      Rect.fromPoints(
        button.localToGlobal(Offset(0, button.size.height + 8), ancestor: overlay),
        button.localToGlobal(button.size.bottomRight(Offset.zero), ancestor: overlay),
      ),
      Offset.zero & overlay.size,
    );

    showMenu<String>(
      context: context,
      position: position,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: Colors.white,
      elevation: 8,
      items: [
        _buildMenuItem('dashboard', Icons.grid_view_rounded, 'Dashboard'),
        _buildMenuItem('services', Icons.design_services_outlined, 'My Services'),
        _buildMenuItem('bookings', Icons.calendar_month_outlined, 'Bookings'),
        const PopupMenuDivider(height: 1),
        _buildMenuItem('logout', Icons.logout, 'Logout', isDestructive: true),
      ],
    ).then((value) {
      if (value == null || !mounted) return;
      switch (value) {
        case 'dashboard':
          Navigator.push(context, MaterialPageRoute(builder: (_) => const VendorDashboardPage()));
          break;
        case 'services':
          Navigator.push(context, MaterialPageRoute(builder: (_) => const VendorMyServicesPage()));
          break;
        case 'bookings':
          Navigator.push(context, MaterialPageRoute(builder: (_) => const VendorBookingsPage()));
          break;
        case 'logout':
          _handleLogout(context);
          break;
      }
    });
  }

  PopupMenuItem<String> _buildMenuItem(
      String value,
      IconData icon,
      String label, {
        bool isDestructive = false,
      }) {
    final color = isDestructive ? Colors.red : const Color(0xFF2D2F3A);
    return PopupMenuItem<String>(
      value: value,
      height: 42,
      child: Row(
        children: [
          Icon(icon, size: 18, color: isDestructive ? Colors.red : const Color(0xFF8A8FA8)),
          const SizedBox(width: 10),
          Text(
            label,
            style: TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w500,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  void _handleLogout(BuildContext context) {
    // TODO: امسحي هون أي بيانات تسجيل دخول محفوظة (token, shared prefs..)
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const logInPage()),
          (route) => false, // يمسح كل الصفحات اللي قبل الـ Login
    );
  }

  @override
  Widget build(BuildContext context) {
    final double statusBarH = MediaQuery.of(context).padding.top;
    final activeTab = widget.activeTab;

    return Container(
      color: Colors.white,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Status bar space ──────────────────
          SizedBox(height: statusBarH),

          // ── Top Bar ───────────────────────────
          SizedBox(
            height: 60,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Logo
                  Image.asset('images/logo.png', height: 36, fit: BoxFit.contain),

                  // Settings + Avatar
                  Row(
                    children: [
                      Stack(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.notifications_outlined, color: Color(0xFF8A8FA8), size: 22),
                            onPressed: () {
                              Navigator.push(context, MaterialPageRoute(builder: (_) => const VendorNotificationsPage()));
                            },
                            splashRadius: 20,
                          ),
                          Positioned(
                            right: 8,
                            top: 8,
                            child: Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 4),
                      Builder(
                        builder: (avatarContext) {
                          return GestureDetector(
                            onTap: () => _showAvatarMenu(avatarContext),
                            child: Container(
                              width: 36,
                              height: 36,
                              decoration: const BoxDecoration(
                                color: Color(0xFFD5A217),
                                shape: BoxShape.circle,
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                _initials,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(width: 16),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // ── Divider ───────────────────────────
          const Divider(height: 1, thickness: 1, color: Color(0xFFEEEFF4)),

          // ── Back to Website + Tabs ────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Back to Website
                GestureDetector(
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const UserHomePage())),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                    decoration: BoxDecoration(
                      border: Border.all(color: const Color(0xFFE5E7EF)),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(Icons.home_outlined, size: 15, color: Color(0xFFD5A217)),
                        SizedBox(width: 6),
                        Text(
                          'Back to Website',
                          style: TextStyle(
                            color: Color(0xFFD5A217),
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                // Nav Tabs
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _NavTab(label: 'Dashboard', icon: Icons.grid_view_rounded, isActive: activeTab == 'Dashboard', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const VendorDashboardPage()))),
                      _NavTab(label: 'My Services', icon: Icons.design_services_outlined, isActive: activeTab == 'My Services', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const VendorMyServicesPage()))),
                      _NavTab(label: 'Bookings', icon: Icons.calendar_month_outlined, isActive: activeTab == 'Bookings', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const VendorBookingsPage()))),
                      _NavTab(label: 'Payments', icon: Icons.account_balance_wallet_outlined, isActive: activeTab == 'Payments', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const VendorPaymentsPage()))),
                      _NavTab(label: 'Messages', icon: Icons.chat_bubble_outline, isActive: activeTab == 'Messages', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const VendorMessagesPage()))),
                      _NavTab(label: 'Notifications', icon: Icons.notifications_outlined, isActive: activeTab == 'Notifications', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const VendorNotificationsPage()))),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Nav Tab ───────────────────────────────────────────
class _NavTab extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isActive;
  final VoidCallback onTap;

  const _NavTab({required this.label, required this.icon, this.isActive = false, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFFFFF4DE) : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: isActive ? null : Border.all(color: const Color(0xFFE5E7EF)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 15, color: isActive ? const Color(0xFFD5A217) : const Color(0xFF8A8FA8)),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: isActive ? const Color(0xFFD5A217) : const Color(0xFF8A8FA8),
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}