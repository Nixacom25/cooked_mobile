import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../core/theme/app_theme.dart';

class ImportFallbackPage extends StatelessWidget {
  final String? failedUrl;
  final String? errorMessage;
  final VoidCallback onTryAnotherLink;
  final VoidCallback onEnterManually;
  final VoidCallback onSearchWeb;
  final VoidCallback onRetry;

  const ImportFallbackPage({
    super.key,
    this.failedUrl,
    this.errorMessage,
    required this.onTryAnotherLink,
    required this.onEnterManually,
    required this.onSearchWeb,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.pageBackground,
      appBar: AppBar(
        backgroundColor: context.colors.surface,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.close, color: context.colors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Recette introuvable',
          style: TextStyle(
            color: context.colors.textPrimary,
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Error Icon
              Container(
                width: 80.r,
                height: 80.r,
                decoration: BoxDecoration(
                  color: context.colors.surface,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.error_outline,
                  size: 40.sp,
                  color: Colors.orange,
                ),
              ),
              SizedBox(height: 24.h),

              // Main Title
              Text(
                'Nous n\'avons pas trouvé la recette complète.',
                style: TextStyle(
                  fontSize: 22.sp,
                  fontWeight: FontWeight.w700,
                  color: context.colors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 16.h),

              // Description
              Text(
                'Ce lien ne contenait pas suffisamment d\'informations sur la recette pour que Cooked puisse l\'importer correctement.',
                style: TextStyle(
                  fontSize: 15.sp,
                  color: context.colors.textSecondary,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 8.h),

              // Failed URL (if available)
              if (failedUrl != null && failedUrl!.isNotEmpty) ...[
                Container(
                  margin: EdgeInsets.symmetric(vertical: 16.h),
                  padding: EdgeInsets.all(12.r),
                  decoration: BoxDecoration(
                    color: context.colors.surface,
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(color: context.colors.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'URL échouée:',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: context.colors.textMuted,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        failedUrl!,
                        style: TextStyle(
                          fontSize: 13.sp,
                          color: context.colors.textSecondary,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],

              // Error Message (if available)
              if (errorMessage != null && errorMessage!.isNotEmpty) ...[
                Container(
                  margin: EdgeInsets.only(bottom: 24.h),
                  padding: EdgeInsets.all(12.r),
                  decoration: BoxDecoration(
                    color: Colors.orange.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: Colors.orange,
                        size: 20.sp,
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Text(
                          errorMessage!,
                          style: TextStyle(
                            fontSize: 13.sp,
                            color: context.colors.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              SizedBox(height: 32.h),

              // Action Buttons
              _ActionButton(
                icon: Icons.link,
                label: 'Essayer un autre lien',
                description: 'Coller un lien de recette différent',
                onTap: onTryAnotherLink,
              ),
              SizedBox(height: 16.h),

              _ActionButton(
                icon: Icons.edit,
                label: 'Saisir manuellement',
                description: 'Entrer les détails de la recette vous-même',
                onTap: onEnterManually,
              ),
              SizedBox(height: 16.h),

              _ActionButton(
                icon: Icons.search,
                label: 'Rechercher sur le Web',
                description: 'Trouver des recettes sur internet',
                onTap: onSearchWeb,
              ),
              SizedBox(height: 16.h),

              _ActionButton(
                icon: Icons.refresh,
                label: 'Réessayer',
                description: 'Réessayer d\'importer ce lien',
                onTap: onRetry,
                isSecondary: true,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final String description;
  final VoidCallback onTap;
  final bool isSecondary;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.description,
    required this.onTap,
    this.isSecondary = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(16.r),
        decoration: BoxDecoration(
          color: isSecondary 
              ? context.colors.surface 
              : context.colors.accent,
          borderRadius: BorderRadius.circular(16.r),
          border: isSecondary 
              ? Border.all(color: context.colors.border)
              : null,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 40.r,
              height: 40.r,
              decoration: BoxDecoration(
                color: isSecondary 
                    ? context.colors.pageBackground 
                    : Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Icon(
                icon,
                color: isSecondary 
                    ? context.colors.textPrimary 
                    : Colors.white,
                size: 20.sp,
              ),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: isSecondary 
                          ? context.colors.textPrimary 
                          : Colors.white,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 13.sp,
                      color: isSecondary 
                          ? context.colors.textSecondary 
                          : Colors.white.withValues(alpha: 0.8),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: isSecondary 
                  ? context.colors.textMuted 
                  : Colors.white.withValues(alpha: 0.8),
              size: 20.sp,
            ),
          ],
        ),
      ),
    );
  }
}