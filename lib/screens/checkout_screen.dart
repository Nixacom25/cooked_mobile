import 'package:flutter/material.dart';
import 'package:app_ecommerce/utils/constants.dart';
import 'package:app_ecommerce/services/cart_service.dart';
import 'package:intl/intl.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final CartService _cartService = CartService();

  // Client Info Controllers
  final _nomController = TextEditingController();
  final _prenomController = TextEditingController();
  final _phone1Controller = TextEditingController();
  final _phone2Controller = TextEditingController();

  // Location
  final _mapsLinkController = TextEditingController();

  // Comments
  final _commentController = TextEditingController();

  // Delivery Choices
  String _deliveryDateOption = 'Aujourd’hui';
  DateTime? _customDate;

  String _deliveryTimeOption = 'Le plus rapidement possible';
  TimeOfDay? _customTime;

  @override
  void dispose() {
    _nomController.dispose();
    _prenomController.dispose();
    _phone1Controller.dispose();
    _phone2Controller.dispose();
    _mapsLinkController.dispose();
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary, // Dark
      appBar: AppBar(
        title: const Text(
          'Formulaire de Commande',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionHeader('📦 PRODUIT & PRIX'),
              _buildProductSummary(),

              const SizedBox(height: 24),
              _buildSectionHeader('👤 INFORMATIONS CLIENT'),
              Row(
                children: [
                  Expanded(
                    child: _buildTextField('Nom', _nomController, Icons.person),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildTextField(
                      'Prénom',
                      _prenomController,
                      Icons.person_outline,
                    ),
                  ),
                ],
              ),
              _buildTextField(
                'Numéro principal',
                _phone1Controller,
                Icons.phone,
                keyboardType: TextInputType.phone,
              ),
              _buildTextField(
                'Deuxième numéro (optionnel)',
                _phone2Controller,
                Icons.phone_android,
                keyboardType: TextInputType.phone,
                isRequired: false,
              ),

              const SizedBox(height: 24),
              _buildSectionHeader('📍 LOCALISATION'),
              _buildTextField(
                'Lien Google Maps',
                _mapsLinkController,
                Icons.map,
                hint: 'https://maps.google.com/...',
              ),

              const SizedBox(height: 24),
              _buildSectionHeader('📅 DATE DE LIVRAISON'),
              _buildDateSelection(),

              const SizedBox(height: 24),
              _buildSectionHeader('⏰ HEURE DE LIVRAISON'),
              _buildTimeSelection(),

              const SizedBox(height: 24),
              _buildSectionHeader('📝 COMMENTAIRES'),
              _buildTextField(
                'Instructions spécifiques...',
                _commentController,
                Icons.note,
                maxLines: 3,
                isRequired: false,
              ),

              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submitOrder,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accent, // Orange
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'VALIDER LA COMMANDE',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w900,
          letterSpacing: 1.0,
          color: Colors.white, // White text
        ),
      ),
    );
  }

  Widget _buildProductSummary() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primaryLight, // Dark Card
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ..._cartService.items.map(
            (item) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.product.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
                Text(
                  'Catégorie: ${item.product.category}',
                  style: TextStyle(color: Colors.white60, fontSize: 12),
                ),
                Text(
                  'Quantité: ${item.quantity}',
                  style: const TextStyle(fontSize: 14, color: Colors.white),
                ),
                Text(
                  'Service: ${item.includeInstallation ? "Livraison + montage" : "Livraison uniquement"}',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.accent, // Orange
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Divider(color: Colors.white24),
              ],
            ),
          ),

          const SizedBox(height: 8),
          _buildPriceRow('Sous-total', _cartService.formattedSubtotal),
          _buildPriceRow(
            'Frais de livraison',
            'Gratuit',
            color: AppColors.success,
          ),
          if (_cartService.totalInstallationFees > 0)
            _buildPriceRow(
              'Frais de montage',
              _cartService.formattedInstallationFees,
            ),

          const Divider(height: 24, thickness: 1.5, color: Colors.white24),
          _buildPriceRow(
            'TOTAL À PAYER',
            _cartService.formattedGrandTotal,
            isMain: true,
          ),
        ],
      ),
    );
  }

  Widget _buildPriceRow(
    String label,
    String value, {
    Color? color,
    bool isMain = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: isMain ? FontWeight.bold : FontWeight.normal,
              fontSize: isMain ? 18 : 14,
              color: isMain ? Colors.white : Colors.white70,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: isMain ? FontWeight.bold : FontWeight.normal,
              fontSize: isMain ? 18 : 14,
              color: color ?? (isMain ? AppColors.accent : Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller,
    IconData icon, {
    TextInputType? keyboardType,
    int maxLines = 1,
    bool isRequired = true,
    String? hint,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        style: const TextStyle(color: Colors.white), // Input text color
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.white70),
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.white30),
          prefixIcon: Icon(icon, color: Colors.white70, size: 20),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.white24),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.white24),
          ),
          filled: true,
          fillColor: AppColors.primaryLight, // Dark fill
          isDense: true,
        ),
        validator: (value) {
          if (!isRequired) return null;
          if (value == null || value.isEmpty) return 'Requis';
          return null;
        },
      ),
    );
  }

  Widget _buildDateSelection() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.primaryLight, // Dark Card
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          _buildRadioTile(
            'Aujourd’hui',
            'Aujourd’hui',
            (val) => setState(() => _deliveryDateOption = val!),
            _deliveryDateOption,
          ),
          _buildRadioTile(
            'Demain',
            'Demain',
            (val) => setState(() => _deliveryDateOption = val!),
            _deliveryDateOption,
          ),
          _buildRadioTile('Autre date (7 jours max)', 'Autre', (val) {
            setState(() => _deliveryDateOption = val!);
            _selectDate(context);
          }, _deliveryDateOption),
          if (_deliveryDateOption == 'Autre' && _customDate != null)
            Padding(
              padding: const EdgeInsets.only(left: 48, bottom: 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Date choisie : ${DateFormat('dd/MM/yyyy').format(_customDate!)}',
                  style: const TextStyle(
                    // Fixed TextStyle
                    color: AppColors.accent,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTimeSelection() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.primaryLight, // Dark Card
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          _buildRadioTile(
            'Le plus rapidement possible',
            'Le plus rapidement possible',
            (val) => setState(() => _deliveryTimeOption = val!),
            _deliveryTimeOption,
          ),
          _buildRadioTile(
            'Disponible à tout moment',
            'Disponible à tout moment',
            (val) => setState(() => _deliveryTimeOption = val!),
            _deliveryTimeOption,
          ),
          _buildRadioTile('Heure précise (optionnel)', 'Precis', (val) {
            setState(() => _deliveryTimeOption = val!);
            _selectTime(context);
          }, _deliveryTimeOption),
          if (_deliveryTimeOption == 'Precis' && _customTime != null)
            Padding(
              padding: const EdgeInsets.only(left: 48, bottom: 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Heure choisie : ${_customTime!.format(context)}',
                  style: const TextStyle(
                    color: AppColors.accent, // Orange
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildRadioTile<T>(
    String title,
    T value,
    ValueChanged<T?> onChanged,
    T groupValue,
  ) {
    return RadioListTile<T>(
      title: Text(
        title,
        style: const TextStyle(fontSize: 14, color: Colors.white),
      ), // White text
      value: value,
      groupValue: groupValue,
      onChanged: onChanged,
      activeColor: AppColors.accent, // Orange active
      contentPadding: EdgeInsets.zero,
      dense: true,
      visualDensity: VisualDensity.compact,
      tileColor: Colors.transparent, // Ensure transparent tile
      selectedTileColor: Colors.transparent,
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 7)),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            // Dark Theme for DatePicker
            primaryColor: AppColors.accent,
            colorScheme: const ColorScheme.dark(
              primary: AppColors.accent,
              onPrimary: Colors.white,
              surface: AppColors.primaryLight,
              onSurface: Colors.white,
            ),
            dialogBackgroundColor: AppColors.primary,
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _customDate) {
      setState(() {
        _customDate = picked;
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            // Dark Theme for TimePicker
            primaryColor: AppColors.accent,
            colorScheme: const ColorScheme.dark(
              primary: AppColors.accent,
              onPrimary: Colors.white,
              surface: AppColors.primaryLight,
              onSurface: Colors.white,
            ),
            // For TimePicker in simpler Material 3
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _customTime) {
      setState(() {
        _customTime = picked;
      });
    }
  }

  void _submitOrder() {
    if (_formKey.currentState!.validate()) {
      if (_deliveryDateOption == 'Autre' && _customDate == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Veuillez choisir une date')),
        );
        return;
      }

      // Construct the formatted string (for potential copy/paste or log)
      final summary =
          '''
PRODUIT
${_cartService.items.map((i) => "Nom: ${i.product.title}\nQuantité: ${i.quantity}").join("\n")}
TOTAL: ${_cartService.formattedGrandTotal}
CLIENT: ${_nomController.text} ${_prenomController.text}
LIVRAISON: $_deliveryDateOption - $_deliveryTimeOption
''';
      print(summary);

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.check_circle, color: Colors.green, size: 64),
              const SizedBox(height: 16),
              const Text(
                'Commande Confirmée!',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text('Votre bon de commande a été généré avec succès.'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                _cartService.clear();
                Navigator.of(
                  context,
                ).pushNamedAndRemoveUntil('/', (route) => false);
              },
              child: const Text('Retour à l\'accueil'),
            ),
          ],
        ),
      );
    }
  }
}
