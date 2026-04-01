import 'dart:async';
import 'package:flutter/material.dart';
import 'package:app_ecommerce/services/cart_service.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:app_ecommerce/screens/map_picker_screen.dart';
import 'package:app_ecommerce/widgets/login_modal.dart';
import 'package:record/record.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:app_ecommerce/services/api_service.dart';
import 'package:app_ecommerce/services/auth_service.dart';
import 'package:geocoding/geocoding.dart' as geo;

class ValidationScreen extends StatefulWidget {
  const ValidationScreen({super.key});

  @override
  State<ValidationScreen> createState() => _ValidationScreenState();
}

class _ValidationScreenState extends State<ValidationScreen> {
  // Form State
  String _selectedDate = 'AUJOURD\'HUI';
  String _selectedTime = 'LE PLUS RAPIDEMENT POSSIBLE';
  bool _withAssembly = false;
  String _paymentMethod = 'CASH';
  String _noteType = 'ECRIT';

  // Multi-selection state
  final Map<int, int> _selectedColors = {0xFF000000: 1}; // Default 1 Black
  final Map<String, int> _selectedDimensions = {
    'Standard': 1,
  }; // Default 1 Standard

  // Controllers
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _phone1Controller = TextEditingController();
  final TextEditingController _phone2Controller = TextEditingController();
  final TextEditingController _noteController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();

  bool _isSubmitting = false;
  double? _latitude;
  double? _longitude;
  bool _isDakar = false;
  bool get _isLoggedIn => AuthService().isLoggedIn.value;
  bool _isRecording = false;
  int _recordingDuration = 0;
  String? _recordedFilePath;
  Timer? _recordingTimer;
  bool _isPlaying = false;
  int _playbackPosition = 0;
  Timer? _playbackTimer;

  final AudioRecorder _audioRecorder = AudioRecorder();
  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();
    // Use the controllers defined in the class
    _locationController.text = ''; // Placeholder
    _firstNameController.text = '';
    _lastNameController.text = '';
    _phone1Controller.text = '';

    _audioPlayer.onPlayerComplete.listen((event) {
      _stopPlayback();
    });
  }

  @override
  void dispose() {
    _noteController.dispose();
    _locationController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phone1Controller.dispose();
    _phone2Controller.dispose();
    _dateController.dispose();
    _timeController.dispose();
    _recordingTimer?.cancel();
    _playbackTimer?.cancel();
    _audioRecorder.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _getCurrentLocation() async {
    final bool hasPermission = await _handleLocationPermission();
    if (!hasPermission) return;

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Récupération de la position...')),
      );
    }

    try {
      Position position = await Geolocator.getCurrentPosition();
      String mapsLink =
          "https://www.google.com/maps/search/?api=1&query=${position.latitude},${position.longitude}";

      setState(() {
        _locationController.text = mapsLink;
        _latitude = position.latitude;
        _longitude = position.longitude;
      });
      _checkIfDakar(position.latitude, position.longitude);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Erreur: $e')));
      }
    }
  }

  Future<bool> _handleLocationPermission() async {
    LocationPermission permission;

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      // Show custom dialog BEFORE system permission dialog
      final bool? proceed = await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: const Text('Autoriser la localisation'),
          content: const Text(
            'Pour faciliter votre livraison, l\'application a besoin d\'accéder à votre position actuelle.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('PLUS TARD'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE65100),
              ),
              child: const Text('AUTORISER'),
            ),
          ],
        ),
      );

      if (proceed != true) return false;

      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Permission de localisation refusée')),
          );
        }
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Permission bloquée'),
            content: const Text(
              'La localisation est bloquée de manière permanente dans vos paramètres. Veuillez l\'activer manuellement pour continuer.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('ANNULER'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  Geolocator.openAppSettings();
                },
                child: const Text('OUVRIR LES PARAMÈTRES'),
              ),
            ],
          ),
        );
      }
      return false;
    }

    // Permission granted, now check if GPS service is actually ON
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Les services de localisation sont désactivés. Veuillez les activer.',
            ),
          ),
        );
      }
      return false;
    }

    return true;
  }

  Future<void> _openMapPicker() async {
    // Permission is OPTIONAL here as user can just drag the marker manually.
    // If they have it, the map can show their current location dot.
    if (!mounted) return;

    final LatLng? result = await Navigator.push(
      context,
      MaterialPageRoute(
        settings: const RouteSettings(name: '/map_picker'),
        builder: (context) => MapPickerScreen(
          initialPosition: _latitude != null && _longitude != null
              ? LatLng(_latitude!, _longitude!)
              : null,
        ),
      ),
    );

    if (result != null) {
      String mapsLink =
          "https://www.google.com/maps/search/?api=1&query=${result.latitude},${result.longitude}";
      setState(() {
        _locationController.text = mapsLink;
        _latitude = result.latitude;
        _longitude = result.longitude;
      });
      _checkIfDakar(result.latitude, result.longitude);
    }
  }

  Future<void> _checkIfDakar(double lat, double lng) async {
    try {
      List<geo.Placemark> placemarks = await geo.placemarkFromCoordinates(
        lat,
        lng,
      );
      if (placemarks.isNotEmpty) {
        final p = placemarks.first;
        // Check if locality or subLocality contains "Dakar"
        final bool isDakarCity =
            (p.locality?.toLowerCase().contains('dakar') ?? false) ||
            (p.subLocality?.toLowerCase().contains('dakar') ?? false) ||
            (p.administrativeArea?.toLowerCase().contains('dakar') ?? false);
        setState(() {
          _isDakar = isDakarCity;
          if (!_isDakar) _withAssembly = false; // Reset if not in Dakar
        });
      }
    } catch (e) {
      debugPrint("Geocoding error: $e");
    }
  }

  Future<void> _selectDate() async {
    DateTime now = DateTime.now();

    // D'aujourd'hui + 2 jours jusqu'à + 6 jours
    // (Puisque Aujourd'hui et Demain sont déjà des options séparées)
    List<DateTime> nextDays = List.generate(
      5, // 5 prochains jours après demain
      (index) => now.add(Duration(days: index + 2)),
    );

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'CHOISIR UNE DATE',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    color: Colors.black87,
                  ),
                ),
              ),
              const Divider(height: 1),
              ...nextDays.map((date) {
                String formattedDate = DateFormat(
                  'EEEE d MMMM yyyy',
                  'fr_FR',
                ).format(date);
                // Majuscule sur le premier lettre
                formattedDate =
                    formattedDate[0].toUpperCase() + formattedDate.substring(1);
                String shortDate = DateFormat('dd/MM/yyyy').format(date);

                return ListTile(
                  title: Text(
                    formattedDate,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  trailing: const Icon(
                    Icons.calendar_today,
                    size: 18,
                    color: Color(0xFFE65100),
                  ),
                  onTap: () {
                    setState(() {
                      _selectedDate = 'AUTRE';
                      _dateController.text = shortDate;
                    });
                    Navigator.pop(context);
                  },
                );
              }).toList(),
            ],
          ),
        );
      },
    );
  }

  Future<void> _selectTime() async {
    TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      initialEntryMode:
          TimePickerEntryMode.input, // Utiliser le clavier par défaut
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(primary: Color(0xFFE65100)),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && mounted) {
      setState(() {
        _selectedTime = 'AUTRE HEURE';
        _timeController.text = picked.format(context);
      });
    }
  }

  // --- Logic ---

  Future<void> _submitOrder() async {
    if (!_isLoggedIn) {
      LoginModal.show(
        context,
        firstName: _firstNameController.text,
        lastName: _lastNameController.text,
        phone: _phone1Controller.text,
      );
      return;
    }

    if (_firstNameController.text.isEmpty || _phone1Controller.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez remplir au moins le nom et le téléphone.'),
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final items = CartService().itemsNotifier.value
          .map(
            (item) => {'productId': item.product.id, 'quantity': item.quantity},
          )
          .toList();

      // Format Delivery Date
      DateTime deliveryDateTime = DateTime.now();
      if (_selectedDate == 'DEMAIN') {
        deliveryDateTime = DateTime.now().add(const Duration(days: 1));
      } else if (_selectedDate == 'AUTRE' && _dateController.text.isNotEmpty) {
        try {
          deliveryDateTime = DateFormat(
            'dd/MM/yyyy',
          ).parse(_dateController.text);
        } catch (_) {}
      }
      final dateStr = DateFormat('yyyy-MM-dd').format(deliveryDateTime);

      // Format Delivery Time
      String timeStr = "ASAP";
      if (_selectedTime == 'AUTRE HEURE' && _timeController.text.isNotEmpty) {
        timeStr = _timeController.text;
      }

      final orderData = {
        'clientFirstName': _firstNameController.text,
        'clientLastName': _lastNameController.text,
        'clientPhoneNumber': _phone1Controller.text,
        'clientEmail': '', // Optional
        'items': items,
        'deliveryAddress': _locationController.text,
        'latitude': _latitude,
        'longitude': _longitude,
        'deliveryDate': dateStr,
        'deliveryTime': timeStr,
        'assemblyIncluded': _withAssembly,
        'paymentMethod': _paymentMethod,
        'notes': _noteType == 'ECRIT'
            ? _noteController.text
            : (_recordedFilePath != null ? 'Note vocale jointe' : ''),
        'voiceNotePath': _noteType == 'VOCAL' ? _recordedFilePath : null,
      };

      await ApiService.postMultipart(
        '/orders',
        {},
        files: _recordedFilePath != null && _noteType == 'VOCAL'
            ? {'audio': File(_recordedFilePath!)}
            : null,
        jsonPartName: 'order',
        jsonData: orderData,
      );

      if (mounted) {
        CartService().clearCart();
        Navigator.popUntil(context, (route) => route.isFirst);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Votre commande a été envoyée avec succès !'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Erreur lors de l\'envoi: $e')));
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cartTotal = CartService().totalNotifier.value;
    final deliveryFee = 5000.0; // Based on mockup
    final finalTotal = cartTotal + deliveryFee;

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 242, 243, 243),
      appBar: AppBar(
        backgroundColor: Colors.white,
        automaticallyImplyLeading: false,
        centerTitle: false,
        titleSpacing: 16,
        elevation: 0,
        shape: const Border(
          bottom: BorderSide(color: Color(0xFF000000), width: 1),
        ),
        title: const Text(
          'VALIDATION',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w900,
            color: Color(0xFF1E2832),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Center(
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  padding: EdgeInsets.zero,
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close, color: Colors.grey, size: 20),
                ),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
        child: Column(
          children: [
            _buildArticlesSection(),
            const SizedBox(height: 16),
            _buildOptionsSection(),
            const SizedBox(height: 16),
            _buildPersonalInfoSection(),
            const SizedBox(height: 16),
            _buildDeliveryScheduleSection(),
            const SizedBox(height: 16),
            _buildAssemblySection(),
            _buildNoteSection(),
            const SizedBox(height: 16),
            _buildPaymentSection(),
            const SizedBox(height: 230),
          ],
        ),
      ),
      bottomSheet: _buildBottomSummary(finalTotal, deliveryFee),
    );
  }

  Widget _buildArticlesSection() {
    return ValueListenableBuilder<List>(
      valueListenable: CartService().itemsNotifier,
      builder: (context, items, _) {
        return _buildSectionContainer(
          title: 'ARTICLES & QUANTITÉ',
          child: Column(
            children: items.map((item) => _buildItemCard(item)).toList(),
          ),
        );
      },
    );
  }

  Widget _buildItemCard(dynamic item) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.network(
              item.product.thumbnailUrl ?? '',
              width: 50,
              height: 50,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                width: 50,
                height: 50,
                color: Colors.grey[200],
                child: const Icon(
                  Icons.image_not_supported_outlined,
                  color: Colors.grey,
                  size: 20,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.product.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 14,
                    fontFamily: 'SF Pro',
                    color: Color(0xFF1E2832),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  '${_formatPrice(item.product.numericPrice)} FCFA',
                  style: const TextStyle(
                    color: Color(0xFFFF6F00),
                    fontWeight: FontWeight.w900,
                    fontFamily: 'SF Pro',
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          _buildQuantityControls(item),
        ],
      ),
    );
  }

  Widget _buildQuantityControls(dynamic item) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: const Color(0xFF1E2832), width: 1.2),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildCircleButton(
            icon: Icons.remove,
            onTap: () => CartService().decrementQuantity(item.product.id),
          ),
          const SizedBox(width: 12),
          Text(
            '${item.quantity}',
            style: const TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: 15,
              fontFamily: 'SF Pro',
              color: Color(0xFF1E2832),
            ),
          ),
          const SizedBox(width: 12),
          _buildCircleButton(
            icon: Icons.add,
            onTap: () => CartService().incrementQuantity(item.product.id),
          ),
        ],
      ),
    );
  }

  Widget _buildCircleButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: const Color(0xFF1E2832), width: 1),
        ),
        child: Icon(icon, size: 16, color: const Color(0xFF1E2832)),
      ),
    );
  }

  String _getColorsSubtitle() {
    if (_selectedColors.isEmpty) return "";
    return _selectedColors.entries
        .map((e) {
          final name = _getColorName(Color(e.key));
          return "${e.value} $name";
        })
        .join(", ");
  }

  String _getDimensionsSubtitle() {
    if (_selectedDimensions.isEmpty) return "";
    return _selectedDimensions.entries
        .map((e) => "${e.value} ${e.key}")
        .join(", ");
  }

  String _getColorName(Color color) {
    if (color == Colors.black) return "Noir";
    if (color == Colors.white) return "Blanc";
    if (color == Colors.grey) return "Gris";
    if (color.value == 0xFFC49A6C) return "Beige";
    return "";
  }

  Widget _buildOptionsSection() {
    return _buildSectionContainer(
      title: '',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'COULEUR',
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 10,
                  color: Colors.black,
                  fontFamily: 'SF Pro',
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                _getColorsSubtitle(),
                style: const TextStyle(
                  fontSize: 10,
                  color: Colors.black38,
                  fontFamily: 'SF Pro',
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildColorCircle(Colors.black),
              _buildColorCircle(Colors.white),
              _buildColorCircle(Colors.grey),
              _buildColorCircle(const Color(0xFFC49A6C)),
            ],
          ),
          const SizedBox(height: 15),
          Row(
            children: [
              const Text(
                'DIMENSIONS',
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 10,
                  color: Colors.black,
                  fontFamily: 'SF Pro',
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                _getDimensionsSubtitle(),
                style: const TextStyle(
                  fontSize: 9,
                  color: Colors.black38,
                  fontFamily: 'SF Pro',
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildDimensionChip('Standard'),
              _buildDimensionChip('1m20'),
              _buildDimensionChip('2m'),
              _buildDimensionChip('3m'),
              _buildDimensionChip('Sur-mesure'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPersonalInfoSection() {
    return _buildSectionContainer(
      title: '',
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  'NOM',
                  'Votre nom',
                  controller: _lastNameController,
                  icon: Icons.person_outline,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildTextField(
                  'PRÉNOM',
                  'Votre prénom',
                  controller: _firstNameController,
                  icon: Icons.person_outline,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  'TÉL. PRINCIPAL',
                  '77...',
                  controller: _phone1Controller,
                  icon: Icons.phone_outlined,
                  keyboardType: TextInputType.phone,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildTextField(
                  'TÉL. 2 (OPTIONNEL)',
                  'Secondaire',
                  controller: _phone2Controller,
                  icon: Icons.phone_outlined,
                  keyboardType: TextInputType.phone,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildTextField(
            'LOCALISATION (LIEN GOOGLE MAPS)',
            'Coller le lien Google Maps ici',
            controller: _locationController,
            icon: Icons.location_on_outlined,
            suffix: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(
                    Icons.map_outlined,
                    color: Color(0xFFFF6F00),
                  ),
                  onPressed: _openMapPicker,
                ),
                IconButton(
                  icon: const Icon(Icons.my_location, color: Color(0xFFFF6F00)),
                  onPressed: _getCurrentLocation,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeliveryScheduleSection() {
    return _buildSectionContainer(
      title: '',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(
                Icons.calendar_today_outlined,
                size: 14,
                color: Color(0xFFFF6F00),
              ),
              SizedBox(width: 6),
              Text(
                'DATE DE LIVRAISON',
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 10,
                  color: Colors.black,
                  fontFamily: 'SF Pro',
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildScheduleChip(
                'AUJOURD\'HUI',
                _selectedDate == 'AUJOURD\'HUI',
                () => setState(() => _selectedDate = 'AUJOURD\'HUI'),
              ),
              const SizedBox(width: 8),
              _buildScheduleChip(
                'DEMAIN',
                _selectedDate == 'DEMAIN',
                () => setState(() => _selectedDate = 'DEMAIN'),
              ),
              const SizedBox(width: 8),
              _buildScheduleChip(
                'AUTRE DATE',
                _selectedDate == 'AUTRE',
                _selectDate,
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: const [
              Icon(Icons.access_time, size: 14, color: Color(0xFFFF6F00)),
              SizedBox(width: 6),
              Text(
                'HEURE DE LIVRAISON',
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 10,
                  color: Colors.black,
                  fontFamily: 'SF Pro',
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildScheduleChip(
                'LE PLUS RAPIDEMENT',
                _selectedTime == 'LE PLUS RAPIDEMENT POSSIBLE',
                () => setState(
                  () => _selectedTime = 'LE PLUS RAPIDEMENT POSSIBLE',
                ),
              ),
              const SizedBox(width: 8),
              _buildTimeDisplayChip(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNoteSection() {
    return _buildSectionContainer(
      title: '',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.description_outlined,
                color: Color(0xFFFF6F00),
                size: 16,
              ),
              const SizedBox(width: 6),
              const Text(
                'NOTE PARTICULIÈRE POUR LE LIVREUR',
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 10,
                  color: Colors.black,
                  fontFamily: 'SF Pro',
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildNoteTypeChip(
                'ÉCRIT',
                _noteType == 'ECRIT',
                () => setState(() => _noteType = 'ECRIT'),
              ),
              const SizedBox(width: 12),
              _buildNoteTypeChip(
                'VOCAL',
                _noteType == 'VOCAL',
                () => setState(() => _noteType = 'VOCAL'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (_noteType == 'ECRIT')
            TextField(
              controller: _noteController,
              maxLines: 3,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                fontFamily: 'SF Pro',
              ),
              decoration: InputDecoration(
                hintText: 'Note particulière...',
                hintStyle: TextStyle(
                  color: Colors.grey[400],
                  fontSize: 14,
                  fontWeight: FontWeight.normal,
                ),
                filled: true,
                fillColor: const Color(0xFFF8F9FA),
                isDense: true,
                contentPadding: const EdgeInsets.all(16),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(
                    color: Colors.grey.shade200,
                    width: 1.5,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(
                    color: Colors.grey.shade200,
                    width: 1.5,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(
                    color: Color(0xFF1E2832),
                    width: 1.5,
                  ),
                ),
              ),
            )
          else
            _buildVocalNotePlaceholder(),
        ],
      ),
    );
  }

  Widget _buildNoteTypeChip(String label, bool selected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFFF6F00) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? const Color(0xFFFF6F00) : Colors.grey.shade300,
            width: 1.5,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : Colors.black87,
            fontWeight: FontWeight.w900,
            fontSize: 11,
            fontFamily: 'SF Pro',
          ),
        ),
      ),
    );
  }

  Widget _buildVocalNotePlaceholder() {
    return GestureDetector(
      onTap: _isRecording
          ? _stopRecording
          : (_recordedFilePath == null ? _startRecording : null),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFFF8F9FA),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200, width: 1.5),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_isRecording) ...[
              const Icon(Icons.circle, color: Colors.red, size: 12),
              const SizedBox(width: 12),
              Text(
                _formatDuration(_recordingDuration),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.red,
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'ENREGISTREMENT...',
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 10,
                  color: Colors.red,
                  letterSpacing: 1,
                ),
              ),
              const Spacer(),
              IconButton(
                onPressed: _stopRecording,
                icon: const Icon(Icons.stop_circle, color: Colors.black),
                iconSize: 32,
                constraints: const BoxConstraints(),
                padding: EdgeInsets.zero,
              ),
            ] else if (_recordedFilePath != null) ...[
              const Icon(Icons.audiotrack, color: Color(0xFFFF6F00), size: 24),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Note vocale enregistrée',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    if (_isPlaying)
                      Padding(
                        padding: const EdgeInsets.only(top: 4.0),
                        child: LinearProgressIndicator(
                          value: _playbackPosition / _recordingDuration,
                          backgroundColor: Colors.grey[200],
                          color: const Color(0xFFFF6F00),
                          minHeight: 2,
                        ),
                      ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () {
                  _stopPlayback();
                  setState(() => _recordedFilePath = null);
                },
                icon: const Icon(Icons.delete_outline, color: Colors.red),
                constraints: const BoxConstraints(),
                padding: EdgeInsets.zero,
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: _isPlaying ? _stopPlayback : _playRecordedVoice,
                icon: Icon(
                  _isPlaying
                      ? Icons.pause_circle_filled
                      : Icons.play_circle_fill,
                  color: const Color(0xFFFF6F00),
                ),
                iconSize: 32,
                constraints: const BoxConstraints(),
                padding: EdgeInsets.zero,
              ),
            ] else ...[
              const Icon(Icons.mic, color: Color(0xFFFF6F00), size: 30),
              const SizedBox(width: 12),
              const Text(
                'Appuyez pour enregistrer',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.black54,
                  fontFamily: 'SF Pro',
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _startRecording() async {
    try {
      if (await _audioRecorder.hasPermission()) {
        final Directory appDocDir = await getApplicationDocumentsDirectory();
        final String path =
            '${appDocDir.path}/note_${DateTime.now().millisecondsSinceEpoch}.m4a';

        const config = RecordConfig();
        await _audioRecorder.start(config, path: path);

        setState(() {
          _isRecording = true;
          _recordingDuration = 0;
          _recordedFilePath = null;
        });

        _recordingTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
          if (mounted) {
            setState(() => _recordingDuration++);
          }
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Permission microphon refusée')),
        );
      }
    } catch (e) {
      print('Error starting recording: $e');
    }
  }

  Future<void> _stopRecording() async {
    _recordingTimer?.cancel();
    final String? path = await _audioRecorder.stop();
    setState(() {
      _isRecording = false;
      _recordedFilePath = path;
    });
  }

  Future<void> _playRecordedVoice() async {
    if (_recordedFilePath == null) return;

    try {
      await _audioPlayer.play(DeviceFileSource(_recordedFilePath!));
      setState(() {
        _isPlaying = true;
        _playbackPosition = 0;
      });

      _playbackTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (mounted) {
          setState(() {
            if (_playbackPosition < _recordingDuration) {
              _playbackPosition++;
            }
          });
        }
      });
    } catch (e) {
      print('Error playing audio: $e');
    }
  }

  void _stopPlayback() {
    _audioPlayer.stop();
    _playbackTimer?.cancel();
    setState(() {
      _isPlaying = false;
      _playbackPosition = 0;
    });
  }

  String _formatDuration(int seconds) {
    final int minutes = seconds ~/ 60;
    final int remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  Widget _buildPaymentSection() {
    return _buildSectionContainer(
      title: '',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(
                Icons.credit_card_outlined,
                color: Color(0xFFFF6F00),
                size: 16,
              ),
              SizedBox(width: 8),
              Text(
                'MÉTHODE DE PAIEMENT',
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 10,
                  color: Colors.black,
                  fontFamily: 'SF Pro',
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildPaymentOption(
            id: 'WAVE',
            title: 'Je valide',
            assetPath: 'assets/images/wave.png',
            isAsset: true,
          ),
          const SizedBox(height: 12),
          _buildPaymentOption(
            id: 'ORANGE_MONEY',
            title: 'Je valide',
            assetPath: 'assets/images/orange.png',
            isAsset: true,
          ),
          const SizedBox(height: 12),
          _buildPaymentOption(
            id: 'CASH',
            title: 'Liquide à la livraison 🚚',
            isAsset: false,
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentOption({
    required String id,
    required String title,
    String? assetPath,
    bool isAsset = false,
  }) {
    final isSelected = _paymentMethod == id;
    return GestureDetector(
      onTap: () => setState(() => _paymentMethod = id),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFFFF3E0) : const Color(0xFFF8F9FA),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? const Color(0xFFFF6F00) : Colors.grey.shade200,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected
                      ? const Color(0xFFFF6F00)
                      : Colors.grey.shade400,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? Center(
                      child: Container(
                        width: 12,
                        height: 12,
                        decoration: const BoxDecoration(
                          color: Color(0xFFFF6F00),
                          shape: BoxShape.circle,
                        ),
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 14,
                  fontFamily: 'SF Pro',
                  color: Color(0xFF1E2832),
                ),
              ),
            ),
            if (isAsset && assetPath != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.asset(
                  assetPath,
                  width: 40,
                  height: 40,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) => Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: const Icon(
                      Icons.payment,
                      color: Colors.grey,
                      size: 20,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildAssemblySection() {
    return ValueListenableBuilder<List>(
      valueListenable: CartService().itemsNotifier,
      builder: (context, items, _) {
        final hasAssemblyItems = items.any(
          (item) => item.product.hasInstallationOption,
        );

        if (!hasAssemblyItems) return const SizedBox.shrink();

        return Column(
          children: [
            _buildSectionContainer(
              title: '',
              child: Row(
                children: [
                  const Icon(
                    Icons.build_circle_outlined,
                    color: Color(0xFFFF6F00),
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'INCLURE LE MONTAGE',
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 11,
                        color: Color(0xFF1E2832),
                        fontFamily: 'SF Pro',
                      ),
                    ),
                  ),
                  Switch(
                    value: _withAssembly,
                    onChanged: (val) {
                      if (!_isDakar && val) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Le montage est disponible uniquement à Dakar.',
                            ),
                          ),
                        );
                        return;
                      }
                      setState(() => _withAssembly = val);
                    },
                    activeColor: const Color(0xFFFF6F00),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
        );
      },
    );
  }

  Widget _buildBottomSummary(double total, double fee) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.black, width: 1)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Livraison',
                  style: TextStyle(
                    color: Colors.grey,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  '${_formatPrice(fee.toInt())} FCFA',
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 16,
                    color: Color(0xFF1E2832),
                  ),
                ),
              ],
            ),
            const Divider(height: 24, thickness: 1.5, color: Colors.black),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'TOTAL À PAYER',
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 18,
                    color: Color(0xFF1E2832),
                  ),
                ),
                Text(
                  '${_formatPrice(total.toInt())} FCFA',
                  style: const TextStyle(
                    color: Color(0xFFFF6F00),
                    fontWeight: FontWeight.w900,
                    fontSize: 24,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 60,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submitOrder,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF6F00),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                child: _isSubmitting
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'JE VALIDE',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionContainer({
    required String title,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF1E2832), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title.isNotEmpty) ...[
            Text(
              title,
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: Color(0xFF000000),
                letterSpacing: 0.2,
              ),
            ),
            const SizedBox(height: 16),
          ],
          child,
        ],
      ),
    );
  }

  Widget _buildColorCircle(Color color) {
    final int colorValue = color.value;
    final int quantity = _selectedColors[colorValue] ?? 0;
    final bool selected = quantity > 0;

    return GestureDetector(
      onTap: () {
        setState(() {
          if (selected) {
            _selectedColors.remove(colorValue);
          } else {
            _selectedColors[colorValue] = 1;
          }
        });
      },
      child: Container(
        margin: const EdgeInsets.only(right: 16),
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(
            color: selected ? Colors.black : Colors.grey.shade300,
            width: selected ? 2.5 : 1,
          ),
          boxShadow: [
            if (selected)
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                spreadRadius: 2,
              ),
          ],
        ),
        child: selected
            ? Stack(
                clipBehavior: Clip.none,
                children: [
                  Positioned(
                    right: -4,
                    top: -4,
                    child: Container(
                      padding: const EdgeInsets.all(5),
                      decoration: const BoxDecoration(
                        color: Color(0xFFFF6F00),
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        '$quantity',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontFamily: 'SF Pro',
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              )
            : null,
      ),
    );
  }

  Widget _buildDimensionChip(String label) {
    final int quantity = _selectedDimensions[label] ?? 0;
    final bool selected = quantity > 0;

    return GestureDetector(
      onTap: () {
        setState(() {
          if (selected) {
            _selectedDimensions.remove(label);
          } else {
            _selectedDimensions[label] = 1;
          }
        });
      },
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: selected ? const Color(0xFFFFF3E0) : Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: selected
                    ? const Color(0xFFFF6F00)
                    : Colors.grey.shade300,
                width: selected ? 2 : 1,
              ),
            ),
            child: Text(
              label,
              style: TextStyle(
                color: selected ? const Color(0xFFFF6F00) : Colors.black87,
                fontFamily: 'SF Pro',
                fontWeight: selected ? FontWeight.w900 : FontWeight.bold,
                fontSize: 10,
              ),
            ),
          ),
          if (selected)
            Positioned(
              right: -5,
              top: -8,
              child: Container(
                padding: const EdgeInsets.all(5),
                decoration: const BoxDecoration(
                  color: Color(0xFFFF6F00),
                  shape: BoxShape.circle,
                ),
                child: Text(
                  '$quantity',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontFamily: 'SF Pro',
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTextField(
    String label,
    String hint, {
    required TextEditingController controller,
    IconData? icon,
    TextInputType? keyboardType,
    Widget? suffix,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            if (icon != null)
              Icon(icon, size: 14, color: const Color(0xFFFF6F00)),
            if (icon != null) const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 10,
                color: Colors.black,
                fontFamily: 'SF Pro',
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          style: const TextStyle(
            fontWeight: FontWeight.w900,
            fontSize: 15,
            color: Color(0xFF1E2832),
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              color: Colors.grey[400],
              fontWeight: FontWeight.normal,
              fontSize: 14,
            ),
            filled: true,
            fillColor: const Color(0xFFF8F9FA),
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: Colors.grey.shade200, width: 1.5),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: Colors.grey.shade200, width: 1.5),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(
                color: Color(0xFF1E2832),
                width: 1.5,
              ),
            ),
            suffixIcon: suffix,
          ),
        ),
      ],
    );
  }

  Widget _buildScheduleChip(String label, bool selected, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 40,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected ? const Color(0xFFFF6F00) : Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: selected ? const Color(0xFFFF6F00) : Colors.grey.shade300,
              width: 1.5,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: selected ? Colors.white : Colors.black87,
              fontWeight: FontWeight.w900,
              fontSize: 11,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTimeDisplayChip() {
    return Expanded(
      child: GestureDetector(
        onTap: _selectTime,
        child: Container(
          height: 40,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.grey.shade300, width: 1.5),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _selectedTime == 'AUTRE HEURE' ? _timeController.text : '--:--',
                style: const TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 14,
                  color: Color(0xFF1E2832),
                ),
              ),
              const Icon(
                Icons.access_time_filled,
                size: 20,
                color: Colors.grey,
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatPrice(int price) {
    return price.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]} ',
    );
  }
}
