import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../services/recipe_service.dart';
import '../../models/recipe.dart';
import '../../routes/app_routes.dart';

// ══════════════════════════════════════════════════════════════════════════════
// FAVORITES SCREEN
// ══════════════════════════════════════════════════════════════════════════════
class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});
  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  @override
  void initState() {
    super.initState();
    if (RecipeService.instance.favoriteRecipesNotifier.value == null) {
      RecipeService.instance.getFavoriteRecipes(size: 100);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleSpacing: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: const Color(0xFF1A1A1A), size: 24.sp),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Your Favorites',
          style: TextStyle(
            fontFamily: 'SF Pro',
            fontWeight: FontWeight.w600,
            fontSize: 18.sp,
            color: const Color(0xFF1A1A1A),
          ),
        ),
      ),
      body: ValueListenableBuilder<List<Recipe>?>(
        valueListenable: RecipeService.instance.favoriteRecipesNotifier,
        builder: (context, recipes, _) {
          if (recipes == null) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFFCC3333)),
            );
          }
          if (recipes.isEmpty) {
            return const Center(child: Text("No favorites yet."));
          }

          return ListView.separated(
            padding: EdgeInsets.only(top: 10.h, bottom: 40.h),
            itemCount: recipes.length,
            separatorBuilder: (_, __) => const Divider(
              color: Color(0xFFEEEEEE),
              height: 1,
              thickness: 1,
            ),
            itemBuilder: (context, i) {
              final r = recipes[i];
              return GestureDetector(
                onTap: () => Navigator.pushNamed(
                  context,
                  AppRoutes.recipeDetail,
                  arguments: {'recipe': r},
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 20.w,
                    vertical: 10.h,
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 50.w,
                        height: 50.h,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF5F5F5),
                          borderRadius: BorderRadius.circular(16.r),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16.r),
                          child: Padding(
                            padding: EdgeInsets.all(4.r),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12.r),
                              child: r.image != null
                                  ? Image.network(
                                      r.image!,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) =>
                                    Center(
                                      child: Icon(
                                        Icons.fastfood_rounded,
                                        color: const Color(0xFFCCCCCC),
                                        size: 24.sp,
                                      ),
                                    ),
                              )
                            : Center(
                                child: Icon(
                                  Icons.fastfood_rounded,
                                  color: const Color(0xFFCCCCCC),
                                  size: 24.sp,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 16.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              r.name,
                              style: TextStyle(
                                fontFamily: 'SF Pro',
                                fontWeight: FontWeight.w600,
                                fontSize: 13.sp,
                                color: const Color(0xFF1A1A1A),
                              ),
                            ),
                            SizedBox(height: 6.h),
                            Row(
                              children: [
                                Icon(
                                  Icons.access_time_rounded,
                                  size: 14.sp,
                                  color: const Color(0xFFAAAAAA),
                                ),
                                SizedBox(width: 4.w),
                                Text(
                                  '${r.cookTime} min',
                                  style: TextStyle(
                                    fontFamily: 'SF Pro',
                                    fontSize: 11.sp,
                                    color: const Color(0xFFAAAAAA),
                                  ),
                                ),
                                SizedBox(width: 16.w),
                                Icon(
                                  Icons.local_fire_department_rounded,
                                  size: 14.sp,
                                  color: const Color(0xFFAAAAAA),
                                ),
                                SizedBox(width: 4.w),
                                Text(
                                  '${r.kcal} kcal',
                                  style: TextStyle(
                                    fontFamily: 'SF Pro',
                                    fontSize: 11.sp,
                                    color: const Color(0xFFAAAAAA),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        Icons.favorite,
                        color: const Color(0xFFC83A2D),
                        size: 20.sp,
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
