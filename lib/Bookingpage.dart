import 'package:farha/UserProfilePage.dart';
import 'package:flutter/material.dart';
import 'farha_shared.dart';

class BookingPage extends StatefulWidget {
  const BookingPage({super.key});

  @override
  State<BookingPage> createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage> {
  DateTime? _selectedDate;
  String? _selectedGuests;
  final _notesController = TextEditingController();
  final _notesFocus = FocusNode();
  bool _focused = false;

  final List<String> _guestOptions = ['50 - 100', '100 - 200', '200 - 300', '300 - 500', '500+'];

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2026),
      lastDate: DateTime(2030),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(primary: kGold, onPrimary: kWhite, onSurface: kNavy),
          textButtonTheme: TextButtonThemeData(style: TextButton.styleFrom(foregroundColor: kGold)),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  @override
  void initState() {
    super.initState();
    _notesFocus.addListener(() => setState(() => _focused = _notesFocus.hasFocus));
  }

  @override
  void dispose() {
    _notesController.dispose();
    _notesFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      appBar: const FarhaAppBar(),
      endDrawer: const FarhaDrawer(),
      body: SingleChildScrollView(
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
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(Icons.arrow_back, color: kNavy, size: 18),
                      SizedBox(width: 6),
                      Text('Back', style: TextStyle(color: kNavy, fontWeight: FontWeight.w600, fontSize: 14)),
                    ],
                  ),
                ),
              ),
            ),

            // ── Hero ──────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  FarhaBadge('Book a Service'),
                  SizedBox(height: 16),
                  Text(
                    'Complete your booking details below.',
                    style: TextStyle(color: kNavy, fontWeight: FontWeight.w900, fontSize: 26, height: 1.2),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Fill in the required information to confirm your reservation.',
                    style: TextStyle(color: kGray, fontSize: 14, height: 1.6),
                  ),
                ],
              ),
            ),

            // ── Venue Summary ─────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: FarhaCard(
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        'https://images.unsplash.com/photo-1519225421980-715cb0215aed?w=200',
                        width: 70,
                        height: 70,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(width: 70, height: 70, color: kGoldBg, child: const Icon(Icons.image, color: kGold)),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text('Grand Crystal Ballroom', style: TextStyle(color: kNavy, fontWeight: FontWeight.w800, fontSize: 16)),
                          SizedBox(height: 4),
                          Text('Downtown, City Center', style: TextStyle(color: kGray, fontSize: 13)),
                          SizedBox(height: 6),
                          Text('\$8,000 – \$12,000', style: TextStyle(color: kNavy, fontWeight: FontWeight.w700, fontSize: 14)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // ── Booking Form ──────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: FarhaCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Booking Details', style: TextStyle(color: kNavy, fontWeight: FontWeight.w800, fontSize: 18)),
                    const SizedBox(height: 20),

                    // Event Date
                    const Text('Event Date', style: TextStyle(color: kNavy, fontWeight: FontWeight.w700, fontSize: 13)),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: _pickDate,
                      child: Container(
                        height: 48,
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        decoration: BoxDecoration(
                          color: kBg,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: kBorder),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.calendar_today_outlined, color: kGray, size: 18),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                _selectedDate == null ? 'Select event date' : '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}',
                                style: TextStyle(color: _selectedDate == null ? kGray : kNavy, fontSize: 14, fontWeight: FontWeight.w600),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Guests
                    const Text('Number of Guests', style: TextStyle(color: kNavy, fontWeight: FontWeight.w700, fontSize: 13)),
                    const SizedBox(height: 8),
                    Container(
                      height: 48,
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      decoration: BoxDecoration(color: kBg, borderRadius: BorderRadius.circular(12), border: Border.all(color: kBorder)),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedGuests,
                          hint: const Text('Select guest count', style: TextStyle(color: kGray, fontSize: 14)),
                          icon: const Icon(Icons.keyboard_arrow_down_rounded, color: kGray),
                          isExpanded: true,
                          style: const TextStyle(color: kNavy, fontSize: 14, fontWeight: FontWeight.w600),
                          items: _guestOptions.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                          onChanged: (v) => setState(() => _selectedGuests = v),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Notes
                    const Text('Additional Notes', style: TextStyle(color: kNavy, fontWeight: FontWeight.w700, fontSize: 13)),
                    const SizedBox(height: 8),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: _focused ? kGold : kBorder, width: _focused ? 1.5 : 1),
                      ),
                      child: TextField(
                        controller: _notesController,
                        focusNode: _notesFocus,
                        maxLines: 4,
                        style: const TextStyle(color: kNavy, fontSize: 14),
                        decoration: const InputDecoration(
                          hintText: 'Any special requests or notes...',
                          hintStyle: TextStyle(color: kGray, fontSize: 14),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.all(14),
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Price Summary
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(color: kGoldBg, borderRadius: BorderRadius.circular(12), border: Border.all(color: kGold.withOpacity(0.2))),
                      child: Column(
                        children: [
                          _PriceRow(label: 'Base Price', value: '\$8,000'),
                          const SizedBox(height: 8),
                          _PriceRow(label: 'Service Fee', value: '\$400'),
                          const Divider(height: 20),
                          _PriceRow(label: 'Total', value: '\$8,400', isBold: true),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Confirm Button
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfilePage())),
                        style: ElevatedButton.styleFrom(
                          elevation: 0,
                          backgroundColor: kGold,
                          foregroundColor: kWhite,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        child: const Text('Proceed to Payment', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
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
      ),
    );
  }
}

class _PriceRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isBold;
  const _PriceRow({required this.label, required this.value, this.isBold = false});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(color: isBold ? kNavy : kGray, fontWeight: isBold ? FontWeight.w800 : FontWeight.w500, fontSize: isBold ? 15 : 13)),
        Text(value, style: TextStyle(color: kNavy, fontWeight: isBold ? FontWeight.w900 : FontWeight.w700, fontSize: isBold ? 16 : 13)),
      ],
    );
  }
}