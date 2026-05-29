import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'role_view.dart'; // Pastikan import ini mengarah ke file RoleView Anda

class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView> with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _textController;
  late AnimationController _taglineController;
  late AnimationController _btnController;

  // Kontroler gelombang
  late AnimationController _waveHeightController;
  late AnimationController _waveRippleController;

  late Animation<double> _logoScale;
  late Animation<double> _logoOpacity;
  late Animation<double> _textOpacity;
  late Animation<Offset> _textSlide;
  late Animation<double> _taglineOpacity;
  late Animation<double> _btnOpacity;

  late Animation<double> _waveHeightAnimation;

  @override
  void initState() {
    super.initState();

    // 1. Kontroler tinggi gelombang (Naik sekali saja lalu stack di atas)
    _waveHeightController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    );

    _waveHeightAnimation = Tween<double>(begin: 0.0, end: 0.42).animate(
      CurvedAnimation(
        parent: _waveHeightController,
        curve: Curves.easeOutCubic, 
      ),
    );

    // 2. Kontroler riak air (Looping bergoyang konstan)
    _waveRippleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();

    // Animasi komponen UI
    _logoController = AnimationController(vsync: this, duration: const Duration(milliseconds: 900));
    _logoScale = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.elasticOut),
    );
    _logoOpacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _logoController, curve: const Interval(0, 0.5)),
    );

    _textController = AnimationController(vsync: this, duration: const Duration(milliseconds: 700));
    _textOpacity = Tween<double>(begin: 0, end: 1).animate(_textController);
    _textSlide = Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
      CurvedAnimation(parent: _textController, curve: Curves.easeOut),
    );

    _taglineController = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
    _taglineOpacity = Tween<double>(begin: 0, end: 1).animate(_taglineController);

    _btnController = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
    _btnOpacity = Tween<double>(begin: 0, end: 1).animate(_btnController);

    _startAnimation();
  }

  Future<void> _startAnimation() async {
    _waveHeightController.forward(); // Jalankan gelombang naik

    await Future.delayed(const Duration(milliseconds: 400));
    await _logoController.forward();
    await Future.delayed(const Duration(milliseconds: 200));
    await _textController.forward();
    await Future.delayed(const Duration(milliseconds: 200));
    await _taglineController.forward();
    await Future.delayed(const Duration(milliseconds: 400));
    await _btnController.forward();
  }

  @override
  void dispose() {
    _logoController.dispose();
    _textController.dispose();
    _taglineController.dispose();
    _btnController.dispose();
    _waveHeightController.dispose();
    _waveRippleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F9FC),
      body: SizedBox(
        width: double.infinity,
        height: double.infinity,
        child: Stack(
          children: [
            // LAPISAN 1 (PALING BELAKANG): Animasi Gelombang Air Biru
            Positioned.fill(
              child: AnimatedBuilder(
                animation: _waveHeightController,
                builder: (context, child) {
                  return Align(
                    alignment: Alignment.bottomCenter,
                    child: SizedBox(
                      width: double.infinity,
                      height: MediaQuery.of(context).size.height * _waveHeightAnimation.value,
                      child: AnimatedBuilder(
                        animation: _waveRippleController,
                        builder: (context, child) {
                          return Stack(
                            children: [
                              // Gelombang belakang
                              ClipPath(
                                clipper: WaveClipper(_waveRippleController.value, 0.0),
                                child: Container(
                                  decoration: const BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      colors: [Color(0x9900B4D8), Color(0xCC0077B6)],
                                    ),
                                  ),
                                ),
                              ),
                              // Gelombang depan
                              ClipPath(
                                clipper: WaveClipper(_waveRippleController.value, math.pi),
                                child: Container(
                                  decoration: const BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      colors: [Color(0xFF00B4D8), Color(0xFF0077B6), Color(0xFF023E8A)],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  );
                },
              ),
            ),

            // LAPISAN 2 (PALING DEPAN): Seluruh Konten Teks, Logo, dan Tombol Utama
            // Menggunakan Positioned.fill agar membungkus sempurna di atas lapisan gelombang
            Positioned.fill(
              child: SafeArea(
                child: Column(
                  children: [
                    const Spacer(flex: 2),

                    // Logo icon
                    AnimatedBuilder(
                      animation: _logoController,
                      builder: (_, __) => Opacity(
                        opacity: _logoOpacity.value,
                        child: Transform.scale(
                          scale: _logoScale.value,
                          child: Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(32),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF0077B6).withOpacity(0.15),
                                  blurRadius: 20,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            padding: const EdgeInsets.all(12),
                            child: Image.asset(
                              'assets/Alirin logo.png',
                              fit: BoxFit.contain,
                              errorBuilder: (_, __, ___) => const Icon(
                                Icons.water_drop,
                                size: 70,
                                color: Color(0xFF0077B6),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // App name text
                    AnimatedBuilder(
                      animation: _textController,
                      builder: (_, __) => SlideTransition(
                        position: _textSlide,
                        child: Opacity(
                          opacity: _textOpacity.value,
                          child: Image.asset(
                            'assets/Alirin.png',
                            height: 55,
                            fit: BoxFit.contain,
                            errorBuilder: (_, __, ___) => const Text(
                              'Alirin',
                              style: TextStyle(
                                fontSize: 44,
                                fontWeight: FontWeight.w900,
                                color: Color(0xFF023E8A),
                                letterSpacing: 1,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Tagline
                    AnimatedBuilder(
                      animation: _taglineController,
                      builder: (_, __) => Opacity(
                        opacity: _taglineOpacity.value,
                        child: Column(
                          children: [
                            const Text(
                              'Sistem Informasi PDAM',
                              style: TextStyle(
                                fontSize: 16,
                                color: Color(0xFF0077B6),
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Air bersih untuk semua',
                              style: TextStyle(
                                fontSize: 13,
                                color: const Color(0xFF023E8A).withOpacity(0.6),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const Spacer(flex: 3),

                    // Bagian Tombol Mulai Sekarang
                    AnimatedBuilder(
                      animation: _btnController,
                      builder: (_, __) => Opacity(
                        opacity: _btnOpacity.value,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 40),
                          child: Column(
                            children: [
                              _buildGetStartedButton(),
                              const SizedBox(height: 20),
                              _buildWaveDecor(),
                            ],
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGetStartedButton() {
    return InkWell( // Mengganti GestureDetector ke InkWell agar ada efek riak sentuh saat diklik
      onTap: () {
        // Navigasi mutlak menggunakan bawaan Flutter (Menjamin tidak macet akibat problem GetX)
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const RoleView()),
          (route) => false, // Menghapus halaman splash screen dari memori HP
        );
      },
      splashColor: const Color(0xFF0077B6).withOpacity(0.1),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: double.infinity,
        height: 56,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.12),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.water_drop, color: Color(0xFF0077B6), size: 22),
            const SizedBox(width: 10),
            const Text(
              'Mulai Sekarang',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Color(0xFF023E8A),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: const Color(0xFF0077B6).withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Icon(Icons.arrow_forward, color: Color(0xFF0077B6), size: 16),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWaveDecor() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        5,
        (i) => Container(
          margin: const EdgeInsets.symmetric(horizontal: 3),
          width: i == 2 ? 24 : 8,
          height: 4,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(i == 2 ? 0.9 : 0.4),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ),
    );
  }
}

class WaveClipper extends CustomClipper<Path> {
  final double animationValue;
  final double wavePhase;

  WaveClipper(this.animationValue, this.wavePhase);

  @override
  Path getClip(Size size) {
    Path path = Path();
    path.lineTo(0, size.height);

    for (double i = 0; i <= size.width; i++) {
      double angle = (animationValue * 2 * math.pi) + (i / size.width * 2 * math.pi) + wavePhase;
      double y = math.sin(angle) * 12; 
      path.lineTo(i, y + 20); 
    }

    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => true;
}