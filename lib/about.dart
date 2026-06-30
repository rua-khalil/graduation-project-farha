import 'package:flutter/material.dart';
import 'farha_shared.dart';
// ── About Page ─────────────────────────────────────────────
class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  // List for "What Makes Farha Different"
  final List<String> differentItems = const [
    'Clean, modern platform design',
    'Organized search and booking flow',
    'Premium presentation for venues and services',
    'Consistent dashboard experience for all users',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      appBar: const FarhaAppBar(),
      endDrawer: const FarhaDrawer(activePage: 'About'),

      // Safe area to avoid phone top/bottom problems
      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 900),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  // ── Hero Section ─────────────────────
                  const FarhaHeroSection(),

                  // ── Our Story Card ───────────────────
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),

                    child: FarhaCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [

                          const Text(
                            'Our Story',
                            style: TextStyle(
                              color: kNavy,
                              fontWeight: FontWeight.w800,
                              fontSize: 22,
                            ),
                          ),

                          const SizedBox(height: 14),

                          _storyParagraph(
                            'Planning weddings and special events can quickly become overwhelming. Too many choices, inconsistent information, and outdated layouts often make the process harder than it should be.',
                          ),

                          const SizedBox(height: 12),

                          _storyParagraph(
                            'Farha was created to simplify that journey. We wanted to bring venues, services, and booking flows together in one elegant space that feels modern, trustworthy, and easy to use.',
                          ),

                          const SizedBox(height: 12),

                          _storyParagraph(
                            'Our goal is not only to help users browse options, but to give them confidence at every step — from discovery to booking.',
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 28),

                  // ── What Makes Farha Different ───────
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),

                    child: FarhaCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [

                          const Text(
                            'What makes Farha different?',
                            style: TextStyle(
                              color: kNavy,
                              fontWeight: FontWeight.w800,
                              fontSize: 18,
                            ),
                          ),

                          const SizedBox(height: 16),

                          // Generate items automatically
                          ...differentItems.map(
                                (item) => Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: FarhaOutlinedItem(item),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 28),

                  // ── Our Values ───────────────────────
                  const FarhaSectionHeader(
                    title: 'Our Values',
                    subtitle:
                    'The principles that shape how we design and improve the experience.',
                  ),

                  const SizedBox(height: 20),

                  // ── Value Cards ──────────────────────
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),

                    child: Column(
                      children: [

                        FarhaValueCard(
                          icon: Icons.favorite_border,
                          title: 'Meaningful Experiences',
                          description:
                          'We help couples and families discover venues and services that make celebrations feel truly special.',
                        ),

                        SizedBox(height: 14),

                        FarhaValueCard(
                          icon: Icons.auto_awesome_outlined,
                          title: 'Curated Quality',
                          description:
                          'We focus on elegant, trusted, and well-presented options so every decision feels clearer and easier.',
                        ),

                        SizedBox(height: 14),
                        FarhaValueCard(
                          icon: Icons.verified_user_outlined,
                          title: 'Reliable Process',
                          description:
                          'From browsing to booking, we aim to make the experience organized, transparent, and dependable.',
                        ),
                        SizedBox(height: 14),

                        FarhaValueCard(
                          icon: Icons.people_outline,
                          title: 'People First',
                          description:
                          'We design every interaction around real customer needs, comfort, and confidence.',
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // ── Footer ───────────────────────────
                  const FarhaFooter(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ── Helper Paragraph ─────────────────────────────────
  Widget _storyParagraph(String text) {
    return Text(
      text,
      style: const TextStyle(
        color: kGray,
        fontSize: 15,
        height: 1.65,
      ),
    );
  }
}