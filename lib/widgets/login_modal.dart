import 'package:flutter/material.dart';
import 'package:app_ecommerce/services/auth_service.dart';

enum AuthView { login, register, forgotPassword, otp, resetPassword }

class LoginModal extends StatefulWidget {
  final String? initialFirstName;
  final String? initialLastName;
  final String? initialPhone;

  const LoginModal({
    super.key,
    this.initialFirstName,
    this.initialLastName,
    this.initialPhone,
  });

  static Future<void> show(
    BuildContext context, {
    String? firstName,
    String? lastName,
    String? phone,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => LoginModal(
        initialFirstName: firstName,
        initialLastName: lastName,
        initialPhone: phone,
      ),
    );
  }

  @override
  State<LoginModal> createState() => _LoginModalState();
}

class _LoginModalState extends State<LoginModal> {
  AuthView _currentView = AuthView.login;
  bool _isLoading = false;
  String? _errorMessage;

  // Controllers
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  @override
  void initState() {
    super.initState();
    // Pre-fill if registration is triggered from ValidationScreen
    _firstNameController.text = widget.initialFirstName ?? '';
    _lastNameController.text = widget.initialLastName ?? '';
    _phoneController.text = widget.initialPhone ?? '';

    // If we have pre-filled data, maybe we should default to register?
    // User requirement: "for register... it recuper direct the info already entered"
    // Usually, we still show login first, but let's see.
    // If we want to be smart: if any initial data exists, we can still start at login
    // but the register view will be ready.
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _otpController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _switchView(AuthView view) {
    setState(() {
      _currentView = view;
      _errorMessage = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(35)),
      ),
      child: AnimatedSize(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Handle
                Center(
                  child: Container(
                    width: 50,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                if (_errorMessage != null)
                  Container(
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.red.shade200),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.error_outline,
                          color: Colors.red,
                          size: 20,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            _errorMessage!,
                            style: const TextStyle(
                              color: Colors.red,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                _buildHeader(),
                const SizedBox(height: 32),
                _buildCurrentView(),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    String title = '';
    String subtitle = '';

    switch (_currentView) {
      case AuthView.login:
        title = 'POUR CONTINUER,\nIDENTIFIEZ-VOUS';
        subtitle = 'Connectez-vous pour finaliser votre commande';
        break;
      case AuthView.register:
        title = 'CRÉER UN COMPTE';
        subtitle = 'Rejoignez-nous pour une meilleure expérience';
        break;
      case AuthView.forgotPassword:
        title = 'MOT DE PASSE OUBLIÉ';
        subtitle = 'Entrez votre email pour recevoir un code OTP';
        break;
      case AuthView.otp:
        title = 'CODE DE VÉRIFICATION';
        subtitle = 'Entrez le code envoyé à votre email';
        break;
      case AuthView.resetPassword:
        title = 'RÉINITIALISATION';
        subtitle = 'Choisissez votre nouveau mot de passe';
        break;
    }

    return Column(
      children: [
        Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w900,
            color: Color(0xFF1E2832),
            fontFamily: 'SF Pro',
            letterSpacing: 0.5,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          subtitle,
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.grey, fontSize: 14),
        ),
      ],
    );
  }

  Widget _buildCurrentView() {
    switch (_currentView) {
      case AuthView.login:
        return _buildLoginView();
      case AuthView.register:
        return _buildRegisterView();
      case AuthView.forgotPassword:
        return _buildForgotPasswordView();
      case AuthView.otp:
        return _buildOTPView();
      case AuthView.resetPassword:
        return _buildResetPasswordView();
    }
  }

  // --- VIEWS ---

  Widget _buildLoginView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: _buildSocialButton(
                image: 'assets/images/google.png',
                label: 'Google',
                onPressed: () async {
                  setState(() {
                    _isLoading = true;
                    _errorMessage = null;
                  });
                  try {
                    await AuthService().signInWithGoogle();
                    if (mounted) Navigator.pop(context);
                  } catch (e) {
                    setState(() => _errorMessage = e.toString());
                  } finally {
                    if (mounted) setState(() => _isLoading = false);
                  }
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildSocialButton(
                image: 'assets/images/apple.png',
                label: 'Apple',
                onPressed: () async {
                  setState(() {
                    _isLoading = true;
                    _errorMessage = null;
                  });
                  try {
                    await AuthService().signInWithApple();
                    if (mounted) Navigator.pop(context);
                  } catch (e) {
                    setState(() => _errorMessage = e.toString());
                  } finally {
                    if (mounted) setState(() => _isLoading = false);
                  }
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 32),
        _buildDivider('OU AVEC EMAIL'),
        const SizedBox(height: 32),
        _buildTextField(
          controller: _emailController,
          hint: 'Email',
          icon: Icons.email_outlined,
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _passwordController,
          hint: 'Mot de passe',
          icon: Icons.lock_outline_rounded,
          isPassword: true,
        ),
        _buildForgotPasswordLink(),
        _buildPrimaryButton(
          _isLoading ? 'CHARGEMENT...' : 'SE CONNECTER',
          _isLoading
              ? null
              : () async {
                  if (_emailController.text.isEmpty ||
                      _passwordController.text.isEmpty) {
                    setState(
                      () => _errorMessage = 'Veuillez remplir tous les champs',
                    );
                    return;
                  }

                  setState(() {
                    _isLoading = true;
                    _errorMessage = null;
                  });
                  try {
                    await AuthService().login(
                      _emailController.text,
                      _passwordController.text,
                    );
                    if (mounted) Navigator.pop(context);
                  } catch (e) {
                    setState(() => _errorMessage = e.toString());
                  } finally {
                    if (mounted) setState(() => _isLoading = false);
                  }
                },
        ),
        const SizedBox(height: 32),
        _buildFooterLink(
          "Pas encore de compte ? ",
          "Créer un compte",
          () => _switchView(AuthView.register),
        ),
      ],
    );
  }

  Widget _buildRegisterView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildTextField(
          controller: _firstNameController,
          hint: 'Prénom',
          icon: Icons.person_outline,
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _lastNameController,
          hint: 'Nom',
          icon: Icons.person_outline,
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _phoneController,
          hint: 'Téléphone',
          icon: Icons.phone_android_outlined,
          keyboardType: TextInputType.phone,
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _emailController,
          hint: 'Email',
          icon: Icons.email_outlined,
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _passwordController,
          hint: 'Mot de passe',
          icon: Icons.lock_outline_rounded,
          isPassword: true,
        ),
        const SizedBox(height: 32),
        _buildPrimaryButton(
          _isLoading ? 'CHARGEMENT...' : 'S\'INSCRIRE',
          _isLoading
              ? null
              : () async {
                  if (_phoneController.text.isEmpty ||
                      _passwordController.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Veuillez remplir tous les champs'),
                      ),
                    );
                    return;
                  }

                  setState(() => _isLoading = true);
                  try {
                    await AuthService().register({
                      'firstName': _firstNameController.text,
                      'lastName': _lastNameController.text,
                      'phone': _phoneController.text,
                      'email': _emailController.text,
                      'password': _passwordController.text,
                    });

                    // Auto login after registration?
                    // Better to just switch to login view or try auto-login
                    // Auto login after registration
                    await AuthService().login(
                      _emailController.text,
                      _passwordController.text,
                    );

                    if (mounted) Navigator.pop(context);
                  } catch (e) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(e.toString()),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  } finally {
                    if (mounted) setState(() => _isLoading = false);
                  }
                },
        ),
        const SizedBox(height: 32),
        _buildFooterLink(
          "Déjà un compte ? ",
          "Se connecter",
          () => _switchView(AuthView.login),
        ),
      ],
    );
  }

  Widget _buildForgotPasswordView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildTextField(
          controller: _emailController,
          hint: 'Email',
          icon: Icons.email_outlined,
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 32),
        _buildPrimaryButton('ENVOYER LE CODE', () => _switchView(AuthView.otp)),
        const SizedBox(height: 32),
        _buildFooterLink(
          "Retour à la ",
          "Connexion",
          () => _switchView(AuthView.login),
        ),
      ],
    );
  }

  Widget _buildOTPView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildTextField(
          controller: _otpController,
          hint: 'Code OTP',
          textAlign: TextAlign.center,
          icon: Icons.security,
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: 32),
        _buildPrimaryButton(
          'VÉRIFIER',
          () => _switchView(AuthView.resetPassword),
        ),
        const SizedBox(height: 32),
        _buildFooterLink("Renvoyer le code", "", () {}),
      ],
    );
  }

  Widget _buildResetPasswordView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildTextField(
          controller: _newPasswordController,
          hint: 'Nouveau mot de passe',
          icon: Icons.lock_outline_rounded,
          isPassword: true,
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _confirmPasswordController,
          hint: 'Confirmer le mot de passe',
          icon: Icons.lock_clock_outlined,
          isPassword: true,
        ),
        const SizedBox(height: 32),
        _buildPrimaryButton(
          'CHANGER LE MOT DE PASSE',
          () => _switchView(AuthView.login),
        ),
      ],
    );
  }

  // --- HELPERS ---

  Widget _buildSocialButton({
    required String image,
    required String label,
    required VoidCallback onPressed,
  }) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16),
        side: BorderSide(color: Colors.grey.shade200),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        backgroundColor: Colors.white,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(image, height: 22),
          const SizedBox(width: 10),
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF1E2832),
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool isPassword = false,
    TextInputType keyboardType = TextInputType.text,
    TextAlign textAlign = TextAlign.start,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: TextField(
        controller: controller,
        obscureText: isPassword,
        keyboardType: keyboardType,
        textAlign: textAlign,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 15),
          prefixIcon: Icon(icon, color: Colors.grey.shade400, size: 22),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            vertical: 20,
            horizontal: 20,
          ),
        ),
      ),
    );
  }

  Widget _buildPrimaryButton(String label, VoidCallback? onPressed) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFF6F00).withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFFF6F00),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 20),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w900,
            fontSize: 16,
            letterSpacing: 1,
          ),
        ),
      ),
    );
  }

  Widget _buildDivider(String text) {
    return Row(
      children: [
        Expanded(child: Divider(color: Colors.grey.shade200, thickness: 1)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            text,
            style: TextStyle(
              color: Colors.grey.shade400,
              fontWeight: FontWeight.w700,
              fontSize: 11,
              letterSpacing: 1.2,
            ),
          ),
        ),
        Expanded(child: Divider(color: Colors.grey.shade200, thickness: 1)),
      ],
    );
  }

  Widget _buildForgotPasswordLink() {
    return Align(
      alignment: Alignment.centerRight,
      child: TextButton(
        onPressed: () => _switchView(AuthView.forgotPassword),
        child: const Text(
          'Mot de passe oublié ?',
          style: TextStyle(
            color: Color(0xFFFF6F00),
            fontSize: 13,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildFooterLink(String text, String link, VoidCallback onTap) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(text, style: const TextStyle(color: Colors.grey, fontSize: 14)),
        GestureDetector(
          onTap: onTap,
          child: Text(
            link,
            style: const TextStyle(
              color: Color(0xFFFF6F00),
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }
}
