import 'package:flutter/material.dart';
import 'farha_shared.dart';

// ── Create Account Page ───────────────────────────────────────────────────────
class CreateAccountPage extends StatefulWidget {
  const CreateAccountPage({super.key});

  @override
  State<CreateAccountPage> createState() => _CreateAccountPageState();
}

class _CreateAccountPageState extends State<CreateAccountPage> {
  final _firstNameController = TextEditingController();
  final _lastNameController  = TextEditingController();
  final _emailController     = TextEditingController();
  final _phoneController     = TextEditingController();
  final _passwordController  = TextEditingController();

  final _firstNameFocus = FocusNode();
  final _lastNameFocus  = FocusNode();
  final _emailFocus     = FocusNode();
  final _phoneFocus     = FocusNode();
  final _passwordFocus  = FocusNode();

  bool _obscurePassword = true;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _firstNameFocus.dispose();
    _lastNameFocus.dispose();
    _emailFocus.dispose();
    _phoneFocus.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // ── Background image ──────────────────────────────────
          Image.network(
            'https://images.unsplash.com/photo-1464366400600-7168b8af9bc3?auto=format&fit=crop&w=1200&q=80',
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(color: kNavy),
          ),

          // ── Dark overlay ──────────────────────────────────────
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  kNavy.withOpacity(0.72),
                  kNavy.withOpacity(0.55),
                  kNavy.withOpacity(0.72),
                ],
              ),
            ),
          ),

          // ── Content ───────────────────────────────────────────
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 72, 20, 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Welcome badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.18),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white30),
                    ),
                    child: const Text(
                      'Create your account',
                      style: TextStyle(
                        color: kWhite,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),

                  // Hero title
                  const Text(
                    'Start planning your event with a modern and premium workflow.',
                    style: TextStyle(
                      color: kWhite,
                      fontWeight: FontWeight.w900,
                      fontSize: 28,
                      height: 1.25,
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Subtitle
                  const Text(
                    'Join Farha to save favorites, manage bookings, and explore venues and services through a beautifully organized experience.',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // ── Create Account Card ───────────────────────
                  FarhaCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Card title
                        const Text(
                          'Create Account',
                          style: TextStyle(
                            color: kNavy,
                            fontWeight: FontWeight.w900,
                            fontSize: 22,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Fill in your details to get started.',
                          style: TextStyle(color: kGray, fontSize: 13),
                        ),
                        const SizedBox(height: 24),

                        // First Name + Last Name (جنب بعض)
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _FieldLabel(
                                    icon: Icons.person_outline_rounded,
                                    label: 'First Name',
                                  ),
                                  const SizedBox(height: 8),
                                  _InputField(
                                    controller: _firstNameController,
                                    focusNode: _firstNameFocus,
                                    hint: 'Enter your First name',
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _FieldLabel(
                                    icon: Icons.person_outline_rounded,
                                    label: 'Last Name',
                                  ),
                                  const SizedBox(height: 8),
                                  _InputField(
                                    controller: _lastNameController,
                                    focusNode: _lastNameFocus,
                                    hint: 'Enter your Last name',
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Email Address
                        _FieldLabel(
                          icon: Icons.mail_outline_rounded,
                          label: 'Email Address',
                        ),
                        const SizedBox(height: 8),
                        _InputField(
                          controller: _emailController,
                          focusNode: _emailFocus,
                          hint: 'Enter your email',
                          keyboardType: TextInputType.emailAddress,
                        ),
                        const SizedBox(height: 16),

                        // Phone Number
                        _FieldLabel(
                          icon: Icons.phone_outlined,
                          label: 'Phone Number',
                        ),
                        const SizedBox(height: 8),
                        _InputField(
                          controller: _phoneController,
                          focusNode: _phoneFocus,
                          hint: 'Enter your phone number',
                          keyboardType: TextInputType.phone,
                        ),
                        const SizedBox(height: 16),

                        // Password
                        _FieldLabel(
                          icon: Icons.lock_outline_rounded,
                          label: 'Password',
                        ),
                        const SizedBox(height: 8),
                        _InputField(
                          controller: _passwordController,
                          focusNode: _passwordFocus,
                          hint: 'Create a password',
                          obscure: _obscurePassword,
                          suffix: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                              color: kGray,
                              size: 18,
                            ),
                            onPressed: () => setState(
                                    () => _obscurePassword = !_obscurePassword),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Create Account button
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: ElevatedButton(
                            onPressed: () {},
                            style: ElevatedButton.styleFrom(
                              elevation: 0,
                              backgroundColor: kGold,
                              foregroundColor: kWhite,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Create Account',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 15,
                                  ),
                                ),
                                SizedBox(width: 8),
                                Icon(Icons.arrow_forward_rounded, size: 18),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // log in link
                        Center(
                          child: RichText(
                            text: TextSpan(
                              style: const TextStyle(
                                fontSize: 13,
                                color: kGray,
                              ),
                              children: [
                                const TextSpan(
                                    text: 'Already have an account? '),
                                WidgetSpan(
                                  child: GestureDetector(
                                    onTap: () => Navigator.pop(context),
                                    child: const Text(
                                      'Login',
                                      style: TextStyle(
                                        color: kGold,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Field Label ───────────────────────────────────────────────────────────────
class _FieldLabel extends StatelessWidget {
  final IconData icon;
  final String label;
  const _FieldLabel({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: kNavy, size: 15),
        const SizedBox(width: 6),
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

// ── Input Field ───────────────────────────────────────────────────────────────
class _InputField extends StatefulWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final String hint;
  final bool obscure;
  final TextInputType? keyboardType;
  final Widget? suffix;

  const _InputField({
    required this.controller,
    required this.focusNode,
    required this.hint,
    this.obscure = false,
    this.keyboardType,
    this.suffix,
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
        obscureText: widget.obscure,
        keyboardType: widget.keyboardType,
        style: const TextStyle(color: kNavy, fontSize: 14),
        decoration: InputDecoration(
          hintText: widget.hint,
          hintStyle: const TextStyle(color: kGray, fontSize: 14),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
              horizontal: 14, vertical: 13),
          suffixIcon: widget.suffix,
        ),
      ),
    );
  }
}