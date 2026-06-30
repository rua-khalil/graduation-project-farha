import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'farha_shared.dart';
import 'VenueDetailPage.dart';
import 'LoginPage.dart';
import 'SearchVenues.dart';
import 'models.dart';
import 'venue_service.dart';
import 'api_service.dart';

class BrowsePage extends StatefulWidget {
  final List<Venue>? searchResults;
  const BrowsePage({super.key, this.searchResults});

  @override
  State<BrowsePage> createState() => _BrowsePageState();
}

class _BrowsePageState extends State<BrowsePage> {
  late Future<List<Venue>> _servicesFuture;

  @override
  void initState() {
    super.initState();
    if (widget.searchResults != null) {
      _servicesFuture = Future.value(widget.searchResults);
    } else {
      _servicesFuture = VenueService.getFeaturedVenues();
    }
  }

  void _retry() {
    setState(() {
      _servicesFuture = VenueService.getFeaturedVenues();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      appBar: const FarhaAppBar(),
      endDrawer: const FarhaDrawer(activePage: 'Browse Services'),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 28, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const FarhaBadge('Explore curated services'),
                  const SizedBox(height: 20),
                  const Text(
                    'Browse premium venues and wedding services.',
                    style: TextStyle(color: kNavy, fontWeight: FontWeight.w900, fontSize: 28, height: 1.25),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Discover elegant halls, gardens, photography teams, decoration providers, and more.',
                    style: TextStyle(color: kGray, fontSize: 15, height: 1.6),
                  ),
                  const SizedBox(height: 24),
                  _SearchBar(),
                  const SizedBox(height: 28),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: FutureBuilder<List<Venue>>(
                future: _servicesFuture,
                builder: (context, snapshot) {
                  // ── تحميل ──
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 60),
                      child: Center(child: CircularProgressIndicator(color: kGold)),
                    );
                  }

                  // ── خطأ ──
                  if (snapshot.hasError) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 40),
                      child: FarhaCard(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          children: [
                            const Icon(Icons.error_outline, color: kGray, size: 32),
                            const SizedBox(height: 10),
                            const Text('تعذّر تحميل الخدمات', style: TextStyle(color: kGray, fontSize: 13)),
                            const SizedBox(height: 14),
                            ElevatedButton(
                              onPressed: _retry,
                              style: ElevatedButton.styleFrom(backgroundColor: kGold, foregroundColor: Colors.white, elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                              child: const Text('إعادة المحاولة'),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  final services = snapshot.data ?? [];

                  // ── فاضي ──
                  if (services.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 40),
                      child: Center(child: Text('لا توجد خدمات حالياً', style: TextStyle(color: kGray))),
                    );
                  }

                  // ── النتائج ──
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Available services', style: TextStyle(color: kNavy, fontWeight: FontWeight.w900, fontSize: 22)),
                      const SizedBox(height: 4),
                      Text('${services.length} results found.', style: const TextStyle(color: kGray, fontSize: 13)),
                      const SizedBox(height: 20),
                      ...services.map((item) => Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: _ServiceCard(venue: item),
                      )),
                    ],
                  );
                },
              ),
            ),

            const SizedBox(height: 16),
            const FarhaFooter(),
          ],
        ),
      ),
    );
  }
}

// ── Search Bar ────────────────────────────────────────
class _SearchBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: kWhite,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: Row(
        children: [
          const Icon(Icons.search, color: kGray, size: 20),
          const SizedBox(width: 10),
          const Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search venues, categories, or locations',
                hintStyle: TextStyle(color: kGray, fontSize: 14),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
          Container(width: 1, height: 24, color: kBorder, margin: const EdgeInsets.symmetric(horizontal: 12)),
          GestureDetector(
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SearchPage())),
            child: const Row(
              children: [
                Icon(Icons.tune_rounded, color: kGold, size: 16),
                SizedBox(width: 6),
                Text('Advanced Filters', style: TextStyle(color: kNavy, fontWeight: FontWeight.w700, fontSize: 13)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Service Card ──────────────────────────────────────
class _ServiceCard extends StatefulWidget {
  final Venue venue;
  const _ServiceCard({required this.venue});

  @override
  State<_ServiceCard> createState() => _ServiceCardState();
}

class _ServiceCardState extends State<_ServiceCard> {
  bool isLoggedIn = false;
  bool isFavorite = false;

  @override
  void initState() {
    super.initState();
    _checkLogin();
  }

  Future<void> _checkLogin() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    });
  }

  void _handleFavorite() {
    if (!isLoggedIn) {
      Navigator.push(context, MaterialPageRoute(builder: (_) => const logInPage()));
      return;
    }
    setState(() => isFavorite = !isFavorite);
  }

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
                    widget.venue.image,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(color: kBg, child: const Icon(Icons.image_outlined, color: kGray, size: 40)),
                  ),
                ),
              ),
              Positioned(
                top: 12, left: 12,
                child: Row(children: [
                  _Tag(label: 'Featured', color: kGold),
                  const SizedBox(width: 6),
                  _Tag(label: widget.venue.category, color: kNavy),
                ]),
              ),
              Positioned(
                top: 12, right: 12,
                child: GestureDetector(
                  onTap: _handleFavorite,
                  child: Container(
                    width: 36, height: 36,
                    decoration: BoxDecoration(color: kWhite, shape: BoxShape.circle, boxShadow: [BoxShadow(color: Colors.black.withOpacity(.08), blurRadius: 8)]),
                    child: Icon(isFavorite ? Icons.favorite : Icons.favorite_border, color: isFavorite ? Colors.redAccent : kGray, size: 18),
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  Expanded(child: Text(widget.venue.name, style: const TextStyle(color: kNavy, fontWeight: FontWeight.w800, fontSize: 16))),
                  const Icon(Icons.star_rounded, color: kGold, size: 16),
                  const SizedBox(width: 4),
                  Text('${widget.venue.rating} (${widget.venue.reviews})', style: const TextStyle(color: kGray, fontSize: 12)),
                ]),
                const SizedBox(height: 10),
                Row(children: [const Icon(Icons.location_on_outlined, color: kGray, size: 15), const SizedBox(width: 6), Text(widget.venue.location, style: const TextStyle(color: kGray, fontSize: 13))]),
                const SizedBox(height: 6),
                Row(children: [const Icon(Icons.people_alt_outlined, color: kGray, size: 15), const SizedBox(width: 6), Text(widget.venue.capacity, style: const TextStyle(color: kGray, fontSize: 13))]),
                const SizedBox(height: 14),
                const Divider(color: kBorder, height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      const Text('Starting from', style: TextStyle(color: kGray, fontSize: 12)),
                      const SizedBox(height: 4),
                      Text(widget.venue.price, style: const TextStyle(color: kNavy, fontWeight: FontWeight.w900, fontSize: 16)),
                    ]),
                    ElevatedButton(
                      onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => VenueDetailPage(venueId: widget.venue.id))),
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
// ── Tag ───────────────────────────────────────────────
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