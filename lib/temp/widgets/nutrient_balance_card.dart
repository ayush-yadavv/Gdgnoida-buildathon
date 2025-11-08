import 'package:eat_right/utils/constants/sizes.dart';
import 'package:flutter/material.dart';

class NutrientBalanceCard extends StatelessWidget {
  final String issue;
  final String explanation;
  final List<Map<String, dynamic>> recommendations;

  const NutrientBalanceCard({
    super.key,
    required this.issue,
    required this.explanation,
    required this.recommendations,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      // margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(
              context,
            ).colorScheme.onErrorContainer.withValues(alpha: .1),
            Colors.transparent,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(Sizes.cardRadiusMd),
        border: Border.all(
          color: Theme.of(context).colorScheme.secondary.withValues(alpha: .2),
          width: 1,
        ),
      ),
      child: ExpansionTile(
        enableFeedback: false,
        shape: Border(),
        childrenPadding: const EdgeInsets.symmetric(
          horizontal: Sizes.defaultSpace / 2,
          vertical: Sizes.m,
        ),
        backgroundColor: Colors.transparent,
        collapsedBackgroundColor: Colors.transparent,
        title: Row(
          children: [
            Icon(
              Icons.warning_amber_rounded,
              color: Theme.of(context).colorScheme.error,
              // size: Sizes.iconLg,
            ),
            const SizedBox(width: Sizes.spaceBtwInputFields),
            Expanded(
              child: Text(
                issue,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium!.copyWith(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                explanation,
                style: Theme.of(context).textTheme.bodyMedium,
                // TextStyle(
                //   color: Theme.of(context).colorScheme.onSurface,
                //   fontSize: 14,
                //   height: 1.5,
                //   fontFamily: 'Poppins',
                // ),
              ),
              const SizedBox(height: Sizes.spaceBtwSections),
              Text(
                'Recommendations',
                style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                  fontWeight: FontWeight.bold,
                ), // TextStyle(
                //   color: Theme.of(context).colorScheme.onSurface,
                //   fontSize: 16,
                //   fontWeight: FontWeight.w500,
                //   fontFamily: 'Poppins',
                // ),
              ),
              const SizedBox(height: Sizes.spaceBtwItems),
              ...recommendations.map(
                (rec) => _RecommendationItem(
                  food: rec['food'] ?? '',
                  quantity: rec['quantity'] ?? '',
                  reasoning: rec['reasoning'] ?? '',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RecommendationItem extends StatelessWidget {
  final String food;
  final String quantity;
  final String reasoning;

  const _RecommendationItem({
    required this.food,
    required this.quantity,
    required this.reasoning,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: Sizes.spaceBtwItems),
      padding: const EdgeInsets.all(Sizes.s),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(Sizes.cardRadiusSm),
      ),
      child: Column(
        // crossAxisAlignment: CrossAxisAlignment.,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(
                Icons.restaurant_menu,
                color: Theme.of(context).colorScheme.secondary,
                size: 24,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: RichText(
                  text: TextSpan(
                    style: const TextStyle(fontSize: 14, fontFamily: 'Poppins'),
                    children: [
                      TextSpan(
                        text: food,
                        style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                          fontWeight: FontWeight.w500,
                        ),

                        //  TextStyle(
                        //   color: Theme.of(context).colorScheme.onSurface,
                        //   fontWeight: FontWeight.w500,
                        // ),
                      ),
                      TextSpan(
                        text: ' • $quantity',
                        style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                          fontWeight: FontWeight.w200,
                        ),
                        // TextStyle(
                        //   color: Theme.of(context).colorScheme.onSurface,
                        // ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: Sizes.spaceBtwInputFields / 2),
          Text(
            reasoning,
            textAlign: TextAlign.start,
            style: Theme.of(context).textTheme.bodySmall!.copyWith(
              // height: 1.5,
              fontWeight: FontWeight.w200,
            ),
            // TextStyle(
            //   color: Theme.of(context).colorScheme.onSurface,
            //   fontSize: 12,
            //   height: 1.5,
            //   fontFamily: 'Poppins',
            // ),
          ),
        ],
      ),
    );
  }
}
