import 'package:flutter/material.dart';
import 'farha_shared.dart';
import 'UserDashboardPage.dart';

class ReviewPage extends StatefulWidget {
  const ReviewPage({super.key});

  @override
  State<ReviewPage> createState() => _ReviewPageState();
}

class _ReviewPageState extends State<ReviewPage> {
  int _rating = 0;
  final _reviewController = TextEditingController();
  final _reviewFocus = FocusNode();
  bool _focused = false;

  @override
  void initState() {
    super.initState();
    _reviewFocus.addListener(() => setState(() => _focused = _reviewFocus.hasFocus));
  }

  @override
  void dispose() {
    _reviewController.dispose();
    _reviewFocus.dispose();
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

            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: InkWell(
                borderRadius: BorderRadius.circular(14),
                onTap: () => Navigator.pop(context),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(color: kWhite, borderRadius: BorderRadius.circular(14), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))]),
                  child: Row(mainAxisSize: MainAxisSize.min, children: const [Icon(Icons.arrow_back, color: kNavy, size: 18), SizedBox(width: 6), Text('Back', style: TextStyle(color: kNavy, fontWeight: FontWeight.w600, fontSize: 14))]),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  FarhaBadge('Submit Review'),
                  SizedBox(height: 16),
                  Text('Share your experience', style: TextStyle(color: kNavy, fontWeight: FontWeight.w900, fontSize: 26)),
                  SizedBox(height: 8),
                  Text('Help others find the perfect venue by sharing your honest feedback.', style: TextStyle(color: kGray, fontSize: 14, height: 1.6)),
                ],
              ),
            ),

            // Venue Card
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: FarhaCard(
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network('https://images.unsplash.com/photo-1519741497674-611481863552?w=200',
                          width: 70, height: 70, fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(width: 70, height: 70, color: kGoldBg, child: const Icon(Icons.image, color: kGold))),
                    ),
                    const SizedBox(width: 14),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Skyline Rooftop Venue', style: TextStyle(color: kNavy, fontWeight: FontWeight.w800, fontSize: 16)),
                          SizedBox(height: 4),
                          Text('Business District', style: TextStyle(color: kGray, fontSize: 13)),
                          SizedBox(height: 4),
                          Text('Event Date: March 10, 2026', style: TextStyle(color: kGray, fontSize: 12)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Review Form
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: FarhaCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Your Review', style: TextStyle(color: kNavy, fontWeight: FontWeight.w800, fontSize: 18)),
                    const SizedBox(height: 20),

                    // Rating Stars
                    const Text('Overall Rating', style: TextStyle(color: kNavy, fontWeight: FontWeight.w700, fontSize: 13)),
                    const SizedBox(height: 12),
                    Row(
                      children: List.generate(5, (i) {
                        return GestureDetector(
                          onTap: () => setState(() => _rating = i + 1),
                          child: Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: Icon(
                              i < _rating ? Icons.star_rounded : Icons.star_outline_rounded,
                              color: kGold,
                              size: 38,
                            ),
                          ),
                        );
                      }),
                    ),
                    if (_rating > 0) ...[
                      const SizedBox(height: 8),
                      Text(
                        _rating == 5 ? 'Excellent!' : _rating == 4 ? 'Very Good' : _rating == 3 ? 'Good' : _rating == 2 ? 'Fair' : 'Poor',
                        style: const TextStyle(color: kGold, fontWeight: FontWeight.w700, fontSize: 14),
                      ),
                    ],

                    const SizedBox(height: 20),

                    // Category Ratings
                    const Text('Detailed Ratings', style: TextStyle(color: kNavy, fontWeight: FontWeight.w700, fontSize: 13)),
                    const SizedBox(height: 14),
                    _CategoryRating(label: 'Venue Quality'),
                    const SizedBox(height: 12),
                    _CategoryRating(label: 'Staff & Service'),
                    const SizedBox(height: 12),
                    _CategoryRating(label: 'Value for Money'),

                    const SizedBox(height: 20),

                    // Review Text
                    const Text('Write your review', style: TextStyle(color: kNavy, fontWeight: FontWeight.w700, fontSize: 13)),
                    const SizedBox(height: 8),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: _focused ? kGold : kBorder, width: _focused ? 1.5 : 1),
                      ),
                      child: TextField(
                        controller: _reviewController,
                        focusNode: _reviewFocus,
                        maxLines: 5,
                        style: const TextStyle(color: kNavy, fontSize: 14),
                        decoration: const InputDecoration(
                          hintText: 'Describe your experience at this venue...',
                          hintStyle: TextStyle(color: kGray, fontSize: 14),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.all(14),
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: _rating == 0 ? null : () => _showSuccessDialog(context),
                        style: ElevatedButton.styleFrom(
                          elevation: 0,
                          backgroundColor: kGold,
                          foregroundColor: kWhite,
                          disabledBackgroundColor: kBorder,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        child: const Text('Submit Review', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                      ),
                    ),

                    if (_rating == 0) ...[
                      const SizedBox(height: 8),
                      const Center(child: Text('Please select a rating to continue', style: TextStyle(color: kGray, fontSize: 12))),
                    ],
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

  void _showSuccessDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: const BoxDecoration(color: kGoldBg, shape: BoxShape.circle),
              child: const Icon(Icons.star_rounded, color: kGold, size: 36),
            ),
            const SizedBox(height: 16),
            const Text('Review Submitted!', style: TextStyle(color: kNavy, fontWeight: FontWeight.w900, fontSize: 20)),
            const SizedBox(height: 8),
            const Text('Thank you for sharing your experience. Your review helps others make better decisions.', textAlign: TextAlign.center, style: TextStyle(color: kGray, fontSize: 13, height: 1.5)),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 46,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const UserDashboardPage()), (route) => false);
                },
                style: ElevatedButton.styleFrom(elevation: 0, backgroundColor: kGold, foregroundColor: kWhite, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                child: const Text('Back to Dashboard', style: TextStyle(fontWeight: FontWeight.w700)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryRating extends StatefulWidget {
  final String label;
  const _CategoryRating({required this.label});

  @override
  State<_CategoryRating> createState() => _CategoryRatingState();
}

class _CategoryRatingState extends State<_CategoryRating> {
  int _rating = 0;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(width: 120, child: Text(widget.label, style: const TextStyle(color: kGray, fontSize: 13))),
        Row(
          children: List.generate(5, (i) => GestureDetector(
            onTap: () => setState(() => _rating = i + 1),
            child: Padding(
              padding: const EdgeInsets.only(right: 4),
              child: Icon(i < _rating ? Icons.star_rounded : Icons.star_outline_rounded, color: kGold, size: 22),
            ),
          )),
        ),
      ],
    );
  }
}