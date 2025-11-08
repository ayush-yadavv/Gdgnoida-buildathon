import 'package:eat_right/utils/constants/sizes.dart';
import 'package:flutter/material.dart';

class FoodNutrientTile extends StatelessWidget {
  final String label;
  final String value;
  final String unit;
  final IconData icon;

  const FoodNutrientTile({
    super.key,
    required this.label,
    required this.value,
    required this.unit,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      // Optional: Add background/border if needed
      padding: const EdgeInsets.all(Sizes.xs),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerLowest,
        // color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.5),
        borderRadius: BorderRadius.circular(Sizes.cardRadiusSm),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 24, color: Theme.of(context).colorScheme.secondary),
          const SizedBox(height: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            '$value ${unit.trim()}', // Trim unit just in case
            style: Theme.of(
              context,
            ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w500),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis, // Might shrink too much
          ),
        ],
      ),
    );
  }
}

// import 'package:flutter/material.dart';

// class FoodNutrientTile extends StatelessWidget {
//   final String label;
//   final String value;
//   final String unit;
//   final IconData icon;

//   const FoodNutrientTile({
//     super.key,
//     required this.label,
//     required this.value,
//     required this.unit,
//     required this.icon,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//       decoration: BoxDecoration(
//         color: Theme.of(context).colorScheme.surface.withOpacity(0.7),
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(
//           color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
//         ),
//       ),
//       child: Row(
//         children: [
//           Container(
//             padding: const EdgeInsets.all(6),
//             decoration: BoxDecoration(
//               color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
//               borderRadius: BorderRadius.circular(8),
//             ),
//             child: Icon(
//               icon,
//               color: Theme.of(context).colorScheme.primary,
//               size: 16,
//             ),
//           ),
//           const SizedBox(width: 8),
//           Expanded(
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               mainAxisAlignment: MainAxisAlignment.center,
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   label,
//                   style: TextStyle(
//                     fontSize: 12,
//                     color: Theme.of(context)
//                         .colorScheme
//                         .onSurface
//                         .withOpacity(0.6),
//                   ),
//                 ),
//                 Text(
//                   '$value$unit',
//                   style: const TextStyle(
//                     fontSize: 14,
//                     fontWeight: FontWeight.w600,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
