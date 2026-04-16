import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../routes/app_routes.dart';

class ForgotSuccessScreen extends StatefulWidget {
  const ForgotSuccessScreen({super.key});
  @override
  State<ForgotSuccessScreen> createState() => _ForgotSuccessScreenState();
}

class _ForgotSuccessScreenState extends State<ForgotSuccessScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeIn);
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Food pattern background
          Image.asset('assets/images/fond.png', fit: BoxFit.cover),

          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minHeight: constraints.maxHeight),
                    child: IntrinsicHeight(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 5,
                            ),
                            child: Row(
                              children: [
                                Image.asset(
                                  'assets/images/logo2.png',
                                  width: 40,
                                  fit: BoxFit.contain,
                                ),
                              ],
                            ),
                          ),

                          const Spacer(flex: 2),

                          FadeTransition(
                            opacity: _fade,
                            child: const Center(
                              child: Text(
                                'Congratulation!',
                                style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.w900,
                                  color: Color(0xFF160B0B),
                                  fontFamily: 'SF Pro',
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 80),

                          // Illustration: success.png
                          FadeTransition(
                            opacity: _fade,
                            child: Center(
                              child: Image.asset(
                                'assets/images/success.png',
                                width: 150,
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),

                          const Spacer(flex: 3),

                          // Bottom text + button
                          FadeTransition(
                            opacity: _fade,
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(28, 0, 28, 0),
                              child: Column(
                                children: [
                                  const Text(
                                    'Password Changed!',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 28,
                                      fontWeight: FontWeight.w900,
                                      color: Color(0xFF160B0B),
                                      fontFamily: 'SF Pro',
                                    ),
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    'Password changed successfully, you can login again with a new password.',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: AppColors.textMuted,
                                      fontFamily: 'SF Pro',
                                      height: 1.2,
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                  SizedBox(
                                    width: double.infinity,
                                    height: 50,
                                    child: ElevatedButton(
                                      onPressed: () => Navigator.pushReplacementNamed(
                                        context,
                                        AppRoutes.login,
                                      ),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(0xFFC83A2D),
                                        foregroundColor: Colors.white,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(30),
                                        ),
                                        elevation: 0,
                                      ),
                                      child: const Text(
                                        'Get Started',
                                        style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w600,
                                          fontFamily: 'SF Pro',
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
