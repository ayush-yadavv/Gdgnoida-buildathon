import 'package:eat_right/comman/shimmer/shimmer.dart';
import 'package:flutter/material.dart';

class TotalNutrientsCardShimmer extends StatelessWidget {
  const TotalNutrientsCardShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Theme.of(context).cardColor,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header section
          Container(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const BShimmerEffect(
                      width: 140,
                      height: 24,
                      borderRadius: 4,
                    ),
                    const SizedBox(height: 8),
                    BShimmerEffect(width: 80, height: 16, borderRadius: 4),
                  ],
                ),
                BShimmerEffect(width: 48, height: 48, borderRadius: 12),
              ],
            ),
          ),
          // Nutrients section
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(20),
              ),
            ),
            child: Column(
              children: [
                ...List.generate(
                  5,
                  (index) => Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Row(
                          children: [
                            BShimmerEffect(
                              width: 36,
                              height: 36,
                              borderRadius: 8,
                            ),
                            const SizedBox(width: 16),
                            BShimmerEffect(
                              width: 120,
                              height: 16,
                              borderRadius: 4,
                            ),
                            const Spacer(),
                            BShimmerEffect(
                              width: 80,
                              height: 16,
                              borderRadius: 4,
                            ),
                          ],
                        ),
                      ),
                      if (index < 4)
                        Divider(
                          color: Theme.of(context).dividerColor,
                          height: 1,
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                // Add to Daily Intake button
                BShimmerEffect(
                  width: double.infinity,
                  height: 50,
                  borderRadius: 8,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
