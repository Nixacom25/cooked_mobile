import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../models/recipe.dart';
import '../../services/recipe_service.dart';
import '../../routes/app_routes.dart';
import '../../widgets/glass_icon_button.dart';
import '../../widgets/saved_recipe_card.dart';
import '../../widgets/red_header_background.dart';
import '../../core/theme/app_theme.dart';

class SavingsDetailsScreen extends StatelessWidget {
  const SavingsDetailsScreen({super.key});

  // Same formula as the recipe detail page's "Estimated savings" card, so
  // both screens agree on the number for the same recipe.
  static double _estimatedSavings(Recipe r) {
    final servings = (r.servings != null && r.servings! > 0) ? r.servings! : 2;
    final pricePerServing = (r.totalPrice != null && r.totalPrice! > 0)
        ? r.totalPrice! / servings
        : 3.50;
    double restaurantPerServing = pricePerServing * 2.5 + 5.0;
    if (restaurantPerServing < 14.75) restaurantPerServing = 14.75;
    final makeAtHome = pricePerServing * servings;
    final orderNearby = restaurantPerServing * servings;
    return orderNearby - makeAtHome;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      resizeToAvoidBottomInset: false,
      body: Stack(
        fit: StackFit.expand,
        children: [
          const Positioned.fill(
            child: RedHeaderBackground(),
          ),
          SafeArea(
            bottom: false,
            child: Container(
              margin: EdgeInsets.only(top: 25.h),
              decoration: BoxDecoration(
                color: context.colors.surface,
                borderRadius: BorderRadius.vertical(top: Radius.circular(32.r)),
              ),
              child: Column(
                children: [
                  // Custom Top Navigation Header Row
                  Padding(
                    padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 10.h),
                    child: Row(
                      children: [
                        // Floating Circular Back Arrow Button
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
                            "Your Savings",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: 'Rubik',
                              fontSize: 22.sp,
                              fontWeight: FontWeight.w800,
                              color: context.colors.textPrimary,
                            ),
                          ),
                        ),
                        SizedBox(width: 42.r), // Balance back button offset
                      ],
                    ),
                  ),

                  // Page Content Body
                  Expanded(
                    child: ValueListenableBuilder<List<Recipe>?>(
                      valueListenable: RecipeService.instance.myRecipesNotifier,
                      builder: (context, recipes, _) {
                        final myRecipes = recipes ?? [];
                        final displayRecipes = myRecipes.where((r) {
                          return r.origin?.toUpperCase() == 'SCAN';
                        }).toList();

                        double totalSaved = 0.0;
                        for (var r in displayRecipes) {
                          totalSaved += _estimatedSavings(r);
                        }

                        if (displayRecipes.isEmpty) {
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.receipt_long_outlined,
                                    size: 60.sp, color: Colors.grey[300]),
                                SizedBox(height: 16.h),
                                Text(
                                  "No scan savings yet",
                                  style: TextStyle(
                                    fontFamily: 'Rubik',
                                    fontSize: 16.sp,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          );
                        }

                        return CustomScrollView(
                          physics: const BouncingScrollPhysics(),
                          slivers: [
                            // Savings Summary Section
                            SliverToBoxAdapter(
                              child: Padding(
                                padding: EdgeInsets.symmetric(vertical: 20.h),
                                child: Column(
                                  children: [
                                    Text(
                                      "Your saved",
                                      style: TextStyle(
                                        fontFamily: 'Rubik',
                                        fontSize: 14.sp,
                                        fontWeight: FontWeight.w600,
                                        color: context.colors.textSecondary,
                                      ),
                                    ),
                                    SizedBox(height: 4.h),
                                    Text(
                                      "\$${totalSaved.toStringAsFixed(0)}",
                                      style: TextStyle(
                                        fontFamily: 'Rubik',
                                        fontSize: 54.sp,
                                        fontWeight: FontWeight.w800,
                                        color: const Color(0xFF15803D),
                                      ),
                                    ),
                                    SizedBox(height: 4.h),
                                    Text(
                                      displayRecipes.length == 1
                                          ? "From 1 saved recipe"
                                          : "From ${displayRecipes.length} saved recipes",
                                      style: TextStyle(
                                        fontFamily: 'Rubik',
                                        fontSize: 14.sp,
                                        fontWeight: FontWeight.w500,
                                        color: context.colors.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            // Saved Recipe Cards List using shared RecipeHorizontalCard
                            SliverPadding(
                              padding: EdgeInsets.fromLTRB(
                                16.w,
                                16.h,
                                16.w,
                                50.h + MediaQuery.of(context).padding.bottom,
                              ),
                              sliver: SliverList.separated(
                                itemCount: displayRecipes.length,
                                separatorBuilder: (context, index) => SizedBox(height: 14.h),
                                itemBuilder: (context, index) {
                                  final recipe = displayRecipes[index];
                                  final itemSavings = _estimatedSavings(recipe);

                                  return SavedRecipeCard(
                                    recipe: recipe,
                                    isRegistered: true,
                                    isSavingsMode: true,
                                    subtitle: "Scanned at home",
                                    savingsBadgeText: "+${itemSavings.toStringAsFixed(0)}\$",
                                    onTap: () {
                                      Navigator.pushNamed(
                                        context,
                                        AppRoutes.recipeDetail,
                                        arguments: {'recipe': recipe},
                                      );
                                    },
                                  );
                                },
                              ),
                            ),
                          ],
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
