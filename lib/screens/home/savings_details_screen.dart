import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../models/recipe.dart';
import '../../services/recipe_service.dart';
import '../../routes/app_routes.dart';
import '../../widgets/saved_recipe_card.dart';
import '../../widgets/red_header_background.dart';

class SavingsDetailsScreen extends StatelessWidget {
  const SavingsDetailsScreen({super.key});

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
                color: Colors.white,
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
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            width: 42.r,
                            height: 42.r,
                            decoration: const BoxDecoration(
                              color: Color(0xFFF1F5F9),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.arrow_back_rounded,
                              size: 20.sp,
                              color: const Color(0xFF0F172A),
                            ),
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
                              color: const Color(0xFF0F172A),
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
                        final validRecipes = myRecipes
                            .where((r) => r.totalPrice != null && r.totalPrice! > 0)
                            .toList();

                        final displayRecipes =
                            validRecipes.isNotEmpty ? validRecipes : myRecipes;

                        double totalSaved = 0.0;
                        for (var r in displayRecipes) {
                          if (r.totalPrice != null && r.totalPrice! > 0) {
                            double makeAtHome = r.totalPrice!;
                            double orderNearby = makeAtHome * 2.5 + 5.0;
                            totalSaved += (orderNearby - makeAtHome);
                          } else {
                            totalSaved += 14.0;
                          }
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
                                  "No savings yet",
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
                                        color: const Color(0xFF475569),
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
                                        color: const Color(0xFF64748B),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            // Saved Recipe Cards List using shared RecipeHorizontalCard
                            SliverPadding(
                              padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 50.h),
                              sliver: SliverList(
                                delegate: SliverChildBuilderDelegate(
                                  (context, index) {
                                    final recipe = displayRecipes[index];
                                    return SavedRecipeCard(
                                      recipe: recipe,
                                      onTap: () {
                                        Navigator.pushNamed(
                                          context,
                                          AppRoutes.recipeDetail,
                                          arguments: {'recipe': recipe},
                                        );
                                      },
                                    );
                                  },
                                  childCount: displayRecipes.length,
                                ),
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
