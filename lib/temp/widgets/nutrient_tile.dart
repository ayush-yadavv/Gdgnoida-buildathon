import 'dart:ui';

import 'package:eat_right/data/services/logic/new_data_model/food_consumption_models/nutrients_data_models/nutrient_detail_model.dart'; // Import NutrientDetail
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

  // Optional: Factory constructor to create from NutrientDetail easily
  factory NutrientTile.fromNutrientDetail(
    NutrientDetail detail,
    String? insightText,
  ) {
    // Format quantity and unit together
    String quantityStr =
        detail.value != null
            ? "${detail.value!.toStringAsFixed(detail.value!.truncateToDouble() == detail.value ? 0 : 1)} ${detail.unit ?? ''}"
                .trim()
            : "N/A";
    // TODO: Implement logic to calculate/retrieve %DV if needed, requires context (total diet goals)
    String? dailyValueStr; // Placeholder for actual %DV calculation

    return NutrientTile(
      nutrient: detail.name,
      healthSign: detail.healthImpact,
      quantity: quantityStr,
      dailyValue: dailyValueStr,
      insight: insightText, // Pass insight from external map or logic
    );
  }

  @override
  State<NutrientTile> createState() => _NutrientTileState();
}

class _NutrientTileState extends State<NutrientTile>
    with SingleTickerProviderStateMixin {
  bool _isExpanded = false;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Color backgroundColor;
    Color borderColor;
    Color iconColor;
    IconData statusIcon;

    // Determine colors and icon based on healthSign
    switch (widget.healthSign?.toLowerCase()) {
      case "good":
        backgroundColor = const Color(
          0xFF4CAF50,
        ).withOpacity(0.1); // Lighter green
        borderColor = const Color(0xFF4CAF50).withOpacity(0.3);
        iconColor = const Color(0xFF4CAF50);
        statusIcon = Icons.check_circle_outline;
        break;
      case "bad":
        backgroundColor = const Color(
          0xFFFF5252,
        ).withOpacity(0.1); // Lighter red
        borderColor = const Color(0xFFFF5252).withOpacity(0.3);
        iconColor = const Color(0xFFFF5252);
        statusIcon = Icons.warning_amber_rounded; // Changed icon
        break;
      case "moderate":
        backgroundColor = const Color(
          0xFFFFC107,
        ).withOpacity(0.1); // Lighter amber
        borderColor = const Color(0xFFFFC107).withOpacity(0.3);
        iconColor = const Color(0xFFFFC107);
        statusIcon = Icons.info_outline_rounded;
        break;
      default: // Neutral / Unknown
        backgroundColor = Theme.of(
          context,
        ).colorScheme.secondaryContainer.withOpacity(0.5); // Use theme color
        borderColor = Theme.of(context).colorScheme.outline.withOpacity(0.3);
        iconColor = Theme.of(context).colorScheme.onSecondaryContainer;
        statusIcon = Icons.help_outline; // Or another neutral icon
    }

    // Use theme for text colors for better adaptability
    final primaryTextColor = Theme.of(context).textTheme.bodyMedium!.color;
    final secondaryTextColor = Theme.of(context).textTheme.bodySmall!.color;
    final dvColor = iconColor; // Match DV color to icon color for consistency

    return Container(
      // Removed outer color, rely on decoration color
      child: GestureDetector(
        onTap:
            widget.insight != null
                ? () {
                  // Only allow tap if insight exists
                  setState(() {
                    _isExpanded = !_isExpanded;
                    if (_isExpanded) {
                      _animationController.forward();
                    } else {
                      _animationController.reverse();
                    }
                  });
                }
                : null, // Disable tap if no insight
        child: ClipRRect(
          // Clip here for consistent rounding
          borderRadius: BorderRadius.circular(16.0),
          child: BackdropFilter(
            // Optional: Keep backdrop if desired
            filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5), // Reduced blur
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300), // Faster animation
              curve: Curves.easeInOut, // Smoother curve
              // width: _isExpanded ? MediaQuery.of(context).size.width - 40 : null, // Adapt width calculation if needed
              constraints: BoxConstraints(
                maxWidth:
                    _isExpanded
                        ? double.infinity
                        : 180, // Slightly wider max default
                minWidth: 140,
                minHeight: 70,
              ),
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: BorderRadius.circular(16.0),
                border: Border.all(color: borderColor, width: 1),
              ),
              // clipBehavior: Clip.antiAlias, // Clipping done by outer ClipRRect
              child: SingleChildScrollView(
                // Keep scroll for expanded content
                physics:
                    const NeverScrollableScrollPhysics(), // Disable scroll unless expanded height demands it
                child: AnimatedSize(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  alignment: Alignment.topCenter,
                  child: Padding(
                    // Add overall padding
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12.0,
                      vertical: 10.0,
                    ),
                    child: Column(
                      mainAxisSize:
                          MainAxisSize.min, // Important for AnimatedSize
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          // mainAxisSize: MainAxisSize.min, // Allow row to expand if needed
                          crossAxisAlignment:
                              CrossAxisAlignment.start, // Align icon top
                          children: [
                            Icon(statusIcon, size: 18, color: iconColor),
                            const SizedBox(width: 8),
                            Expanded(
                              // Allow text column to take space
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    // Nutrient Name
                                    widget.nutrient,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleSmall
                                        ?.copyWith(fontWeight: FontWeight.w600),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 2),
                                  Row(
                                    // Quantity and DV row
                                    children: [
                                      Text(
                                        // Formatted Quantity
                                        widget.quantity,
                                        style: Theme.of(
                                          context,
                                        ).textTheme.bodySmall?.copyWith(
                                          color: secondaryTextColor,
                                        ),
                                      ),
                                      if (widget.dailyValue != null &&
                                          widget.dailyValue!.isNotEmpty) ...[
                                        const SizedBox(width: 4),
                                        Text(
                                          // Separator and DV%
                                          "| ${widget.dailyValue}",
                                          style: Theme.of(
                                            context,
                                          ).textTheme.bodySmall?.copyWith(
                                            color: dvColor,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            // Expansion Arrow (only if insight exists)
                            if (widget.insight != null)
                              RotationTransition(
                                turns: Tween(begin: 0.0, end: 0.5).animate(
                                  CurvedAnimation(
                                    parent: _animationController,
                                    curve: Curves.easeInOut,
                                  ),
                                ),
                                child: Icon(
                                  Icons.keyboard_arrow_down,
                                  size: 20,
                                  color: primaryTextColor?.withOpacity(0.7),
                                ),
                              ),
                          ],
                        ),
                        // Expanded Insight Section
                        if (_isExpanded && widget.insight != null)
                          Padding(
                            padding: const EdgeInsets.only(
                              top: 8.0,
                            ), // Add padding above insight
                            child: AnimatedOpacity(
                              duration: const Duration(
                                milliseconds: 200,
                              ), // Faster fade
                              opacity: _isExpanded ? 1.0 : 0.0,
                              child: Text(
                                widget.insight!,
                                style: Theme.of(
                                  context,
                                ).textTheme.bodySmall?.copyWith(
                                  color: secondaryTextColor,
                                  height: 1.4,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
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
