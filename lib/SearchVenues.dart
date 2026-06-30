import 'package:flutter/material.dart';
import 'farha_shared.dart';
import 'VenueDetailPage.dart';

// ── Search Page ───────────────────────────────────────────────────────────────
class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  String _selectedCategory = 'All categories';
  String _selectedGuests   = 'Any size';
  String _selectedBudget   = 'Any budget';

  final _searchController   = TextEditingController();
  final _locationController = TextEditingController();

  final _categories = [
    'All categories',
    'Wedding Hall Reservations',
    'Catering and Food Services',
    'Photography and Videography',
    'Floral Arrangements and Decorations',
    'Wedding Dresses and Fashion Services',
    'Wedding Cars',
    'Music and DJ Services',
    'Bridal Stage Setups',
  ];
  final _guests  = ['Any size', 'Up to 100', 'Up to 200', 'Up to 300', 'Up to 500', '500+'];
  final _budgets = ['Any budget', 'Up to \$5,000', 'Up to \$10,000', 'Up to \$15,000', '\$15,000+'];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() => setState(() {}));
    _locationController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _searchController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  List<_VenueModel> get _filteredVenues {
    return _venues.where((v) {
      final search   = _searchController.text.toLowerCase();
      final location = _locationController.text.toLowerCase();

      final matchSearch = search.isEmpty ||
          v.name.toLowerCase().contains(search) ||
          v.category.toLowerCase().contains(search);

      final matchLocation = location.isEmpty ||
          v.location.toLowerCase().contains(location);

      final matchCategory = _selectedCategory == 'All categories' ||
          v.category.toLowerCase().contains(_selectedCategory.toLowerCase());

      final matchGuests = _selectedGuests == 'Any size' ||
          v.capacity.toLowerCase().contains(
              _selectedGuests.replaceAll('Up to ', '').toLowerCase());

      return matchSearch && matchLocation && matchCategory && matchGuests;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      appBar: const FarhaAppBar(),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Hero Section ──────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 28, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const FarhaBadge('Smart venue filtering'),
                  const SizedBox(height: 20),
                  const Text(
                    'Search and filter venues with a premium layout.',
                    style: TextStyle(
                      color: kNavy,
                      fontWeight: FontWeight.w900,
                      fontSize: 28,
                      height: 1.25,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Narrow down your options by location, category, guest size, and budget using a cleaner admin-inspired interface.',
                    style: TextStyle(
                      color: kGray,
                      fontSize: 15,
                      height: 1.6,
                    ),
                  ),
                ],
              ),
            ),

            // ── Filter Panel ──────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: FarhaCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.tune_rounded, color: kNavy, size: 18),
                        SizedBox(width: 8),
                        Text(
                          'Filters',
                          style: TextStyle(
                            color: kNavy,
                            fontWeight: FontWeight.w800,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    const _FilterLabel(label: 'Search', icon: Icons.search),
                    const SizedBox(height: 8),
                    _TextInput(hint: 'Venue name or keyword', controller: _searchController),
                    const SizedBox(height: 16),
                    const _FilterLabel(label: 'Location', icon: Icons.location_on_outlined),
                    const SizedBox(height: 8),
                    _TextInput(hint: 'City or district', controller: _locationController),
                    const SizedBox(height: 16),
                    const _FilterLabel(label: 'Category', icon: null),
                    const SizedBox(height: 8),
                    _DropdownInput(
                      value: _selectedCategory,
                      items: _categories,
                      onChanged: (v) => setState(() => _selectedCategory = v!),
                    ),
                    const SizedBox(height: 16),
                    const _FilterLabel(label: 'Guests', icon: Icons.people_outline),
                    const SizedBox(height: 8),
                    _DropdownInput(
                      value: _selectedGuests,
                      items: _guests,
                      onChanged: (v) => setState(() => _selectedGuests = v!),
                    ),
                    const SizedBox(height: 16),
                    const _FilterLabel(label: 'Budget', icon: Icons.wallet_outlined),
                    const SizedBox(height: 8),
                    _DropdownInput(
                      value: _selectedBudget,
                      items: _budgets,
                      onChanged: (v) => setState(() => _selectedBudget = v!),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      height: 44,
                      child: OutlinedButton(
                        onPressed: () => setState(() {
                          _selectedCategory = 'All categories';
                          _selectedGuests   = 'Any size';
                          _selectedBudget   = 'Any budget';
                          _searchController.clear();
                          _locationController.clear();
                        }),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: kNavy,
                          side: const BorderSide(color: kBorder),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Reset Filters',
                          style: TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 28),

            // ── Results Section ───────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Matching venues',
                    style: TextStyle(
                      color: kNavy,
                      fontWeight: FontWeight.w900,
                      fontSize: 22,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${_filteredVenues.length} results based on your selected filters.',
                    style: const TextStyle(color: kGray, fontSize: 13),
                  ),
                  const SizedBox(height: 20),
                  if (_filteredVenues.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 40),
                      child: Center(
                        child: Text(
                          'No venues match your filters.',
                          style: TextStyle(color: kGray, fontSize: 14),
                        ),
                      ),
                    )
                  else
                    ..._filteredVenues.map(
                          (item) => Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: _VenueCard(item: item),
                      ),
                    ),
                ],
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

// ── Filter Helpers ────────────────────────────────────────────────────────────
class _FilterLabel extends StatelessWidget {
  final String label;
  final IconData? icon;
  const _FilterLabel({required this.label, this.icon});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (icon != null) ...[
          Icon(icon, color: kGray, size: 15),
          const SizedBox(width: 6),
        ],
        Text(
          label,
          style: const TextStyle(
            color: kNavy,
            fontWeight: FontWeight.w700,
            fontSize: 13,
          ),
        ),
      ],
    );
  }
}

class _TextInput extends StatelessWidget {
  final String hint;
  final TextEditingController controller;
  const _TextInput({required this.hint, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: kBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: kBorder),
      ),
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.text,
        textInputAction: TextInputAction.done,
        style: const TextStyle(
          color: kNavy,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: kGray, fontSize: 14),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        ),
      ),
    );
  }
}

class _DropdownInput extends StatelessWidget {
  final String value;
  final List<String> items;
  final ValueChanged<String?> onChanged;
  const _DropdownInput({
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return StatefulBuilder(
      builder: (context, setState) {
        final GlobalKey key = GlobalKey();
        return GestureDetector(
          onTap: () async {
            final RenderBox box =
            key.currentContext!.findRenderObject() as RenderBox;
            final Offset offset = box.localToGlobal(Offset.zero);
            final selected = await showMenu<String>(
              context: context,
              color: kWhite,
              constraints: BoxConstraints(
                minWidth: box.size.width,
                maxWidth: box.size.width,
                maxHeight: 150,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              position: RelativeRect.fromLTRB(
                offset.dx,
                offset.dy + box.size.height,
                MediaQuery.of(context).size.width - offset.dx - box.size.width,
                MediaQuery.of(context).size.height * 0.1,
              ),
              items: items.map((option) {
                final isSelected = option == value;
                return PopupMenuItem<String>(
                  value: option,
                  padding: EdgeInsets.zero,
                  child: Container(
                    width: box.size.width,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: isSelected ? kGold : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      option,
                      style: TextStyle(
                        color: isSelected ? kWhite : kNavy,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                );
              }).toList(),
            );
            if (selected != null) onChanged(selected);
          },
          child: Container(
            key: key,
            height: 44,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: kBg,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: kBorder),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    value,
                    style: const TextStyle(
                      color: kNavy,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const Icon(Icons.keyboard_arrow_down_rounded, color: kGray, size: 18),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ── Venue Card ────────────────────────────────────────────────────────────────
class _VenueCard extends StatelessWidget {
  final _VenueModel item;
  const _VenueCard({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return FarhaCard(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Image ─────────────────────────────
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            child: SizedBox(
              height: 220,
              width: double.infinity,
              child: Image.network(
                item.image,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  color: kBg,
                  child: const Icon(Icons.image_outlined, color: kGray, size: 40),
                ),
              ),
            ),
          ),

          // ── Info ──────────────────────────────
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                // Category badge + "New (reviews)" row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Category badge — gold background
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: kGoldBg,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        item.category,
                        style: const TextStyle(
                          color: kGold,
                          fontWeight: FontWeight.w700,
                          fontSize: 11,
                        ),
                      ),
                    ),

                    // Star + New (reviews)
                    Row(
                      children: [
                        const Icon(Icons.star_rounded, color: kGold, size: 15),
                        const SizedBox(width: 4),
                        Text(
                          'New (${item.reviews})',
                          style: const TextStyle(
                            color: kNavy,
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                // Venue name
                Text(
                  item.name,
                  style: const TextStyle(
                    color: kNavy,
                    fontWeight: FontWeight.w800,
                    fontSize: 17,
                  ),
                ),

                const SizedBox(height: 10),

                // Location + Capacity in one row
                Row(
                  children: [
                    const Icon(Icons.location_on_outlined, color: kGray, size: 14),
                    const SizedBox(width: 4),
                    Text(item.location,
                        style: const TextStyle(color: kGray, fontSize: 13)),
                    const SizedBox(width: 16),
                    const Icon(Icons.people_alt_outlined, color: kGray, size: 14),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(item.capacity,
                          style: const TextStyle(color: kGray, fontSize: 13)),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Price left + View Details right — same row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Up to ${item.price}',
                      style: const TextStyle(
                        color: kNavy,
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                      ),
                    ),
                    SizedBox(
                      height: 40,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const VenueDetailPage(venueId: '1')),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          elevation: 0,
                          backgroundColor: kGold,
                          foregroundColor: kWhite,
                          padding: const EdgeInsets.symmetric(horizontal: 18),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'View Details',
                          style: TextStyle(
                              fontWeight: FontWeight.w700, fontSize: 13),
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
}

// ── Data ──────────────────────────────────────────────────────────────────────
class _VenueModel {
  final String name;
  final String location;
  final String capacity;
  final String price;
  final String image;
  final String rating;
  final String reviews;
  final String category;
  const _VenueModel({
    required this.name,
    required this.location,
    required this.capacity,
    required this.price,
    required this.image,
    required this.rating,
    required this.reviews,
    required this.category,
  });
}

const _venues = [
  _VenueModel(
    name: 'Lavender Halls',
    location: 'Jenin',
    capacity: 'Up to 500 guests',
    price: '\$1,000',
    image: 'https://images.unsplash.com/photo-1519225421980-715cb0215aed?auto=format&fit=crop&w=800&q=80',
    rating: '4.8',
    reviews: '0',
    category: 'Wedding Hall Reservations',
  ),
  _VenueModel(
    name: 'Wawi Halls',
    location: 'Hebron',
    capacity: 'Up to 800 guests',
    price: '\$1,500',
    image: 'https://images.unsplash.com/photo-1464366400600-7168b8af9bc3?auto=format&fit=crop&w=800&q=80',
    rating: '4.9',
    reviews: '0',
    category: 'Wedding Hall Reservations',
  ),
  _VenueModel(
    name: 'San Moris Halls',
    location: 'Tulkarm',
    capacity: 'Up to 1000 guests',
    price: '\$1,200',
    image: 'https://images.unsplash.com/photo-1519741497674-611481863552?auto=format&fit=crop&w=800&q=80',
    rating: '4.7',
    reviews: '0',
    category: 'Wedding Hall Reservations',
  ),
  _VenueModel(
    name: 'Levent Halls',
    location: 'Ramallah',
    capacity: 'Up to 1000 guests',
    price: '\$1,600',
    image: 'https://images.unsplash.com/photo-1522673607200-164d1b6ce486?auto=format&fit=crop&w=800&q=80',
    rating: '4.8',
    reviews: '0',
    category: 'Wedding Hall Reservations',
  ),
  _VenueModel(
    name: 'Al Ahlam Studio',
    location: 'Hebron',
    capacity: 'Up to 0 guests',
    price: '\$200',
    image: 'https://images.unsplash.com/photo-1537633552985-df8429e8048b?auto=format&fit=crop&w=800&q=80',
    rating: '4.9',
    reviews: '0',
    category: 'Photography and Videography',
  ),
  _VenueModel(
    name: 'T.Aljabaly',
    location: 'Tulkarm',
    capacity: 'Up to 0 guests',
    price: '\$200',
    image: 'https://images.unsplash.com/photo-1520854221256-17451cc331bf?auto=format&fit=crop&w=800&q=80',
    rating: '4.8',
    reviews: '0',
    category: 'Photography and Videography',
  ),
  _VenueModel(
    name: 'Studio Mar Mar',
    location: 'Qalqilya',
    capacity: 'Up to 0 guests',
    price: '\$150',
    image: 'https://images.unsplash.com/photo-1465495976277-4387d4b0b4c6?auto=format&fit=crop&w=800&q=80',
    rating: '4.7',
    reviews: '0',
    category: 'Photography and Videography',
  ),
  _VenueModel(
    name: 'Lebanese cakes and sweets',
    location: 'Jenin',
    capacity: 'Up to 0 guests',
    price: '\$100',
    image: 'https://images.unsplash.com/photo-1478146059778-26028b07395a?auto=format&fit=crop&w=800&q=80',
    rating: '4.9',
    reviews: '0',
    category: 'Catering and Food Services',
  ),
];