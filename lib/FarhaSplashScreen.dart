import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'farha_shared.dart';
import 'GuestHomePage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'UserHomePage.dart';
import 'VendorDashboardpage.dart';

class FarhaSplashScreen extends StatefulWidget {
  const FarhaSplashScreen({super.key});

  @override
  State<FarhaSplashScreen> createState() => _FarhaSplashScreenState();
}

class _FarhaSplashScreenState extends State<FarhaSplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _mainController;
  late final AnimationController _pulseController;
  late final AnimationController _shineController;
  late final AnimationController _ringController;

  @override
  void initState() {
    super.initState();
    _mainController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2600),
    )..forward();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat(reverse: true);

    _shineController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2800),
    )..repeat();

    // دوران بطيء جداً للحلقة الزجاجية المحيطة باللوجو (إحساس ماسي)
    _ringController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 6000),
    )..repeat();

    Future.delayed(const Duration(seconds: 8), () async {
      if (!mounted) return;

      // ── فحص حالة تسجيل الدخول المحفوظة ──
      final prefs = await SharedPreferences.getInstance();
      final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
      final role = prefs.getString('userRole') ?? '';
      final firstName = prefs.getString('firstName') ?? 'User';
      debugPrint(
          'isLoggedIn = $isLoggedIn | role = $role | firstName = $firstName');

      Widget destination;
      if (isLoggedIn && role == 'vendor') {
        destination = const VendorDashboardPage();
      } else if (isLoggedIn) {
        destination = UserHomePage(userName: firstName);
      } else {
        destination = const HomePage();
      }

      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 900),
          pageBuilder: (_, animation, __) => destination,
          transitionsBuilder: (_, animation, __, child) {
            final fade = CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic,
            );
            final slide = Tween<Offset>(
              begin: const Offset(0, .04),
              end: Offset.zero,
            ).animate(fade);
            return FadeTransition(
              opacity: fade,
              child: SlideTransition(position: slide, child: child),
            );
          },
        ),
      );
    });
  }

  @override
  void dispose() {
    _mainController.dispose();
    _pulseController.dispose();
    _shineController.dispose();
    _ringController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final logoScale = Tween<double>(begin: .72, end: 1).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.08, 0.42, curve: Curves.easeOutBack),
      ),
    );

    final logoFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.0, 0.28, curve: Curves.easeOut),
      ),
    );

    final textSlide = Tween<Offset>(
      begin: const Offset(0, .24),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.22, 0.60, curve: Curves.easeOutCubic),
      ),
    );

    final textFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.22, 0.52, curve: Curves.easeOut),
      ),
    );

    final subtitleFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.42, 0.72, curve: Curves.easeOut),
      ),
    );

    final pulse = Tween<double>(begin: 1, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    return Scaffold(
      body: AnimatedBuilder(
        animation: Listenable.merge([
          _mainController,
          _pulseController,
          _shineController,
          _ringController,
        ]),
        builder: (context, _) {
          return Container(
            decoration: const BoxDecoration(
              gradient: RadialGradient(
                center: Alignment(0, -0.05),
                radius: 1.3,
                colors: [
                  Color(0xff241a0c),
                  Color(0xff160f07),
                  Color(0xff0c0804),
                  Color(0xff050302),
                ],
                stops: [0.0, 0.35, 0.68, 1.0],
              ),
            ),
            child: Stack(
              fit: StackFit.expand,
              children: [
                // شبكة خفيفة بالخلفية لإحساس فخامة تقنية
                CustomPaint(
                  painter: _GridPainter(),
                ),

                // شعاع ضوء قطري ثابت بالزاوية العلوية اليمين
                Positioned(
                  top: -60,
                  right: -120,
                  child: Transform.rotate(
                    angle: -math.pi / 5.2,
                    child: ImageFiltered(
                      imageFilter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                      child: Container(
                        width: 130,
                        height: 480,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                            colors: [
                              Colors.white.withOpacity(0),
                              Colors.white.withOpacity(.10),
                              Colors.white.withOpacity(0),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                // توهج خلفي خافت وراء اللوجو فقط
                _BlurGlow(
                  alignment: const Alignment(0, -.05),
                  size: 260,
                  color: const Color(0x22d7af48),
                ),

                // Center content
                Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Logo + glass ring
                      Opacity(
                        opacity: logoFade.value,
                        child: Transform.scale(
                          scale: logoScale.value * pulse.value,
                          child: _GlassLogoFrame(
                            shineValue: _shineController.value,
                            ringValue: _ringController.value,
                          ),
                        ),
                      ),
                      const SizedBox(height: 30),

                      // App name
                      SlideTransition(
                        position: textSlide,
                        child: FadeTransition(
                          opacity: textFade,
                          child: const Text(
                            'Farha',
                            style: TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.6,
                              color: Color(0xfff0c84a),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),

                      // LOADING + dots
                      FadeTransition(
                        opacity: subtitleFade,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text(
                              'LOADING',
                              style: TextStyle(
                                fontSize: 11,
                                letterSpacing: 1.6,
                                color: Color(0xffcdb98f),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(width: 8),
                            const _LoadingDots(),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ── إطار زجاجي (دائرة + معيّن دوّار) يحتضن صورة اللوجو ────────────────────────
class _GlassLogoFrame extends StatelessWidget {
  final double shineValue;
  final double ringValue;
  const _GlassLogoFrame({required this.shineValue, required this.ringValue});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 192,
      height: 192,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // هالة خارجية متوهجة خافتة
          Container(
            width: 192,
            height: 192,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: const [
                BoxShadow(
                  color: Color(0x30d7af48),
                  blurRadius: 50,
                  spreadRadius: 4,
                ),
              ],
              gradient: const RadialGradient(
                colors: [
                  Color(0x22f1d07a),
                  Color(0x0af1d07a),
                  Colors.transparent
                ],
                stops: [0.0, 0.55, 1.0],
              ),
            ),
          ),

          // الدائرة الذهبية الرفيعة الخارجية (ثابتة)
          Container(
            width: 172,
            height: 172,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: const Color(0xffb8831f).withOpacity(.55),
                width: 1.1,
              ),
            ),
          ),

          // المعيّن (Diamond) الذهبي الدوّار ببطء
          Transform.rotate(
            angle: ringValue * 2 * math.pi,
            child: Container(
              width: 122,
              height: 122,
              decoration: BoxDecoration(
                border: Border.all(
                  color: const Color(0xffe7bf6b),
                  width: 1.6,
                ),
                borderRadius: BorderRadius.circular(6),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xffd7af48).withOpacity(.45),
                    blurRadius: 16,
                    spreadRadius: 1,
                  ),
                ],
              ),
            ),
          ),

          // اللوح الزجاجي (Glass morphism) خلف اللوجو
          ClipOval(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
              child: Container(
                width: 134,
                height: 134,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.white.withOpacity(.08),
                      Colors.white.withOpacity(.015),
                      const Color(0xffba8220).withOpacity(.05),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // صورة اللوجو الأصلية (مفرّغة الخلفية)
          SizedBox(
            width: 92,
            height: 92,
            child: Image.asset(
              'images/logo.png',
              fit: BoxFit.contain,
            ),
          ),

          // لمعة منعكسة متحركة فوق الزجاج (specular highlight)
          ClipOval(
            child: IgnorePointer(
              child: Transform.translate(
                offset:
                Offset(-90 + (shineValue * 220), -90 + (shineValue * 180)),
                child: Transform.rotate(
                  angle: math.pi / 4,
                  child: Container(
                    width: 40,
                    height: 220,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.white.withOpacity(0),
                          Colors.white.withOpacity(.22),
                          Colors.white.withOpacity(0),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Blur Glow ─────────────────────────────────────────────────────────────────
class _BlurGlow extends StatelessWidget {
  final Alignment alignment;
  final double size;
  final Color color;
  const _BlurGlow({
    required this.alignment,
    required this.size,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: alignment,
      child: ImageFiltered(
        imageFilter: ImageFilter.blur(sigmaX: 40, sigmaY: 40),
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color,
          ),
        ),
      ),
    );
  }
}

// ── شبكة خلفية خفيفة جداً لإحساس فخامة تقنية ──────────────────────────────────
class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.6
      ..color = Colors.white.withOpacity(0.025);

    const step = 38.0;
    for (double x = 0; x <= size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y <= size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _GridPainter oldDelegate) => false;
}

// ── Loading Dots ──────────────────────────────────────────────────────────────
class _LoadingDots extends StatefulWidget {
  const _LoadingDots();

  @override
  State<_LoadingDots> createState() => _LoadingDotsState();
}

class _LoadingDotsState extends State<_LoadingDots>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (index) {
            final delay = index * .18;
            final t = ((_controller.value - delay) % 1.0).clamp(0.0, 1.0);
            final scale = 0.75 + (math.sin(t * math.pi) * .35);
            final opacity = 0.35 + (math.sin(t * math.pi) * .65);
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 2.5),
              child: Transform.scale(
                scale: scale,
                child: Opacity(
                  opacity: opacity,
                  child: Container(
                    width: 5,
                    height: 5,
                    decoration: const BoxDecoration(
                      color: Color(0xffdfbb62),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ),
            );
          }),
        );
      },
    );
  }
}