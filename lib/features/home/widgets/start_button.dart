import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../main/domain/background_service_controller.dart';

class StartButton extends StatefulWidget {
  final PingServiceController service;

  const StartButton({
    super.key,
    required this.service,
  });

  @override
  State<StartButton> createState() => _StartButtonState();
}

class _StartButtonState extends State<StartButton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _rotationAnimation;
  late Animation<double> _scaleAnimation;
  double scale = 1;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _rotationAnimation = Tween<double>(begin: 0, end: 45).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutQuint),
    );

    _scaleAnimation = Tween<double>(begin: 1, end: 1.6).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutQuint),
    );

    if (widget.service.isRunning.value) {
      _controller.value = 1.0;
    }

    widget.service.isRunning.addListener(_syncControllerWithService);
  }

  void _syncControllerWithService() {
    final targetValue = widget.service.isRunning.value ? 1.0 : 0.0;

    if (!_controller.isAnimating && _controller.value != targetValue) {
      _controller.value = targetValue;
    }
  }

  @override
  void dispose() {
    widget.service.isRunning.removeListener(_syncControllerWithService);
    _controller.dispose();
    super.dispose();
  }

  Future<void> _toggleSpringAnimation() async {
    if (!mounted) return;
    setState(() => scale = 0.9);
    await Future.delayed(const Duration(milliseconds: 125));
    if (!mounted) return;
    setState(() => scale = 1.0);
  }

  void _toggleAnimation() {
    debugPrint("tap");
    if (!widget.service.isRunning.value) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
  }

  Future<void> _handleToggle() async {
    try {
      await widget.service.toggle();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final appColors = Theme.of(context).extension<AppColors>()!;
    return ValueListenableBuilder(
      valueListenable: widget.service.isRunning,
      builder: (context, isRunning, child) {
        return Material(
          color: Colors.transparent,
          child: InkWell(
            overlayColor: WidgetStatePropertyAll(Colors.transparent),
            splashFactory: NoSplash.splashFactory,
            onTap: () {
              _toggleAnimation();
              _toggleSpringAnimation();
              _handleToggle();
            },
            child: Stack(
              children: [
                Positioned(
                  top: 25,
                  right: 25,
                  child: AnimatedBuilder(
                    animation: _controller,
                    builder: (context, child) {
                      return Transform(
                        transform: Matrix4.identity()
                          ..rotateZ(_rotationAnimation.value * 3.14159 / 180)
                          ..scale(_scaleAnimation.value),
                        alignment: Alignment.center,
                        child: child,
                      );
                    },
                    child: Container(
                      height: 100,
                      width: 100,
                      decoration: BoxDecoration(
                        color: appColors.mediumColor,
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                  ),
                ),
                AnimatedScale(
                  scale: scale,
                  duration: const Duration(milliseconds: 125),
                  curve: Curves.easeInOut,
                  child: Container(
                    height: 150,
                    width: 150,
                    decoration: BoxDecoration(
                      color: appColors.backColor,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Center(
                      child: AnimatedIcon(
                        icon: AnimatedIcons.play_pause,
                        progress: _controller,
                        size: 60,
                        color: appColors.accentColor,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}