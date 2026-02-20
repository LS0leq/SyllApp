import 'dart:math';
import 'package:flutter/material.dart';





class AnimatedAuthBackground extends StatefulWidget {
  const AnimatedAuthBackground({super.key});

  @override
  State<AnimatedAuthBackground> createState() =>
      _AnimatedAuthBackgroundState();
}

class _AnimatedAuthBackgroundState extends State<AnimatedAuthBackground>
    with TickerProviderStateMixin {
  late final AnimationController _bgController;
  late final AnimationController _particleController;

  @override
  void initState() {
    super.initState();
    _bgController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();

    _particleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();
  }

  @override
  void dispose() {
    _bgController.dispose();
    _particleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Stack(
      children: [
        
        Positioned.fill(
          child: RepaintBoundary(
            child: AnimatedBuilder(
              animation: _bgController,
              builder: (_, _) => CustomPaint(
                painter: _GradientBackgroundPainter(
                  progress: _bgController.value,
                ),
              ),
            ),
          ),
        ),

        
        Positioned.fill(
          child: RepaintBoundary(
            child: AnimatedBuilder(
              animation: _particleController,
              builder: (_, _) => CustomPaint(
                painter: _ParticlePainter(
                  progress: _particleController.value,
                  size: size,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}






class _GradientBackgroundPainter extends CustomPainter {
  final double progress;
  _GradientBackgroundPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    
    canvas.drawRect(
      Offset.zero & size,
      Paint()..color = const Color(0xFF0A0A0F),
    );

    final angle = progress * 2 * pi;

    
    _drawBlob(
      canvas,
      Offset(
        size.width * 0.7 + cos(angle) * size.width * 0.15,
        size.height * 0.25 + sin(angle) * size.height * 0.1,
      ),
      size.width * 0.6, 
      const Color(0xFF007ACC).withValues(alpha: 0.18),
    );

    
    _drawBlob(
      canvas,
      Offset(
        size.width * 0.25 + cos(angle + pi) * size.width * 0.12,
        size.height * 0.7 + sin(angle + pi * 0.7) * size.height * 0.08,
      ),
      size.width * 0.55,
      const Color(0xFF6C63FF).withValues(alpha: 0.14),
    );

    
    _drawBlob(
      canvas,
      Offset(
        size.width * 0.5 + sin(angle * 0.7) * size.width * 0.2,
        size.height * 0.45 + cos(angle * 1.3) * size.height * 0.15,
      ),
      size.width * 0.45,
      const Color(0xFF4EC9B0).withValues(alpha: 0.06),
    );
  }

  void _drawBlob(Canvas canvas, Offset center, double radius, Color color) {
    
    
    final paint = Paint()
      ..shader = RadialGradient(
        colors: [color, color.withValues(alpha: 0)],
        stops: const [0.0, 1.0], 
      ).createShader(Rect.fromCircle(center: center, radius: radius));
      
    canvas.drawCircle(center, radius, paint);
  }

  @override
  bool shouldRepaint(_GradientBackgroundPainter old) =>
      old.progress != progress;
}


class _ParticlePainter extends CustomPainter {
  final double progress;
  final Size size;
  _ParticlePainter({required this.progress, required this.size});

  static final List<_Particle> _particles = List.generate(
    18,
    (i) => _Particle(
      x: (i * 7.31 % 1),
      y: (i * 3.79 % 1),
      radius: 1.2 + (i % 4) * 0.6,
      speed: 0.3 + (i % 5) * 0.15,
      drift: (i.isEven ? 1 : -1) * (0.02 + (i % 3) * 0.01),
      phase: i * 0.35,
      alpha: 0.12 + (i % 4) * 0.06,
    ),
  );

  @override
  void paint(Canvas canvas, Size canvasSize) {
    final w = canvasSize.width;
    final h = canvasSize.height;

    
    
    
    for (final p in _particles) {
      final yPos =
          (p.y + progress * p.speed + sin(progress * 4 * pi + p.phase) * 0.02) %
              1.0;
      final xPos = p.x + sin(progress * 2 * pi + p.phase) * p.drift * 3;
      final alpha = p.alpha * (0.5 + 0.5 * sin(progress * 2 * pi + p.phase));

      if (alpha <= 0.01) continue;

      canvas.drawCircle(
        Offset(xPos * w, yPos * h),
        p.radius,
        Paint()
          ..color = Colors.white.withValues(alpha: alpha)
          
          
      );
    }
  }

  @override
  bool shouldRepaint(_ParticlePainter old) => old.progress != progress;
}

class _Particle {
  final double x, y, radius, speed, drift, phase, alpha;
  const _Particle({
    required this.x,
    required this.y,
    required this.radius,
    required this.speed,
    required this.drift,
    required this.phase,
    required this.alpha,
  });
}
