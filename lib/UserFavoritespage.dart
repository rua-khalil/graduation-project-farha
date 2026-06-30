import 'package:farha/BrowseServicesPage.dart';
import 'package:flutter/material.dart';
import 'farha_shared.dart';
import 'UserNav.dart';
import 'SearchVenues.dart';
import 'VenueDetailPage.dart';
import 'favorites_service.dart';

// ── Favorite Model ────────────────────────────────────────────────────────────
class FavoriteModel {
  final String id;
  final String venueName;
  final String location;
  final String price;
  final String category;
  final String image;
  final String rating;

  const FavoriteModel({
    required this.id,
    required this.venueName,
    required this.location,
    required this.price,
    required this.category,
    required this.image,
    required this.rating,
  });

  factory FavoriteModel.fromJson(Map<String, dynamic> json) {
    return FavoriteModel(
      id: json['id']?.toString() ?? '',
      venueName: json['venue_name'] ?? json['venueName'] ?? '',
      location: json['location'] ?? '',
      price: json['price'] ?? '',
      category: json['category'] ?? '',
      image: json['image'] ?? '',
      rating: json['rating']?.toString() ?? '',
    );
  }
}

// ── Favorites Page ────────────────────────────────────────────────────────────
class FavoritesPage extends StatefulWidget {
  const FavoritesPage({super.key});

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  bool _loading = true;
  String? _error;
  List<FavoriteModel> _favorites = [];

  @override
  void initState() {
    super.initState();
    _fetchFavorites();
  }

  // ── Fetch from API ────────────────────────────────
  Future<void> _fetchFavorites() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      _favorites = await FavoritesService.getFavorites();
    } catch (e) {
      _error = 'Failed to load favorites. Please try again.';
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _removeFavorite(String id) async {
    // Optimistic UI: remove immediately, roll back if the API call fails.
    final removed = _favorites.firstWhere((f) => f.id == id);
    setState(() => _favorites.removeWhere((f) => f.id == id));

    try {
      await FavoritesService.removeFavorite(id);
    } catch (e) {
      // Roll back on failure
      if (mounted) {
        setState(() => _favorites.add(removed));
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to remove favorite. Try again.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      appBar: const UserNav(activeTab: 'Favorites'),
      body: RefreshIndicator(
        color: kGold,
        onRefresh: _fetchFavorites,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 28, 20, 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // ── Title ─────────────────────────────
              const Text(
                'Favorites',
                style: TextStyle(
                  color: kNavy,
                  fontWeight: FontWeight.w900,
                  fontSize: 28,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'All your saved venues and services in one polished list.',
                style: TextStyle(color: kGray, fontSize: 14, height: 1.5),
              ),

              const SizedBox(height: 24),

              // ── Saved Venues Card ──────────────────
              FarhaCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    const Text(
                      'Saved Venues & Services',
                      style: TextStyle(
                        color: kNavy,
                        fontWeight: FontWeight.w800,
                        fontSize: 17,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Revisit your favorite places and compare them before booking.',
                      style: TextStyle(color: kGray, fontSize: 13, height: 1.5),
                    ),

                    const SizedBox(height: 16),

                    // Count badge
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: kBg,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: kBorder),
                      ),
                      child: Text(
                        '${_favorites.length} saved item${_favorites.length == 1 ? '' : 's'}',
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
                    else if (_favorites.isEmpty)
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
            onPressed: _fetchFavorites,
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(height: 8),
        const Text(
          'No favorites yet.',
          style: TextStyle(color: kGray, fontSize: 14),
        ),
        const SizedBox(height: 14),
        Center(
          child: SizedBox(
            width: 160,
            height: 46,
            child: ElevatedButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const BrowsePage()),
              ),
              style: ElevatedButton.styleFrom(
                elevation: 0,
                backgroundColor: kGold,
                foregroundColor: kWhite,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Browse Services',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
              ),
            ),
          ),
        ),
      ],
    );
  }
  // ── List ──────────────────────────────────────────
  Widget _buildList() {
    return Column(
      children: _favorites.map((fav) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: _FavoriteItem(
            favorite: fav,
            onRemove: () => _removeFavorite(fav.id),
          ),
        );
      }).toList(),
    );
  }
}

// ── Favorite Item ─────────────────────────────────────────────────────────────
class _FavoriteItem extends StatelessWidget {
  final FavoriteModel favorite;
  final VoidCallback onRemove;

  const _FavoriteItem({required this.favorite, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: kWhite,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: kBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          // Image + remove button
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(14),
                ),
                child: favorite.image.isNotEmpty
                    ? Image.network(
                  favorite.image,
                  width: double.infinity,
                  height: 150,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => _placeholder(),
                )
                    : _placeholder(),
              ),

              // Remove button
              Positioned(
                top: 10,
                right: 10,
                child: GestureDetector(
                  onTap: onRemove,
                  child: Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: kWhite,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.favorite,
                      color: Colors.redAccent,
                      size: 17,
                    ),
                  ),
                ),
              ),

              // Category badge
              Positioned(
                top: 10,
                left: 10,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: kNavy,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    favorite.category,
                    style: const TextStyle(
                      color: kWhite,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),

          // Info
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                // Name + rating
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        favorite.venueName,
                        style: const TextStyle(
                          color: kNavy,
                          fontWeight: FontWeight.w800,
                          fontSize: 15,
                        ),
                      ),
                    ),
                    if (favorite.rating.isNotEmpty) ...[
                      const Icon(Icons.star_rounded, color: kGold, size: 15),
                      const SizedBox(width: 3),
                      Text(
                        favorite.rating,
                        style: const TextStyle(
                          color: kGray,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ],
                ),

                const SizedBox(height: 6),

                // Location
                Row(
                  children: [
                    const Icon(Icons.location_on_outlined,
                        color: kGray, size: 13),
                    const SizedBox(width: 4),
                    Text(
                      favorite.location,
                      style: const TextStyle(color: kGray, fontSize: 12),
                    ),
                  ],
                ),

                const SizedBox(height: 10),
                const Divider(color: kBorder, height: 1),
                const SizedBox(height: 10),

                // Price + View button
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Starting from',
                          style: TextStyle(color: kGray, fontSize: 11),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          favorite.price,
                          style: const TextStyle(
                            color: kNavy,
                            fontWeight: FontWeight.w900,
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
                    ElevatedButton(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => VenueDetailPage(venueId: favorite.id),
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        elevation: 0,
                        backgroundColor: kGold,
                        foregroundColor: kWhite,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 10,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        'View Details',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                      ),
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

  Widget _placeholder() {
    return Container(
      width: double.infinity,
      height: 150,
      color: kGoldBg,
      child: const Icon(Icons.image_outlined, color: kGold, size: 36),
    );
  }
}