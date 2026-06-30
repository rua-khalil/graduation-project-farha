import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'BrowseServicesPage.dart';
import 'SearchVenues.dart';
import 'LoginPage.dart';
import 'ContactPage.dart';
import 'Createaccountpage.dart';
import 'GuestHomePage.dart';
import 'about.dart';
// ── Colours ────────────────────────────────────────────
const kNavy = Color(0xFF1A2744);
const kGold = Color(0xFFD5A217);
const kGoldBg = Color(0xFFFFF4DE);
const kWhite = Color(0xFFFFFFFF);
const kBg = Color(0xFFF2F2F0);
const kGray = Color(0xFF6B7280);
const kBorder = Color(0xFFE5E5E0);

// ── Theme ──────────────────────────────────────────────
ThemeData farhaTheme() {
  return ThemeData(
    useMaterial3: false,
    fontFamily: 'Roboto',
    scaffoldBackgroundColor: kBg,
    colorScheme: ColorScheme.fromSeed(
      seedColor: Color(0xFFD5A217),
      brightness: Brightness.light,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: kNavy,
      elevation: 0,
      foregroundColor: kWhite,
    ),
  );
}

// ── App Bar ────────────────────────────────────────────
class FarhaAppBar extends StatelessWidget implements PreferredSizeWidget {
  const FarhaAppBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(50);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: kNavy,
      elevation: 0,
      toolbarHeight: 50,
      titleSpacing: 0,
      automaticallyImplyLeading: false,

      title: Padding(
        padding: const EdgeInsets.only(left: 12, bottom: 8),
        child: GestureDetector(
          onTap: () => Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const HomePage()),
          ),
          child: Image.asset(
            'images/logo.png',
            height: 50,
            fit: BoxFit.contain,
          ),
        ),
      ),

      actions: [
        Padding(
          padding: const EdgeInsets.only(
            right: 20,
            top: 5,
            bottom: 8,
          ),
          child: Builder(
            builder: (context) => InkWell(
              onTap: () => Scaffold.of(context).openEndDrawer(),
              borderRadius: BorderRadius.circular(10),
              child: Container(
                width: 30,
                height: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.menu_rounded,
                  color: kNavy,
                  size: 18,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
// ── Hero Section ───────────────────────────────────────
class FarhaHeroSection extends StatelessWidget {
  const FarhaHeroSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 28, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Badge
          const FarhaBadge('About Farha'),
          const SizedBox(height: 20),

          // Main title
          const Text(
            'We make event planning feel premium, simple, and beautifully organized.',
            style: TextStyle(
              color: kNavy,
              fontWeight: FontWeight.w900,
              fontSize: 28,
              height: 1.25,
            ),
          ),

          const SizedBox(height: 16),

          // Subtitle
          const Text(
            'Farha is built to help people discover venues and event services through a cleaner experience inspired by modern dashboards and premium product design.',
            style: TextStyle(
              color: kGray,
              fontSize: 15,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Shared Widgets ─────────────────────────────────────

// Badge widget
class FarhaBadge extends StatelessWidget {
  final String label;

  const FarhaBadge(this.label, {super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: kGoldBg,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: kGold.withOpacity(0.35)),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: kGold,
          fontWeight: FontWeight.w600,
          fontSize: 13,
        ),
      ),
    );
  }
}

// White card container
class FarhaCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;

  const FarhaCard({
    super.key,
    required this.child,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding ?? const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: kWhite,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: child,
    );
  }
}

// Section title + subtitle
class FarhaSectionHeader extends StatelessWidget {
  final String title;
  final String? subtitle;

  const FarhaSectionHeader({
    super.key,
    required this.title,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: kNavy,
              fontWeight: FontWeight.w900,
              fontSize: 26,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 8),
            Text(
              subtitle!,
              style: const TextStyle(
                color: kGray,
                fontSize: 14,
                height: 1.5,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// Outlined item widget
class FarhaOutlinedItem extends StatelessWidget {
  final String text;

  const FarhaOutlinedItem(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: () {},
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: kBg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: kBorder),
        ),
        child: Text(
          text,
          style: const TextStyle(
            color: kNavy,
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}

// Value card widget
class FarhaValueCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const FarhaValueCard({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return FarhaCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: kGoldBg,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: kGold, size: 26),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(
              color: kNavy,
              fontWeight: FontWeight.w800,
              fontSize: 17,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: const TextStyle(
              color: kGray,
              fontSize: 14,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Farha Drawer ─────────────────────────────────────
class FarhaDrawer extends StatelessWidget {
  final String activePage;

  const FarhaDrawer({super.key, this.activePage = 'Home'});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.zero,
      ),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // ── Header ───────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [

                  // ── Logo ──────────────────────
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => const HomePage()),
                      );
                    },
                    child: Image.asset(
                      'images/logo.png',
                      height: 50,
                    ),
                  ),

                  // ── Close Button ──────────────
                  InkWell(
                    onTap: () => Navigator.pop(context),
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5F5F5),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.close, color: kNavy, size: 20),
                    ),
                  ),
                ],
              ),
            ),

            // ── Nav Items ────────────────────────
            _drawerItem(context, 'Home',
                isActive: activePage == 'Home',
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const HomePage()),
                  );
                }),

            _drawerItem(context, 'Browse Services',
                isActive: activePage == 'Browse Services',
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const BrowsePage()),
                  );
                }),

            _drawerItem(context, 'About',
                isActive: activePage == 'About',
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const AboutPage()),
                  );
                }),

            _drawerItem(context, 'Contact',
                isActive: activePage == 'Contact',
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const ContactPage()),
                  );
                }),

            const Spacer(),

            // ── Bottom Buttons ───────────────────
// ── Bottom Buttons ───────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
              child: FutureBuilder<bool>(
                future: _checkIsLoggedIn(),
                builder: (context, snapshot) {
                  final isLoggedIn = snapshot.data ?? false;

                  return SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        Navigator.pop(context);
                        if (isLoggedIn) {
                          await _logout(context);
                        } else {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const logInPage()),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        elevation: 0,
                        backgroundColor: isLoggedIn ? Colors.redAccent : const Color(0xFFD5A217),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      icon: Icon(
                        isLoggedIn ? Icons.logout : Icons.person_outline,
                        size: 18,
                      ),
                      label: Text(
                        isLoggedIn ? 'Logout' : 'logIn',
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _drawerItem(BuildContext context, String title,
      {bool isActive = false, VoidCallback? onTap}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: isActive ? const Color(0xFFFDF3D6) : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        onTap: onTap ?? () => Navigator.pop(context),
        title: Text(
          title,
          style: TextStyle(
            color: kNavy,
            fontSize: 15,
            fontWeight: isActive ? FontWeight.w800 : FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
Future<bool> _checkIsLoggedIn() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getBool('isLoggedIn') ?? false;
}

Future<void> _logout(BuildContext context) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setBool('isLoggedIn', false);
  await prefs.remove('userRole');
  await prefs.remove('firstName');
  await prefs.remove('lastName');
  await prefs.remove('userId');
  await prefs.remove('userEmail');
  await prefs.remove('auth_token');

  if (!context.mounted) return;
  Navigator.pushAndRemoveUntil(
    context,
    MaterialPageRoute(builder: (_) => const HomePage()),
        (route) => false,
  );
}
// ── Footer ─────────────────────────────────────────────
class FarhaFooter extends StatelessWidget {
  const FarhaFooter({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: kNavy,
      padding: const EdgeInsets.fromLTRB(20, 32, 20, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
        // Footer
          Text(
            'FARHA',
            style: TextStyle(
              color: kWhite,
              fontWeight: FontWeight.w700,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 12),
          // Footer description
          const Text(
            'Discover elegant venues and trusted wedding services through a cleaner, more premium booking experience.',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 28),

          // ── Explore Links ───────────────────────
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Explore',
                style: TextStyle(
                  color: kWhite,
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 12),

              InkWell(
                onTap: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => const HomePage()));
                },
                child: const Padding(
                  padding: EdgeInsets.only(bottom: 10),
                  child: Text('Home',
                      style: TextStyle(color: Colors.white70, fontSize: 14)),
                ),
              ),

              InkWell(
                onTap: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => const BrowsePage()));
                },
                child: const Padding(
                  padding: EdgeInsets.only(bottom: 10),
                  child: Text('Browse Services',
                      style: TextStyle(color: Colors.white70, fontSize: 14)),
                ),
              ),

              InkWell(
                onTap: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => const SearchPage()));
                },
                child: const Padding(
                  padding: EdgeInsets.only(bottom: 10),
                  child: Text('Search Venues',
                      style: TextStyle(color: Colors.white70, fontSize: 14)),
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // ── Company Links ───────────────────────
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Company',
                style: TextStyle(
                  color: kWhite,
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 12),

              InkWell(
                onTap: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => const AboutPage()));
                },
                child: const Padding(
                  padding: EdgeInsets.only(bottom: 10),
                  child: Text('About Us',
                      style: TextStyle(color: Colors.white70, fontSize: 14)),
                ),
              ),

              InkWell(
                onTap: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => const ContactPage()));
                },
                child: const Padding(
                  padding: EdgeInsets.only(bottom: 10),
                  child: Text('Contact',
                      style: TextStyle(color: Colors.white70, fontSize: 14)),
                ),
              ),

              InkWell(
                onTap: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => const logInPage()));
                },
                child: const Padding(
                  padding: EdgeInsets.only(bottom: 10),
                  child: Text('logIn',
                      style: TextStyle(color: Colors.white70, fontSize: 14)),
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // ── For Users ───────────────────────────
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'For Users',
                style: TextStyle(
                  color: kWhite,
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 12),

              InkWell(
                onTap: () {
                  Navigator.push(context,
                      MaterialPageRoute(
                          builder: (context) => const CreateAccountPage()));
                },
                child: const Padding(
                  padding: EdgeInsets.only(bottom: 10),
                  child: Text('Create Account',
                      style: TextStyle(color: Colors.white70, fontSize: 14)),
                ),
              ),
            ],
          ),

          const Text(
            '© 2026 Farha. All rights reserved.',
            style: TextStyle(color: Colors.white54, fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _footerSection(String title, List<String> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: kWhite,
            fontWeight: FontWeight.w700,
            fontSize: 15,
          ),
        ),
        const SizedBox(height: 12),
        ...items.map(
              (item) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: InkWell(
              onTap: () {},
              child: Text(item,
                  style: const TextStyle(color: Colors.white70, fontSize: 14)),
            ),
          ),
        ),
      ],
    );
  }
}