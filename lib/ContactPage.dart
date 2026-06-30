import 'package:flutter/material.dart';
import 'farha_shared.dart';

// ── Contact Page ──────────────────────────────────────────────────────────────
class ContactPage extends StatefulWidget {
  const ContactPage({super.key});

  @override
  State<ContactPage> createState() => _ContactPageState();
}

class _ContactPageState extends State<ContactPage> {
  final _nameController    = TextEditingController();
  final _emailController   = TextEditingController();
  final _subjectController = TextEditingController();
  final _messageController = TextEditingController();

  final _nameFocus    = FocusNode();
  final _emailFocus   = FocusNode();
  final _subjectFocus = FocusNode();
  final _messageFocus = FocusNode();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _subjectController.dispose();
    _messageController.dispose();
    _nameFocus.dispose();
    _emailFocus.dispose();
    _subjectFocus.dispose();
    _messageFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      appBar: const FarhaAppBar(),
      endDrawer: const FarhaDrawer(activePage: 'Contact'),
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
                  // Badge
                  const FarhaBadge('Contact Us'),
                  const SizedBox(height: 20),

                  // Title
                  const Text(
                    "We're here to help with bookings, venues, and platform support.",
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
                    'Reach out to us anytime and our team will guide you through questions about venues, services, accounts, or your booking journey.',
                    style: TextStyle(
                      color: kGray,
                      fontSize: 15,
                      height: 1.6,
                    ),
                  ),
                ],
              ),
            ),

            // ── Message Form Card ─────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: FarhaCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Card title
                    const Text(
                      'Send us a message',
                      style: TextStyle(
                        color: kNavy,
                        fontWeight: FontWeight.w800,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'We usually respond as quickly as possible during working hours.',
                      style: TextStyle(color: kGray, fontSize: 13),
                    ),
                    const SizedBox(height: 22),

                    // Full Name
                    _FieldLabel('Full Name'),
                    const SizedBox(height: 8),
                    _InputField(
                      controller: _nameController,
                      focusNode: _nameFocus,
                      hint: 'Enter your full name',
                    ),
                    const SizedBox(height: 16),

                    // Email Address
                    _FieldLabel('Email Address'),
                    const SizedBox(height: 8),
                    _InputField(
                      controller: _emailController,
                      focusNode: _emailFocus,
                      hint: 'Enter your email',
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 16),

                    // Subject
                    _FieldLabel('Subject'),
                    const SizedBox(height: 8),
                    _InputField(
                      controller: _subjectController,
                      focusNode: _subjectFocus,
                      hint: 'What do you need help with?',
                    ),
                    const SizedBox(height: 16),

                    // Message
                    _FieldLabel('Message'),
                    const SizedBox(height: 8),
                    _InputField(
                      controller: _messageController,
                      focusNode: _messageFocus,
                      hint: 'Write your message here...',
                      maxLines: 5,
                    ),
                    const SizedBox(height: 24),

                    // Send button
                    SizedBox(
                      height: 48,
                      child: ElevatedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.send_rounded, size: 16),
                        label: const Text(
                          'Send Message',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          elevation: 0,
                          backgroundColor: kGold,
                          foregroundColor: kWhite,
                          padding: const EdgeInsets.symmetric(horizontal: 22),
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

            // ── Contact Information Card ──────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: FarhaCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Card title
                    const Text(
                      'Contact Information',
                      style: TextStyle(
                        color: kNavy,
                        fontWeight: FontWeight.w800,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Email
                    _ContactInfoRow(
                      icon: Icons.mail_outline_rounded,
                      label: 'Email',
                      value: 'support@farha.com',
                    ),
                    const SizedBox(height: 16),

                    // Phone
                    _ContactInfoRow(
                      icon: Icons.phone_outlined,
                      label: 'Phone',
                      value: '+970 59 123 4567',
                    ),
                    const SizedBox(height: 16),

                    // Address
                    _ContactInfoRow(
                      icon: Icons.location_on_outlined,
                      label: 'Address',
                      value: 'City Center, Hebron',
                    ),
                    const SizedBox(height: 16),

                    // Working Hours
                    _ContactInfoRow(
                      icon: Icons.access_time_rounded,
                      label: 'Working Hours',
                      value: 'Sun – Thu, 9:00 AM – 5:00 PM',
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 32),

            // ── Footer ────────────────────────────────────────────
            const FarhaFooter(),
          ],
        ),
      ),
    );
  }
}

// ── Field Label ───────────────────────────────────────────────────────────────
class _FieldLabel extends StatelessWidget {
  final String label;
  const _FieldLabel(this.label);

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: const TextStyle(
        color: kNavy,
        fontWeight: FontWeight.w700,
        fontSize: 13,
      ),
    );
  }
}

// ── Input Field ───────────────────────────────────────────────────────────────
class _InputField extends StatefulWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final String hint;
  final int maxLines;
  final TextInputType? keyboardType;

  const _InputField({
    required this.controller,
    required this.focusNode,
    required this.hint,
    this.maxLines = 1,
    this.keyboardType,
  });

  @override
  State<_InputField> createState() => _InputFieldState();
}

class _InputFieldState extends State<_InputField> {
  bool _focused = false;

  @override
  void initState() {
    super.initState();
    widget.focusNode.addListener(
          () => setState(() => _focused = widget.focusNode.hasFocus),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _focused ? kGold : kBorder,
          width: _focused ? 1.5 : 1,
        ),
      ),
      child: TextField(
        controller: widget.controller,
        focusNode: widget.focusNode,
        maxLines: widget.maxLines,
        keyboardType: widget.keyboardType,
        style: const TextStyle(color: kNavy, fontSize: 14),
        decoration: InputDecoration(
          hintText: widget.hint,
          hintStyle: const TextStyle(color: kGray, fontSize: 14),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 13,
          ),
        ),
      ),
    );
  }
}

// ── Contact Info Row ──────────────────────────────────────────────────────────
class _ContactInfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _ContactInfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Icon box
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: kGoldBg,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: kGold, size: 18),
        ),
        const SizedBox(width: 12),

        // Label + value
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                color: kGray,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: const TextStyle(
                color: kNavy,
                fontWeight: FontWeight.w800,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ],
    );
  }
}