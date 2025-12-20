import 'package:flutter/material.dart';

/// Schwebender SOS-Button zur Auslösung eines Notrufs.
/// Der Button zeigt je nach Status eine pulsierende Animation
/// oder einen aktiven Zustand an.
class FloatingSOSButton extends StatefulWidget {
  /// Callback, der beim Drücken des SOS-Buttons ausgeführt wird.
  final VoidCallback onPressed;

  /// Gibt an, ob der Notruf aktuell aktiv ist.
  /// Bei aktivem Zustand wird die Animation deaktiviert und der Status visuell angepasst.
  final bool isActive;

  const FloatingSOSButton({
    Key? key,
    required this.onPressed,
    this.isActive = false,
  }) : super(key: key);

  @override
  State<FloatingSOSButton> createState() => _FloatingSOSButtonState();
}

class _FloatingSOSButtonState extends State<FloatingSOSButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            const Color(0xFFF5F5F5).withOpacity(0),
            const Color(0xFFF5F5F5),
          ],
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: AnimatedBuilder(
            animation: _scaleAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: widget.isActive ? 1.0 : _scaleAnimation.value,
                child: SizedBox(
                  width: double.infinity,
                  height: 72,
                  child: ElevatedButton(
                    onPressed: widget.onPressed,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE53935),
                      foregroundColor: Colors.white,
                      elevation: 8,
                      shadowColor: const Color(0xFFE53935).withOpacity(0.5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(36),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          widget.isActive ? Icons.check_circle : Icons.warning,
                          size: 32,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          widget.isActive ? 'Notruf aktiv' : 'SOS',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}