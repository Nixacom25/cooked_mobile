import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../models/savings.dart';
import '../../services/recipe_service.dart';
import '../../routes/app_routes.dart';
import '../../widgets/glass_icon_button.dart';
import '../../widgets/saved_recipe_card.dart';
import '../../widgets/red_header_background.dart';
import '../../core/theme/app_theme.dart';
import '../../core/motion/motion_widgets.dart';
import '../../core/l10n/l10n.dart';

class SavingsDetailsScreen extends StatefulWidget {
  const SavingsDetailsScreen({super.key});

  @override
  State<SavingsDetailsScreen> createState() => _SavingsDetailsScreenState();
}

class _SavingsDetailsScreenState extends State<SavingsDetailsScreen> {
  // Savings are computed by the backend from scanned recipes only; this
  // screen only displays them.
  @override
  void initState() {
    super.initState();
    RecipeService.instance.refreshSavings().catchError((_) => null);
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
                            context.l10n.savingsTitle,
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
                    child: ValueListenableBuilder<SavingsSummary?>(
                      valueListenable: RecipeService.instance.savingsNotifier,
                      builder: (context, summary, _) {
                        if (summary == null) {
                          return const Center(
                            child: CircularProgressIndicator.adaptive(),
                          );
                        }

                        final displayRecipes = summary.recipes;
                        final totalSaved = summary.totalSaved;

                        if (displayRecipes.isEmpty) {
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.receipt_long_outlined,
                                    size: 60.sp, color: Colors.grey[300]),
                                SizedBox(height: 16.h),
                                Text(
                                  context.l10n.savingsEmpty,
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
                                      context.l10n.savingsYourSaved,
                                      style: TextStyle(
                                        fontFamily: 'Rubik',
                                        fontSize: 14.sp,
                                        fontWeight: FontWeight.w600,
                                        color: context.colors.textSecondary,
                                      ),
                                    ),
                                    SizedBox(height: 4.h),
                                    AnimatedNumber(
                                      value: totalSaved,
                                      format: (v) => "\$${v.toStringAsFixed(0)}",
                                      pulse: true,
                                      style: TextStyle(
                                        fontFamily: 'Rubik',
                                        fontSize: 54.sp,
                                        fontWeight: FontWeight.w800,
                                        color: const Color(0xFF15803D),
                                      ),
                                    ),
                                    SizedBox(height: 4.h),
                                    Text(
                                      context.l10n.savingsFromRecipes(displayRecipes.length),
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
                                  final item = displayRecipes[index];
                                  final recipe = item.recipe;
                                  final itemSavings = item.savings;

                                  return SavedRecipeCard(
                                    recipe: recipe,
                                    title: item.displayName,
                                    isRegistered: true,
                                    isSavingsMode: true,
                                    subtitle: context.l10n.savingsScannedAtHome,
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
