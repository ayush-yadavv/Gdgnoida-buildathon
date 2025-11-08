import 'package:eat_right/comman/shimmer/shimmer.dart';
import 'package:flutter/material.dart';

class NutrientInfoShimmer extends StatelessWidget {
  const NutrientInfoShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Title
          const Padding(
            padding: EdgeInsets.all(16),
            child: BShimmerEffect(width: 200, height: 24, borderRadius: 4),
          ),

          // Content
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Section Title
                const BShimmerEffect(width: 140, height: 20, borderRadius: 4),
                const SizedBox(height: 16),

                // Grid Items
                _buildShimmerGrid(),
                const SizedBox(height: 24),

                // Section Title 2
                const BShimmerEffect(width: 100, height: 20, borderRadius: 4),
                const SizedBox(height: 16),

                // Grid Items 2
                _buildShimmerGrid(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShimmerGrid() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 8,
      crossAxisSpacing: 8,
      childAspectRatio: 3.0,
      children: List.generate(
        4,
        (index) => const BShimmerEffect(
          width: double.infinity,
          height: 40,
          borderRadius: 8,
        ),
      ),
    );
  }
}
