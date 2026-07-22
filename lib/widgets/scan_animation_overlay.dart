import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rive/rive.dart' as rive;
import '../models/recipe.dart';

class ScanAnimationOverlay extends StatefulWidget {
  final List<RecipeIngredient>? detectedIngredients;
  final List<Recipe>? generatedRecipes;
  final VoidCallback onAnimationComplete;
  final String? imagePath;
  final bool showTestControls;

  const ScanAnimationOverlay({
    super.key,
    required this.detectedIngredients,
    required this.generatedRecipes,
    required this.onAnimationComplete,
    this.imagePath,
    this.showTestControls = false,
  });

  @override
  State<ScanAnimationOverlay> createState() => _ScanAnimationOverlayState();
}

class _ScanAnimationOverlayState extends State<ScanAnimationOverlay> {
  rive.FileLoader? _fileLoader;
  rive.StateMachine? _stateMachine;
  Timer? _minDurationTimer;
  bool _minDurationElapsed = false;

  @override
  void initState() {
    super.initState();
    _loadRiveFile();

    if (!widget.showTestControls) {
      // In production mode, play the full Rive animation for at least 5 seconds
      _minDurationTimer = Timer(const Duration(seconds: 5), () {
        if (mounted) {
          setState(() {
            _minDurationElapsed = true;
          });
          _checkCompletion();
        }
      });
    }
  }

  Future<void> _loadRiveFile() async {
    try {
      final file = await rive.File.asset(
        'assets/onboarding/cooked.riv',
        assetLoader: _loadRiveAsset,
      );
      if (mounted && file != null) {
        setState(() {
          _fileLoader = rive.FileLoader.fromFile(file);
        });
      }
    } catch (e) {
      debugPrint("RIVE_LOAD_ERROR: $e");
    }
  }

  bool _loadRiveAsset(rive.FileAsset fileAsset, Uint8List? bytes) {
    if (fileAsset is rive.FontAsset) {
      debugPrint("RIVE_ASSET_LOADER: Encountered FontAsset: ${fileAsset.name}.${fileAsset.fileExtension}");
      // Asynchronously load the custom font from our asset bundle
      rootBundle.load('assets/fonts/Larken/Larken Bold-6264325.ttf').then((fontData) async {
        final fontBytes = fontData.buffer.asUint8List();
        final success = await fileAsset.decode(fontBytes);
        debugPrint("RIVE_ASSET_LOADER: Decoded font ${fileAsset.name} success: $success");
      }).catchError((e) {
        debugPrint("RIVE_ASSET_LOADER: Error decoding font ${fileAsset.name}: $e");
      });
      return true; // Return true to indicate we are handling it
    }
    return false; // Let Rive handle other assets (e.g. embedded images)
  }

  void _updateRiveInputs() {
    if (_stateMachine == null) return;

    final isReady = widget.generatedRecipes != null && widget.generatedRecipes!.isNotEmpty;
    debugPrint("RIVE_INPUT_UPDATE: Checking inputs for ready state: $isReady");

    try {
      // We check for common boolean and trigger input names to advance/manipulate the state machine
      final doneInput = _stateMachine!.boolean('isDone') ??
                        _stateMachine!.boolean('ready') ??
                        _stateMachine!.boolean('success') ??
                        _stateMachine!.boolean('isScanning');
      
      final isScanningInput = _stateMachine!.boolean('isScanning');
      if (isScanningInput != null) {
        isScanningInput.value = !isReady;
        debugPrint("RIVE_INPUT_UPDATE: Set isScanning = ${!isReady}");
      }

      if (doneInput != null && doneInput.name != 'isScanning') {
        doneInput.value = isReady;
        debugPrint("RIVE_INPUT_UPDATE: Set ${doneInput.name} = $isReady");
      }

      final triggerInput = _stateMachine!.trigger('triggerDone') ??
                           _stateMachine!.trigger('complete') ??
                           _stateMachine!.trigger('done');
      if (triggerInput != null && isReady) {
        triggerInput.fire();
        debugPrint("RIVE_INPUT_UPDATE: Fired trigger ${triggerInput.name}");
      }
    } catch (e) {
      debugPrint("RIVE_INPUT_UPDATE_ERROR: $e");
    }
  }

  void _checkCompletion() {
    if (widget.showTestControls) return;
    if (_minDurationElapsed &&
        widget.generatedRecipes != null &&
        widget.generatedRecipes!.isNotEmpty) {
      widget.onAnimationComplete();
    }
  }

  @override
  void didUpdateWidget(ScanAnimationOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    _updateRiveInputs();
    if (!widget.showTestControls) {
      _checkCompletion();
    }
  }

  @override
  void dispose() {
    _minDurationTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Rive animation taking up the FULL SCREEN
          Positioned.fill(
            child: _fileLoader == null
                ? const Center(
                    child: CircularProgressIndicator(
                      color: Color(0xFFC83A2D),
                    ),
                  )
                : rive.RiveWidgetBuilder(
                    fileLoader: _fileLoader!,
                    onLoaded: (riveLoadedState) {
                      final controller = riveLoadedState.controller;
                      _stateMachine = controller.stateMachine;
                      debugPrint("RIVE_STATE_MACHINE: Loaded StateMachine '${_stateMachine!.name}'");
                      try {
                        final file = File('/home/ousseynou_diedhiou/Bureau/Nixacom/cooked/mobile/lib/widgets/rive_inputs_debug.txt');
                        final sink = file.openWrite();
                        sink.writeln("StateMachine: ${_stateMachine!.name}");
                        for (var input in _stateMachine!.inputs) {
                          sink.writeln("Input: ${input.name} (type: ${input.runtimeType})");
                        }
                        sink.close();
                      } catch (e) {
                        debugPrint("RIVE_DEBUG_WRITE_ERROR: $e");
                      }
                      _updateRiveInputs();
                    },
                    builder: (context, state) => switch (state) {
                      rive.RiveLoaded() => rive.RiveWidget(
                          controller: state.controller,
                          fit: rive.Fit.cover,
                        ),
                      rive.RiveFailed() => const Center(
                          child: Text(
                            'Error loading animation',
                            style: TextStyle(color: Colors.black54),
                          ),
                        ),
                      _ => const Center(
                          child: CircularProgressIndicator(
                            color: Color(0xFFC83A2D),
                          ),
                        ),
                    },
                  ),
          ),

          // Test controls on top, if enabled (commented out)
          /*
          if (widget.showTestControls) ...[
            // Top Left Close button
            Positioned(
              top: MediaQuery.of(context).padding.top + 10.h,
              left: 10.w,
              child: IconButton(
                icon: Icon(
                  Icons.close,
                  color: const Color(0xFF1E293B),
                  size: 28.sp,
                ),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            // Top Right Next button
            Positioned(
              top: MediaQuery.of(context).padding.top + 10.h,
              right: 20.w,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  GestureDetector(
                    onTap: widget.onAnimationComplete,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 14.w,
                        vertical: 8.h,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFC83A2D),
                        borderRadius: BorderRadius.circular(20.r),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFC83A2D).withValues(alpha: 0.3),
                            blurRadius: 8.r,
                            offset: Offset(0, 3.h),
                          ),
                        ],
                      ),
                      child: Text(
                        "Next",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 13.sp,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'SF Pro',
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          */
        ],
      ),
    );
  }
}
