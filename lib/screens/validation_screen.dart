import 'package:flutter/material.dart';
import 'package:app_ecommerce/services/cart_service.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:app_ecommerce/screens/map_picker_screen.dart';
import 'package:record/record.dart';
import 'package:audioplayers/audioplayers.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:app_ecommerce/services/api_service.dart';
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

  // Audio State
  late AudioRecorder _audioRecorder;
  late AudioPlayer _audioPlayer;
  bool _isRecording = false;
  bool _isPlaying = false;
  String? _recordedFilePath;

  @override
  void initState() {
    super.initState();

    _audioRecorder = AudioRecorder();
    _audioPlayer = AudioPlayer();

    _audioPlayer.onPlayerComplete.listen((event) {
      if (mounted) setState(() => _isPlaying = false);
    });
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phone1Controller.dispose();
    _phone2Controller.dispose();
    _noteController.dispose();
    _locationController.dispose();
    _dateController.dispose();
    _timeController.dispose();
    _audioRecorder.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  // --- Logic ---

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
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now,
      lastDate: now.add(const Duration(days: 6)),
      locale: const Locale('fr', 'FR'),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(primary: Color(0xFFE65100)),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedDate = 'AUTRE DATE';
        _dateController.text = DateFormat('dd/MM/yyyy').format(picked);
      });
    }
  }

  Future<void> _selectTime() async {
    TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
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

  // --- Voice Recorder Logic ---

  Future<void> _startRecording() async {
    // Explicitly request microphone permission using permission_handler
    var status = await Permission.microphone.request();

    if (status.isGranted) {
      final directory = await getTemporaryDirectory();
      String filePath =
          '${directory.path}/voice_note_${DateTime.now().millisecondsSinceEpoch}.m4a';

      await _audioRecorder.start(const RecordConfig(), path: filePath);
      setState(() {
        _isRecording = true;
        _recordedFilePath = null;
      });
    } else if (status.isPermanentlyDenied) {
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Permission requise'),
            content: const Text(
              'Le microphone est nécessaire pour enregistrer une note vocale. Veuillez l\'activer dans les paramètres.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Annuler'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  openAppSettings();
                },
                child: const Text('Ouvrir les paramètres'),
              ),
            ],
          ),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Permission microphone refusée')),
        );
      }
    }
  }

  Future<void> _stopRecording() async {
    final path = await _audioRecorder.stop();
    setState(() {
      _isRecording = false;
      _recordedFilePath = path;
    });
  }

  Future<void> _playRecording() async {
    if (_recordedFilePath != null) {
      await _audioPlayer.play(DeviceFileSource(_recordedFilePath!));
      setState(() => _isPlaying = true);
    }
  }

  Future<void> _stopPlayback() async {
    await _audioPlayer.stop();
    setState(() => _isPlaying = false);
  }

  Future<void> _deleteRecording() async {
    await _audioPlayer.stop();
    if (_recordedFilePath != null) {
      final file = File(_recordedFilePath!);
      if (await file.exists()) {
        await file.delete();
      }
    }
    setState(() {
      _recordedFilePath = null;
      _isPlaying = false;
    });
  }

  Future<void> _submitOrder() async {
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
      File? audioFile;
      if (_recordedFilePath != null && _noteType == 'VOCAL') {
        audioFile = File(_recordedFilePath!);
      }

      final items = CartService().itemsNotifier.value
          .map(
            (item) => {'productId': item.product.id, 'quantity': item.quantity},
          )
          .toList();

      // Format Delivery Date
      DateTime deliveryDateTime = DateTime.now();
      if (_selectedDate == 'DEMAIN') {
        deliveryDateTime = DateTime.now().add(const Duration(days: 1));
      } else if (_selectedDate == 'AUTRE DATE' &&
          _dateController.text.isNotEmpty) {
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
            : 'Note vocale jointe',
      };

      await ApiService.postMultipart(
        '/orders',
        orderData,
        audioFile: audioFile,
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
    final deliveryFee = 3000.0;
    final finalTotal = cartTotal + deliveryFee;

    String formatPrice(int price) {
      return '${price.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]} ')}';
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFFE65100), // Orange
        elevation: 0,
        centerTitle: false,
        leading: IconButton(
          icon: const Icon(Icons.check_circle_outline, color: Colors.white),
          onPressed: () {},
        ),
        title: const Text(
          '5. VALIDATION',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.close, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 20.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Names
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
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Phones
                  Row(
                    children: [
                      Expanded(
                        child: _buildTextField(
                          'TEL. PRINCIPAL',
                          '77...',
                          controller: _phone1Controller,
                          icon: Icons.phone_outlined,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildTextField(
                          'TEL. 2 (OPTIONNEL)',
                          'Secondaire',
                          controller: _phone2Controller,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Location with Button
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: const [
                          Icon(
                            Icons.location_on_outlined,
                            size: 14,
                            color: Colors.black87,
                          ),
                          SizedBox(width: 6),
                          Text(
                            'LOCALISATION',
                            style: TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 11,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.only(
                          left: 16,
                          right: 8,
                          top: 4,
                          bottom: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF5F5F5),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _locationController,
                                readOnly: true,
                                onTap: _openMapPicker,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                                decoration: const InputDecoration(
                                  hintText:
                                      'Choisir la localisation sur la carte',
                                  border: InputBorder.none,
                                  hintStyle: TextStyle(
                                    color: Colors.grey,
                                    fontWeight: FontWeight.normal,
                                  ),
                                ),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.map_outlined,
                                color: Color(0xFFE65100),
                              ),
                              onPressed: _openMapPicker,
                              tooltip: 'Choisir sur la carte',
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.my_location,
                                color: Color(0xFFE65100),
                              ),
                              onPressed: _getCurrentLocation,
                              tooltip: 'Ma position actuelle',
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Delivery Date
                  Row(
                    children: const [
                      Icon(
                        Icons.calendar_today_outlined,
                        size: 16,
                        color: Colors.black87,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'DATE DE LIVRAISON',
                        style: TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 12,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _buildSelectableButton(
                        'AUJOURD\'HUI',
                        _selectedDate == 'AUJOURD\'HUI',
                        () => setState(() {
                          _selectedDate = 'AUJOURD\'HUI';
                          _dateController.clear();
                        }),
                      ),
                      const SizedBox(width: 10),
                      _buildSelectableButton(
                        'DEMAIN',
                        _selectedDate == 'DEMAIN',
                        () => setState(() {
                          _selectedDate = 'DEMAIN';
                          _dateController.clear();
                        }),
                      ),
                      const SizedBox(width: 10),

                      // Custom Date Button
                      Expanded(
                        child: GestureDetector(
                          onTap: _selectDate,
                          child: Container(
                            height: 48,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: _selectedDate == 'AUTRE DATE'
                                  ? const Color(0xFFE65100)
                                  : Colors.white,
                              border: Border.all(
                                color: _selectedDate == 'AUTRE DATE'
                                    ? const Color(0xFFE65100)
                                    : Colors.black,
                                width: 1.5,
                              ),
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: Text(
                              _selectedDate == 'AUTRE DATE' &&
                                      _dateController.text.isNotEmpty
                                  ? _dateController.text
                                  : 'AUTRE DATE',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: _selectedDate == 'AUTRE DATE'
                                    ? Colors.white
                                    : Colors.black,
                                fontWeight: FontWeight.w900,
                                fontSize: 10,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Delivery Time
                  Row(
                    children: const [
                      Icon(Icons.access_time, size: 16, color: Colors.black87),
                      SizedBox(width: 8),
                      Text(
                        'HEURE DE LIVRAISON',
                        style: TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 12,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: _buildSelectableButton(
                          'LE PLUS RAPIDEMENT POSSIBLE',
                          _selectedTime == 'LE PLUS RAPIDEMENT POSSIBLE',
                          () => setState(() {
                            _selectedTime = 'LE PLUS RAPIDEMENT POSSIBLE';
                            _timeController.clear();
                          }),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 2,
                        child: GestureDetector(
                          onTap: _selectTime,
                          child: Container(
                            height: 48,
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: _selectedTime == 'AUTRE HEURE'
                                    ? const Color(0xFFE65100)
                                    : Colors.black87,
                                width: 1.5,
                              ),
                              color: _selectedTime == 'AUTRE HEURE'
                                  ? const Color(0xFFE65100).withOpacity(0.1)
                                  : null,
                              borderRadius: BorderRadius.circular(30),
                            ),
                            alignment: Alignment.center,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  _selectedTime == 'AUTRE HEURE' &&
                                          _timeController.text.isNotEmpty
                                      ? _timeController.text
                                      : '--:--',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: _selectedTime == 'AUTRE HEURE'
                                        ? const Color(0xFFE65100)
                                        : Colors.black,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Icon(
                                  Icons.access_time_filled,
                                  size: 18,
                                  color: _selectedTime == 'AUTRE HEURE'
                                      ? const Color(0xFFE65100)
                                      : Colors.black,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Assembly Toggle (Conditional)
                  if (CartService().items.any(
                    (item) => item.product.hasInstallationOption,
                  ))
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFFDE7), // Very light yellow
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: Colors.amber.withOpacity(0.3),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  const Icon(
                                    Icons.build,
                                    color: Colors.orange,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 12),
                                  const Text(
                                    'AVEC MONTAGE',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w900,
                                      fontSize: 14,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ],
                              ),
                              Switch(
                                value: _withAssembly,
                                onChanged: (val) {
                                  if (val && !_isDakar) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          "Le service de montage est disponible principalement à Dakar. Votre localisation actuelle pourrait ne pas être couverte.",
                                        ),
                                        backgroundColor: Colors.orange,
                                      ),
                                    );
                                  }
                                  setState(() => _withAssembly = val);
                                },
                                activeColor: const Color(0xFFE65100),
                              ),
                            ],
                          ),
                        ),
                        if (!_isDakar)
                          const Padding(
                            padding: EdgeInsets.only(left: 16, bottom: 24),
                            child: Text(
                              "* Service disponible uniquement à Dakar",
                              style: TextStyle(
                                color: Colors.orange,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          )
                        else
                          const SizedBox(height: 24),
                      ],
                    ),

                  const SizedBox(height: 24),
                  // Payment Method
                  const Text(
                    'MODE DE PAIEMENT',
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 14,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 12),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildSelectableButton(
                          'ESPÈCES',
                          _paymentMethod == 'CASH',
                          () => setState(() => _paymentMethod = 'CASH'),
                        ),
                        const SizedBox(width: 8),
                        _buildSelectableButton(
                          'WAVE',
                          _paymentMethod == 'WAVE',
                          () => setState(() => _paymentMethod = 'WAVE'),
                        ),
                        const SizedBox(width: 8),
                        _buildSelectableButton(
                          'ORANGE MONEY',
                          _paymentMethod == 'ORANGE_MONEY',
                          () => setState(() => _paymentMethod = 'ORANGE_MONEY'),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Note Box
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black87, width: 1.5),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            children: const [
                              Icon(Icons.comment_outlined, size: 18),
                              SizedBox(width: 8),
                              Text(
                                'NOTE PARTICULIÈRE POUR LE LIVREUR',
                                style: TextStyle(
                                  fontWeight: FontWeight.w900,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Segmented Control Look-alike
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () =>
                                        setState(() => _noteType = 'ECRIT'),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 10,
                                      ),
                                      decoration: BoxDecoration(
                                        color: _noteType == 'ECRIT'
                                            ? Colors.black
                                            : Colors.transparent,
                                        borderRadius: BorderRadius.circular(25),
                                      ),
                                      alignment: Alignment.center,
                                      child: Text(
                                        'ÉCRIT',
                                        style: TextStyle(
                                          color: _noteType == 'ECRIT'
                                              ? Colors.white
                                              : Colors.black54,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () =>
                                        setState(() => _noteType = 'VOCAL'),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 10,
                                      ),
                                      decoration: BoxDecoration(
                                        color: _noteType == 'VOCAL'
                                            ? Colors.black
                                            : Colors.transparent,
                                        borderRadius: BorderRadius.circular(25),
                                      ),
                                      alignment: Alignment.center,
                                      child: Text(
                                        'VOCAL',
                                        style: TextStyle(
                                          color: _noteType == 'VOCAL'
                                              ? Colors.white
                                              : Colors.black54,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        // Content Area (Text or Voice)
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: _noteType == 'ECRIT'
                              ? TextField(
                                  controller: _noteController,
                                  maxLines: 4,
                                  decoration: InputDecoration(
                                    hintText:
                                        'Note particulière pour le livreur...',
                                    hintStyle: TextStyle(
                                      color: Colors.grey[400],
                                      fontWeight: FontWeight.w500,
                                    ),
                                    border: InputBorder.none,
                                    contentPadding: EdgeInsets.zero,
                                  ),
                                )
                              : _buildVoiceRecorder(),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Footer Total
          Container(
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'LIVRAISON',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      '${formatPrice(deliveryFee.toInt())} FCFA',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Divider(color: Colors.white24),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'TOTAL À PAYER',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 14,
                      ),
                    ),
                    Row(
                      children: [
                        Text(
                          formatPrice(finalTotal.toInt()),
                          style: const TextStyle(
                            color: Color(0xFFE65100),
                            fontSize: 32,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const Text(
                          ' FCFA',
                          style: TextStyle(
                            color: Color(0xFFE65100),
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            height: 2,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isSubmitting ? null : _submitOrder,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE65100), // Orange
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
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                              letterSpacing: 1,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVoiceRecorder() {
    if (_recordedFilePath != null && !_isRecording) {
      // Playback UI
      return Row(
        children: [
          IconButton(
            onPressed: _isPlaying ? _stopPlayback : _playRecording,
            icon: Icon(
              _isPlaying ? Icons.stop_circle : Icons.play_circle_fill,
              size: 40,
              color: const Color(0xFFE65100),
            ),
          ),
          const SizedBox(width: 8),
          const Expanded(
            child: Text(
              "Note vocale enregistrée",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          IconButton(
            onPressed: _deleteRecording,
            icon: const Icon(Icons.delete_outline, color: Colors.red),
          ),
        ],
      );
    }

    // Recording UI
    return GestureDetector(
      onLongPressStart: (_) => _startRecording(),
      onLongPressEnd: (_) => _stopRecording(),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        width: double.infinity,
        decoration: BoxDecoration(
          color: _isRecording ? Colors.red.withOpacity(0.1) : Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
          border: _isRecording ? Border.all(color: Colors.red) : null,
        ),
        child: Column(
          children: [
            Icon(
              _isRecording ? Icons.mic : Icons.mic_none,
              size: 40,
              color: _isRecording ? Colors.red : Colors.grey[600],
            ),
            const SizedBox(height: 8),
            Text(
              _isRecording
                  ? "Relâchez pour envoyer"
                  : "Maintenez pour enregistrer",
              style: TextStyle(
                color: _isRecording ? Colors.red : Colors.grey[600],
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(
    String label,
    String hint, {
    IconData? icon,
    TextEditingController? controller,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (icon != null) ...[
          Row(
            children: [
              Icon(icon, size: 14, color: Colors.black87),
              const SizedBox(width: 6),
              Text(
                label,
                style: const TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 11,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ] else
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: 11,
              color: Colors.black87,
            ),
          ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFFF5F5F5),
            borderRadius: BorderRadius.circular(12),
          ),
          child: TextField(
            controller: controller,
            style: const TextStyle(fontWeight: FontWeight.bold),
            decoration: InputDecoration(
              hintText: hint,
              border: InputBorder.none,
              hintStyle: TextStyle(
                color: Colors.grey[400],
                fontSize: 13,
                fontWeight: FontWeight.normal,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSelectableButton(
    String text,
    bool isSelected,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 48,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFE65100) : Colors.white,
          border: Border.all(
            color: isSelected ? const Color(0xFFE65100) : Colors.black,
            width: 1.5,
          ),
          borderRadius: BorderRadius.circular(30),
        ),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black,
            fontWeight: FontWeight.w900,
            fontSize: 10,
          ),
        ),
      ),
    );
  }
}
