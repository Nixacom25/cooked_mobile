import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

import '../../models/recipe.dart';
import '../../routes/app_routes.dart';
import '../../services/recipe_service.dart';
import '../../widgets/skeleton_list.dart';
import '../../widgets/glass_icon_button.dart';
import '../../widgets/red_header_background.dart';
import '../../widgets/recipe_horizontal_card.dart';
import '../../core/theme/app_theme.dart';

class ActivityHistoryScreen extends StatefulWidget {
  const ActivityHistoryScreen({super.key});

  @override
  State<ActivityHistoryScreen> createState() => _ActivityHistoryScreenState();
}

class _ActivityHistoryScreenState extends State<ActivityHistoryScreen> {
  late Future<List<Recipe>> _recentRecipesFuture;

  @override
  void initState() {
    super.initState();
    _recentRecipesFuture = RecipeService.instance.getRecentImports(forceRefresh: true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      resizeToAvoidBottomInset: false,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // ── Red background fond_page.png ──
          const Positioned.fill(
            child: RedHeaderBackground(),
          ),
          SafeArea(
            bottom: false,
            child: Container(
              margin: EdgeInsets.only(top: 25.h),
              decoration: BoxDecoration(
                color: context.colors.surface,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(32.r),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Header (Back Button & Title) ──
                  Padding(
                    padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 12.h),
                    child: Row(
                      children: [
                        GlassIconButton(
                          onTap: () => Navigator.pop(context),
                          size: 42.r,
                          child: Icon(
                            Icons.arrow_back_rounded,
                            size: 20.sp,
                            color: context.colors.textPrimary,
                          ),
                        ),
                        Expanded(
                          child: Text(
                            'Recent Recipes',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: 'Rubik',
                              fontWeight: FontWeight.w700,
                              fontSize: 20.sp,
                              color: context.colors.textPrimary,
                            ),
                          ),
                        ),
                        SizedBox(width: 42.r),
                      ],
                    ),
                  ),

                  // ── Section Title ──
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
                    child: Text(
                      DateFormat('MMMM yyyy').format(DateTime.now()),
                      style: TextStyle(
                        fontFamily: 'Rubik',
                        fontWeight: FontWeight.w700,
                        fontSize: 18.sp,
                        color: context.colors.textPrimary,
                      ),
                    ),
                  ),

                  // ── Recent Recipes Content ──
                  Expanded(
                    child: FutureBuilder<List<Recipe>>(
                      future: _recentRecipesFuture,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return Padding(
                            padding: EdgeInsets.all(20.r),
                            child: const SkeletonList(height: 140, itemCount: 4),
                          );
                        }

                        final recipes = snapshot.data ?? [];
                        if (recipes.isEmpty) {
                          return Center(
                            child: Padding(
                              padding: EdgeInsets.all(24.w),
                              child: Text(
                                "You haven't imported or scanned any recipes yet.",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontFamily: 'Rubik',
                                  fontSize: 14.sp,
                                  color: context.colors.textSecondary,
                                ),
                              ),
                            ),
                          );
                        }

                        return ListView.builder(
                          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
                          itemCount: recipes.length,
                          itemBuilder: (context, i) {
                            final recipe = recipes[i];
                            return RecipeHorizontalCard(
                              recipe: recipe,
                              onTap: () => Navigator.pushNamed(
                                context,
                                AppRoutes.recipeDetail,
                                arguments: {'recipe': recipe, 'isPreview': recipe.isSuggested},
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
