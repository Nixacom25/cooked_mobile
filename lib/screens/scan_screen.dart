import 'dart:io';
import 'dart:ui' as ui;
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:camera/camera.dart';
import 'package:permission_handler/permission_handler.dart';
import '../routes/app_routes.dart';
import '../core/utils/error_helper.dart';
import '../services/ingredient_service.dart';
import '../services/recipe_service.dart';
import '../widgets/skeleton_loader.dart';
import '../widgets/glass_icon_button.dart';
import '../widgets/loading_text.dart';
import '../widgets/app_loading_indicator.dart';
import '../widgets/skeleton_list.dart';
import '../widgets/add_to_cookbook_sheet.dart';
import '../models/recipe.dart';
import '../core/widgets/ios_toast.dart';
import '../core/services/tutorial_service.dart';
import '../core/utils/tutorial_helper.dart';
import '../core/extensions/string_extensions.dart';
import '../utils/paywall_helper.dart';
import '../widgets/scan_animation_overlay.dart';
import '../widgets/red_header_background.dart';

enum ScanState { scan, type, saved, results }


class ScanScreen extends StatefulWidget {
  final ValueNotifier<bool> isActiveNotifier;
  final ValueNotifier<bool>? isResultsModeNotifier;
  final Function(int)? onTabSwitch;
  final VoidCallback? onClose;

  const ScanScreen({
    super.key,
    required this.isActiveNotifier,
    this.isResultsModeNotifier,
    this.onTabSwitch,
    this.onClose,
  });
  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> with TickerProviderStateMixin {
  ScanState _state = ScanState.scan;
  bool _showingSuccessMessage = false;
  final TextEditingController _ingCtrl = TextEditingController();
  final List<String> _typedIngredients = [];
  List<Map<String, dynamic>> _savedIngredients = [];
  final Set<String> _selectedSavedNames = {};
  bool _isLoadingSaved = false;
  bool _useAllSaved = false;
  List<Map<String, dynamic>> _recentIngredients = [];
  List<Map<String, dynamic>> _suggestedIngredients = [];
  Timer? _searchDebounce;

  final List<RecipeIngredient> _ingredients = [];
  final List<RecipeIngredient> _restrictedIngredients = [];
  final List<Recipe> _recipes = [];
  final Set<String> _savedRecipeNames = {};
  final PageController _resultPageController = PageController();
  int _currentResultPage = 0;

  // GlobalKeys for tutorial
  final GlobalKey _shutterKey = GlobalKey();
  final GlobalKey _typeTabKey = GlobalKey();

  // LIVE CAMERA Logic
  CameraController? _cameraController;
  bool _isCameraInitialized = false;
  bool _isInitializing = false;
  String _cameraStatus = "Initializing...";
  bool _hasCameraError = false;
  bool _useManualStreaming = false;
  DateTime? _lastInitAttempt;

  // Software Rendering Logic
  DateTime? _lastFrameTime;
  ui.Image? _decodedFrame;
  bool _isProcessingFrame = false;

  // Placeholder background for scan simulation
  String? _capturedImagePath;

  // Analysis Loading state
  Timer? _analysisTimer;

  // Scan Animation Overlay state
  bool _showAnimationOverlay = false;
  List<RecipeIngredient>? _overlayDetectedIngredients;
  List<Recipe>? _overlayGeneratedRecipes;

  late final AnimationController _scannerController;

  void _updateState(ScanState newState) {
    if (!mounted) return;
    if (_state != newState) HapticFeedback.selectionClick();
    setState(() {
      _state = newState;
    });
    if (newState == ScanState.scan && _isCameraInitialized && _cameraController != null) {
      _cameraController!.resumePreview().catchError((_) {});
    }
    widget.isResultsModeNotifier?.value = (newState == ScanState.results);
  }

  @override
  void initState() {
    super.initState();
    _scannerController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    widget.isActiveNotifier.addListener(_onActiveStateChanged);
    _ingCtrl.addListener(_onIngChanged);
    _fetchSavedIngredients();
    _fetchRecentIngredients();

    // Sync saved recipes status
    RecipeService.instance.myRecipesNotifier.addListener(_onRecipesChanged);
    _onRecipesChanged();
    // Pre-fetch if null to ensure we have the data
    if (RecipeService.instance.myRecipesNotifier.value == null) {
      RecipeService.instance.getMyRecipes().catchError((_) => <Recipe>[]);
    }

    if (widget.isActiveNotifier.value) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _initCamera());
    } else {
      _cameraStatus = "On hold";
    }
  }

  void _onIngChanged() {
    final query = _ingCtrl.text.trim();
    if (_searchDebounce?.isActive ?? false) _searchDebounce!.cancel();

    if (query.isEmpty) {
      setState(() => _suggestedIngredients = []);
      return;
    }

    _searchDebounce = Timer(const Duration(milliseconds: 150), () async {
      final results = await IngredientService.instance.searchIngredients(query);
      if (mounted) setState(() => _suggestedIngredients = results);
    });
  }

  Future<void> _fetchRecentIngredients() async {
    try {
      final names = await IngredientService.instance.getRecentTypedIngredients();
      if (mounted) {
        setState(() {
          _recentIngredients = names.map((name) => {'name': name, 'icon': '🥕'}).toList();
        });
      }
    } catch (_) {}
  }

  void _onRecipesChanged() {
    if (!mounted) return;
    final recipes = RecipeService.instance.myRecipesNotifier.value;
    if (recipes != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        setState(() {
          _savedRecipeNames.clear();
          _savedRecipeNames.addAll(recipes.map((r) => r.name));
        });
      });
    }
  }

  Future<void> _fetchSavedIngredients() async {
    setState(() => _isLoadingSaved = true);
    try {
      final items = await IngredientService.instance.getSavedIngredients();
      if (mounted) {
        setState(() {
          _savedIngredients = items;
          _isLoadingSaved = false;
          if (_useAllSaved) {
            _selectedSavedNames.clear();
            for (var item in items) {
              _selectedSavedNames.add(item['name'].toString());
            }
          } else {
            // Ensure we don't clear if user already selected some before refresh,
            // but for now, default is empty selection on first load.
          }
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoadingSaved = false);
    }
  }

  Future<void> _toggleSaveIngredient(String name) async {
    final existing = _savedIngredients.firstWhere(
      (i) => i['name'].toString().toLowerCase() == name.toLowerCase(),
      orElse: () => {},
    );
    if (existing.isNotEmpty) {
      final success = await IngredientService.instance.unsaveIngredient(
        existing['id'].toString(),
      );
      if (success) _fetchSavedIngredients();
    } else {
      final success = await IngredientService.instance.saveIngredient(name);
      if (success) _fetchSavedIngredients();
    }
  }

  void _toggleSavedSelection(String name) {
    setState(() {
      if (_selectedSavedNames.contains(name)) {
        _selectedSavedNames.remove(name);
        _useAllSaved = false;
      } else {
        _selectedSavedNames.add(name);
        if (_selectedSavedNames.length == _savedIngredients.length) {
          _useAllSaved = true;
        }
      }
    });
  }

  Future<void> _generateFromTyped() async {
    final allIngredients = [..._typedIngredients, ..._selectedSavedNames];
    if (allIngredients.isEmpty) {
      IosToast.show(
        context,
        message: "Please add or select ingredients",
        type: ToastType.error,
      );
      return;
    }

    setState(() {
      _showAnimationOverlay = true;
      _overlayDetectedIngredients = null;
      _overlayGeneratedRecipes = null;
      _capturedImagePath = null;
    });

    try {
      final scanResult = await RecipeService.instance.scanTyped(allIngredients);

      final List<RecipeIngredient> allowed =
          (scanResult['allowed_ingredients'] as List? ?? [])
              .map((i) => RecipeIngredient.fromJson(i))
              .toList();

      final List<RecipeIngredient> restricted =
          (scanResult['restricted_ingredients'] as List? ?? [])
              .map((i) => RecipeIngredient.fromJson(i))
              .toList();

      final List<Recipe> generatedRecipes =
          (scanResult['recipes'] as List? ?? [])
              .map((j) => Recipe.fromJson(j))
              .toList();

      if (mounted) {
        setState(() {
          _ingredients.clear();
          _ingredients.addAll(allowed);
          _restrictedIngredients.clear();
          _restrictedIngredients.addAll(restricted);
          
          _recipes.clear();
          _recipes.addAll(generatedRecipes);
          _typedIngredients.clear();
          
          _overlayDetectedIngredients = allowed;
          _overlayGeneratedRecipes = generatedRecipes;
        });
      }

      // Save to temporary home suggestions for 3 days
      RecipeService.instance.saveScanResults(generatedRecipes);

    } catch (e) {
      if (mounted) {
        setState(() {
          _showAnimationOverlay = false;
        });
        if (!PaywallHelper.handleError(context, e)) {
          IosToast.show(
            context,
            message: e.toString().replaceAll("Exception: ", ""),
            type: ToastType.error,
          );
        }
      }
    }
  }

  void _onActiveStateChanged() {
    if (widget.isActiveNotifier.value) {
      // Always start with Scan tab when joining the page
      _updateState(ScanState.scan);

      // Trigger onboarding instantly if active
      if (!TutorialService.instance.hasSeenScan) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            TutorialHelper.showScanOnboardingDialog(
              context,
              onTabSwitch: widget.onTabSwitch,
            );
          }
        });
      }

      if (!_isCameraInitialized) {
        _initCamera();
      }
    } else {
      // Keep camera alive but maybe stop stream if any to save resources
      // instead of full dispose which causes the re-init delay the user dislikes.
      if (_cameraController != null && _useManualStreaming) {
        _toggleManualStreaming(); // Stop stream if active
      }
    }
  }

  @override
  void didUpdateWidget(ScanScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActiveNotifier != oldWidget.isActiveNotifier) {
      oldWidget.isActiveNotifier.removeListener(_onActiveStateChanged);
      widget.isActiveNotifier.addListener(_onActiveStateChanged);
    }
  }

  Future<void> _disposeCamera() async {
    if (_cameraController != null) {
      await _cameraController!.dispose();
      _cameraController = null;
      if (mounted) {
        setState(() {
          _isCameraInitialized = false;
          _isInitializing = false;
          _cameraStatus = "Camera Off";
        });
        _updateState(_state); // Sync notifier
      }
    }
  }

  Future<void> _initCamera() async {
    if (_isInitializing || !mounted) return;

    final now = DateTime.now();
    if (_lastInitAttempt != null &&
        now.difference(_lastInitAttempt!).inSeconds < 5) {
      debugPrint("CAMERA_LOG: Init throttled (too frequent).");
      return;
    }
    _lastInitAttempt = now;

    // Safety delay to ensure previous hardware resources are released
    await Future.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;

    setState(() {
      _isInitializing = true;
      _isCameraInitialized = false;
      _hasCameraError = false;
      _cameraStatus = "Direct Access...";
    });

    // On some Androids, camera init fails without both permissions
    final camStat = await Permission.camera.request();
    if (camStat != PermissionStatus.granted) {
      if (mounted) {
        setState(() {
          _cameraStatus = "Camera permission denied";
          _hasCameraError = true;
          _isInitializing = false;
        });
      }
      return;
    }

    setState(() => _cameraStatus = "Finding cameras...");
    await Future.delayed(
      const Duration(milliseconds: 200),
    ); // Hardware stabilization

    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        if (mounted) {
          setState(() {
            _cameraStatus = "No cameras found";
            _hasCameraError = true;
            _isInitializing = false;
          });
        }
        return;
      }

      final backCam = cameras.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.back,
        orElse: () => cameras.first,
      );

      _cameraController = CameraController(
        backCam,
        ResolutionPreset.medium, // Stable resolution
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.jpeg, // Fixes ImageReader_JNI buffer spam on Android
      );

      debugPrint("CAMERA_LOG: Stabilization delay 2...");
      await Future.delayed(const Duration(milliseconds: 200));

      debugPrint("CAMERA_LOG: Executing initialize()...");
      await _cameraController!.initialize();

      if (!mounted) return;

      // Stream removed from default init - only start when manual mode is requested
      // to avoid ImageReader_JNI buffer pressure warnings.

      setState(() {
        _isCameraInitialized = true;
        _isInitializing = false;
        _cameraStatus = "Ready";
      });
      debugPrint("CAMERA_LOG: Setup finished.");
    } catch (e) {
      debugPrint("CAMERA_LOG: Critical HW Catch: $e");
      if (mounted) {
        setState(() {
          _isInitializing = false;
          _cameraStatus = "HW Init Error: $e";
          _hasCameraError = true;
        });
      }
    }
  }

  Future<void> _toggleManualStreaming() async {
    if (_cameraController == null || !mounted) return;

    if (_useManualStreaming) {
      try {
        await _cameraController!.stopImageStream();
      } catch (_) {}
      setState(() => _useManualStreaming = false);
    } else {
      setState(() => _useManualStreaming = true);
      try {
        await _cameraController!.startImageStream((image) {
          if (mounted) _handleCameraStream(image);
        });
      } catch (e) {
        debugPrint("CAMERA_LOG: Manual stream start fail: $e");
      }
    }
  }

  void _handleCameraStream(CameraImage image) async {
    if (!_useManualStreaming || _isProcessingFrame) return;

    final now = DateTime.now();
    if (_lastFrameTime != null &&
        now.difference(_lastFrameTime!).inMilliseconds < 150) {
      return; // Cap at ~6 FPS for software rendering stability
    }
    _lastFrameTime = now;
    _isProcessingFrame = true;

    try {
      // Basic YUV to RGBA conversion
      final int width = image.width;
      final int height = image.height;
      final Uint8List yPlane = image.planes[0].bytes;
      final Uint8List uPlane = image.planes[1].bytes;
      final Uint8List vPlane = image.planes[2].bytes;

      final Uint8List rgba = Uint8List(width * height * 4);
      final int yRowStride = image.planes[0].bytesPerRow;
      final int uvRowStride = image.planes[1].bytesPerRow;
      final int uvPixelStride = image.planes[1].bytesPerPixel!;

      for (int y = 0; y < height; y++) {
        for (int x = 0; x < width; x++) {
          final int yIndex = y * yRowStride + x;
          final int uvIndex = (y ~/ 2) * uvRowStride + (x ~/ 2) * uvPixelStride;

          final int yValue = yPlane[yIndex];
          final int uValue = uPlane[uvIndex] - 128;
          final int vValue = vPlane[uvIndex] - 128;

          int r = (yValue + 1.370705 * vValue).toInt().clamp(0, 255);
          int g = (yValue - 0.337633 * uValue - 0.698001 * vValue)
              .toInt()
              .clamp(0, 255);
          int b = (yValue + 1.732446 * uValue).toInt().clamp(0, 255);

          final int rgbaIndex = (y * width + x) * 4;
          rgba[rgbaIndex] = r;
          rgba[rgbaIndex + 1] = g;
          rgba[rgbaIndex + 2] = b;
          rgba[rgbaIndex + 3] = 255;
        }
      }

      ui.decodeImageFromPixels(rgba, width, height, ui.PixelFormat.rgba8888, (
        ui.Image img,
      ) {
        if (mounted) {
          setState(() {
            _decodedFrame?.dispose();
            _decodedFrame = img;
            _isProcessingFrame = false;
          });
        } else {
          img.dispose();
        }
      });
    } catch (e) {
      _isProcessingFrame = false;
    }
  }

  String _capitalize(String text) {
    return text.toTitleCase();
  }

  @override
  void dispose() {
    _scannerController.dispose();
    widget.isActiveNotifier.removeListener(_onActiveStateChanged);
    RecipeService.instance.myRecipesNotifier.removeListener(_onRecipesChanged);
    _disposeCamera();
    _ingCtrl.dispose();
    _analysisTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    debugPrint(
      "BUILD_SCAN: state=$_state manual=$_useManualStreaming init=$_isCameraInitialized status=$_cameraStatus notify=${widget.isActiveNotifier.value}",
    );
    final bool isKeyboardOpen = MediaQuery.of(context).viewInsets.bottom > 0;
    final bool isScan = _state == ScanState.scan;
    bool showPill = _state != ScanState.results && !isKeyboardOpen;

    return Scaffold(
      backgroundColor: isScan ? Colors.black : Colors.transparent,
      resizeToAvoidBottomInset: false,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 1. Red Header Background for non-scan states
          if (!isScan)
            const Positioned.fill(
              child: RedHeaderBackground(),
            ),

          // 2. Background Content (Camera for Scan, White sheet card for Type/Saved/Results)
          if (isScan)
            _buildBackground()
          else
            SafeArea(
              bottom: false,
              child: Container(
                margin: EdgeInsets.only(top: 25.h),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(32.r),
                  ),
                ),
                child: Column(
                  children: [
                    if (_state != ScanState.results) _buildDynamicHeader(),
                    Expanded(child: _buildStateContent()),
                    if (showPill)
                      SizedBox(height: _state == ScanState.saved ? 150.h : 90.h)
                    else
                      SizedBox(height: 20.h),
                  ],
                ),
              ),
            ),

          // 2. Main Content for Scan mode
          if (isScan)
            SafeArea(
              bottom: false,
              child: Column(
                children: [
                  Expanded(child: _buildStateContent()),
                  if (showPill) SizedBox(height: 140.h),
                ],
              ),
            ),

          // 3. Floating Overlays (Brackets for Scan)
          if (isScan)
            Positioned.fill(child: _buildScanBrackets()),

          // 4. Floating Action Buttons (Fixed at bottom above pill)
          if (!isKeyboardOpen) _buildFloatingActions(),

          // 5. Success Message Overlay
          if (_showingSuccessMessage) _buildSuccessOverlay(),

          // 6. Bottom Pill Navigation
          if (showPill)
            Positioned(
              bottom: 20.h,
              left: 20.w,
              right: 20.w,
              child: SafeArea(top: false, child: _buildBottomPillNav()),
            ),

          // 7. New Scan Animation Overlay
          if (_showAnimationOverlay)
            Positioned.fill(
              child: ScanAnimationOverlay(
                detectedIngredients: _overlayDetectedIngredients,
                generatedRecipes: _overlayGeneratedRecipes,
                imagePath: _capturedImagePath,
                skipImageAnalysis: _state == ScanState.type || _state == ScanState.saved,
                onAnimationComplete: () {
                  setState(() {
                    _showAnimationOverlay = false;
                  });
                  _updateState(ScanState.results);
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildBackground() {
    Widget? loadingOverlay;
    if (_isInitializing && _state == ScanState.scan) {
      loadingOverlay = Positioned.fill(
        child: Container(
          color: Colors.black.withValues(alpha: 0.4),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SkeletonLoader(width: 40, height: 40, borderRadius: 20),
                SizedBox(height: 16.h),
                LoadingText(
                  text: "Initializing Camera",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // Show branded red header background for non-scan states
    if (_state != ScanState.scan) {
      return Stack(
        children: [
          const Positioned.fill(
            child: RedHeaderBackground(),
          ),
          if (loadingOverlay != null) loadingOverlay,
        ],
      );
    }


    // NEW: If we are scanning, show the captured frame (freeze-frame)
    if (_showingSuccessMessage && _capturedImagePath != null) {
      return Stack(
        children: [
          SizedBox(
            width: double.infinity,
            height: double.infinity,
            child: Image.file(File(_capturedImagePath!), fit: BoxFit.cover),
          ),
          if (loadingOverlay != null) loadingOverlay,

          // 4. Close Icon (Top-left) & Centered Title "Scan" for Scan mode
          Positioned(
            top: 50.h,
            left: 20.w,
            right: 20.w,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GlassIconButton(
                  onTap: widget.onClose,
                  size: 44.r,
                  child: Icon(
                    Icons.close_rounded,
                    color: const Color(0xFF0F172A),
                    size: 22.sp,
                  ),
                ),
                Text(
                  "Scan",
                  style: TextStyle(
                    fontFamily: 'Rubik',
                    fontWeight: FontWeight.w800,
                    fontSize: 20.sp,
                    color: const Color(0xFF0F172A),
                  ),
                ),
                SizedBox(width: 44.r),
              ],
            ),
          ),
        ],
      );
    }

    return Stack(
      children: [
        // 1. MAIN DISPLAY LAYER (Native or Manual)
        Positioned.fill(
          child: Container(color: Colors.black, child: _buildCameraLayer()),
        ),

        // 2. Loading / Status Layer
        if (!_isCameraInitialized || _hasCameraError || _isInitializing)
          Positioned.fill(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_isInitializing)
                    const SkeletonLoader(width: 40, height: 40, borderRadius: 20)
                  else if (!_isCameraInitialized && !_hasCameraError)
                    const SkeletonLoader(width: 40, height: 40, borderRadius: 20),
                  SizedBox(height: 16.h),
                  // Status Text
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 12.w,
                      vertical: 4.h,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Text(
                      _useManualStreaming
                          ? "MODE: DIRECT STREAM (Logic)"
                          : _cameraStatus,
                      style: TextStyle(
                        color: _useManualStreaming
                            ? Colors.amber
                            : Colors.white70,
                        fontSize: 12.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

        // 3. Top Header Bar (Close button left, Cooked logo center, Help icon right)
        Positioned(
          top: 50.h,
          left: 20.w,
          right: 20.w,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Close Icon (Top-left)
              GlassIconButton(
                onTap: widget.onClose,
                size: 38.r,
                child: Icon(
                  Icons.close_rounded,
                  color: Colors.white,
                  size: 22.sp,
                ),
              ),

              // Cooked Logo (Top-center)
              Image.asset(
                'assets/images/logo1.png',
                height: 30.h,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => Text(
                  'Cooked',
                  style: TextStyle(
                    fontFamily: 'Rubik',
                    fontWeight: FontWeight.w900,
                    fontSize: 22.sp,
                    color: Colors.white,
                  ),
                ),
              ),

              // Help / Reset Icon (Top-right)
              GestureDetector(
                onLongPress: () => _toggleManualStreaming(),
                child: Container(
                  padding: EdgeInsets.all(8.r),
                  decoration: const BoxDecoration(
                    color: Colors.transparent,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.help_outline_rounded,
                    color: Colors.transparent,
                    size: 20.sp,
                  ),
                ),
              ),
            ],
          ),
        ),

        if (loadingOverlay != null) loadingOverlay,
      ],
    );
  }

  Widget _buildCameraLayer() {
    if (!_isCameraInitialized ||
        _cameraController == null ||
        !_cameraController!.value.isInitialized) {
      return const SizedBox();
    }

    if (_useManualStreaming && _decodedFrame != null) {
      return RepaintBoundary(
        child: Center(
          child: RotatedBox(
            quarterTurns: 1,
            child: RawImage(image: _decodedFrame, fit: BoxFit.cover),
          ),
        ),
      );
    }

    // Standard Native Preview
    return RepaintBoundary(
      child: SizedBox.expand(
        child: FittedBox(
          fit: BoxFit.cover,
          child: SizedBox(
            width: _cameraController!.value.previewSize?.height ?? 1080,
            height: _cameraController!.value.previewSize?.width ?? 1920,
            child: CameraPreview(_cameraController!),
          ),
        ),
      ),
    );
  }

  Widget _buildDynamicHeader() {
    String title = _state == ScanState.type ? "Type Ingredient" : "Saved";
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 20.h, 16.w, 16.h),
      child: Row(
        children: [
          GlassIconButton(
            onTap: widget.onClose,
            size: 44.r,
            child: Icon(
              Icons.close_rounded,
              size: 22.sp,
              color: const Color(0xFF0F172A),
            ),
          ),
          Expanded(
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Rubik',
                fontWeight: FontWeight.w800,
                fontSize: 22.sp,
                color: const Color(0xFF0F172A),
              ),
            ),
          ),
          SizedBox(width: 44.r),
        ],
      ),
    );
  }

  Widget _buildStateContent() {
    switch (_state) {
      case ScanState.scan:
        return const SizedBox.shrink();
      case ScanState.type:
        return _buildTypeTab();
      case ScanState.saved:
        return _buildSavedTab();
      case ScanState.results:
        return _buildResultsPage();
    }
  }

  Widget _buildScanBrackets() {
    return Center(
      child: Container(
        margin: EdgeInsets.only(bottom: 60.h),
        width: 320.w,
        height: 380.h,
        child: Stack(
          children: [
            Positioned.fill(
              child: CustomPaint(
                painter: _FramePainter(
                  corner: 36.r,
                  thick: 4.w,
                  color: const Color(0xFFC83A2D),
                ),
              ),
            ),
            AnimatedBuilder(
              animation: _scannerController,
              builder: (context, child) {
                return Align(
                  alignment: Alignment(0, -1.0 + (_scannerController.value * 2.0)),
                  child: Container(
                    height: 1.5.h,
                    margin: EdgeInsets.symmetric(horizontal: 10.w),
                    decoration: BoxDecoration(
                      color: const Color(0xFFC83A2D).withValues(alpha: 0.95),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFC83A2D).withValues(alpha: 0.6),
                          blurRadius: 8.r,
                          spreadRadius: 1.r,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFloatingActions() {
    if (_state == ScanState.scan) {
      return Positioned(
        bottom: 95.h,
        left: 0,
        right: 0,
        child: SafeArea(
          top: false,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildGalleryBtn(),
              SizedBox(width: 32.w),
              _buildShutterBtn(),
              SizedBox(width: 84.w),
            ],
          ),
        ),
      );
    }

    if (_state == ScanState.results) {
      return const SizedBox.shrink();
    }

    // Action button ("Get Recipes" for Type, "Add" for Saved)
    final String label = _state == ScanState.saved ? "Add" : "Get Recipes";
    Widget actionBtn = _buildWideBtn(label, _generateFromTyped);

    return Positioned(
      bottom: 88.h,
      left: 20.w,
      right: 20.w,
      child: SafeArea(top: false, child: actionBtn),
    );
  }

  Widget _buildGalleryBtn() {
    return GlassIconButton(
      onTap: () => _pickAndScan(ImageSource.gallery),
      size: 52.r,
      child: Icon(
        Icons.photo_library_outlined,
        color: const Color(0xFF0F172A),
        size: 24.sp,
      ),
    );
  }

  Widget _buildShutterBtn() {
    return GlassIconButton(
      key: _shutterKey,
      onTap: () => _pickAndScan(ImageSource.camera),
      size: 76.r,
      glassColor: Colors.white.withValues(alpha: 0.35),
      borderColor: Colors.white.withValues(alpha: 0.85),
      child: Container(
        width: 54.r,
        height: 54.r,
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
        ),
      ),
    );
  }

  Widget _buildWideBtn(String label, dynamic action) {
    return GestureDetector(
      onTap: () {
        if (action is ScanState) {
          _updateState(action);
        } else if (action is Function) {
          action();
        }
      },
      child: Container(
        width: double.infinity,
        height: 50.h,
        decoration: BoxDecoration(
          color: const Color(0xFFC83A2D),
          borderRadius: BorderRadius.circular(30.r),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 15.sp,
          ),
        ),
      ),
    );
  }

  Widget _buildBottomPillNav() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(30.r),
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 25, sigmaY: 25),
        child: Container(
          height: 54.h,
          padding: EdgeInsets.all(5.r),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.45),
            borderRadius: BorderRadius.circular(30.r),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.70),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              _PillTab(
                label: 'Scan',
                active: _state == ScanState.scan,
                onTap: () => _updateState(ScanState.scan),
              ),
              _PillTab(
                key: _typeTabKey,
                label: 'Type Ingredients',
                active: _state == ScanState.type,
                onTap: () => _updateState(ScanState.type),
              ),
              _PillTab(
                label: 'Saved',
                active: _state == ScanState.saved,
                onTap: () => _updateState(ScanState.saved),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Tab 2: Type Ingredient ────────────────────────────────────────────────
  Widget _buildTypeTab() {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── FIXED HEADER PART ─────────────────────────────────────────────
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Enter ingredients one by one",
                style: TextStyle(
                  fontFamily: 'Rubik',
                  color: const Color(0xFF475569),
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 12.h),
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(16.r),
                ),
                child: TextField(
                  controller: _ingCtrl,
                  textCapitalization: TextCapitalization.words,
                  style: TextStyle(
                    fontFamily: 'Rubik',
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF0F172A),
                  ),
                  decoration: InputDecoration(
                    prefixIcon: Icon(
                      Icons.search_rounded,
                      color: const Color(0xFF64748B),
                      size: 22.sp,
                    ),
                    hintText: 'Search your recipes',
                    hintStyle: TextStyle(
                      fontFamily: 'Rubik',
                      color: const Color(0xFF94A3B8),
                      fontSize: 15.sp,
                    ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 14.h,
                    ),
                    suffixIcon: Padding(
                      padding: EdgeInsets.only(right: 8.w),
                      child: GestureDetector(
                        onTap: _addTypedIngredient,
                        child: Container(
                          width: 32.r,
                          height: 32.r,
                          decoration: const BoxDecoration(
                            color: Color(0xFFC83A2D),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.add_rounded,
                            color: Colors.white,
                            size: 20.sp,
                          ),
                        ),
                      ),
                    ),
                    suffixIconConstraints: BoxConstraints(
                      minWidth: 40.r,
                      minHeight: 40.r,
                    ),
                  ),
                  onSubmitted: (_) => _addTypedIngredient(),
                ),
              ),
              if (_suggestedIngredients.isNotEmpty)
                Padding(
                  padding: EdgeInsets.only(top: 0.h),
                  child: Material(
                    elevation: 4,
                    borderRadius: BorderRadius.circular(12.r),
                    child: Container(
                      constraints: BoxConstraints(maxHeight: 200.h),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: ListView.separated(
                        shrinkWrap: true,
                        padding: EdgeInsets.zero,
                        itemCount: _suggestedIngredients.length,
                        separatorBuilder: (_, __) =>
                            Divider(height: 1, color: Colors.grey[100]),
                        itemBuilder: (context, i) {
                          final item = _suggestedIngredients[i];
                          return ListTile(
                            dense: true,
                            title: Text(_capitalize(item['name'] ?? '')),
                            onTap: () {
                              _ingCtrl.text = _capitalize(item['name'] ?? '');
                              _addTypedIngredient();
                              setState(() => _suggestedIngredients = []);
                            },
                          );
                        },
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),

        // ── SCROLLABLE LIST PART ──────────────────────────────────────────
        Expanded(
          child: ListView(
            padding: EdgeInsets.fromLTRB(22.w, 5.h, 22.w, bottomInset + 120.h),
            children: [
              if (_ingCtrl.text.isEmpty) ...[
                SizedBox(height: 5.h),
                Text(
                  "Add ingredients to find recipes you can make",
                  style: TextStyle(
                    color: const Color(0xFF94A3B8),
                    fontSize: 12.sp,
                    fontStyle: FontStyle.italic,
                  ),
                ),

                // DYNAMIC RECENTLY USED
                if (_recentIngredients.isNotEmpty) ...(() {
                  // Filter out ingredients already in _typedIngredients
                  final filteredRecent = _recentIngredients
                      .where((ing) => !_typedIngredients.contains(ing['name']))
                      .toList();

                  if (filteredRecent.isEmpty) return [const SizedBox.shrink()];

                  return [
                    SizedBox(height: 25.h),
                    Text(
                      "Recently Used",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14.sp,
                        color: const Color(0xFF64748B),
                      ),
                    ),
                    SizedBox(height: 10.h),
                    Wrap(
                      spacing: 8.w,
                      runSpacing: 8.h,
                      children: filteredRecent.take(8).map((ing) {
                        final name = ing['name'] ?? '';
                        return GestureDetector(
                          onTap: () {
                            _ingCtrl.text = name;
                            _addTypedIngredient();
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(20.r),
                              border: Border.all(color: Colors.grey[200]!),
                            ),
                            child: Text(
                              name,
                              style: TextStyle(
                                color: const Color(0xFF1E293B),
                                fontSize: 13.sp,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ];
                })(),
              ],
              SizedBox(height: 24.h),
              ..._typedIngredients.map(
                (ing) => _buildIngredientCard(
                  ing,
                  isSaved: _savedIngredients.any(
                    (si) =>
                        si['name'].toString().toLowerCase() ==
                        ing.toLowerCase(),
                  ),
                  onContainerTap: () => _toggleSaveIngredient(ing),
                  onHeartTap: () => _toggleSaveIngredient(ing),
                  onDeleteTap: () =>
                      setState(() => _typedIngredients.remove(ing)),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ── Tab 3: Saved ──────────────────────────────────────────────────────────
  Widget _buildSavedTab() {
    if (_isLoadingSaved) {
      return Padding(
        padding: EdgeInsets.only(top: 20.h),
        child: const SkeletonList(height: 60, itemCount: 8),
      );
    }
    return ListView(
      padding: EdgeInsets.symmetric(horizontal: 22.w),
      children: [
        if (_savedIngredients.isNotEmpty) ...[
          if (_selectedSavedNames.isNotEmpty) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Transform.scale(
                      scale: 0.8,
                      child: Switch(
                        value: _useAllSaved,
                        activeTrackColor: const Color(0xFFC83A2D),
                        onChanged: (val) {
                          setState(() {
                            _useAllSaved = val;
                            if (val) {
                              _selectedSavedNames.clear();
                              for (var item in _savedIngredients) {
                                _selectedSavedNames.add(
                                  item['name'].toString(),
                                );
                              }
                            } else {
                              _selectedSavedNames.clear();
                            }
                          });
                        },
                      ),
                    ),
                    Text(
                      "Use all",
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF475569),
                      ),
                    ),
                  ],
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _useAllSaved = false;
                      _selectedSavedNames.clear();
                    });
                  },
                  child: Text(
                    "Clear selection",
                    style: TextStyle(
                      color: const Color(0xFF64748B),
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 10.h),
          ],
          ..._savedIngredients.map((ing) {
            final name = ing['name'] ?? '';
            final isSelected = _selectedSavedNames.contains(name);
            return _buildIngredientCard(
              name,
              icon: ing['icon'],
              isSelected: isSelected,
              onContainerTap: () {
                _toggleSavedSelection(name);
              },
              onSelectionTap: () {
                _toggleSavedSelection(name);
              },
              onDeleteTap: () => _unsaveIngredientAction(ing['id'].toString()),
              showIcon: true,
            );
          }),
        ] else
          Center(
            child: Padding(
              padding: EdgeInsets.only(top: 40.h),
              child: Text(
                "No saved ingredients yet.",
                style: TextStyle(
                  color: const Color(0xFF6B7280),
                  fontSize: 14.sp,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildIngredientCard(
    String name, {
    String? icon,
    bool? isSaved,
    bool? isSelected,
    VoidCallback? onContainerTap,
    VoidCallback? onHeartTap,
    VoidCallback? onSelectionTap,
    VoidCallback? onDeleteTap,
    bool showIcon = false,
  }) {
    return GestureDetector(
      onTap: onContainerTap,
      child: Container(
        margin: EdgeInsets.only(bottom: 16.h),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        decoration: BoxDecoration(
          color: const Color(0xFFF9FAFB),
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: const Color(0xFFF1F5F9)),
        ),
        child: Row(
          children: [
            if (onSelectionTap != null)
              GestureDetector(
                onTap: onSelectionTap,
                behavior: HitTestBehavior.opaque,
                child: Padding(
                  padding: EdgeInsets.only(right: 12.w),
                  child: Icon(
                    (isSelected ?? false)
                        ? Icons.check_box_rounded
                        : Icons.check_box_outline_blank_rounded,
                    color: (isSelected ?? false)
                        ? const Color(0xFFC83A2D)
                        : const Color(0xFFCBD5E1),
                    size: 24.sp,
                  ),
                ),
              ),

            Expanded(
              child: Text(
                name,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16.sp,
                  color: const Color(0xFF1E293B),
                ),
              ),
            ),

            if (onHeartTap != null)
              GestureDetector(
                onTap: onHeartTap,
                behavior: HitTestBehavior.opaque,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                  child: Icon(
                    Icons.favorite_rounded,
                    color: (isSaved ?? false)
                        ? const Color(0xFFC83A2D)
                        : const Color(0xFFCBD5E1),
                    size: 24.sp,
                  ),
                ),
              ),

            if (onDeleteTap != null)
              GestureDetector(
                onTap: onDeleteTap,
                behavior: HitTestBehavior.opaque,
                child: Padding(
                  padding: EdgeInsets.fromLTRB(8.w, 4.h, 4.w, 4.h),
                  child: Icon(
                    _state == ScanState.saved
                        ? Icons.delete_outline_rounded
                        : Icons.close_rounded,
                    color: const Color(0xFF94A3B8),
                    size: 24.sp,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _unsaveIngredientAction(String id) async {
    final success = await IngredientService.instance.unsaveIngredient(id);
    if (success) _fetchSavedIngredients();
  }

  String _getEmojiForIngredient(String name) {
    final lower = name.toLowerCase();
    if (lower.contains('tomato')) return '🍅';
    if (lower.contains('garlic')) return '🧄';
    if (lower.contains('pasta') || lower.contains('fettuccine') || lower.contains('spaghetti')) return '🍝';
    if (lower.contains('butter')) return '🧈';
    if (lower.contains('egg')) return '🥚';
    if (lower.contains('cheese') || lower.contains('parmesan')) return '🧀';
    if (lower.contains('chicken')) return '🍗';
    if (lower.contains('rice')) return '🍚';
    if (lower.contains('onion')) return '🧅';
    if (lower.contains('oil')) return '🫒';
    if (lower.contains('salt') || lower.contains('pepper')) return '🧂';
    return '🥗';
  }

  Widget _buildResultsPage() {
    final int ingredientCount = _ingredients.isNotEmpty
        ? _ingredients.length
        : _typedIngredients.length;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 24.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Top Bar inside white card (Cooked Logo + Close Button) ──
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Cooked Logo
              Image.asset(
                'assets/images/logo2.png',
                height: 36.h,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => Text(
                  'Cooked',
                  style: TextStyle(
                    fontFamily: 'Rubik',
                    fontWeight: FontWeight.w900,
                    fontSize: 22.sp,
                    color: const Color(0xFFC83A2D),
                  ),
                ),
              ),

              // Close Button (X)
              GestureDetector(
                onTap: () => _updateState(ScanState.scan),
                child: Container(
                  width: 38.r,
                  height: 38.r,
                  decoration: const BoxDecoration(
                    color: Color(0xFFF1F5F9),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.close_rounded,
                    size: 20.sp,
                    color: const Color(0xFF0F172A),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),

          // Header Title: "Recipes You \n Can Cook Now"
          Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: 'Recipes You\n',
                  style: TextStyle(
                    fontFamily: 'Rubik',
                    fontSize: 26.sp,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF0F172A),
                    height: 1.1,
                  ),
                ),
                TextSpan(
                  text: 'Can Cook Now',
                  style: TextStyle(
                    fontFamily: 'Rubik',
                    fontSize: 26.sp,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFFC83A2D),
                    height: 1.1,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            'We found ${_recipes.length} ${_recipes.length == 1 ? "recipe" : "recipes"} for you',
            style: TextStyle(
              fontFamily: 'Rubik',
              fontSize: 13.sp,
              color: const Color(0xFF64748B),
            ),
          ),
          SizedBox(height: 16.h),

          // Recipe Carousel / Card
          _buildScanResultCarouselCard(ingredientCount),
        ],
      ),
    );
  }

  Widget _buildScanResultCarouselCard(int ingredientCount) {
    if (_recipes.isEmpty) {
      return const Center(child: SkeletonList(height: 300, itemCount: 1));
    }

    return Column(
      children: [
        SizedBox(
          height: 520.h,
          child: PageView.builder(
            controller: _resultPageController,
            onPageChanged: (idx) {
              setState(() => _currentResultPage = idx);
            },
            itemCount: _recipes.length,
            itemBuilder: (context, index) {
              final recipe = _recipes[index];
              return _buildScanRecipeDetailCard(recipe, ingredientCount);
            },
          ),
        ),
        SizedBox(height: 12.h),

        // Page Indicator Dots
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            _recipes.length > 5 ? 5 : _recipes.length,
            (i) => AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              margin: EdgeInsets.symmetric(horizontal: 4.w),
              width: _currentResultPage == i ? 10.r : 8.r,
              height: _currentResultPage == i ? 10.r : 8.r,
              decoration: BoxDecoration(
                color: _currentResultPage == i
                    ? const Color(0xFFC83A2D)
                    : const Color(0xFFE2E8F0),
                shape: BoxShape.circle,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildScanRecipeDetailCard(Recipe recipe, int ingredientCount) {
    final displayIngredients = _ingredients.isNotEmpty
        ? _ingredients.map((i) => i.name).toList()
        : _typedIngredients;

    void openRecipeDetail() {
      Navigator.pushNamed(
        context,
        AppRoutes.recipeDetail,
        arguments: {'recipe': recipe, 'isPreview': true},
      );
    }

    return GestureDetector(
      onTap: openRecipeDetail,
      behavior: HitTestBehavior.opaque,
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 2.w),
        decoration: BoxDecoration(
          color: const Color(0xFFFAF6ED),
          borderRadius: BorderRadius.circular(24.r),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Recipe Image (Rounded on all sides, no padding)
            ClipRRect(
              borderRadius: BorderRadius.circular(20.r),
              child: SizedBox(
                height: 200.h,
                width: double.infinity,
                child: (recipe.image != null && recipe.image!.isNotEmpty)
                    ? (recipe.image!.startsWith('http')
                        ? Image.network(
                            recipe.image!,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Image.asset(
                              'assets/images/plat1.png',
                              fit: BoxFit.cover,
                            ),
                          )
                        : Image.asset(
                            recipe.image!,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Image.asset(
                              'assets/images/plat1.png',
                              fit: BoxFit.cover,
                            ),
                          ))
                    : Image.asset(
                        'assets/images/plat1.png',
                        fit: BoxFit.cover,
                      ),
              ),
            ),

            // 2. Recipe Info Body
            Padding(
              padding: EdgeInsets.all(16.r),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title & Heart Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          recipe.name,
                          style: TextStyle(
                            fontFamily: 'Rubik',
                            fontSize: 18.sp,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF0F172A),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      ValueListenableBuilder<List<Recipe>?>(
                        valueListenable: RecipeService.instance.myRecipesNotifier,
                        builder: (context, savedRecipes, _) {
                          final isSaved = (savedRecipes ?? []).any(
                            (r) =>
                                (r.id == recipe.id && recipe.id.isNotEmpty) ||
                                r.name == recipe.name,
                          );
                          return GestureDetector(
                            onTap: () => _handleSaveRecipe(recipe),
                            child: Container(
                              width: 34.r,
                              height: 34.r,
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                isSaved ? Icons.favorite : Icons.favorite_outline,
                                color: isSaved ? const Color(0xFFC83A2D) : const Color(0xFF94A3B8),
                                size: 18.sp,
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                  SizedBox(height: 8.h),

                  // Time & Calories Badges
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.access_time_rounded, size: 13.sp, color: const Color(0xFF64748B)),
                            SizedBox(width: 4.w),
                            Text(
                              '${recipe.cookTime} min',
                              style: TextStyle(
                                fontFamily: 'Rubik',
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF64748B),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.local_fire_department_rounded, size: 13.sp, color: const Color(0xFF64748B)),
                            SizedBox(width: 4.w),
                            Text(
                              '${recipe.kcal} kcal',
                              style: TextStyle(
                                fontFamily: 'Rubik',
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF64748B),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 12.h),
                  const Divider(color: Color(0xFFE2E8F0), height: 1),
                  SizedBox(height: 12.h),

                  // Your Ingredients Header
                  Text(
                    'Your Ingredients',
                    style: TextStyle(
                      fontFamily: 'Rubik',
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF0F172A),
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    'We found ${displayIngredients.length} items in your kitchen',
                    style: TextStyle(
                      fontFamily: 'Rubik',
                      fontSize: 12.sp,
                      color: const Color(0xFF94A3B8),
                    ),
                  ),
                  SizedBox(height: 8.h),

                  // Ingredient Chips with Emojis
                  Wrap(
                    spacing: 6.w,
                    runSpacing: 6.h,
                    children: displayIngredients.take(6).map((ingName) {
                      return Container(
                        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16.r),
                        ),
                        child: Text(
                          '${_getEmojiForIngredient(ingName)} ${_capitalize(ingName)}',
                          style: TextStyle(
                            fontFamily: 'Rubik',
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF0F172A),
                          ),
                        ),
                      );
                    }).toList(),
                  ),

                  SizedBox(height: 16.h),

                  // View Recipe Primary Button
                  GestureDetector(
                    onTap: openRecipeDetail,
                    child: Container(
                      width: double.infinity,
                      height: 46.h,
                      decoration: BoxDecoration(
                        color: const Color(0xFFC83A2D),
                        borderRadius: BorderRadius.circular(24.r),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        'View Recipe',
                        style: TextStyle(
                          fontFamily: 'Rubik',
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }


  Future<void> _handleSaveRecipe(Recipe r) async {
    HapticFeedback.mediumImpact();
    try {
      showDialog(
        context: context,
        barrierColor: Colors.black26,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: AppLoadingIndicator(),
        ),
      );

      Recipe finalRecipe = r;
      if (r.id.isEmpty) {
        finalRecipe = await RecipeService.instance.createRecipe(r);
        int idx = _recipes.indexWhere((element) => element == r);
        if (idx != -1) {
          setState(() {
            _recipes[idx] = finalRecipe;
          });
        }
      }

      if (mounted) Navigator.pop(context);

      if (mounted) {
        showModalBottomSheet(
          context: context,
          backgroundColor: Colors.transparent,
          isScrollControlled: true,
          builder: (_) => AddToCookbookSheet(
            recipe: finalRecipe,
            onSuccess: () {},
          ),
        );
      }
    } catch (e) {
      if (mounted) Navigator.pop(context);
      if (mounted) {
        IosToast.show(
          context,
          message: ErrorHelper.getFriendlyMessage(e),
          type: ToastType.error,
        );
      }
    }
  }



  void _addTypedIngredient() {
    final text = _ingCtrl.text.trim();
    if (text.isNotEmpty) {
      final capitalized = _capitalize(text);

      IngredientService.instance
          .addToRecentTypedIngredient(capitalized)
          .then((_) {
        _fetchRecentIngredients();
      });

      HapticFeedback.lightImpact();
      setState(() {
        if (!_typedIngredients.contains(capitalized)) {
          _typedIngredients.add(capitalized);
        }
        _ingCtrl.clear();
      });
    }
  }

  Future<void> _pickAndScan(ImageSource source) async {
    XFile? photo;

    if (source == ImageSource.camera &&
        _isCameraInitialized &&
        _cameraController != null) {
      try {
        photo = await _cameraController!.takePicture();
        await _cameraController!.pausePreview();
      } catch (e) {
        debugPrint('Error taking picture: $e');
        return;
      }
    } else {
      final picker = ImagePicker();
      photo = await picker.pickImage(source: source, imageQuality: 70);
      if (_cameraController != null && _isCameraInitialized) {
        await _cameraController!.pausePreview();
      }
    }

    if (photo == null) return;
    HapticFeedback.mediumImpact();

    setState(() {
      _showAnimationOverlay = true;
      _overlayDetectedIngredients = null;
      _overlayGeneratedRecipes = null;
      _capturedImagePath = photo!.path;
    });

    try {
      final scanResult = await RecipeService.instance.scan(photo);

      final List<RecipeIngredient> detectedAllowed =
          (scanResult['allowed_ingredients'] as List? ?? [])
              .map((j) => RecipeIngredient.fromJson(j))
              .toList();

      final List<RecipeIngredient> detectedRestricted =
          (scanResult['restricted_ingredients'] as List? ?? [])
              .map((j) => RecipeIngredient.fromJson(j))
              .toList();

      final List<Recipe> generatedRecipes =
          (scanResult['recipes'] as List? ?? [])
              .map((j) => Recipe.fromJson(j))
              .toList();

      if (mounted) {
        setState(() {
          _ingredients.clear();
          _ingredients.addAll(detectedAllowed);

          _restrictedIngredients.clear();
          _restrictedIngredients.addAll(detectedRestricted);

          _recipes.clear();
          _recipes.addAll(generatedRecipes);

          _overlayDetectedIngredients = detectedAllowed;
          _overlayGeneratedRecipes = generatedRecipes;
        });
      }

      RecipeService.instance.saveScanResults(generatedRecipes);
    } catch (e) {
      if (mounted) {
        setState(() {
          _showAnimationOverlay = false;
          _capturedImagePath = null;
        });
        if (!PaywallHelper.handleError(context, e)) {
          IosToast.show(
            context,
            message: ErrorHelper.getFriendlyMessage(e),
            type: ToastType.error,
          );
        }
      }
    }
  }

  Widget _buildSuccessOverlay() {
    return Container(
      color: Colors.black.withValues(alpha: 0.7),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              'assets/images/logo2.png',
              width: 120.w,
              fit: BoxFit.contain,
            ),
            SizedBox(height: 24.h),
            LoadingText(
              text: _cameraStatus.replaceAll('.', ''),
              style: TextStyle(
                color: Colors.white,
                fontSize: 18.sp,
                fontWeight: FontWeight.w700,
                fontFamily: 'SF Pro',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PillTab extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;
  const _PillTab({
    super.key,
    required this.label,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final int flexValue = label.length > 10 ? 13 : 8;

    return Expanded(
      flex: flexValue,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: double.infinity,
          margin: EdgeInsets.symmetric(horizontal: 2.w),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: active ? const Color(0xFFC83A2D) : Colors.transparent,
            borderRadius: BorderRadius.circular(26.r),
            boxShadow: active
                ? [
                    BoxShadow(
                      color: const Color(0xFFC83A2D).withValues(alpha: 0.35),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    )
                  ]
                : [],
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontFamily: 'Rubik',
              color: active ? Colors.white : const Color(0xFF0F172A),
              fontWeight: active ? FontWeight.w700 : FontWeight.w600,
              fontSize: 14.sp,
            ),
          ),
        ),
      ),
    );
  }
}

class _FramePainter extends CustomPainter {
  final double corner;
  final double thick;
  final Color color;

  const _FramePainter({
    required this.corner,
    required this.thick,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = color
      ..strokeWidth = thick
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    final w = size.width;
    final h = size.height;
    final r = 12.0;
    final arm = corner;

    // Top-Left
    canvas.drawLine(Offset(0, arm), Offset(0, r), p);
    canvas.drawArc(Rect.fromLTWH(0, 0, r * 2, r * 2), 3.14, 1.57, false, p);
    canvas.drawLine(Offset(r, 0), Offset(arm, 0), p);

    // Top-Right
    canvas.drawLine(Offset(w - arm, 0), Offset(w - r, 0), p);
    canvas.drawArc(
        Rect.fromLTWH(w - 2 * r, 0, r * 2, r * 2), -1.57, 1.57, false, p);
    canvas.drawLine(Offset(w, r), Offset(w, arm), p);

    // Bottom-Right
    canvas.drawLine(Offset(w, h - arm), Offset(w, h - r), p);
    canvas.drawArc(
        Rect.fromLTWH(w - 2 * r, h - 2 * r, r * 2, r * 2), 0, 1.57, false, p);
    canvas.drawLine(Offset(w - r, h), Offset(w - arm, h), p);

    // Bottom-Left
    canvas.drawLine(Offset(arm, h), Offset(r, h), p);
    canvas.drawArc(
        Rect.fromLTWH(0, h - 2 * r, r * 2, r * 2), 1.57, 1.57, false, p);
    canvas.drawLine(Offset(0, h - r), Offset(0, h - arm), p);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
