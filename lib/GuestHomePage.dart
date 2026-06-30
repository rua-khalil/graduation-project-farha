import 'package:flutter/material.dart';
import 'farha_shared.dart';
import 'BrowseServicesPage.dart';
import 'Createaccountpage.dart';
import 'VenueDetailPage.dart';
import 'models.dart';
import 'venue_service.dart';
import 'api_service.dart';
import 'models.dart';


// ── Home Page ─────────────────────────────────────────
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      appBar: const FarhaAppBar(),
      endDrawer: const FarhaDrawer(),

      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 900),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  // ── Hero Section ─────────────────
                  HomeHeroSection(),

                  // ── Stats Section (مربوطة بالـ API) ──
                  const HomeStatsSection(),

                  // ── Category Section ─────────────
                  const HomeCategorySection(),

                  // ── Featured Section (مربوطة بالـ API) ──
                  const HomeFeaturedSection(),

                  // ── How It Works Section ─────────
                  const HomeHowItWorksSection(),

                  // ── Testimonials Section ─────────
                  const HomeTestimonialsSection(),

                  // ── CTA Section ──────────────────
                  const HomeCTASection(),

                  // ── Footer ───────────────────────
                  const FarhaFooter(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Hero Section ─────────────────────────────────────
class HomeHeroSection extends StatelessWidget {
  const HomeHeroSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: NetworkImage(
            'https://images.unsplash.com/photo-1519225421980-715cb0215aed?auto=format&fit=crop&w=1600&q=80',
          ),
          fit: BoxFit.cover,
        ),
      ),

      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 28, 20, 24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.black.withOpacity(.45),
              Colors.black.withOpacity(.25),
              Colors.black.withOpacity(.60),
            ],
          ),
        ),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Badge ─────────────────────────────
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(.18),
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: Colors.white24),
              ),
              child: const Text(
                'Premium wedding planning experience',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),

            const SizedBox(height: 24),

            const Text(
              'Find your dream venue with a cleaner, smarter experience.',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                fontSize: 34,
                height: 1.08,
              ),
            ),

            const SizedBox(height: 16),

            const Text(
              'Browse elegant venues, trusted vendors, and beautifully organized event options — all in one premium platform inspired by your new dashboard design system.',
              style: TextStyle(
                color: Color(0xffEEF2F7),
                fontSize: 14,
                height: 1.7,
                fontWeight: FontWeight.w500,
              ),
            ),

            const SizedBox(height: 22),

            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const BrowsePage()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    elevation: 0,
                    backgroundColor: const Color(0xFFD5A217),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Explore Venues', style: TextStyle(fontWeight: FontWeight.w700)),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const CreateAccountPage()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    elevation: 0,
                    backgroundColor: Colors.white,
                    foregroundColor: kNavy,
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Create Account', style: TextStyle(fontWeight: FontWeight.w700)),
                ),
              ],
            ),

            const SizedBox(height: 28),

            // ── Quick Search Card (مربوطة بالـ API) ──
            const HeroQuickSearch(),
          ],
        ),
      ),
    );
  }
}

// ── Quick Search Card ────────────────────────────────
class HeroQuickSearch extends StatefulWidget {
  const HeroQuickSearch({super.key});

  @override
  State<HeroQuickSearch> createState() => _HeroQuickSearchState();
}

class _HeroQuickSearchState extends State<HeroQuickSearch> {
  final TextEditingController _locationController = TextEditingController();
  final GlobalKey _guestKey = GlobalKey();

  DateTime? _selectedDate;
  String? _selectedGuests;
  bool _isSearching = false;

  final List<String> _guestOptions = [
    '50 - 100',
    '100 - 200',
    '200 - 300',
    '300 - 500',
    '500+',
  ];

  @override
  void dispose() {
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2050),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFFD5A217),
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: kNavy,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(foregroundColor: const Color(0xFFD5A217)),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  // ── ينفذ البحث عن طريق الـ API وينتقل لصفحة النتائج ──
  Future<void> _onSearchPressed() async {
    setState(() => _isSearching = true);

    try {
      final results = await VenueService.searchVenues(
        location: _locationController.text.trim(),
        date: _selectedDate,
        guests: _selectedGuests,
      );

      if (!mounted) return;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => BrowsePage(searchResults: results),
        ),
      );
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message)),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تعذّر إتمام البحث، حاول مرة أخرى')),
      );
    } finally {
      if (mounted) setState(() => _isSearching = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return FarhaCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Quick Search',
            style: TextStyle(color: kNavy, fontSize: 20, fontWeight: FontWeight.w800),
          ),

          const SizedBox(height: 16),

          // ── Location ─────────────────────────────
          const Text(
            'Location',
            style: TextStyle(color: kNavy, fontSize: 12, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 6),
          Container(
            height: 42,
            decoration: BoxDecoration(
              color: kBg,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: kBorder),
            ),
            child: TextField(
              controller: _locationController,
              enabled: true,
              keyboardType: TextInputType.text,
              textInputAction: TextInputAction.done,
              style: const TextStyle(color: kNavy, fontSize: 12, fontWeight: FontWeight.w600),
              decoration: const InputDecoration(
                hintText: 'City or region',
                hintStyle: TextStyle(color: kGray, fontSize: 12, fontWeight: FontWeight.w600),
                contentPadding: EdgeInsets.symmetric(horizontal: 12),
                border: InputBorder.none,
              ),
            ),
          ),

          const SizedBox(height: 12),

          // ── Date & Guests Row ─────────────────────
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Date',
                      style: TextStyle(color: kNavy, fontSize: 12, fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 6),
                    GestureDetector(
                      onTap: _pickDate,
                      child: Container(
                        height: 42,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: kBg,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: kBorder),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                _selectedDate == null
                                    ? 'mm/dd/yyyy'
                                    : '${_selectedDate!.month.toString().padLeft(2, '0')}/'
                                    '${_selectedDate!.day.toString().padLeft(2, '0')}/'
                                    '${_selectedDate!.year}',
                                style: TextStyle(
                                  color: _selectedDate == null ? kGray : kNavy,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            const Icon(Icons.calendar_today_outlined, color: kGray, size: 16),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              // ── Guests Dropdown ──────────────────
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Guests',
                      style: TextStyle(color: kNavy, fontSize: 12, fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 6),
                    GestureDetector(
                      onTap: () async {
                        final RenderBox box =
                        _guestKey.currentContext!.findRenderObject() as RenderBox;
                        final Offset offset = box.localToGlobal(Offset.zero);
                        final selected = await showMenu<String>(
                          context: context,
                          color: kWhite,
                          constraints: BoxConstraints(
                            minWidth: box.size.width,
                            maxWidth: box.size.width,
                          ),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          position: RelativeRect.fromLTRB(
                            offset.dx,
                            offset.dy + box.size.height,
                            MediaQuery.of(context).size.width - offset.dx - box.size.width,
                            0,
                          ),
                          items: _guestOptions.map((option) {
                            return PopupMenuItem<String>(
                              value: option,
                              child: SizedBox(
                                width: box.size.width,
                                child: Text(
                                  option,
                                  style: const TextStyle(
                                    color: kNavy,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        );
                        if (selected != null) {
                          setState(() => _selectedGuests = selected);
                        }
                      },
                      child: Container(
                        key: _guestKey,
                        height: 42,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: kBg,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: kBorder),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                _selectedGuests ?? 'Select',
                                style: const TextStyle(color: kNavy, fontSize: 12, fontWeight: FontWeight.w600),
                              ),
                            ),
                            const Icon(Icons.keyboard_arrow_down_rounded, color: kNavy, size: 18),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          SizedBox(
            width: double.infinity,
            height: 44,
            child: ElevatedButton(
              onPressed: _isSearching ? null : _onSearchPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD5A217),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: _isSearching
                  ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
              )
                  : const Text('Search Venues', style: TextStyle(fontWeight: FontWeight.w700)),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Stats Section (مربوطة بالـ API) ──────────────────
class HomeStatsSection extends StatefulWidget {
  const HomeStatsSection({super.key});

  @override
  State<HomeStatsSection> createState() => _HomeStatsSectionState();
}

class _HomeStatsSectionState extends State<HomeStatsSection> {
  late Future<HomeStats> _statsFuture;

  @override
  void initState() {
    super.initState();
    _statsFuture = VenueService.getStats();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
      child: FutureBuilder<HomeStats>(
        future: _statsFuture,
        builder: (context, snapshot) {
          // أثناء التحميل أو عند الخطأ منعرض قيم افتراضية بدل ما نكسر الشكل
          final stats = snapshot.data ?? HomeStats.fallback();

          return Column(
            children: [
              Row(
                children: [
                  Expanded(child: StatCard(number: stats.venuesCount, label: 'Curated venues')),
                  const SizedBox(width: 12),
                  Expanded(child: StatCard(number: stats.eventsCount, label: 'Successful events')),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(child: StatCard(number: stats.satisfaction, label: 'Satisfaction')),
                  const SizedBox(width: 12),
                  Expanded(child: StatCard(number: stats.supportAvailability, label: 'Booking support')),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}

// ── Stat Card ────────────────────────────────────────
class StatCard extends StatelessWidget {
  final String number;
  final String label;

  const StatCard({super.key, required this.number, required this.label});

  @override
  Widget build(BuildContext context) {
    return FarhaCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(number, style: const TextStyle(color: kNavy, fontSize: 26, fontWeight: FontWeight.w900)),
          const SizedBox(height: 6),
          Text(label, style: const TextStyle(color: kGray, fontSize: 13, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

// ── Category Section ─────────────────────────────────
class HomeCategorySection extends StatelessWidget {
  const HomeCategorySection({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          FarhaSectionHeader(
            title: 'Browse by category',
            subtitle: 'Start with the most requested wedding services and venue types.',
          ),
          SizedBox(height: 20),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                HomeCategoryItem(icon: Icons.business_outlined, title: 'Wedding Hall Reservations', count: 'Explore options'),
                SizedBox(height: 12),
                HomeCategoryItem(icon: Icons.restaurant_outlined, title: 'Catering and Food Services', count: 'Explore options'),
                SizedBox(height: 12),
                HomeCategoryItem(icon: Icons.camera_alt_outlined, title: 'Photography and Videography', count: 'Explore options'),
                SizedBox(height: 12),
                HomeCategoryItem(icon: Icons.local_florist_outlined, title: 'Floral Arrangements and Decorations', count: 'Explore options'),
                SizedBox(height: 12),
                HomeCategoryItem(icon: Icons.checkroom_outlined, title: 'Wedding Dresses and Fashion Services', count: 'Explore options'),
                SizedBox(height: 12),
                HomeCategoryItem(icon: Icons.directions_car_outlined, title: 'Wedding Cars', count: 'Explore options'),
                SizedBox(height: 12),
                HomeCategoryItem(icon: Icons.music_note_outlined, title: 'Music and DJ Services', count: 'Explore options'),
                SizedBox(height: 12),
                HomeCategoryItem(icon: Icons.auto_awesome_outlined, title: 'Bridal Stage Setups', count: 'Explore options'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Category Item ────────────────────────────────────
class HomeCategoryItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String count;
  final String? subtitle;

  const HomeCategoryItem({
    super.key,
    required this.icon,
    required this.title,
    required this.count,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return FarhaCard(
      padding: const EdgeInsets.all(18),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(color: kGoldBg, borderRadius: BorderRadius.circular(14)),
            child: Icon(icon, color: kGold, size: 23),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: kNavy, fontSize: 16, fontWeight: FontWeight.w800)),
                const SizedBox(height: 4),
                Text(subtitle ?? count, style: const TextStyle(color: kGray, fontSize: 13)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Featured Section (مربوطة بالـ API) ───────────────
class HomeFeaturedSection extends StatefulWidget {
  const HomeFeaturedSection({super.key});

  @override
  State<HomeFeaturedSection> createState() => _HomeFeaturedSectionState();
}

class _HomeFeaturedSectionState extends State<HomeFeaturedSection> {
  late Future<List<Venue>> _venuesFuture;

  @override
  void initState() {
    super.initState();
    _venuesFuture = VenueService.getFeaturedVenues();
  }

  void _retry() {
    setState(() {
      _venuesFuture = VenueService.getFeaturedVenues();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const FarhaSectionHeader(
            title: 'Featured venues',
            subtitle: 'Modern cards and spacing matched to the new admin and user style.',
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const BrowsePage()));
              },
              style: ElevatedButton.styleFrom(
                elevation: 0,
                backgroundColor: Colors.white,
                foregroundColor: kNavy,
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: const BorderSide(color: kBorder),
                ),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('View all', style: TextStyle(fontWeight: FontWeight.w700)),
                  SizedBox(width: 6),
                  Icon(Icons.arrow_forward, size: 16),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: FutureBuilder<List<Venue>>(
              future: _venuesFuture,
              builder: (context, snapshot) {
                // ── حالة التحميل ──────────────────────
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 40),
                    child: Center(
                      child: CircularProgressIndicator(color: Color(0xFFD5A217)),
                    ),
                  );
                }

                // ── حالة الخطأ ────────────────────────
                if (snapshot.hasError) {
                  final message = snapshot.error is ApiException
                      ? (snapshot.error as ApiException).message
                      : 'تعذّر تحميل القاعات المميزة';

                  return FarhaCard(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        const Icon(Icons.error_outline, color: kGray, size: 32),
                        const SizedBox(height: 10),
                        Text(
                          message,
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: kGray, fontSize: 13, fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 14),
                        ElevatedButton(
                          onPressed: _retry,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: kGold,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          child: const Text('إعادة المحاولة'),
                        ),
                      ],
                    ),
                  );
                }

                final venues = snapshot.data ?? [];

                // ── حالة لا يوجد بيانات ────────────────
                if (venues.isEmpty) {
                  return const FarhaCard(
                    padding: EdgeInsets.all(24),
                    child: Center(
                      child: Text(
                        'لا توجد قاعات مميزة حالياً',
                        style: TextStyle(color: kGray, fontSize: 13, fontWeight: FontWeight.w600),
                      ),
                    ),
                  );
                }

                // ── عرض النتائج ───────────────────────
                return Column(
                  children: [
                    for (int i = 0; i < venues.length; i++) ...[
                      VenueCard(venue: venues[i]),
                      if (i != venues.length - 1) const SizedBox(height: 14),
                    ],
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ── Venue Card ───────────────────────────────────────
class VenueCard extends StatelessWidget {
  final Venue venue;

  const VenueCard({super.key, required this.venue});

  @override
  Widget build(BuildContext context) {
    return FarhaCard(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                child: SizedBox(
                  height: 180,
                  width: double.infinity,
                  child: Image.network(
                    venue.image,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(color: kBg, child: const Icon(Icons.image_outlined, color: kGray, size: 40)),
                  ),
                ),
              ),
              Positioned(
                top: 12, left: 12,
                child: Row(children: [
                  const _Tag(label: 'Featured', color: kGold),
                  const SizedBox(width: 6),
                  _Tag(label: venue.category, color: kNavy),
                ]),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  Expanded(child: Text(venue.name, style: const TextStyle(color: kNavy, fontWeight: FontWeight.w800, fontSize: 16))),
                  const Icon(Icons.star_rounded, color: kGold, size: 16),
                  const SizedBox(width: 4),
                  Text('${venue.rating} (${venue.reviews})', style: const TextStyle(color: kGray, fontSize: 12)),
                ]),
                const SizedBox(height: 10),
                Row(children: [const Icon(Icons.location_on_outlined, color: kGray, size: 15), const SizedBox(width: 6), Expanded(child: Text(venue.location, style: const TextStyle(color: kGray, fontSize: 13)))]),
                const SizedBox(height: 6),
                Row(children: [const Icon(Icons.people_alt_outlined, color: kGray, size: 15), const SizedBox(width: 6), Expanded(child: Text(venue.capacity, style: const TextStyle(color: kGray, fontSize: 13)))]),
                const SizedBox(height: 14),
                const Divider(color: kBorder, height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      const Text('Starting from', style: TextStyle(color: kGray, fontSize: 12)),
                      const SizedBox(height: 4),
                      Text(venue.price, style: const TextStyle(color: kNavy, fontWeight: FontWeight.w900, fontSize: 16)),
                    ]),
                    ElevatedButton(
                      onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => VenueDetailPage(venueId: venue.id))),
                      style: ElevatedButton.styleFrom(backgroundColor: kGold, foregroundColor: kWhite, elevation: 0, padding: const EdgeInsets.symmetric(horizontal: 18), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                      child: const Text('View Details', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
// ── Tag Widget ────────────────────────────────────────
class _Tag extends StatelessWidget {
  final String label;
  final Color color;
  const _Tag({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(8)),
      child: Text(label, style: const TextStyle(color: kWhite, fontWeight: FontWeight.w700, fontSize: 11)),
    );
  }
}

// ── How It Works Section ─────────────────────────────
class HomeHowItWorksSection extends StatelessWidget {
  const HomeHowItWorksSection({super.key});

  Widget _numberedValueCard(int number, IconData icon, String title, String description) {
    return FarhaCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(number.toString().padLeft(2, '0'),
              style: const TextStyle(color: kGray, fontSize: 13, fontWeight: FontWeight.w700)),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: kNavy, fontSize: 15, fontWeight: FontWeight.w800)),
                const SizedBox(height: 6),
                Text(description, style: const TextStyle(color: kGray, fontSize: 13, height: 1.5)),
              ],
            ),
          ),
          const SizedBox(width: 14),
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(color: kGoldBg, borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: kGold, size: 20),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const FarhaSectionHeader(
            title: 'How it works',
            subtitle: 'A simple flow from discovery to booking.',
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                _numberedValueCard(1, Icons.search, 'Browse & compare',
                    'Explore venues and services with clean details, ratings, and pricing.'),
                const SizedBox(height: 14),
                _numberedValueCard(2, Icons.favorite_border, 'Save favorites',
                    'Keep your preferred options in one place and return anytime.'),
                const SizedBox(height: 14),
                _numberedValueCard(3, Icons.verified_user_outlined, 'Book with confidence',
                    'Send your booking request and manage everything from your dashboard.'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Testimonials Section ─────────────────────────────
class HomeTestimonialsSection extends StatelessWidget {
  const HomeTestimonialsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          FarhaSectionHeader(
            title: 'What our clients say',
            subtitle: 'Real experiences from couples who used Farha.',
          ),
          SizedBox(height: 20),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                TestimonialCard(
                  text: 'Farha made finding our dream venue so easy. The whole experience felt clean, modern, and well organized.',
                  name: 'Sarah & Michael',
                ),
                SizedBox(height: 14),
                TestimonialCard(
                  text: 'We loved how simple it was to compare options and move from browsing to booking without confusion.',
                  name: 'Ahmed & Fatima',
                ),
                SizedBox(height: 14),
                TestimonialCard(
                  text: 'The platform saved us a lot of time and gave us confidence in every decision we made.',
                  name: 'David & Emily',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Testimonial Card ─────────────────────────────────
class TestimonialCard extends StatelessWidget {
  final String text;
  final String name;

  const TestimonialCard({super.key, required this.text, required this.name});

  @override
  Widget build(BuildContext context) {
    return FarhaCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: List.generate(
              5,
                  (index) => const Icon(Icons.star_rounded, color: Color(0xFFD5A217), size: 18),
            ),
          ),
          const SizedBox(height: 10),
          Text(text, style: const TextStyle(color: kGray, fontSize: 14, height: 1.7)),
          const SizedBox(height: 14),
          Text(name, style: const TextStyle(color: kNavy, fontWeight: FontWeight.w800, fontSize: 13)),
        ],
      ),
    );
  }
}

// ── CTA Section ──────────────────────────────────────
class HomeCTASection extends StatelessWidget {
  const HomeCTASection({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 28, 16, 32),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(color: kNavy, borderRadius: BorderRadius.circular(22)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Ready to start planning your event?',
              style: TextStyle(color: kWhite, fontSize: 25, height: 1.2, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 10),
            const Text(
              'Join Farha and discover venues and vendors with a premium, organized workflow.',
              style: TextStyle(color: Colors.white70, fontSize: 14, height: 1.6),
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const CreateAccountPage()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    elevation: 0,
                    backgroundColor: kGold,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Get Started', style: TextStyle(fontWeight: FontWeight.w700)),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const BrowsePage()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    elevation: 0,
                    backgroundColor: Colors.white,
                    foregroundColor: kNavy,
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Browse First', style: TextStyle(fontWeight: FontWeight.w700)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}