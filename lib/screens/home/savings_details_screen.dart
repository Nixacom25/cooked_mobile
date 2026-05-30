import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../models/recipe.dart';
import '../../services/recipe_service.dart';
import '../../routes/app_routes.dart';

class SavingsDetailsScreen extends StatelessWidget {
  const SavingsDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Color(0xFF1E293B)),
        title: Text(
          "Your Savings",
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF1E293B),
          ),
        ),
      ),
      body: ValueListenableBuilder<List<Recipe>?>(
        valueListenable: RecipeService.instance.myRecipesNotifier,
        builder: (context, recipes, _) {
          final myRecipes = recipes ?? [];
          final validRecipes = myRecipes
              .where((r) => r.totalPrice != null && r.totalPrice! > 0)
              .toList();
          
          double totalSaved = 0.0;
          for (var r in validRecipes) {
            double makeAtHome = r.totalPrice!;
            double orderNearby = makeAtHome * 2.5 + 5.0;
            totalSaved += (orderNearby - makeAtHome);
          }

          if (validRecipes.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.receipt_long_outlined, size: 60.sp, color: Colors.grey[300]),
                  SizedBox(height: 16.h),
                  Text(
                    "No savings yet",
                    style: TextStyle(
                      fontSize: 16.sp,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            );
          }

          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Container(
                  color: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 30.h),
                  child: Column(
                    children: [
                      Text(
                        "Total Saved",
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF64748B),
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        "~\$${totalSaved.toStringAsFixed(0)}",
                        style: TextStyle(
                          fontSize: 42.sp,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF00C40A),
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        "From ${validRecipes.length} saved recipes",
                        style: TextStyle(
                          fontSize: 13.sp,
                          color: const Color(0xFF94A3B8),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SliverPadding(
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final recipe = validRecipes[index];
                      return _buildSavingsItem(context, recipe);
                    },
                    childCount: validRecipes.length,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSavingsItem(BuildContext context, Recipe recipe) {
    double savedAmount = 0.0;
    if (recipe.totalPrice != null && recipe.totalPrice! > 0) {
      double makeAtHome = recipe.totalPrice!;
      double orderNearby = makeAtHome * 2.5 + 5.0;
      savedAmount = orderNearby - makeAtHome;
    }

    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(
          context,
          AppRoutes.recipeDetail,
          arguments: {'recipe': recipe},
        );
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 12.h),
        padding: EdgeInsets.all(10.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12.r),
              child: recipe.image != null && recipe.image!.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: recipe.image!,
                      width: 60.w,
                      height: 60.w,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        color: Colors.grey[200],
                        width: 60.w,
                        height: 60.w,
                      ),
                      errorWidget: (context, url, error) => Container(
                        color: Colors.grey[200],
                        width: 60.w,
                        height: 60.w,
                        child: Icon(Icons.restaurant, color: Colors.grey[400]),
                      ),
                    )
                  : Container(
                      width: 60.w,
                      height: 60.w,
                      color: Colors.grey[200],
                      child: Icon(Icons.restaurant, color: Colors.grey[400]),
                    ),
            ),
            SizedBox(width: 4.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    recipe.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF1E293B),
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    recipe.origin?.toUpperCase() == 'SCAN' ? "Scanned at home" : "Saved in your cookbook",
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: const Color(0xFF94A3B8),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: 10.w),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
              decoration: BoxDecoration(
                color: const Color(0xFFDCFCE7),
                borderRadius: BorderRadius.circular(20.r),
              ),
              child: Text(
                "+\$${savedAmount.toStringAsFixed(0)}",
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF166534),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
