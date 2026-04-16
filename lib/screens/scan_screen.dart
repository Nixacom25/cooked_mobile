import 'dart:io';
import 'dart:ui' as ui;
import 'dart:typed_data';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:camera/camera.dart';
import 'package:permission_handler/permission_handler.dart';
import '../routes/app_routes.dart';
import '../core/utils/error_helper.dart';
import '../services/ingredient_service.dart';
import '../services/recipe_service.dart';
import '../widgets/recipe_card.dart';
import '../models/recipe.dart';
import '../core/widgets/ios_toast.dart';

enum ScanState { scan, type, saved, results }

class ScanScreen extends StatefulWidget {
  final ValueNotifier<bool> isActiveNotifier;
  final ValueNotifier<bool>? isResultsModeNotifier;
  final VoidCallback? onClose;

  const ScanScreen({
    super.key,
    required this.isActiveNotifier,
    this.isResultsModeNotifier,
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

  final List<RecipeIngredient> _ingredients = [];
  final List<RecipeIngredient> _restrictedIngredients = [];
  final List<Recipe> _recipes = [];
  final Set<String> _savedRecipeNames = {};

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

  void _updateState(ScanState newState) {
    if (!mounted) return;
    setState(() {
      _state = newState;
    });
    widget.isResultsModeNotifier?.value = (newState == ScanState.results);
  }

  @override
  void initState() {
    super.initState();
    widget.isActiveNotifier.addListener(_onActiveStateChanged);
    _fetchSavedIngredients();
    if (widget.isActiveNotifier.value) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _initCamera());
    } else {
      _cameraStatus = "On hold";
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
      final success = await IngredientService.instance.unsaveIngredient(existing['id'].toString());
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
      } else {
        _selectedSavedNames.add(name);
      }
    });
  }

  Future<void> _deleteSavedIngredient(String id) async {
    final success = await IngredientService.instance.unsaveIngredient(id);
    if (success) _fetchSavedIngredients();
  }

  Future<void> _generateFromTyped() async {
    final allIngredients = [..._typedIngredients, ..._selectedSavedNames];
    if (allIngredients.isEmpty) {
      IosToast.show(context, message: "Please add or select ingredients", type: ToastType.error);
      return;
    }

    setState(() {
      _isInitializing = true;
      _cameraStatus = "Generating Recipes...";
    });

    try {
      final response = await RecipeService.instance.scanTyped(allIngredients);
      
      final List<RecipeIngredient> allowed = (response['allowed_ingredients'] as List)
          .map((i) => RecipeIngredient.fromJson(i))
          .toList();
      final List<RecipeIngredient> restricted = (response['restricted_ingredients'] as List)
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
          _isInitializing = false;
          _typedIngredients.clear();
          _updateState(ScanState.results);
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isInitializing = false);
        IosToast.show(context, message: e.toString(), type: ToastType.error);
      }
    }
  }

  void _onActiveStateChanged() {
    if (widget.isActiveNotifier.value && !_isCameraInitialized) {
      _initCamera();
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
    if (_lastInitAttempt != null && now.difference(_lastInitAttempt!).inSeconds < 5) {
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
    await Permission.microphone.request();
    
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
    await Future.delayed(const Duration(milliseconds: 200)); // Hardware stabilization
    
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
      try { await _cameraController!.stopImageStream(); } catch (_) {}
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
    if (_lastFrameTime != null && now.difference(_lastFrameTime!).inMilliseconds < 150) {
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
          int g = (yValue - 0.337633 * uValue - 0.698001 * vValue).toInt().clamp(0, 255);
          int b = (yValue + 1.732446 * uValue).toInt().clamp(0, 255);

          final int rgbaIndex = (y * width + x) * 4;
          rgba[rgbaIndex] = r;
          rgba[rgbaIndex + 1] = g;
          rgba[rgbaIndex + 2] = b;
          rgba[rgbaIndex + 3] = 255;
        }
      }

      ui.decodeImageFromPixels(
        rgba,
        width,
        height,
        ui.PixelFormat.rgba8888,
        (ui.Image img) {
          if (mounted) {
            setState(() {
              _decodedFrame?.dispose();
              _decodedFrame = img;
              _isProcessingFrame = false;
            });
          } else {
            img.dispose();
          }
        },
      );
    } catch (e) {
      _isProcessingFrame = false;
    }
  }

  @override
  void dispose() {
    widget.isActiveNotifier.removeListener(_onActiveStateChanged);
    _disposeCamera();
    _ingCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    debugPrint("BUILD_SCAN: state=$_state manual=$_useManualStreaming init=$_isCameraInitialized status=$_cameraStatus notify=${widget.isActiveNotifier.value}");
    bool showPill = _state != ScanState.results;
    return Scaffold(
      backgroundColor: _state == ScanState.scan ? Colors.black : Colors.white,
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
                if (_state != ScanState.scan) _buildDynamicHeader(),
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
          _buildFloatingActions(),

          // 5. Success Message Overlay
          if (_showingSuccessMessage) _buildSuccessOverlay(),

          // 6. Bottom Pill Navigation
          if (showPill)
            Positioned(
              bottom: 60.h,
              left: 22.w,
              right: 22.w,
              child: _buildBottomPillNav(),
            ),
        ],
      ),
    );
  }

  Widget _buildBackground() {
    // Show white/empty background for non-scan states
    if (_state != ScanState.scan) {
      return Container(color: Colors.white);
    }

    // NEW: If we are scanning, show the captured frame (freeze-frame)
    if (_showingSuccessMessage && _capturedImagePath != null) {
      return Container(
        width: double.infinity,
        height: double.infinity,
        child: Image.file(
          File(_capturedImagePath!),
          fit: BoxFit.cover,
        ),
      );
    }

    return Stack(
      children: [
        // 1. MAIN DISPLAY LAYER (Native or Manual)
        Positioned.fill(
          child: Container(
            color: Colors.black,
            child: _buildCameraLayer(),
          ),
        ),

        // 2. DIAGNOSTIC LAYER (Only show if NOT ready or if manual is active)
        if (!_isCameraInitialized || _hasCameraError || _isInitializing)
          Positioned.fill(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_isInitializing)
                    const CircularProgressIndicator(color: Colors.white),
                  SizedBox(height: 16.h),
                  // Status Text
                  Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Text(
                      _useManualStreaming
                          ? "MODE: DIRECT STREAM (Logic)"
                          : _cameraStatus,
                      style: TextStyle(
                        color:
                            _useManualStreaming ? Colors.amber : Colors.white70,
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
              child: Icon(Icons.help_outline_rounded, color: Colors.white24, size: 20.sp),
            ),
          ),
        
        // 4. Close Icon (Top-left) for Scan mode
        if (_state == ScanState.scan)
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
                child: Icon(Icons.close_rounded, color: Colors.white, size: 22.sp),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildCameraLayer() {
    if (!_isCameraInitialized || _cameraController == null || !_cameraController!.value.isInitialized) {
      return const SizedBox();
    }

    if (_useManualStreaming && _decodedFrame != null) {
      return RepaintBoundary(
        child: Center(
          child: RotatedBox(
            quarterTurns: 1,
            child: RawImage(
              image: _decodedFrame,
              fit: BoxFit.cover,
            ),
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
    if (_state == ScanState.results) {
      return Padding(
        padding: EdgeInsets.fromLTRB(22.w, 10.h, 22.w, 20.h),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            GestureDetector(
              onTap: widget.onClose,
              child: Container(
                padding: EdgeInsets.all(6.r),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.close_rounded, size: 20.sp, color: Colors.grey[700]),
              ),
            ),
            // Optional: Info button on the right for results page too if needed
            Icon(Icons.help_outline_rounded, color: Colors.grey[400], size: 20.sp),
          ],
        ),
      );
    }

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
              child: Icon(Icons.close_rounded, size: 20.sp, color: Colors.grey[700]),
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
      child: Container(
        width: 300.w,
        height: 250.h,
        child: CustomPaint(
          painter: _FramePainter(
            corner: 30.r,
            thick: 3.w,
            color: const Color(0xFFCC3333),
          ),
        ),
      ),
    );
  }

  Widget _buildFloatingActions() {
    if (_state == ScanState.scan) {
      return Positioned(
        bottom: 130.h,
        left: 0,
        right: 0,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildGalleryBtn(),
            SizedBox(width: 60.w),
            _buildShutterBtn(),
            SizedBox(width: 85.w),
          ],
        ),
      );
    }

    // "Add" or "Scan More" buttons
    Widget actionBtn;
    if (_state == ScanState.results) {
      actionBtn = _buildWideBtn("Scan More", ScanState.scan);
    } else {
      actionBtn = _buildWideBtn("Add", _generateFromTyped);
    }

    return Positioned(
      bottom: _state == ScanState.results ? 30.h : 110.h,
      left: 22.w,
      right: 22.w,
      child: actionBtn,
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
          color: const Color(0xFFCC3333),
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
      height: 40.h,
      padding: EdgeInsets.all(4.r),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF6D6),
        borderRadius: BorderRadius.circular(30.r),
      ),
      child: Row(
        children: [
          _PillTab(
            label: 'Scan',
            active: _state == ScanState.scan,
            onTap: () => _updateState(ScanState.scan),
          ),
          _PillTab(
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
    return ListView(
      padding: EdgeInsets.symmetric(horizontal: 22.w),
      children: [
        Text(
          "Enter Name",
          style: TextStyle(color: const Color(0xFF6B7280), fontSize: 14.sp),
        ),
        SizedBox(height: 6.h),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(color: const Color(0xFFF1F5F9)),
          ),
          child: TextField(
            controller: _ingCtrl,
            decoration: const InputDecoration(
              hintText: 'Garlic',
              border: InputBorder.none,
            ),
            onSubmitted: (_) => _addTypedIngredient(),
          ),
        ),
        SizedBox(height: 20.h),
        ..._typedIngredients.map((ing) => _buildIngredientCard(
          ing,
          isSaved: _savedIngredients.any((si) => si['name'].toString().toLowerCase() == ing.toLowerCase()),
          onHeartTap: () => _toggleSaveIngredient(ing),
        )),
      ],
    );
  }

  // ── Tab 3: Saved ──────────────────────────────────────────────────────────
  Widget _buildSavedTab() {
    if (_isLoadingSaved) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_savedIngredients.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.only(top: 40.h),
          child: Text(
            "No saved ingredients yet.",
            style: TextStyle(color: const Color(0xFF6B7280), fontSize: 14.sp),
          ),
        ),
      );
    }
    return ListView(
      padding: EdgeInsets.symmetric(horizontal: 22.w),
      children: [
        ..._savedIngredients.map((ing) => _buildIngredientCard(
          ing['name'] ?? '',
          icon: ing['icon'],
          isSelected: _selectedSavedNames.contains(ing['name']),
          onSelectionTap: () => _toggleSavedSelection(ing['name']),
          onDeleteTap: () => _deleteSavedIngredient(ing['id'].toString()),
        )),
      ],
    );
  }

  Widget _buildIngredientCard(
    String name, {
    String? icon,
    bool? isSaved,
    bool? isSelected,
    VoidCallback? onHeartTap,
    VoidCallback? onSelectionTap,
    VoidCallback? onDeleteTap,
    bool showIcon = false,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: Row(
        children: [
          if (onSelectionTap != null)
            Padding(
              padding: EdgeInsets.only(right: 12.w),
              child: GestureDetector(
                onTap: onSelectionTap,
                child: Icon(
                  (isSelected ?? false) ? Icons.check_box_rounded : Icons.check_box_outline_blank_rounded,
                  color: (isSelected ?? false) ? const Color(0xFFCC3333) : const Color(0xFFCBD5E1),
                  size: 24.sp,
                ),
              ),
            ),
          if (showIcon && icon != null) ...[
            Text(icon, style: TextStyle(fontSize: 18.sp)),
            SizedBox(width: 12.w),
          ] else
            SizedBox(width: 4.w),
          Expanded(
            child: Text(
              name,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 16.sp,
                color: const Color(0xFF1E293B),
              ),
            ),
          ),
          if (onHeartTap != null)
            GestureDetector(
              onTap: onHeartTap,
              child: Icon(
                Icons.favorite_rounded,
                color: (isSaved ?? false) ? const Color(0xFFCC3333) : const Color(0xFFCBD5E1),
                size: 22.sp,
              ),
            ),
          if (onDeleteTap != null)
            GestureDetector(
              onTap: onDeleteTap,
              child: Icon(
                Icons.delete_outline_rounded,
                color: const Color(0xFF94A3B8),
                size: 22.sp,
              ),
            ),
        ],
      ),
    );
  }

  // ── Results Page ──────────────────────────────────────────────────────────
  Widget _buildResultsPage() {
    return ListView(
      padding: EdgeInsets.symmetric(horizontal: 22.w),
      children: [
        Text(
          "Recipes You Can Cook Now",
          style: TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 20.sp,
            color: const Color(0xFF1E293B),
          ),
        ),
        SizedBox(height: 16.h),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _recipes.length > 0
              ? (_recipes.length > 10 ? 10 : _recipes.length)
              : 4,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 14.h,
            crossAxisSpacing: 14.w,
            childAspectRatio: 0.82,
          ),
          itemBuilder: (_, i) {
            if (_recipes.isEmpty) return _buildMockResultCard(i);
            final recipe = _recipes[i];
            final isSaved = _savedRecipeNames.contains(recipe.name);
            return RecipeCard(
              recipe: recipe,
              useValidationIcon: true,
              isValidated: isSaved,
              onValidateTap: isSaved ? null : () => _saveGeneratedRecipe(recipe),
              onTap: () {
                Navigator.pushNamed(
                  context,
                  AppRoutes.recipeDetail,
                  arguments: {
                    'recipe': recipe,
                    'isPreview': true,
                  },
                );
              },
            );
          },
        ),
        SizedBox(height: 30.h),
        Text(
          "Your Ingredients",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20.sp),
        ),
        Text(
          "We found ${(_ingredients.length + _restrictedIngredients.length) > 0 ? (_ingredients.length + _restrictedIngredients.length) : 0} items in your kitchen",
          style: TextStyle(color: Color(0xFF6B7280), fontSize: 14.sp),
        ),
        SizedBox(height: 16.h),
        if (_ingredients.isEmpty && _restrictedIngredients.isEmpty)
          Text("No items detected.", style: TextStyle(color: Colors.grey, fontSize: 13.sp))
        else
          Wrap(
            spacing: 8.w,
            runSpacing: 10.h,
            children: [
              ..._ingredients.map((ing) => _buildYellowChip(ing.name, icon: ing.icon, showIcon: true)),
              ..._restrictedIngredients.map((ing) => _buildYellowChip(ing.name, icon: ing.icon, isRestricted: true, showIcon: true)),
            ],
          ),
        SizedBox(height: 40.h),
      ],
    );
  }

  Widget _buildMockResultCard(int i) {
    final names = [
      "Cheese Omelet",
      "Alfredo Fettuccini",
      "Lemon Grilled Salmon",
      "Chicken Stir-Fry",
    ];
    final imgs = [
      "assets/images/recipe_omelet.png",
      "assets/images/recipe_pasta.png",
      "assets/images/recipe_salmon.png",
      "assets/images/recipe_stir_fry.png",
    ];
    final times = ["5 min", "20 min", "20 min", "25 min"];
    final kcals = ["117 kcal", "417 kcal", "217 kcal", "317 kcal"];

    return RecipeCard(
      name: names[i % 4],
      img: imgs[i % 4],
      time: times[i % 4],
      kcal: kcals[i % 4],
      onTap: () {},
    );
  }

  Widget _buildYellowChip(String label, {String? icon, bool isRestricted = false, bool showIcon = false}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: isRestricted ? Colors.red[50] : const Color(0xFFF2C94C),
        borderRadius: BorderRadius.circular(20.r),
        border: isRestricted ? Border.all(color: Colors.red[200]!) : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showIcon && icon != null && icon.isNotEmpty) ...[
            Text(icon, style: TextStyle(fontSize: 14.sp)),
            SizedBox(width: 6.w),
          ],
          Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 13.sp,
              color: Colors.black,
            ),
          ),
          SizedBox(width: 6.w),
          Container(
            padding: EdgeInsets.all(2.r),
            decoration: const BoxDecoration(
              color: Color(0xFF755F0E),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.close_rounded,
              size: 10.sp,
              color: const Color(0xFFF2C94C),
            ),
          ),
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
      setState(() {
        _typedIngredients.add(text);
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
    setState(() {
      _showingSuccessMessage = true;
      _cameraStatus = "Scanning and generating recipes...";
      _capturedImagePath = photo!.path;
    });
    try {
      final result = await RecipeService.instance.scan(photo);
      setState(() {
        _recipes.clear();
        _recipes.addAll(
          (result['recipes'] as List? ?? []).map((j) => Recipe.fromJson(j)).toList(),
        );

        _ingredients.clear();
        _ingredients.addAll(
          (result['allowed_ingredients'] as List? ?? []).map((j) => RecipeIngredient.fromJson(j)).toList(),
        );

        _restrictedIngredients.clear();
        _restrictedIngredients.addAll(
          (result['restricted_ingredients'] as List? ?? []).map((j) => RecipeIngredient.fromJson(j)).toList(),
        );

        _showingSuccessMessage = false;
        _capturedImagePath = null;
        _updateState(ScanState.results);
      });
    } catch (e) {
      setState(() {
        _showingSuccessMessage = false;
        _capturedImagePath = null;
      });
      IosToast.show(
        context,
        message: ErrorHelper.getFriendlyMessage(e),
        type: ToastType.error,
      );
    }
  }

  Future<void> _saveGeneratedRecipe(Recipe recipe) async {
    try {
      await RecipeService.instance.createRecipe(recipe);
      if (mounted) {
        setState(() {
          _savedRecipeNames.add(recipe.name);
        });
        IosToast.show(
          context,
          message: "Recipe saved to your collection!",
          type: ToastType.success,
        );
      }
    } catch (e) {
      if (mounted) {
        IosToast.show(
          context,
          message: "Failed to save recipe: ${e.toString()}",
          type: ToastType.error,
        );
      }
    }
  }

  Widget _buildSuccessOverlay() {
    return Container(
      color: Colors.black.withOpacity(0.85),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.check_circle_outline, color: Colors.green, size: 80.sp),
            SizedBox(height: 24.h),
            Text(
              'Success!',
              style: TextStyle(
                color: Colors.white,
                fontSize: 28.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 40.h),
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation(Color(0xFFCC3333)),
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
    required this.label,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: double.infinity,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: active ? const Color(0xFFCC3333) : Colors.transparent,
            borderRadius: BorderRadius.circular(25.r),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: active ? Colors.white : const Color(0xFF6B7280),
              fontWeight: FontWeight.bold,
              fontSize: 12.sp,
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
