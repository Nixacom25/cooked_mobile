import 'package:flutter/material.dart';
import '../../models/cookbook.dart';
import '../../widgets/cookbook_form_modal.dart';
import '../../core/theme/app_theme.dart';

class CookbookFormScreen extends StatelessWidget {
  const CookbookFormScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>? ?? {};
    final Cookbook? cookbook = args['cookbook'] as Cookbook?;

    return Scaffold(
      backgroundColor: context.colors.pageBackground,
      body: SafeArea(
        bottom: false,
        child: CookbookFormModal(
          cookbook: cookbook,
          onComplete: (cb) => Navigator.pop(context, true),
        ),
      ),
    );
  }
}
