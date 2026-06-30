import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:farha/GuestHomePage.dart';
import 'package:farha/UserHomePage.dart';
import 'farha_shared.dart';
import 'Createaccountpage.dart';
import 'VendorDashboardpage.dart';
import 'api_config.dart';
import 'api_service.dart';

// ── log In Page ──────────────────────────────────────────────────────────────
class logInPage extends StatefulWidget {
  const logInPage({super.key});

  @override
  State<logInPage> createState() => _logInPageState();
}

class _logInPageState extends State<logInPage> {
  final _emailController    = TextEditingController();
  final _passwordController = TextEditingController();
  bool _rememberMe          = false;
  bool _obscurePassword     = true;
  bool _isLoading           = false;

  final _emailFocus    = FocusNode();
  final _passwordFocus = FocusNode();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  // ── Handle Login (مربوط بالباك الحقيقي) ──────────────
  Future<void> _handleLogin() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    setState(() => _isLoading = true);

    try {
      final response = await ApiService.post(
        '/users/login',
        body: {'email': email, 'password': password},
      );

      final data = response is Map && response['data'] is Map
          ? response['data']
          : response;

      final token = data['token']?.toString() ?? '';
      final user = data['user'] is Map ? data['user'] : {};

      final firstName = user['f_name']?.toString() ?? '';
      final lastName  = user['l_name']?.toString() ?? '';
      final userId    = user['u_id']?.toString() ?? '';
      final roleName  = (user['role_name']?.toString() ?? 'user').toLowerCase();

      if (token.isEmpty) {
        _showSnack('تعذّر تسجيل الدخول، حاول مرة أخرى', isError: true);
        _goToGuestHome();
        return;
      }

      await ApiConfig.saveToken(token);

      final prefs = await ApiConfig.prefsInstance();
      await prefs.setBool('isLoggedIn', true);
      await prefs.setString('userEmail', email);
      await prefs.setString('firstName', firstName);
      await prefs.setString('lastName', lastName);
      await prefs.setString('userId', userId);
      await prefs.setString('userRole', roleName);

      if (_rememberMe) {
        await prefs.setString('savedEmail', email);
      }

      if (!mounted) return;

      if (roleName == 'vendor') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const VendorDashboardPage()),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => UserHomePage(userName: firstName.isNotEmpty ? firstName : 'User'),
          ),
        );
      }
    } on ApiException catch (e) {
      _showSnack(e.message, isError: true);
      _goToGuestHome();
    } catch (e) {
      _showSnack('حدث خطأ غير متوقع، حاول مرة أخرى', isError: true);
      _goToGuestHome();
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
  void _showSnack(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : kGold,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
  void _goToGuestHome() {
    Future.delayed(const Duration(milliseconds: 1200), () {
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomePage()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.network(
            'https://images.unsplash.com/photo-1464366400600-7168b8af9bc3?auto=format&fit=crop&w=1200&q=80',
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(color: kNavy),
          ),
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
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 72, 20, 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => const HomePage()),
                    ),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: kGold,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.home_outlined, color: kWhite, size: 16),
                          SizedBox(width: 6),
                          Text(
                            'Back to Home',
                            style: TextStyle(
                              color: kWhite,
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.18),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white30),
                    ),
                    child: const Text(
                      'Welcome back',
                      style: TextStyle(
                        color: kWhite,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  const Text(
                    'Login to continue your premium Farha experience.',
                    style: TextStyle(
                      color: kWhite,
                      fontWeight: FontWeight.w900,
                      fontSize: 28,
                      height: 1.25,
                    ),
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    'Access your bookings, saved venues, notifications, and personal dashboard in one elegant place.',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: 32),

                  FarhaCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'LogIn',
                          style: TextStyle(
                            color: kNavy,
                            fontWeight: FontWeight.w900,
                            fontSize: 22,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Enter your account details to continue.',
                          style: TextStyle(color: kGray, fontSize: 13),
                        ),
                        const SizedBox(height: 24),

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
                        const SizedBox(height: 18),

                        _FieldLabel(
                          icon: Icons.lock_outline_rounded,
                          label: 'Password',
                        ),
                        const SizedBox(height: 8),
                        _InputField(
                          controller: _passwordController,
                          focusNode: _passwordFocus,
                          hint: 'Enter your password',
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
                        const SizedBox(height: 16),

                        Row(
                          children: [
                            SizedBox(
                              width: 20,
                              height: 20,
                              child: Checkbox(
                                value: _rememberMe,
                                activeColor: kGold,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                onChanged: (v) =>
                                    setState(() => _rememberMe = v!),
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'Remember me',
                              style: TextStyle(
                                color: kNavy,
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const Spacer(),
                            GestureDetector(
                              onTap: () {},
                              child: const Text(
                                'Forgot password?',
                                style: TextStyle(
                                  color: kGold,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _handleLogin,
                            style: ElevatedButton.styleFrom(
                              elevation: 0,
                              backgroundColor: kGold,
                              foregroundColor: kWhite,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            child: _isLoading
                                ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: kWhite,
                                strokeWidth: 2.2,
                              ),
                            )
                                : const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'LogIn',
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

                        Center(
                          child: RichText(
                            text: TextSpan(
                              style: const TextStyle(
                                fontSize: 13,
                                color: kGray,
                              ),
                              children: [
                                const TextSpan(text: "Don't have an account? "),
                                WidgetSpan(
                                  child: GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                          const CreateAccountPage(),
                                        ),
                                      );
                                    },
                                    child: const Text(
                                      'Create one',
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
    widget.focusNode.addListener(() {
      setState(() => _focused = widget.focusNode.hasFocus);
    });
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
          contentPadding:
          const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
          suffixIcon: widget.suffix,
        ),
      ),
    );
  }
}