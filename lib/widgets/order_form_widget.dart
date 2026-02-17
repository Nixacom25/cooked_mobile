import 'package:flutter/material.dart';
import 'package:app_ecommerce/models/cart_item.dart';
import 'package:app_ecommerce/models/order_form.dart';
import 'package:app_ecommerce/models/order.dart';
import 'package:app_ecommerce/services/database_service.dart';

class OrderFormWidget extends StatefulWidget {
  final List<CartItem> cartItems;
  final Function(OrderForm) onSubmit;
  final VoidCallback onCancel;

  const OrderFormWidget({
    super.key,
    required this.cartItems,
    required this.onSubmit,
    required this.onCancel,
  });

  @override
  State<OrderFormWidget> createState() => _OrderFormWidgetState();
}

class _OrderFormWidgetState extends State<OrderFormWidget> {
  final _formKey = GlobalKey<FormState>();
  final OrderForm _form = OrderForm();

  bool _isSubmitting = false;

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    _formKey.currentState!.save();

    if (!_form.isValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez remplir tous les champs obligatoires'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      // Create Order object
      final order = Order(
        id: DatabaseService().generateOrderId(),
        firstName: _form.firstName,
        lastName: _form.lastName,
        primaryPhone: _form.primaryPhone,
        secondaryPhone: _form.secondaryPhone,
        googleMapsLink: _form.googleMapsLink,
        deliveryDate: _form.deliveryDateText,
        deliveryTime: _form.deliveryTimeText,
        comments: _form.comments,
        items: widget.cartItems.map((cartItem) {
          return OrderItem(
            productId: cartItem.product.id,
            productTitle: cartItem.product.title,
            productCategory: cartItem.product.category,
            quantity: cartItem.quantity,
            unitPrice: cartItem.product.numericPrice,
            deliveryFee: cartItem.deliveryFee,
            includeInstallation: cartItem.includeInstallation,
            installationFee: cartItem.installationFee,
            total: cartItem.total,
          );
        }).toList(),
        totalAmount: widget.cartItems.fold(0, (sum, item) => sum + item.total),
        createdAt: DateTime.now(),
      );

      // Save to database
      await DatabaseService().saveOrder(order);

      if (mounted) {
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Commande enregistrée avec succès !'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
          ),
        );

        // Call onSubmit callback
        widget.onSubmit(_form);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              IconButton(
                onPressed: widget.onCancel,
                icon: const Icon(Icons.arrow_back, color: Colors.white),
              ),
              const SizedBox(width: 8),
              const Text(
                'Informations de livraison',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),

        // Form
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Client Info Section
                  _buildSectionTitle('👤 Informations Client'),
                  const SizedBox(height: 12),

                  _buildTextField(
                    label: 'Prénom *',
                    hint: 'Votre prénom',
                    onSaved: (value) => _form.firstName = value ?? '',
                    validator: (value) =>
                        value?.isEmpty ?? true ? 'Requis' : null,
                  ),
                  const SizedBox(height: 12),

                  _buildTextField(
                    label: 'Nom *',
                    hint: 'Votre nom',
                    onSaved: (value) => _form.lastName = value ?? '',
                    validator: (value) =>
                        value?.isEmpty ?? true ? 'Requis' : null,
                  ),
                  const SizedBox(height: 12),

                  _buildTextField(
                    label: 'Numéro principal *',
                    hint: '+221 XX XXX XX XX',
                    keyboardType: TextInputType.phone,
                    onSaved: (value) => _form.primaryPhone = value ?? '',
                    validator: (value) =>
                        value?.isEmpty ?? true ? 'Requis' : null,
                  ),
                  const SizedBox(height: 12),

                  _buildTextField(
                    label: 'Deuxième numéro (optionnel)',
                    hint: '+221 XX XXX XX XX',
                    keyboardType: TextInputType.phone,
                    onSaved: (value) => _form.secondaryPhone = value,
                  ),

                  const SizedBox(height: 24),

                  // Location Section
                  _buildSectionTitle('📍 Localisation'),
                  const SizedBox(height: 12),

                  _buildTextField(
                    label: 'Lien Google Maps *',
                    hint: 'https://maps.google.com/...',
                    keyboardType: TextInputType.url,
                    onSaved: (value) => _form.googleMapsLink = value,
                    validator: (value) =>
                        value?.isEmpty ?? true ? 'Requis' : null,
                  ),

                  const SizedBox(height: 24),

                  // Delivery Date Section
                  _buildSectionTitle('📅 Date de Livraison'),
                  const SizedBox(height: 12),

                  _buildRadioGroup<DeliveryDate>(
                    value: _form.deliveryDate,
                    options: const [
                      (DeliveryDate.today, 'Aujourd\'hui'),
                      (DeliveryDate.tomorrow, 'Demain'),
                      (DeliveryDate.other, 'Autre date'),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _form.deliveryDate = value;
                      });
                    },
                  ),

                  if (_form.deliveryDate == DeliveryDate.other) ...[
                    const SizedBox(height: 12),
                    _buildTextField(
                      label: 'Précisez la date',
                      hint: 'JJ/MM/AAAA',
                      onSaved: (value) => _form.otherDate = value,
                    ),
                  ],

                  const SizedBox(height: 24),

                  // Delivery Time Section
                  _buildSectionTitle('⏰ Heure de Livraison'),
                  const SizedBox(height: 12),

                  _buildRadioGroup<DeliveryTime>(
                    value: _form.deliveryTime,
                    options: const [
                      (DeliveryTime.asap, 'Le plus rapidement possible'),
                      (DeliveryTime.anytime, 'Disponible à tout moment'),
                      (DeliveryTime.specific, 'Heure précise'),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _form.deliveryTime = value;
                      });
                    },
                  ),

                  if (_form.deliveryTime == DeliveryTime.specific) ...[
                    const SizedBox(height: 12),
                    _buildTextField(
                      label: 'Précisez l\'heure',
                      hint: 'HH:MM',
                      onSaved: (value) => _form.specificTime = value,
                    ),
                  ],

                  const SizedBox(height: 24),

                  // Comments Section
                  _buildSectionTitle('📝 Commentaires (optionnel)'),
                  const SizedBox(height: 12),

                  _buildTextField(
                    label: 'Commentaires',
                    hint: 'Instructions spéciales...',
                    maxLines: 3,
                    onSaved: (value) => _form.comments = value,
                  ),

                  const SizedBox(height: 32),

                  // Submit Button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton.icon(
                      onPressed: _isSubmitting ? null : _handleSubmit,
                      icon: _isSubmitting
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.send, size: 24),
                      label: Text(
                        _isSubmitting ? 'Envoi...' : 'J\'achète sur WhatsApp',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(
                          0xFF25D366,
                        ), // WhatsApp green
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(28),
                        ),
                        elevation: 4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 16,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required String hint,
    TextInputType? keyboardType,
    int maxLines = 1,
    void Function(String?)? onSaved,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: Colors.grey[300], fontSize: 14)),
        const SizedBox(height: 6),
        TextFormField(
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey[600]),
            filled: true,
            fillColor: Colors.white.withOpacity(0.1),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
          ),
          keyboardType: keyboardType,
          maxLines: maxLines,
          onSaved: onSaved,
          validator: validator,
        ),
      ],
    );
  }

  Widget _buildRadioGroup<T>({
    required T value,
    required List<(T, String)> options,
    required ValueChanged<T> onChanged,
  }) {
    return Column(
      children: options.map((option) {
        final (optionValue, optionLabel) = option;
        final isSelected = value == optionValue;

        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: InkWell(
            onTap: () => onChanged(optionValue),
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: isSelected
                    ? Colors.orange.withOpacity(0.2)
                    : Colors.white.withOpacity(0.05),
                border: Border.all(
                  color: isSelected ? Colors.orange : Colors.white24,
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(
                    isSelected
                        ? Icons.radio_button_checked
                        : Icons.radio_button_unchecked,
                    color: isSelected ? Colors.orange : Colors.white,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      optionLabel,
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.grey[300],
                        fontSize: 14,
                        fontWeight: isSelected
                            ? FontWeight.w600
                            : FontWeight.normal,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
