import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math' as math;
import '../services/shake_service.dart';

class ShakeDetectorWidget extends StatefulWidget {
  final Function(bool) onShakeDetected;
  final bool isEnabled;
  final int requiredShakes; // Number of shakes required to get voucher

  const ShakeDetectorWidget({
    super.key,
    required this.onShakeDetected,
    this.isEnabled = true,
    this.requiredShakes = 20, // Default 20 shakes (increased from 10)
  });

  @override
  State<ShakeDetectorWidget> createState() => _ShakeDetectorWidgetState();
}

class _ShakeDetectorWidgetState extends State<ShakeDetectorWidget>
    with TickerProviderStateMixin {
  final ShakeService _shakeService = ShakeService.instance;
  StreamSubscription<bool>? _shakeSubscription;
  late AnimationController _animationController;
  late AnimationController _progressAnimationController;
  late AnimationController _waveAnimationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _waveAnimation;
  bool _isShaking = false;
  int _shakeCount = 0;
  Timer? _resetTimer;
  static const Duration _resetDuration = Duration(seconds: 5); // Reset after 5s of inactivity (increased from 3s)

  @override
  void initState() {
    super.initState();
    
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _progressAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _waveAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat();

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _waveAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _waveAnimationController, curve: Curves.linear),
    );

    if (widget.isEnabled) {
      _startListening();
    }
  }

  void _startListening() {
    _shakeService.startListening();
    _shakeSubscription = _shakeService.shakeStream.listen((shakeDetected) {
      if (shakeDetected && widget.isEnabled && mounted) {
        _handleShake();
      }
    });
  }

  void _handleShake() {
    setState(() {
      _shakeCount++;
      _isShaking = true;
    });

    // Animate
    _animationController.forward().then((_) {
      _animationController.reverse();
    });

    // Progress animation
    _progressAnimationController.forward(from: 0.0);

    // Reset timer
    _resetTimer?.cancel();
    _resetTimer = Timer(_resetDuration, () {
      if (mounted && _shakeCount < widget.requiredShakes) {
        setState(() => _shakeCount = 0);
      }
    });

    // Check if goal reached
    if (_shakeCount >= widget.requiredShakes) {
      _shakeSubscription?.cancel();
      widget.onShakeDetected(true);
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          setState(() {
            _isShaking = false;
            _shakeCount = 0;
          });
        }
      });
    } else {
      Future.delayed(const Duration(milliseconds: 200), () {
        if (mounted) setState(() => _isShaking = false);
      });
    }
  }

  @override
  void didUpdateWidget(ShakeDetectorWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isEnabled != oldWidget.isEnabled) {
      if (widget.isEnabled) {
        _startListening();
      } else {
        _stopListening();
      }
    }
  }

  void _stopListening() {
    _shakeSubscription?.cancel();
    _resetTimer?.cancel();
    _shakeService.stopListening();
  }

  @override
  void dispose() {
    _stopListening();
    _animationController.dispose();
    _progressAnimationController.dispose();
    _waveAnimationController.dispose();
    super.dispose();
  }

  double get _progress => _shakeCount / widget.requiredShakes;

  @override
  Widget build(BuildContext context) {
    final progress = _progress.clamp(0.0, 1.0);
    final isComplete = _shakeCount >= widget.requiredShakes;
    final percentage = (progress * 100).toInt();

    return GestureDetector(
      onTap: () {
        _showShakeDialog(context, progress, isComplete, percentage);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 32),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isComplete
                ? [const Color(0xFF4CAF50), const Color(0xFF2E7D32)]
                : [const Color(0xFF2196F3), const Color(0xFF1565C0)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: (isComplete ? Colors.green : const Color(0xFF2196F3))
                  .withValues(alpha: 0.3),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isComplete ? Icons.celebration : Icons.phone_android,
              size: 40,
              color: Colors.white,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    isComplete ? 'SELAMAT! 🎉' : 'TAP UNTUK MULAI',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    isComplete
                        ? 'Voucher berhasil didapat!'
                        : 'Goyangkan HP untuk voucher',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.9),
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            if (!isComplete && _shakeCount > 0)
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '$percentage%',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _showShakeDialog(BuildContext context, double progress, bool isComplete, int percentage) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext dialogContext) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: AnimatedBuilder(
            animation: _scaleAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _scaleAnimation.value,
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: isComplete
                          ? [const Color(0xFF4CAF50), const Color(0xFF2E7D32)]
                          : _isShaking
                              ? [const Color(0xFFFFD700), const Color(0xFFFF8C00)]
                              : [const Color(0xFF2196F3), const Color(0xFF1565C0)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: (isComplete
                                ? Colors.green
                                : _isShaking
                                    ? Colors.orange
                                    : const Color(0xFF2196F3))
                            .withValues(alpha: 0.5),
                        blurRadius: 30,
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isComplete
                            ? Icons.celebration
                            : _isShaking
                                ? Icons.vibration
                                : Icons.phone_android,
                        size: 60,
                        color: Colors.white,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        isComplete
                            ? 'SELAMAT! 🎉'
                            : _isShaking
                                ? 'TERUS KOCOK!'
                                : 'KOCOK HANDPHONE!',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        isComplete
                            ? 'Voucher berhasil didapat!'
                            : 'Goyangkan HP untuk voucher gratis!',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.9),
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 24),
                      // Circular Progress
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          AnimatedBuilder(
                            animation: _waveAnimation,
                            builder: (context, child) {
                              return Container(
                                width: 140,
                                height: 140,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white.withValues(
                                      alpha: 0.3 * (1 - _waveAnimation.value),
                                    ),
                                    width: 2,
                                  ),
                                ),
                                transform: Matrix4.identity()
                                  ..scale(0.8 + (_waveAnimation.value * 0.4)),
                              );
                            },
                          ),
                          SizedBox(
                            width: 120,
                            height: 120,
                            child: AnimatedBuilder(
                              animation: _progressAnimationController,
                              builder: (context, child) {
                                return CustomPaint(
                                  painter: _CircularProgressPainter(
                                    progress: progress,
                                    animationValue: _progressAnimationController.value,
                                    isShaking: _isShaking,
                                  ),
                                );
                              },
                            ),
                          ),
                          Text(
                            '$percentage%',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      if (_shakeCount > 0 && _shakeCount < widget.requiredShakes) ...[
                        const SizedBox(height: 16),
                        Text(
                          'Lanjutkan! ${100 - percentage}% lagi',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.8),
                            fontSize: 12,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                      const SizedBox(height: 16),
                      TextButton(
                        onPressed: () => Navigator.of(dialogContext).pop(),
                        child: Text(
                          'Tutup',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.8),
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}

// Custom painter for circular progress with animations
class _CircularProgressPainter extends CustomPainter {
  final double progress;
  final double animationValue;
  final bool isShaking;

  _CircularProgressPainter({
    required this.progress,
    required this.animationValue,
    required this.isShaking,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Background circle
    final bgPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius - 6, bgPaint);

    // Progress arc with gradient effect
    final progressPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Colors.white, Color(0xFFFFD700)],
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12
      ..strokeCap = StrokeCap.round;

    // Draw progress arc
    final sweepAngle = 2 * math.pi * progress;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius - 6),
      -math.pi / 2,
      sweepAngle,
      false,
      progressPaint,
    );

    // Draw pulsing dots at progress point when shaking
    if (isShaking && progress > 0) {
      final angle = -math.pi / 2 + sweepAngle;
      final dotX = center.dx + (radius - 6) * math.cos(angle);
      final dotY = center.dy + (radius - 6) * math.sin(angle);

      final dotPaint = Paint()
        ..color = Colors.white.withValues(alpha: 1 - animationValue)
        ..style = PaintingStyle.fill;

      canvas.drawCircle(
        Offset(dotX, dotY),
        6 + (6 * animationValue),
        dotPaint,
      );
    }
  }

  @override
  bool shouldRepaint(_CircularProgressPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.animationValue != animationValue ||
        oldDelegate.isShaking != isShaking;
  }
}
