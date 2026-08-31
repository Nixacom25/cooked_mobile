import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:rive/rive.dart' hide LinearGradient, Image;
import '../models/recipe.dart';

class ScanAnimationOverlay extends StatefulWidget {
  final List<RecipeIngredient>? detectedIngredients;
  final List<Recipe>? generatedRecipes;
  final VoidCallback onAnimationComplete;
  final String? imagePath;
  final bool showTestControls;

  const ScanAnimationOverlay({
    super.key,
    this.detectedIngredients,
    this.generatedRecipes,
    required this.onAnimationComplete,
    this.imagePath,
    this.showTestControls = false,
  });

  @override
  State<ScanAnimationOverlay> createState() => _ScanAnimationOverlayState();
}

class _ScanAnimationOverlayState extends State<ScanAnimationOverlay> {
  Artboard? _riveArtboard;
  String? _errorMessage;
  Timer? _completionTimer;

  @override
  void initState() {
    super.initState();
    _loadRiveFile();
    if (!widget.showTestControls) {
      _checkCompletion();
    }
  }

  @override
  void didUpdateWidget(ScanAnimationOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!widget.showTestControls) {
      _checkCompletion();
    }
  }

  Future<void> _loadRiveFile() async {
    try {
      final bytes = await rootBundle.load('assets/cooked.riv');
      final file = RiveFile.import(
        bytes,
        assetLoader: CallbackAssetLoader((asset, bytes) async {
          // Returning false allows Rive to decode embedded graphics and font assets!
          return false;
        }),
      );
      
      final artboard = file.artboardByName('MAIN') ?? file.mainArtboard;

      final smName = artboard.stateMachines.isNotEmpty
          ? artboard.stateMachines.first.name
          : 'State Machine 1';
      final controller = StateMachineController.fromArtboard(
        artboard,
        smName,
        onStateChange: (stateMachineName, stateName) {
          debugPrint('RIVE_STATE_CHANGE: $stateMachineName -> $stateName');
        },
      );
      if (controller != null) {
        artboard.addController(controller);
      } else if (artboard.animations.isNotEmpty) {
        artboard.addController(
          SimpleAnimation(artboard.animations.first.name),
        );
      }

      if (mounted) {
        setState(() {
          _riveArtboard = artboard;
        });
      }
    } catch (e, stack) {
      debugPrint('RIVE_LOAD_ERROR: $e\n$stack');
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
        });
      }
    }
  }

  void _checkCompletion() {
    if (widget.generatedRecipes != null && widget.generatedRecipes!.isNotEmpty) {
      _completionTimer?.cancel();
      // Allow full Rive animation cycle (25 seconds) to play completely without cutting off early
      _completionTimer = Timer(const Duration(seconds: 25), () {
        if (mounted) {
          widget.onAnimationComplete();
        }
      });
    }
  }

  @override
  void dispose() {
    _completionTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: Colors.white,
      child: Stack(
        children: [
          Positioned.fill(
            child: _errorMessage != null
                ? Center(
                    child: Padding(
                      padding: EdgeInsets.all(24.w),
                      child: Text(
                        "Erreur Rive: $_errorMessage",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.red,
                          fontSize: 14.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  )
                : _riveArtboard != null
                    ? Rive(
                        artboard: _riveArtboard!,
                        fit: BoxFit.contain,
                        antialiasing: true,
                      )
                    : const Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFFC83A2D),
                        ),
                      ),
          ),
          if (widget.showTestControls)
            Positioned(
              top: MediaQuery.of(context).padding.top + 10.h,
              right: 20.w,
              child: GestureDetector(
                onTap: widget.onAnimationComplete,
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 14.w,
                    vertical: 8.h,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black87,
                    borderRadius: BorderRadius.circular(16.r),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 6.r,
                        offset: Offset(0, 3.h),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.close, color: Colors.white, size: 16.sp),
                      SizedBox(width: 6.w),
                      Text(
                        "Fermer",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12.sp,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'SF Pro',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
