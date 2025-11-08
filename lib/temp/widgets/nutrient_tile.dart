import 'package:eat_right/data/services/logic/new_data_model/food_consumption_models/nutrients_data_models/nutrient_detail_model.dart';
import 'package:eat_right/utils/constants/nutrient_dv.dart';
import 'package:eat_right/utils/constants/sizes.dart';
import 'package:flutter/material.dart';

// Keep NutrientGrid if used elsewhere, update its NutrientData if needed or remove if unused
// class NutrientGrid extends ...

// Updated NutrientTile to be more flexible and handle potentially null values
class NutrientTile extends StatefulWidget {
  final String nutrient; // Name of the nutrient
  final String? healthSign; // e.g., "Good", "Bad", "Moderate", or null
  final String quantity; // Formatted string like "10.0 g" or "N/A"
  final String? dailyValue; // Formatted string like "20% DV" or null
  final String? insight; // Explanation text or null

  const NutrientTile({
    super.key,
    required this.nutrient,
    required this.quantity, // Quantity is now required, format before passing
    this.healthSign,
    this.dailyValue,
    this.insight,
  });

  // Factory constructor to create from NutrientDetail with actual DV calculation
  factory NutrientTile.fromNutrientDetail(
    NutrientDetail detail,
    String? insightText,
  ) {
    // Format quantity and unit together
    String quantityStr = "N/A";
    String? dailyValueStr;

    if (detail.value != null) {
      // Format the quantity string with value and unit
      quantityStr =
          "${detail.value!.toStringAsFixed(detail.value!.truncateToDouble() == detail.value ? 0 : 1)}${detail.unit?.isNotEmpty == true ? ' ${detail.unit}' : ''}"
              .trim();

      // Calculate %DV if possible
      final percentageDV = NutrientDV.calculateDailyValuePercentage(
        detail.name,
        detail.value!.toDouble(),
      );
      if (percentageDV != null) {
        dailyValueStr = "$percentageDV% DV";
      }
    }

    return NutrientTile(
      nutrient: detail.name,
      healthSign: detail.healthImpact,
      quantity: quantityStr,
      dailyValue: dailyValueStr,
      insight: insightText,
    );
  }

  @override
  State<NutrientTile> createState() => _NutrientTileState();
}

class _NutrientTileState extends State<NutrientTile>
    with SingleTickerProviderStateMixin {
  bool _isExpanded = false;
  late AnimationController _controller;
  late Animation<double> _animation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.3, 1.0, curve: Curves.easeInOut),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggleExpanded() {
    if (widget.insight != null) {
      setState(() {
        _isExpanded = !_isExpanded;
        if (_isExpanded) {
          _controller.forward();
        } else {
          _controller.reverse();
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Determine colors based on health impact
    final Color backgroundColor = widget.healthSign?.toLowerCase() == 'good'
        ? const Color(0xFF4CAF50).withOpacity(0.1)
        : widget.healthSign?.toLowerCase() == 'moderate'
        ? const Color(0xFFFFC107).withOpacity(0.1)
        : const Color(0xFF9E9E9E).withOpacity(0.1);

    final Color borderColor = widget.healthSign?.toLowerCase() == 'good'
        ? const Color(0xFF4CAF50).withValues()
        : widget.healthSign?.toLowerCase() == 'moderate'
        ? const Color(0xFFFFC107).withOpacity(0.1)
        : const Color(0xFF9E9E9E).withOpacity(0.1);

    final Color dvColor = widget.healthSign?.toLowerCase() == 'good'
        ? const Color(0xFF4CAF50)
        : widget.healthSign?.toLowerCase() == 'moderate'
        ? const Color(0xFFFFC107)
        : const Color(0xFF9E9E9E);

    final Color secondaryTextColor =
        Theme.of(context).brightness == Brightness.dark
        ? Colors.white.withOpacity(0.8)
        : Colors.black.withOpacity(0.7);

    return GestureDetector(
      onTap: _toggleExpanded,
      child: Container(
        // height: 44,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(8.0),
          border: Border.all(color: borderColor, width: .8),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header row with nutrient name and quantity
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: Sizes.m,
                vertical: Sizes.m,
              ),
              child: Row(
                children: [
                  // Nutrient name and expand icon
                  Text(
                    widget.nutrient,
                    style: Theme.of(context).textTheme.titleSmall,
                  ),

                  // Expand/collapse icon (only if there's an insight)
                  if (widget.insight != null)
                    Padding(
                      padding: const EdgeInsets.only(left: 4.0, right: 8.0),
                      child: Icon(
                        _isExpanded
                            ? Icons.keyboard_arrow_up
                            : Icons.keyboard_arrow_down,
                        size: 20,
                        color: secondaryTextColor,
                      ),
                    ),

                  // Spacer to push quantity to the right
                  const Spacer(),

                  // Quantity and DV
                  Text(
                    widget.quantity,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: secondaryTextColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (widget.dailyValue != null) ...[
                    const SizedBox(width: 4),
                    Text(
                      '| ${widget.dailyValue}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: dvColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // Animated insight content
            if (widget.insight != null)
              SizeTransition(
                sizeFactor: _animation,
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                      Sizes.m,
                      0,
                      Sizes.m,
                      Sizes.m,
                    ),
                    child: Text(
                      widget.insight!,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: secondaryTextColor,
                        height: 1.4,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// Removed NutrientData class as NutrientTile now uses basic types or NutrientDetail
// import 'dart:ui';

// import 'package:flutter/material.dart';

// class NutrientGrid extends StatefulWidget {
//   final List<NutrientData> nutrients;

//   const NutrientGrid({
//     super.key,
//     required this.nutrients,
//   });

//   @override
//   State<NutrientGrid> createState() => _NutrientGridState();
// }

// class _NutrientGridState extends State<NutrientGrid> {
//   @override
//   Widget build(BuildContext context) {
//     return Wrap(
//       spacing: 8.0,
//       runSpacing: 20.0,
//       children: widget.nutrients
//           .map((nutrient) => NutrientTile(
//                 nutrient: nutrient.name,
//                 healthSign: nutrient.healthSign,
//                 quantity: nutrient.quantity,
//                 dailyValue: nutrient.dailyValue,
//                 insight: nutrient.insight,
//               ))
//           .toList(),
//     );
//   }
// }

// class NutrientTile extends StatefulWidget {
//   final String nutrient;
//   final String healthSign;
//   final String quantity;
//   final String dailyValue;
//   final String? insight;

//   const NutrientTile({
//     super.key,
//     required this.nutrient,
//     required this.healthSign,
//     required this.quantity,
//     required this.dailyValue,
//     this.insight,
//   });

//   @override
//   State<NutrientTile> createState() => _NutrientTileState();
// }

// class _NutrientTileState extends State<NutrientTile>
//     with SingleTickerProviderStateMixin {
//   bool _isExpanded = false;
//   late AnimationController _animationController;

//   @override
//   void initState() {
//     super.initState();
//     _animationController = AnimationController(
//       duration: const Duration(milliseconds: 300),
//       vsync: this,
//     );
//   }

//   @override
//   void dispose() {
//     _animationController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     Color backgroundColor;
//     IconData statusIcon;

//     switch (widget.healthSign) {
//       case "Good":
//         backgroundColor =
//             Theme.of(context).colorScheme.secondary.withOpacity(0.15);
//         statusIcon = Icons.check_circle_outline;
//         break;
//       case "Bad":
//         backgroundColor = Theme.of(context).colorScheme.error.withOpacity(0.15);
//         statusIcon = Icons.warning_outlined;
//         break;
//       default: // "Moderate"
//         backgroundColor =
//             Theme.of(context).colorScheme.primary.withOpacity(0.15);
//         statusIcon = Icons.info_outline;
//     }

//     return Container(
//       color: Theme.of(context).colorScheme.surface,
//       child: GestureDetector(
//         onTap: () {
//           setState(() {
//             _isExpanded = !_isExpanded;
//             if (_isExpanded) {
//               _animationController.forward();
//             } else {
//               _animationController.reverse();
//             }
//           });
//         },
//         child: ClipRRect(
//           child: BackdropFilter(
//             filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
//             child: AnimatedContainer(
//               duration: const Duration(milliseconds: 500),
//               curve: Curves.fastOutSlowIn,
//               width:
//                   _isExpanded ? MediaQuery.of(context).size.width - 32 : null,
//               constraints: BoxConstraints(
//                 maxWidth: _isExpanded ? double.infinity : 170,
//                 minWidth: 140,
//                 minHeight: 70, // Add minimum height
//                 maxHeight: _isExpanded ? 300 : 70,
//               ),
//               decoration: BoxDecoration(
//                 color: backgroundColor,
//                 borderRadius: BorderRadius.circular(16.0),
//                 border: Border.all(
//                   color: widget.healthSign == "Good"
//                       ? const Color(0xFF4CAF50).withValues(alpha: 0.3)
//                       : widget.healthSign == "Bad"
//                           ? const Color(0xFFFF5252).withValues(alpha: 0.3)
//                           : const Color(0xFFFFC107).withValues(alpha: 0.3),
//                   width: 1,
//                 ),
//               ),
//               clipBehavior: Clip.antiAlias,
//               child: ClipRRect(
//                 borderRadius: BorderRadius.circular(16.0),
//                 child: SingleChildScrollView(
//                   child: AnimatedSize(
//                     duration: const Duration(milliseconds: 500),
//                     curve: Curves.fastOutSlowIn,
//                     alignment: Alignment.topCenter,
//                     child: Column(
//                       mainAxisSize: MainAxisSize.min,
//                       children: [
//                         Padding(
//                           padding: const EdgeInsets.symmetric(
//                               horizontal: 8.0, vertical: 14.0),
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             mainAxisSize: MainAxisSize.min,
//                             children: [
//                               Row(
//                                 mainAxisSize: MainAxisSize.min,
//                                 children: [
//                                   Icon(
//                                     statusIcon,
//                                     size: 20,
//                                     color: widget.healthSign == "Good"
//                                         ? const Color(0xFF4CAF50)
//                                         : widget.healthSign == "Bad"
//                                             ? const Color(0xFFFF5252)
//                                             : const Color(0xFFFFC107),
//                                   ),
//                                   const SizedBox(width: 8),
//                                   Flexible(
//                                     child: Column(
//                                       crossAxisAlignment:
//                                           CrossAxisAlignment.start,
//                                       children: [
//                                         Row(
//                                           children: [
//                                             Text(
//                                               widget.nutrient,
//                                               style: TextStyle(
//                                                 color: Theme.of(context)
//                                                     .textTheme
//                                                     .bodyMedium!
//                                                     .color,
//                                                 fontSize: 12,
//                                                 fontWeight: FontWeight.w600,
//                                                 fontFamily: 'Poppins',
//                                               ),
//                                             ),
//                                             Expanded(
//                                               child: Container(),
//                                             ),
//                                             RotationTransition(
//                                               turns: Tween(begin: 0.0, end: 0.5)
//                                                   .animate(
//                                                       _animationController),
//                                               child: Icon(
//                                                 Icons.keyboard_arrow_down,
//                                                 color: Theme.of(context)
//                                                     .textTheme
//                                                     .bodyMedium!
//                                                     .color,
//                                                 size: 20,
//                                               ),
//                                             ),
//                                           ],
//                                         ),
//                                         Row(
//                                           children: [
//                                             Text(
//                                               widget.quantity,
//                                               style: TextStyle(
//                                                 color: Theme.of(context)
//                                                     .textTheme
//                                                     .bodyMedium!
//                                                     .color,
//                                                 fontSize: 11,
//                                                 fontFamily: 'Poppins',
//                                               ),
//                                             ),
//                                             const SizedBox(width: 4),
//                                             Text(
//                                               "| ${widget.dailyValue} DV",
//                                               style: TextStyle(
//                                                 color: widget.healthSign ==
//                                                         "Good"
//                                                     ? const Color(0xFF4CAF50)
//                                                     : widget.healthSign == "Bad"
//                                                         ? const Color(
//                                                             0xFFFF5252)
//                                                         : const Color(
//                                                             0xFFFFC107),
//                                                 fontSize: 11,
//                                                 fontWeight: FontWeight.w600,
//                                                 fontFamily: 'Poppins',
//                                               ),
//                                             ),
//                                           ],
//                                         ),
//                                       ],
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                               if (_isExpanded && widget.insight != null)
//                                 AnimatedOpacity(
//                                   duration: const Duration(milliseconds: 300),
//                                   opacity: _isExpanded ? 1.0 : 0.0,
//                                   child: Padding(
//                                     padding: const EdgeInsets.only(top: 12.0),
//                                     child: Text(
//                                       widget.insight!,
//                                       style: TextStyle(
//                                         fontSize: 13,
//                                         color: Theme.of(context)
//                                             .textTheme
//                                             .bodyMedium!
//                                             .color,
//                                         height: 1.5,
//                                         fontFamily: 'Poppins',
//                                       ),
//                                     ),
//                                   ),
//                                 ),
//                             ],
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

// // Data model for nutrient information
// class NutrientData {
//   final String name;
//   final String healthSign;
//   final String quantity;
//   final String dailyValue;
//   final String? insight;

//   NutrientData({
//     required this.name,
//     required this.healthSign,
//     required this.quantity,
//     required this.dailyValue,
//     this.insight,
//   });
// }
