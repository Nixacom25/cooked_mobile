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
import '../widgets/loading_text.dart';
import '../widgets/recipe_grid_skeleton.dart';
import '../widgets/skeleton_list.dart';
import '../widgets/recipe_card.dart';
import '../widgets/add_to_cookbook_sheet.dart';
import '../models/recipe.dart';
import '../core/widgets/ios_toast.dart';
import '../core/services/tutorial_service.dart';
import '../core/utils/tutorial_helper.dart';
import '../core/extensions/string_extensions.dart';
import '../utils/paywall_helper.dart';

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

  // GlobalKeys for tutorial
  final GlobalKey _shutterKey = GlobalKey();
  final GlobalKey _typeTabKey = GlobalKey();
  final GlobalKey _scanMoreKey = GlobalKey();

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
  int _analysisDotCount = 0;
  Timer? _analysisTimer;

  void _updateState(ScanState newState) {
    if (!mounted) return;
    if (_state != newState) HapticFeedback.selectionClick();
    setState(() {
      _state = newState;
    });
    widget.isResultsModeNotifier?.value = (newState == ScanState.results);
  }

  @override
  void initState() {
    super.initState();
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

    if (query.length < 2) {
      setState(() => _suggestedIngredients = []);
      return;
    }

    _searchDebounce = Timer(const Duration(milliseconds: 300), () async {
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

  void _startAnalysisLoading(String status) {
    _showingSuccessMessage = true;
    _cameraStatus = status;
    _analysisDotCount = 0;
    _analysisTimer?.cancel();
    _analysisTimer = Timer.periodic(const Duration(milliseconds: 500), (timer) {
      if (mounted) {
        setState(() {
          _analysisDotCount = (_analysisDotCount + 1) % 4;
        });
      }
    });
  }

  void _stopAnalysisLoading() {
    _analysisTimer?.cancel();
    _showingSuccessMessage = false;
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
      _startAnalysisLoading("Analyzing...");
    });

    try {
      final response = await RecipeService.instance.scanTyped(allIngredients);

      final List<RecipeIngredient> allowed =
          (response['allowed_ingredients'] as List)
              .map((i) => RecipeIngredient.fromJson(i))
              .toList();
      final List<RecipeIngredient> restricted =
          (response['restricted_ingredients'] as List)
              .map((i) => RecipeIngredient.fromJson(i))
              .toList();
      final List<Recipe> recipes = (response['recipes'] as List)
          .map((r) => Recipe.fromJson(r))
          .toList();

      if (mounted) {
        setState(() {
          _ingredients.clear();
          _ingredients.addAll(allowed);
          _restrictedIngredients.clear();
          _restrictedIngredients.addAll(restricted);
          _recipes.clear();
          _recipes.addAll(recipes);
          _stopAnalysisLoading();
          _typedIngredients.clear();
          _updateState(ScanState.results);
        });
        
        // Save to temporary home suggestions for 3 days
        RecipeService.instance.saveScanResults(recipes);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _stopAnalysisLoading());
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

  void _onActiveStateChanged() {
    if (widget.isActiveNotifier.value) {
      // Always start with Scan tab when joining the page
      _updateState(ScanState.scan);

      // Trigger onboarding instantly if active
      if (!TutorialService.instance.hasSeenScan) {
        TutorialHelper.showScanOnboardingDialog(
          context,
          onTabSwitch: widget.onTabSwitch,
        );
        TutorialService.instance.completeScan();
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
    bool showPill = _state != ScanState.results && !isKeyboardOpen;
    return Scaffold(
      backgroundColor: _state == ScanState.scan ? Colors.black : Colors.white,
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          // 1. Background Content
          _buildBackground(),

          // 2. Main Content
          SafeArea(
            bottom: false,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (_state != ScanState.scan && _state != ScanState.results) _buildDynamicHeader(),
                Expanded(child: _buildStateContent()),
                // Spacer for buttons and pill nav
                if (showPill)
                  SizedBox(height: 140.h)
                else
                  SizedBox(height: 100.h),
              ],
            ),
          ),

          // 3. Floating Overlays (Brackets for Scan)
          if (_state == ScanState.scan)
            Positioned.fill(child: _buildScanBrackets()),

          // 4. Floating Action Buttons (Fixed at bottom above pill)
          if (!isKeyboardOpen) _buildFloatingActions(),

          // 5. Success Message Overlay
          if (_showingSuccessMessage) _buildSuccessOverlay(),

          // 6. Bottom Pill Navigation
          if (showPill)
            Positioned(
              bottom: 20.h,
              left: 22.w,
              right: 22.w,
              child: SafeArea(top: false, child: _buildBottomPillNav()),
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
          color: Colors.black.withOpacity(0.4),
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

    // Show white/empty background for non-scan states
    if (_state != ScanState.scan) {
      return Stack(
        children: [
          Container(color: Colors.white),
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

          // 4. Close Icon (Top-left) for Scan mode
          Positioned(
            top: 50.h,
            left: 20.w,
            child: GestureDetector(
              onTap: widget.onClose,
              child: Container(
                padding: EdgeInsets.all(8.r),
                decoration: const BoxDecoration(
                  color: Colors.black26,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.close_rounded,
                  color: Colors.white,
                  size: 22.sp,
                ),
              ),
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

        // 3. Discreet "Reset/Fix" anchor (Top-right)
        if (_isCameraInitialized && !_useManualStreaming)
          Positioned(
            top: 50.h,
            right: 20.w,
            child: GestureDetector(
              onLongPress: () => _toggleManualStreaming(),
              child: Icon(
                Icons.help_outline_rounded,
                color: Colors.white24,
                size: 20.sp,
              ),
            ),
          ),

        // 4. Close Icon (Top-left) for Scan mode
        Positioned(
          top: 50.h,
          left: 20.w,
          child: GestureDetector(
            onTap: widget.onClose,
            child: Container(
              padding: EdgeInsets.all(8.r),
              decoration: const BoxDecoration(
                color: Colors.black26,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.close_rounded,
                color: Colors.white,
                size: 22.sp,
              ),
            ),
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
      padding: EdgeInsets.fromLTRB(22.w, 40.h, 22.w, 20.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              fontFamily: 'SF Pro',
              fontWeight: FontWeight.w800,
              fontSize: 24.sp,
              color: const Color(0xFF1E293B),
            ),
          ),
          GestureDetector(
            onTap: widget.onClose,
            child: Container(
              padding: EdgeInsets.all(6.r),
              margin: EdgeInsets.only(top: 15.h), // Adjust for alignment
              decoration: BoxDecoration(
                color: Colors.grey[100],
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.close_rounded,
                size: 20.sp,
                color: Colors.grey[700],
              ),
            ),
          ),
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
      child: SizedBox(
        width: 300.w,
        height: 250.h,
        child: CustomPaint(
          painter: _FramePainter(
            corner: 30.r,
            thick: 3.w,
            color: const Color(0xFFC83A2D),
          ),
        ),
      ),
    );
  }

  Widget _buildFloatingActions() {
    if (_state == ScanState.scan) {
      return Positioned(
        bottom: 90.h,
        left: 0,
        right: 0,
        child: SafeArea(
          top: false,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildGalleryBtn(),
              SizedBox(width: 60.w),
              _buildShutterBtn(),
              SizedBox(width: 85.w),
            ],
          ),
        ),
      );
    }

    // "Get Recipes" or "Scan More" buttons
    Widget actionBtn;
    if (_state == ScanState.results) {
      actionBtn = SizedBox(
        key: _scanMoreKey,
        child: _buildWideBtn("Show Updated Recipes", _reprocessFromResults),
      );
    } else {
      actionBtn = _buildWideBtn("Get Recipes", _generateFromTyped);
    }

    return Positioned(
      bottom: _state == ScanState.results ? 15.h : 90.h,
      left: 22.w,
      right: 22.w,
      child: SafeArea(top: false, child: actionBtn),
    );
  }

  Widget _buildGalleryBtn() {
    return GestureDetector(
      onTap: () => _pickAndScan(ImageSource.gallery),
      child: Container(
        width: 50.r,
        height: 50.r,
        decoration: const BoxDecoration(
          color: Color(0xFFFAF2DE),
          shape: BoxShape.circle,
        ),
        child: Icon(
          Icons.image_outlined,
          color: const Color(0xFFC83A2D),
          size: 27.sp,
        ),
      ),
    );
  }

  Widget _buildShutterBtn() {
    return GestureDetector(
      onTap: () => _pickAndScan(ImageSource.camera),
      child: Container(
        key: _shutterKey,
        width: 70.r,
        height: 70.r,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 4.r),
        ),
        child: Padding(
          padding: EdgeInsets.all(1.r),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.grey[500]!, width: 4.r),
            ),
          ),
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
    return Container(
      height: 50.h,
      padding: EdgeInsets.all(6.r),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF6D6),
        borderRadius: BorderRadius.circular(35.r),
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
          padding: EdgeInsets.symmetric(horizontal: 22.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Enter ingredients one by one",
                style: TextStyle(
                  color: const Color(0xFF64748B),
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 10.h),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16.r),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: TextField(
                  controller: _ingCtrl,
                  textCapitalization: TextCapitalization.words,
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w500,
                  ),
                  decoration: InputDecoration(
                    hintText: 'e.g., Tomato, Cheese...',
                    hintStyle: TextStyle(
                      color: const Color(0xFF94A3B8),
                      fontSize: 14.sp,
                    ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 14.h,
                    ),
                    suffixIcon: IconButton(
                      onPressed: _addTypedIngredient,
                      icon: Icon(
                        Icons.add_circle_rounded,
                        color: const Color(0xFFC83A2D),
                        size: 26.sp,
                      ),
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
                        activeColor: const Color(0xFFC83A2D),
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

  // ── Results Page ──────────────────────────────────────────────────────────
  Widget _buildResultsPage() {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    return ListView(
      padding: EdgeInsets.fromLTRB(22.w, 10.h, 22.w, bottomInset + 120.h),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Image.asset(
              'assets/images/logo2.png',
              width: 40.w,
              fit: BoxFit.contain,
            ),
            GestureDetector(
              onTap: () {
                _updateState(ScanState.scan);
                if (widget.onClose != null) widget.onClose!();
              },
              child: Container(
                padding: EdgeInsets.all(6.r),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.close_rounded,
                  size: 20.sp,
                  color: Colors.grey[700],
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 20.h),
        Text(
          "Recipes You Can Cook Now",
          style: TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 20.sp,
            color: const Color(0xFF1E293B),
          ),
        ),
        SizedBox(height: 20.h),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _recipes.isNotEmpty
              ? (_recipes.length > 10 ? 10 : _recipes.length)
              : 6,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 14.h,
            crossAxisSpacing: 14.w,
            childAspectRatio: 0.72,
          ),
          itemBuilder: (_, i) {
            if (_recipes.isEmpty) return const RecipeGridSkeleton(itemCount: 1, padding: EdgeInsets.zero);
            final recipe = _recipes[i];
            
            return ValueListenableBuilder<List<Recipe>?>(
              valueListenable: RecipeService.instance.myRecipesNotifier,
              builder: (context, savedRecipes, _) {
                final savedIds = (savedRecipes ?? []).map((r) => r.id).toSet();
                final savedNames = (savedRecipes ?? []).map((r) => r.name.toLowerCase()).toSet();
                
                final isSaved = _savedRecipeNames.contains(recipe.name) || 
                                (recipe.id.isNotEmpty && savedIds.contains(recipe.id)) ||
                                (recipe.name.isNotEmpty && savedNames.contains(recipe.name.toLowerCase()));

                return RecipeCard(
                  recipe: recipe,
                  useValidationIcon: true,
                  isValidated: isSaved,
                  useScanButton: true,
                  onValidateTap: () => _handleValidation(recipe),
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      AppRoutes.recipeDetail,
                      arguments: {'recipe': recipe, 'isPreview': !isSaved},
                    );
                  },
                );
              },
            );
          },
        ),
        Text(
          "Your Ingredients",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20.sp),
        ),
        Text(
          "We found ${(_ingredients.length + _restrictedIngredients.length) > 0 ? (_ingredients.length + _restrictedIngredients.length) : 0} items in your kitchen",
          style: TextStyle(color: Color(0xFF6B7280), fontSize: 14.sp),
        ),
        SizedBox(height: 12.h),
        // Add Ingredient Input
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: TextField(
            controller: _ingCtrl,
            textCapitalization: TextCapitalization.words,
            onSubmitted: (val) {
              if (val.trim().isNotEmpty) {
                _addIngredientToResults(val.trim());
              }
            },
            decoration: InputDecoration(
              hintText: "Add missing ingredient...",
              hintStyle: TextStyle(
                fontSize: 13.sp,
                color: const Color(0xFF94A3B8),
              ),
              border: InputBorder.none,
              prefixIcon: Icon(
                Icons.add_rounded,
                color: const Color(0xFFC83A2D),
                size: 20.sp,
              ),
              contentPadding: EdgeInsets.symmetric(
                horizontal: 12.w,
                vertical: 10.h,
              ),
            ),
          ),
        ),
        if (_suggestedIngredients.isNotEmpty && _state == ScanState.results)
          Padding(
            padding: EdgeInsets.only(top: 4.h),
            child: Material(
              elevation: 4,
              borderRadius: BorderRadius.circular(12.r),
              child: Container(
                constraints: BoxConstraints(maxHeight: 180.h),
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
                        _addIngredientToResults(
                          _capitalize(item['name'] ?? ''),
                        );
                      },
                    );
                  },
                ),
              ),
            ),
          ),
        SizedBox(height: 16.h),
        if (_ingredients.isEmpty && _restrictedIngredients.isEmpty)
          Text(
            "No items detected.",
            style: TextStyle(color: Colors.grey, fontSize: 13.sp),
          )
        else
          Wrap(
            spacing: 8.w,
            runSpacing: 10.h,
            children: [
              ..._ingredients.map(
                (ing) => _buildYellowChip(
                  ing.name,
                  icon: ing.icon,
                  onDelete: () => _removeIngredientFromResults(ing, false),
                ),
              ),
              ..._restrictedIngredients.map(
                (ing) => _buildYellowChip(
                  ing.name,
                  icon: ing.icon,
                  isRestricted: true,
                  onDelete: () => _removeIngredientFromResults(ing, true),
                ),
              ),
            ],
          ),
        if (_restrictedIngredients.isNotEmpty)
          Padding(
            padding: EdgeInsets.only(top: 10.h),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline_rounded,
                  size: 14.sp,
                  color: Colors.red[400],
                ),
                SizedBox(width: 6.w),
                Expanded(
                  child: Text(
                    "Some ingredients may not match your dietary preferences.",
                    style: TextStyle(
                      color: Colors.red[600],
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        SizedBox(height: 40.h),
      ],
    );
  }


  Widget _buildYellowChip(
    String label, {
    String? icon,
    bool isRestricted = false,
    VoidCallback? onDelete,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: isRestricted ? Colors.red[50] : const Color(0xFFF2C94C),
        borderRadius: BorderRadius.circular(20.r),
        border: isRestricted ? Border.all(color: Colors.red[200]!) : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            _capitalize(label),
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 12.sp,
              color: Colors.black,
            ),
          ),
          if (onDelete != null) ...[
            SizedBox(width: 4.w),
            GestureDetector(
              onTap: onDelete,
              child: Icon(
                Icons.close_rounded,
                size: 14.sp,
                color: isRestricted ? Colors.red[400] : const Color(0xFF755F0E),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // Widget _buildActionBtn(String label, IconData icon) {
  //   return Container(
  //     height: 50.h,
  //     decoration: BoxDecoration(
  //       color: const Color(0xFFF1F5F9),
  //       borderRadius: BorderRadius.circular(14.r),
  //     ),
  //     child: Row(
  //       mainAxisAlignment: MainAxisAlignment.center,
  //       children: [
  //         Icon(icon, size: 18.sp, color: const Color(0xFF64748B)),
  //         SizedBox(width: 8.w),
  //         Text(
  //           label,
  //           style: TextStyle(
  //             fontWeight: FontWeight.w600,
  //             color: const Color(0xFF64748B),
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  // ── Logic ──────────────────────────────────────────────────────────────────
  void _addTypedIngredient() {
    final text = _ingCtrl.text.trim();
    if (text.isNotEmpty) {
      final capitalized = _capitalize(text);
      
      // Save to recent
      IngredientService.instance.addToRecentTypedIngredient(capitalized).then((_) {
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
      } catch (e) {
        debugPrint('Error taking picture: $e');
        return;
      }
    } else {
      final picker = ImagePicker();
      photo = await picker.pickImage(source: source, imageQuality: 70);
    }

    if (photo == null) return;
    HapticFeedback.mediumImpact();
    setState(() {
      _startAnalysisLoading("Analyzing...");
      _capturedImagePath = photo!.path;
    });

    try {
      final result = await RecipeService.instance.scan(photo);
      final recipes = (result['recipes'] as List? ?? [])
          .map((j) => Recipe.fromJson(j))
          .toList();

      setState(() {
        _recipes.clear();
        _recipes.addAll(recipes);

        _ingredients.clear();
        _ingredients.addAll(
          (result['allowed_ingredients'] as List? ?? [])
              .map((j) => RecipeIngredient.fromJson(j))
              .toList(),
        );

        _restrictedIngredients.clear();
        _restrictedIngredients.addAll(
          (result['restricted_ingredients'] as List? ?? [])
              .map((j) => RecipeIngredient.fromJson(j))
              .toList(),
        );

        _analysisTimer?.cancel();
        _stopAnalysisLoading();
        _capturedImagePath = null;
        _updateState(ScanState.results);
      });
      
      // Save to temporary home suggestions for 3 days
      RecipeService.instance.saveScanResults(recipes);
    } catch (e) {
      setState(() {
        _stopAnalysisLoading();
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

  void _handleValidation(Recipe r) {
    final isSaved = _savedRecipeNames.contains(r.name);
    if (isSaved) {
      IosToast.show(
        context,
        message: "This recipe is already present in your recipes",
        type: ToastType.success,
      );
      return;
    }

    // 1. Optimistic Save immediately 'In Direct'
    RecipeService.instance.createRecipe(r).catchError((e) {
      if (mounted) {
        IosToast.show(context, message: ErrorHelper.getFriendlyMessage(e), type: ToastType.error);
      }
      return r;
    });
    _updateLocalStateForValidation(r);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddToCookbookSheet(
        recipe: r,
        onSuccess: () => _updateLocalStateForValidation(r),
      ),
    );
  }

  void _updateLocalStateForValidation(Recipe r) {
    if (!mounted) return;
    
    final validatedRecipe = r.copyWith(origin: 'MANUAL', isValidated: true, isSuggested: false);

    // Update local set
    _savedRecipeNames.add(r.name);

    // Update global state via notifiers
    final currentSaved = RecipeService.instance.myRecipesNotifier.value ?? [];
    if (!currentSaved.any((item) => item.id == r.id)) {
      RecipeService.instance.myRecipesNotifier.value = [validatedRecipe, ...currentSaved];
    }

    // Refresh backgrounds
    RecipeService.instance.getMyRecipes(forceRefresh: true).catchError((_) => <Recipe>[]);
    
    setState(() {}); // Local refresh
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




  void _removeIngredientFromResults(RecipeIngredient ing, bool isRestricted) {
    setState(() {
      if (isRestricted) {
        _restrictedIngredients.remove(ing);
      } else {
        _ingredients.remove(ing);
      }
    });
  }

  void _addIngredientToResults(String name) {
    setState(() {
      _ingredients.add(
        RecipeIngredient(
          id: DateTime.now().toString(),
          name: name,
          amount: 1.0,
          unit: "",
          quantity: "1",
        ),
      );
      _ingCtrl.clear();
      _suggestedIngredients = [];
    });
  }

  Future<void> _reprocessFromResults() async {
    final allNames = [
      ..._ingredients.map((i) => i.name),
      ..._restrictedIngredients.map((i) => i.name),
    ];

    if (allNames.isEmpty) {
      IosToast.show(
        context,
        message: "Please keep at least one ingredient",
        type: ToastType.error,
      );
      return;
    }

    setState(() {
      _startAnalysisLoading("Analyzing...");
    });

    try {
      final response = await RecipeService.instance.scanTyped(allNames);

      final List<RecipeIngredient> allowed =
          (response['allowed_ingredients'] as List)
              .map((i) => RecipeIngredient.fromJson(i))
              .toList();
      final List<RecipeIngredient> restricted =
          (response['restricted_ingredients'] as List)
              .map((i) => RecipeIngredient.fromJson(i))
              .toList();
      final List<Recipe> recipes = (response['recipes'] as List)
          .map((r) => Recipe.fromJson(r))
          .toList();

      if (mounted) {
        setState(() {
          _ingredients.clear();
          _ingredients.addAll(allowed);
          _restrictedIngredients.clear();
          _restrictedIngredients.addAll(restricted);
          _recipes.clear();
          _recipes.addAll(recipes);
          _stopAnalysisLoading();
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _stopAnalysisLoading());
        IosToast.show(
          context,
          message: ErrorHelper.getFriendlyMessage(e),
          type: ToastType.error,
        );
      }
    }
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
    // Give more width ratio to the longer "Type Ingredients" text
    final int flexValue = label.length > 10 ? 12 : 7;
    
    return Expanded(
      flex: flexValue,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: double.infinity,
          margin: EdgeInsets.symmetric(horizontal: 2.w),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: active ? const Color(0xFFC83A2D) : Colors.transparent,
            borderRadius: BorderRadius.circular(25.r),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: active ? Colors.white : const Color(0xFF6B7280),
              fontWeight: FontWeight.w800,
              fontSize: 11.sp,
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
    final r = 5.0;

    canvas.drawLine(Offset(0, corner), Offset(0, r), p);
    canvas.drawArc(Rect.fromLTWH(0, 0, r * 2, r * 2), 3.14, 1.57, false, p);
    canvas.drawLine(Offset(r, 0), Offset(corner, 0), p);
    canvas.drawLine(Offset(w - corner, 0), Offset(w - r, 0), p);
    canvas.drawArc(
      Rect.fromLTWH(w - 2 * r, 0, r * 2, r * 2),
      -1.57,
      1.57,
      false,
      p,
    );
    canvas.drawLine(Offset(w, r), Offset(w, corner), p);
    canvas.drawLine(Offset(w, h - corner), Offset(w, h - r), p);
    canvas.drawArc(
      Rect.fromLTWH(w - 2 * r, h - 2 * r, r * 2, r * 2),
      0,
      1.57,
      false,
      p,
    );
    canvas.drawLine(Offset(w - r, h), Offset(w - corner, h), p);
    canvas.drawLine(Offset(corner, h), Offset(r, h), p);
    canvas.drawArc(
      Rect.fromLTWH(0, h - 2 * r, r * 2, r * 2),
      1.57,
      1.57,
      false,
      p,
    );
    canvas.drawLine(Offset(0, h - r), Offset(0, h - corner), p);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
