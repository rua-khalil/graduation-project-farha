import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'farha_shared.dart';
import 'LoginPage.dart';
import 'venue_service.dart';
import 'models.dart';
import 'api_service.dart';

class VenueDetailPage extends StatefulWidget {
  final String venueId;
  const VenueDetailPage({super.key, required this.venueId});

  @override
  State<VenueDetailPage> createState() => _VenueDetailPageState();
}

class _VenueDetailPageState extends State<VenueDetailPage> {
  // ── Favorite state ────────────────────────────────
  bool _isLoggedIn = false;
  bool _isSaved = false;

  // ── Venue data (من الـ API) ────────────────────────
  late Future<Venue> _venueFuture;

  // ── Booking state ─────────────────────────────────
  DateTime? _bookingDate;
  String _bookingHour = '12';
  String _bookingMinute = '00';
  String _bookingPeriod = 'PM';
  String _duration = '24 Hours';

  final List<String> _unavailableDates = [
    '2026-05-09',
    '2026-05-13',
    '2026-06-09',
    '2026-06-06',
    '2026-06-07',
  ];

  @override
  void initState() {
    super.initState();
    _checkLogin();
    _venueFuture = VenueService.getVenueById(widget.venueId);
  }

  void _reloadVenue() {
    setState(() {
      _venueFuture = VenueService.getVenueById(widget.venueId);
    });
  }

  // ── Check login from SharedPreferences ────────────
  Future<void> _checkLogin() async {
    final prefs = await SharedPreferences.getInstance();
    final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    final email = prefs.getString('userEmail') ?? '';
    final password = prefs.getString('userPassword') ?? '';

    setState(() {
      _isLoggedIn = isLoggedIn &&
          email == 'mohammadnasir@farha.com' &&
          password == 'Farha@2026';
    });
  }

  // ── Handle favorite tap ───────────────────────────
  void _handleFavorite() {
    if (!_isLoggedIn) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const logInPage()),
      );
      return;
    }
    setState(() => _isSaved = !_isSaved);
  }

  Future<void> _pickBookingDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _bookingDate ?? DateTime.now(),
      firstDate: DateTime(2025),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: kGold,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: kNavy,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(foregroundColor: kGold),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) setState(() => _bookingDate = picked);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      appBar: const FarhaAppBar(),
      endDrawer: const FarhaDrawer(),
      body: FutureBuilder<Venue>(
        future: _venueFuture,
        builder: (context, snapshot) {
          // ── حالة التحميل ──────────────────────────
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.only(top: 120),
                child: CircularProgressIndicator(color: kGold),
              ),
            );
          }

          // ── حالة الخطأ ────────────────────────────
          if (snapshot.hasError || !snapshot.hasData) {
            final message = snapshot.error is ApiException
                ? (snapshot.error as ApiException).message
                : 'تعذّر تحميل تفاصيل القاعة';

            return Center(
              child: Padding(
                padding: const EdgeInsets.only(top: 120),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.error_outline, color: kGray, size: 40),
                    const SizedBox(height: 12),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      child: Text(
                        message,
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: kGray, fontSize: 14, fontWeight: FontWeight.w600),
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _reloadVenue,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kGold,
                        foregroundColor: kWhite,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: const Text('إعادة المحاولة'),
                    ),
                  ],
                ),
              ),
            );
          }

          final venue = snapshot.data!;

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                // ── Back Button ───────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(14),
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color: kWhite,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(Icons.arrow_back, color: kNavy, size: 18),
                          SizedBox(width: 6),
                          Text(
                            'Back',
                            style: TextStyle(
                              color: kNavy,
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // ── Main Card ─────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: FarhaCard(
                    padding: EdgeInsets.zero,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [

                        // ── Hero Image (من الـ API) ──
                        ClipRRect(
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(20),
                          ),
                          child: Image.network(
                            venue.image.isNotEmpty
                                ? venue.image
                                : 'https://images.unsplash.com/photo-1519225421980-715cb0215aed?w=800',
                            width: double.infinity,
                            height: 220,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => Container(
                              height: 220,
                              color: kGoldBg,
                              child: const Icon(Icons.image, color: kGold, size: 60),
                            ),
                          ),
                        ),

                        // ── Venue Info ────────────────
                        Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [

                              // Badge + Heart Row
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  FarhaBadge(
                                    venue.category.isNotEmpty ? venue.category : 'Service',
                                  ),

                                  // ── Favorite Heart Button ──────────
                                  GestureDetector(
                                    onTap: _handleFavorite,
                                    child: Container(
                                      width: 40,
                                      height: 40,
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
                                      child: Icon(
                                        _isSaved
                                            ? Icons.favorite
                                            : Icons.favorite_border,
                                        color: _isSaved ? Colors.redAccent : kGray,
                                        size: 20,
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 12),

                              // Venue Name (من الـ API)
                              Text(
                                venue.name.isNotEmpty ? venue.name : 'Unnamed venue',
                                style: const TextStyle(
                                  color: kNavy,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 28,
                                  height: 1.15,
                                ),
                              ),

                              const SizedBox(height: 12),

                              // ── Rating Row (من الـ API) ──
                              Row(
                                children: [
                                  const Icon(Icons.star, color: kGold, size: 16),
                                  const SizedBox(width: 4),
                                  Text(
                                    venue.rating.toStringAsFixed(1),
                                    style: const TextStyle(
                                      color: kNavy,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '(${venue.reviews} reviews)',
                                    style: TextStyle(color: kGray, fontSize: 13),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 14),

                              // ── Details (من الـ API) ──
                              Wrap(
                                spacing: 16,
                                runSpacing: 8,
                                children: [
                                  _inlineDetail(
                                    Icons.location_on_outlined,
                                    venue.location.isNotEmpty
                                        ? venue.location
                                        : 'Location not specified',
                                  ),
                                  _inlineDetail(
                                    Icons.people_alt_outlined,
                                    venue.capacity,
                                  ),
                                ],
                              ),

                              const SizedBox(height: 20),
                              const Divider(color: kBorder),
                              const SizedBox(height: 14),

                              // ── Price (من الـ API) ──
                              const Text('Starting from',
                                  style: TextStyle(color: kGray, fontSize: 13)),
                              const SizedBox(height: 4),
                              Text(
                                venue.price.isNotEmpty
                                    ? '\$${venue.price}'
                                    : 'Contact for price',
                                style: const TextStyle(
                                  color: kNavy,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 22,
                                ),
                              ),

                              const SizedBox(height: 18),

                              // ── Chat + Book Now Buttons ─
                              Row(
                                children: [
                                  Expanded(
                                    child: OutlinedButton.icon(
                                      onPressed: () {
                                        if (!_isLoggedIn) {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(builder: (context) => const logInPage()),
                                          );
                                          return;
                                        }
                                      },
                                      icon: const Icon(Icons.chat_bubble_outline, size: 16),
                                      label: const Text('Chat'),
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor: kNavy,
                                        side: const BorderSide(color: kBorder, width: 1.5),
                                        padding: const EdgeInsets.symmetric(vertical: 14),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(14),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    flex: 2,
                                    child: ElevatedButton(
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) => const logInPage()),
                                        );
                                      },
                                      style: ElevatedButton.styleFrom(
                                        elevation: 0,
                                        backgroundColor: kGold,
                                        foregroundColor: kWhite,
                                        padding: const EdgeInsets.symmetric(vertical: 14),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(14),
                                        ),
                                      ),
                                      child: const Text(
                                        'Book Now',
                                        style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
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
                  ),
                ),

                const SizedBox(height: 20),

                // ── Gallery ───────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: FarhaCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Gallery',
                            style: TextStyle(
                                color: kNavy, fontWeight: FontWeight.w900, fontSize: 20)),
                        const SizedBox(height: 4),
                        const Text('A quick preview of the venue atmosphere and style.',
                            style: TextStyle(color: kGray, fontSize: 13, height: 1.5)),
                        const SizedBox(height: 16),
                        if (venue.images.isEmpty)
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 20),
                            child: Center(
                              child: Text(
                                'لا توجد صور إضافية لهاي القاعة',
                                style: TextStyle(color: kGray, fontSize: 13, fontWeight: FontWeight.w600),
                              ),
                            ),
                          )
                        else
                          for (int i = 0; i < venue.images.length; i++) ...[
                            _galleryImage(venue.images[i]),
                            if (i != venue.images.length - 1) const SizedBox(height: 12),
                          ],
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // ── Reviews & Ratings ─────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: FarhaCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Reviews & Ratings',
                            style: TextStyle(
                                color: kNavy, fontWeight: FontWeight.w900, fontSize: 20)),
                        const SizedBox(height: 4),
                        const Text('What customers say about this service.',
                            style: TextStyle(color: kGray, fontSize: 13, height: 1.5)),
                        const SizedBox(height: 18),
                        _reviewItem(name: 'Mohammad Nasir', date: '11/06/2026', rating: 4),
                        const Divider(color: kBorder, height: 24),
                        _reviewItem(name: 'Mohammad Nasir', date: '05/06/2026', rating: 5),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // ── Contact Info ──────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: FarhaCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Contact Information',
                            style: TextStyle(
                                color: kNavy, fontWeight: FontWeight.w900, fontSize: 20)),
                        const SizedBox(height: 18),
                        _contactRow(Icons.business_outlined, 'Company',
                            venue.name.isNotEmpty ? venue.name : 'N/A'),
                        const SizedBox(height: 14),
                        _contactRow(Icons.phone_outlined, 'Phone', '+970 59 123 4567'),
                        const SizedBox(height: 14),
                        _contactRow(Icons.email_outlined, 'Email', 'venue@farha.com'),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: OutlinedButton.icon(
                            onPressed: () {
                              if (!_isLoggedIn) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => const logInPage()),
                                );
                                return;
                              }
                            },
                            icon: const Icon(Icons.chat_bubble_outline, size: 18),
                            label: const Text(
                              'Chat with Vendor',
                              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                            ),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: kNavy,
                              side: const BorderSide(color: kBorder, width: 1.5),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // ── Customize Your Booking ────────────
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: FarhaCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Customize your booking',
                            style: TextStyle(
                                color: kNavy, fontWeight: FontWeight.w900, fontSize: 20)),
                        const SizedBox(height: 18),

                        Row(
                          children: const [
                            Icon(Icons.calendar_today_outlined, color: kGray, size: 16),
                            SizedBox(width: 6),
                            Text('Booking Date',
                                style: TextStyle(
                                    color: kGray, fontSize: 13, fontWeight: FontWeight.w600)),
                          ],
                        ),
                        const SizedBox(height: 8),

                        GestureDetector(
                          onTap: _pickBookingDate,
                          child: Container(
                            width: double.infinity,
                            height: 48,
                            padding: const EdgeInsets.symmetric(horizontal: 14),
                            decoration: BoxDecoration(
                              color: kBg,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: kBorder),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.calendar_today_outlined, color: kGray, size: 16),
                                const SizedBox(width: 10),
                                Text(
                                  _bookingDate == null
                                      ? 'Select date'
                                      : '${_bookingDate!.year}-'
                                      '${_bookingDate!.month.toString().padLeft(2, '0')}-'
                                      '${_bookingDate!.day.toString().padLeft(2, '0')}',
                                  style: TextStyle(
                                    color: _bookingDate == null ? kGray : kNavy,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 14),

                        const Text('Unavailable dates:',
                            style: TextStyle(
                                color: kGray, fontSize: 12, fontWeight: FontWeight.w600)),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: _unavailableDates.map((date) {
                            return Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFF0F0),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: const Color(0xFFFFCCCC)),
                              ),
                              child: Text(date,
                                  style: const TextStyle(
                                      color: Color(0xFFCC0000),
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600)),
                            );
                          }).toList(),
                        ),

                        const SizedBox(height: 18),

                        Row(
                          children: const [
                            Icon(Icons.access_time_outlined, color: kGray, size: 16),
                            SizedBox(width: 6),
                            Text('Booking Time',
                                style: TextStyle(
                                    color: kGray, fontSize: 13, fontWeight: FontWeight.w600)),
                          ],
                        ),
                        const SizedBox(height: 10),

                        Container(
                          height: 44,
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          decoration: BoxDecoration(
                            color: kBg,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: kBorder),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Expanded(
                                child: _timeDropdown(
                                  context: context,
                                  value: _bookingHour,
                                  items: List.generate(
                                      12, (i) => (i + 1).toString().padLeft(2, '0')),
                                  onChanged: (v) => setState(() => _bookingHour = v!),
                                ),
                              ),
                              const Text(':',
                                  style: TextStyle(
                                      color: kNavy, fontSize: 18, fontWeight: FontWeight.w700)),
                              Expanded(
                                child: _timeDropdown(
                                  context: context,
                                  value: _bookingMinute,
                                  items: List.generate(
                                      60, (i) => i.toString().padLeft(2, '0')),
                                  onChanged: (v) => setState(() => _bookingMinute = v!),
                                ),
                              ),
                              Expanded(
                                child: _timeDropdown(
                                  context: context,
                                  value: _bookingPeriod,
                                  items: const ['AM', 'PM'],
                                  onChanged: (v) => setState(() => _bookingPeriod = v!),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 18),

                        Row(
                          children: const [
                            Icon(Icons.timelapse_outlined, color: kGray, size: 16),
                            SizedBox(width: 6),
                            Text('Duration',
                                style: TextStyle(
                                    color: kGray, fontSize: 13, fontWeight: FontWeight.w600)),
                          ],
                        ),
                        const SizedBox(height: 8),

                        Container(
                          width: double.infinity,
                          height: 48,
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          decoration: BoxDecoration(
                            color: kBg,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: kBorder),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(_duration,
                                  style: const TextStyle(
                                      color: kNavy,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600)),
                            ],
                          ),
                        ),

                        const SizedBox(height: 22),

                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const logInPage()),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              elevation: 0,
                              backgroundColor: kGold,
                              foregroundColor: kWhite,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: const Text('Continue to Booking',
                                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),
                const FarhaFooter(),
              ],
            ),
          );
        },
      ),
    );
  }

  // ── Time Dropdown ─────────────────────────────────
  Widget _timeDropdown({
    required BuildContext context,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    final GlobalKey key = GlobalKey();
    return StatefulBuilder(
      builder: (context, setState) {
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
                maxHeight: 200,
              ),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              position: RelativeRect.fromLTRB(
                offset.dx,
                offset.dy + box.size.height,
                MediaQuery.of(context).size.width - offset.dx - box.size.width,
                0,
              ),
              items: items.map((item) {
                return PopupMenuItem<String>(
                  value: item,
                  height: 38,
                  child: SizedBox(
                    width: box.size.width,
                    child: Text(item,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            color: kNavy, fontSize: 13, fontWeight: FontWeight.w700)),
                  ),
                );
              }).toList(),
            );
            if (selected != null) onChanged(selected);
          },
          child: Container(
            key: key,
            height: 44,
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: const BoxDecoration(color: Colors.transparent),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(value,
                    style: const TextStyle(
                        color: kNavy, fontSize: 14, fontWeight: FontWeight.w700)),
                const SizedBox(width: 5),
                const Icon(Icons.keyboard_arrow_down_rounded, color: kGray, size: 14),
              ],
            ),
          ),
        );
      },
    );
  }

  // ── Review Item ───────────────────────────────────
  Widget _reviewItem({
    required String name,
    required String date,
    required int rating,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(name,
                  style: const TextStyle(
                      color: kNavy, fontWeight: FontWeight.w700, fontSize: 14)),
              const SizedBox(height: 4),
              Text(date, style: const TextStyle(color: kGray, fontSize: 12)),
            ],
          ),
        ),
        Row(
          children: List.generate(5, (index) {
            return Icon(
              index < rating ? Icons.star_rounded : Icons.star_outline_rounded,
              color: kGold,
              size: 18,
            );
          }),
        ),
      ],
    );
  }

  // ── Contact Row ───────────────────────────────────
  Widget _contactRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: kGray, size: 18),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(color: kGray, fontSize: 13)),
            const SizedBox(height: 2),
            Text(value,
                style: const TextStyle(
                    color: kNavy, fontWeight: FontWeight.w700, fontSize: 15)),
          ],
        ),
      ],
    );
  }

  // ── Inline Detail ─────────────────────────────────
  Widget _inlineDetail(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: kGray, size: 15),
        const SizedBox(width: 5),
        Text(text, style: const TextStyle(color: kGray, fontSize: 13)),
      ],
    );
  }

  // ── Gallery Image ─────────────────────────────────
  Widget _galleryImage(String url) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: Image.network(
        url,
        width: double.infinity,
        height: 200,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => Container(
          height: 200,
          decoration: BoxDecoration(
            color: kGoldBg,
            borderRadius: BorderRadius.circular(14),
          ),
          child: const Icon(Icons.image, color: kGold, size: 50),
        ),
      ),
    );
  }
}