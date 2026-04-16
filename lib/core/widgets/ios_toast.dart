import 'package:flutter/material.dart';

enum ToastType { success, error, warning }

class IosToast {
  static void show(
    BuildContext context, {
    required String message,
    required ToastType type,
  }) {
    late OverlayEntry entry;
    entry = OverlayEntry(
      builder: (context) => _IosToastWidget(
        message: message,
        type: type,
        onDismiss: () {
          entry.remove();
        },
      ),
    );
    Overlay.of(context).insert(entry);
  }
}

class _IosToastWidget extends StatefulWidget {
  final String message;
  final ToastType type;
  final VoidCallback onDismiss;

  const _IosToastWidget({
    required this.message,
    required this.type,
    required this.onDismiss,
  });

  @override
  State<_IosToastWidget> createState() => _IosToastWidgetState();
}

class _IosToastWidgetState extends State<_IosToastWidget> {
  bool _isPopped = false;
  bool _isExpanded = false;
  bool _isDisappearing = false;

  @override
  void initState() {
    super.initState();
    _playSequence();
  }

  Future<void> _playSequence() async {
    // 1. Apparition au centre
    await Future.delayed(const Duration(milliseconds: 50));
    if (!mounted) return;
    setState(() => _isPopped = true);

    // Attendre la fin du pop-in
    await Future.delayed(const Duration(milliseconds: 300));
    if (!mounted) return;

    // 2. Expansion
    setState(() => _isExpanded = true);

    // 3. Rester visible pendant 4 secondes
    await Future.delayed(const Duration(seconds: 4));
    if (!mounted) return;

    // 4. Shrink (réduction de la card vers l'icône)
    setState(() => _isExpanded = false);

    // Attendre la fin du shrink
    await Future.delayed(const Duration(milliseconds: 300));
    if (!mounted) return;

    // 5. Disparition vers le haut
    setState(() => _isDisappearing = true);

    // Attendre la fin de l'animation de slide
    await Future.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;

    widget.onDismiss();
  }

  Color get _backgroundColor {
    switch (widget.type) {
      case ToastType.success:
        return const Color(0xFFE8F5E9); // Vert doux (Aqua/mint)
      case ToastType.error:
        return const Color(0xFFFFEBEE); // Rouge doux
      case ToastType.warning:
        return const Color(0xFFFFF3E0); // Orange/Jaune doux
    }
  }

  Color get _iconColor {
    switch (widget.type) {
      case ToastType.success:
        return const Color(0xFF43A047);
      case ToastType.error:
        return const Color(0xFFE53935);
      case ToastType.warning:
        return const Color(0xFFFB8C00);
    }
  }

  IconData get _iconData {
    switch (widget.type) {
      case ToastType.success:
        return Icons.check_circle_rounded;
      case ToastType.error:
        return Icons.cancel_rounded;
      case ToastType.warning:
        return Icons.error_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Ignorer les clics pour que l'utilisateur puisse interagir avec l'app
    return IgnorePointer(
      child: Material(
        color: Colors.transparent,
        child: Stack(
          children: [
            AnimatedPositioned(
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeOutCubic,
              // Au début et à la fin: hors de l'écran en haut. Sinon: en haut avec marge.
              top: (!_isPopped || _isDisappearing)
                  ? (MediaQuery.of(context).padding.top - 100)
                  : (MediaQuery.of(context).padding.top + 16),
              left: 0,
              right: 0,
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 300),
                opacity: _isDisappearing ? 0.0 : (_isPopped ? 1.0 : 0.0),
                child: AnimatedScale(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOutBack,
                  scale: _isPopped ? 1.0 : 0.8,
                  child: Center(
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOutCubic,
                      constraints: const BoxConstraints(minHeight: 50),
                      decoration: BoxDecoration(
                        color: _backgroundColor,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 15,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Icon(_iconData, color: _iconColor, size: 24),
                          AnimatedSize(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOutCubic,
                            alignment: Alignment.centerLeft,
                            child: _isExpanded
                                ? AnimatedOpacity(
                                    duration: const Duration(milliseconds: 200),
                                    opacity: 1.0,
                                    child: Padding(
                                      padding: const EdgeInsets.only(
                                        left: 8.0,
                                        right: 4,
                                      ),
                                      child: ConstrainedBox(
                                        constraints: BoxConstraints(
                                          maxWidth:
                                              MediaQuery.of(
                                                context,
                                              ).size.width *
                                              0.7,
                                        ),
                                        child: Text(
                                          widget.message,
                                          style: TextStyle(
                                            color: _iconColor.withOpacity(0.9),
                                            fontWeight: FontWeight.w700,
                                            fontFamily: 'SF Pro',
                                            fontSize: 15,
                                            height: 1.2,
                                          ),
                                        ),
                                      ),
                                    ),
                                  )
                                : const SizedBox(width: 0, height: 24),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
