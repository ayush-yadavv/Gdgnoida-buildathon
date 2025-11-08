import 'dart:io';

// import 'package:eat_right/data/services/logic/new_logic/food_consumption_controller.dart';
import 'package:eat_right/comman/widgets/appbar/appbar.dart';
import 'package:eat_right/data/services/Image_handler/image_controller.dart';
import 'package:eat_right/data/services/logic/new_data_model/food_consumption_models/analysis_models/meal_analysis_model.dart'; // Correct model
import 'package:eat_right/data/services/logic/new_logic/new_analysis_controllers.dart/food_consumption_controller.dart';
import 'package:eat_right/data/services/logic/new_logic/new_analysis_controllers.dart/meal_analysis_controller.dart';
import 'package:eat_right/temp/screens/ask_ai_page.dart';
import 'package:eat_right/temp/screens/scan_label_controller.dart';
import 'package:eat_right/temp/widgets/ask_ai_widget.dart';
import 'package:eat_right/temp/widgets/food_item_card.dart'; // This widget needs updating
import 'package:eat_right/temp/widgets/food_item_card_shimmer.dart';
import 'package:eat_right/temp/widgets/total_nutrients_card.dart'; // This widget needs updating
import 'package:eat_right/temp/widgets/total_nutrients_card_shimmer.dart';
import 'package:eat_right/utils/constants/sizes.dart'; // Import sizes
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:image_picker/image_picker.dart';

class FoodScanPage extends StatelessWidget {
  FoodScanPage({super.key});

  // Inject new controllers
  final ImageController imageController = Get.put(
    ImageController(),
    tag: "food_scan",
  );
  final MealAnalysisController mealAnalysisController = Get.put(
    MealAnalysisController(),
  );
  final FoodConsumptionController foodConsumptionController = Get.put(
    FoodConsumptionController(),
  );

  @override
  Widget build(BuildContext context) {
    // Clear previous state when the page is built (optional, depends on desired behavior)
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //    mealAnalysisController.clearAnalysis();
    //    imageController.clearImages();
    // });

    return Scaffold(
      // Add Scaffold for better structure and potential AppBar/FAB
      // appBar: AppBar(title: Text("Scan Meal")), // Optional AppBar
      appBar: SAppBar(
        title: Obx(
          () => AnimatedDefaultTextStyle(
            style: Theme.of(context).textTheme.titleLarge!,
            duration: const Duration(milliseconds: 300),
            child:
                mealAnalysisController
                        .mealAnalysisResult
                        .value
                        ?.mealDetails
                        .nameSuggestion !=
                    null
                ? FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      mealAnalysisController
                          .mealAnalysisResult
                          .value!
                          .mealDetails
                          .nameSuggestion!,

                      // maxLines: 1,
                      // overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  )
                : const Text("Scan Meal"),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Iconsax.refresh_copy),
            onPressed: () {
              HapticFeedback.selectionClick();
              mealAnalysisController.clearAnalysis();
              imageController.clearImages();
            },
            tooltip: "Clear Analysis",
          ),
          SizedBox(width: Sizes.defaultSpace / 2),
        ],
      ),
      body: Obx(
        () => // Wrap body for logging indicator
        foodConsumptionController.isLogging.value
            ? const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 10),
                    Text("Logging Meal..."),
                  ],
                ),
              )
            : SingleChildScrollView(
                physics: AlwaysScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Removed extra SizedBox
                    _buildScanningSection(context),
                    if (mealAnalysisController.mealAnalysisResult.value != null)
                      const Divider(height: Sizes.spaceBtwSections),
                    _buildAnalysisResults(context),
                  ],
                ),
              ),
      ),
      floatingActionButton: Obx(
        () =>
            mealAnalysisController.mealAnalysisResult.value !=
                    null && // Show only when results exist
                (mealAnalysisController.mealAnalysisResult.value!.status
                            .toLowerCase() ==
                        'success' ||
                    mealAnalysisController.mealAnalysisResult.value!.status
                            .toLowerCase() ==
                        'partial success') && // Only for successful analysis
                !mealAnalysisController
                    .isAnalyzing
                    .value && // Not while analyzing
                !foodConsumptionController
                    .isLogging
                    .value // Not while logging
            ? FloatingActionButton.extended(
                onPressed: _logMeal,
                icon: const Icon(Icons.add_chart_outlined),
                label: const Text("Log This Meal"),
              )
            : const SizedBox.shrink(),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildImagePreviewSection(
    BuildContext context,
    ScanLabelPageController controller,
  ) {
    return Obx(() {
      final frontImg = controller.imageController.frontImage.value;
      final labelImg = controller.imageController.nutritionLabelImage.value;

      if (frontImg == null && labelImg == null) {
        return const SizedBox.shrink();
      }

      return Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: Sizes.defaultSpace,
          vertical: Sizes.s,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Captured Images",
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: Sizes.spaceBtwItems / 2),
            Row(
              mainAxisAlignment:
                  MainAxisAlignment.center, // Center items if only one image
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (frontImg != null)
                  Expanded(
                    flex: labelImg != null
                        ? 1
                        : 0, // Take half space only if both exist
                    // Use the NEW simplified ImagePreviewTile
                    child: ImagePreviewTileSimple(
                      title: "Product Front",
                      imageFile: frontImg,
                      onTap: () => controller.captureFoodImage(
                        ImageSource.camera,
                      ), // Example re-take action
                    ),
                  ),
                if (frontImg != null && labelImg != null)
                  const SizedBox(width: Sizes.spaceBtwItems),
                if (labelImg != null)
                  Expanded(
                    flex: frontImg != null ? 1 : 0,
                    // Use the NEW simplified ImagePreviewTile
                    child: ImagePreviewTileSimple(
                      title: "Nutrition Label",
                      imageFile: labelImg,
                      onTap: () => controller.captureLabelImage(
                        ImageSource.camera,
                      ), // Example re-take action
                    ),
                  ),
              ],
            ),
            const SizedBox(height: Sizes.s),
            const Divider(),
          ],
        ),
      );
    });
  }

  Widget _buildScanningSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: Sizes.defaultSpace,
        vertical: Sizes.defaultSpace / 2,
      ),
      child: Card(
        // margin: const EdgeInsets.all(20), // Use defaultSpace from Sizes
        // padding: const EdgeInsets.symmetric(
        //   horizontal: Sizes.defaultSpace,
        //   vertical: Sizes.defaultSpace / 2,
        // ),
        // shape: RoundedRectangleBorder(
        //   borderRadius: BorderRadius.circular(Sizes.defaultSpace),
        // ),
        elevation: 0,
        clipBehavior: Clip.antiAlias,
        child: SizedBox(
          height: 250,
          width: double.infinity,
          child: Stack(
            // Removed DottedBorder for simplicity, can be added back
            children: [
              Obx(
                // Show image preview if available
                () {
                  final imageFile = imageController.frontImage.value;
                  return imageFile != null
                      ? Image.file(
                          imageFile,
                          height: 250,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        )
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            SizedBox(
                              child: Icon(
                                Iconsax.camera_copy,
                                size: 80,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                            const SizedBox(height: Sizes.spaceBtwItems / 2),
                            Text(
                              "Snap a picture of your meal or pick one from your gallery",
                              textAlign: TextAlign.center,
                              style: Theme.of(
                                context,
                              ).textTheme.bodySmall, // Use theme style
                            ),
                            const SizedBox(height: Sizes.spaceBtwItems),
                            _buildImageCaptureButtons(),
                            // Optionally show reset button if image exists
                          ],
                        ); // Placeholder icon
                },
              ),

              Obx(
                () => imageController.frontImage.value != null
                    ? Positioned(
                        bottom: 10,
                        right: 10,
                        child: IconButton.filledTonal(
                          onPressed: () {
                            imageController.clearImages();
                            mealAnalysisController.clearAnalysis();
                          },
                          icon: Icon(Iconsax.trash_copy),
                        ),
                      )
                    : SizedBox.shrink(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAnalysisResults(BuildContext context) {
    return Obx(() {
      final analysisResult = mealAnalysisController.mealAnalysisResult.value;
      final isAnalyzing = mealAnalysisController.isAnalyzing.value;
      final errorMsg = mealAnalysisController.errorMessage.value;

      if (isAnalyzing) {
        return _buildLoadingShimmer(); // Show shimmer while analyzing
      } else if (errorMsg.isNotEmpty) {
        return _buildErrorState(errorMsg); // Show error message
      } else if (analysisResult != null &&
          analysisResult.status.toLowerCase() != 'failure') {
        // Analysis successful, show results
        return _buildResults(context, analysisResult);
      } else if (analysisResult != null &&
          analysisResult.status.toLowerCase() == 'failure') {
        // Analysis finished but reported failure
        return _buildErrorState(
          analysisResult.errorMessage ??
              "Analysis failed. Please try again with a clearer image.",
        );
      } else {
        // Initial state or after clearing
        return const SizedBox.shrink();
      }
    });
  }

  Widget _buildLoadingShimmer() {
    // Keep existing shimmer structure or enhance it
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        // Padding(
        //   padding: EdgeInsets.symmetric(vertical: Sizes.spaceBtwItems),
        //   child: Text(
        //     "Analyzing your meal...",
        //     style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        //   ),
        // ),
        FoodItemCardShimmer(),
        SizedBox(height: Sizes.spaceBtwItems),
        FoodItemCardShimmer(),
        SizedBox(height: Sizes.spaceBtwItems),
        TotalNutrientsCardShimmer(),
      ],
    );
  }

  Widget _buildErrorState(String message) {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: Sizes.defaultSpace,
        vertical: Sizes.defaultSpace / 2,
      ),
      padding: const EdgeInsets.all(Sizes.m),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(Sizes.cardRadiusMd),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.error_outline, color: Colors.red),
          SizedBox(width: Sizes.spaceBtwItems),
          Expanded(
            child: Text(
              "Analysis Error: $message",
              style: TextStyle(color: Colors.red.shade800),
            ),
          ),
        ],
      ),
    );
  }

  // Updated to accept MealAnalysisModel
  Widget _buildResults(BuildContext context, MealAnalysisModel analysisResult) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Padding(
        //   padding: const EdgeInsets.only(bottom: Sizes.spaceBtwItems),
        //   child: Text(
        //     analysisResult.mealDetails.nameSuggestion ??
        //         'Analysis Results', // Use suggested name
        //     style: Theme.of(context).textTheme.headlineSmall,
        //   ),
        // ),
        // --- Display Meal Items ---
        // IMPORTANT: FoodItemCard needs to be refactored to accept MealItem
        // from MealAnalysisModel instead of the old FoodItem model.
        // For now, this might cause errors or display incorrectly.
        if (analysisResult.items.isNotEmpty)
          ...analysisResult.items.map(
            // Replace with a new widget if FoodItemCard isn't updated:
            // (item) => MealItemDisplayWidget(item: item),
            (item) =>
                FoodItemCard(item: item), // Assumes FoodItemCard is updated
          )
        else
          const Text("Could not identify specific items in the meal."),

        const SizedBox(height: Sizes.spaceBtwItems),

        // --- Display Total Nutrients ---
        // IMPORTANT: TotalNutrientsCard needs refactoring to accept NutrientInfo
        // from MealAnalysisModel.totalMealNutrients.
        // Inside FoodScanPage _buildResults method:
        TotalNutrientsCard(
          totalNutrients:
              analysisResult.totalMealNutrients, // Pass the NutrientInfo object
          itemCount: analysisResult.items.length, // Pass the number of items
        ), // Assumes TotalNutrientsCard is updated
        const SizedBox(height: Sizes.spaceBtwItems / 2),

        // --- Ask AI Widget ---
        InkWell(onTap: _navigateToAskAi, child: const AskAiWidget()),
        const SizedBox(height: 100),
      ],
    );
  }

  Widget _buildImageCaptureButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center, // Even spacing
      children: [
        OutlinedButton.icon(
          icon: const Icon(Icons.camera_alt_outlined),
          label: const Text("Take Photo"),
          onPressed: () => _handleFoodImageCapture(ImageSource.camera),
        ),
        const SizedBox(width: Sizes.spaceBtwItems), // Use spaceEvenly
        OutlinedButton.icon(
          icon: const Icon(Icons.photo_library_outlined),
          label: const Text("Gallery"),
          onPressed: () => _handleFoodImageCapture(ImageSource.gallery),
        ),
      ],
    );
  }

  void _handleFoodImageCapture(ImageSource source) async {
    // Clear previous results before starting new analysis
    mealAnalysisController.clearAnalysis();
    final imagePicker = ImagePicker();
    final image = await imagePicker.pickImage(
      source: source,
      imageQuality: 80,
    ); // Reduced quality slightly
    if (image != null) {
      final imageFile = File(image.path);
      imageController.frontImage.value = imageFile; // Update image controller
      // Trigger analysis - result is handled by Obx listener
      mealAnalysisController.analyzeFoodImage(imageFile: imageFile);
    }
  }

  void _logMeal() {
    final analysisResult = mealAnalysisController.mealAnalysisResult.value;
    if (analysisResult == null) {
      Get.snackbar(
        'Error',
        'No analysis result available to log.',
        snackPosition: SnackPosition.BOTTOM,
      );
      mealAnalysisController.clearAnalysis();
      imageController.clearImages();
      return;
    }
    // Optional: Show DateTime picker for consumedAt
    DateTime consumedAtTime = DateTime.now();

    foodConsumptionController.logMealConsumption(
      analysis: analysisResult,
      consumedAt: consumedAtTime,
    );
    mealAnalysisController.clearAnalysis();
    imageController.clearImages();
  }

  void _navigateToAskAi() {
    final analysisResult = mealAnalysisController.mealAnalysisResult.value;
    final imageFile = imageController.frontImage.value;

    if (analysisResult != null && imageFile != null) {
      Get.to(
        () => AskAiPage(
          analysisData: analysisResult,
          foodImage: imageFile,
          // Pass other relevant context if AskAiPage needs it
        ),
      );
    } else {
      Get.snackbar(
        'Missing Info',
        'Please analyze a meal first.',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
}

class ImagePreviewTileSimple extends StatelessWidget {
  final String title;
  final File? imageFile;
  final VoidCallback? onTap; // Still allow tap for retake

  const ImagePreviewTileSimple({
    super.key,
    required this.title,
    required this.imageFile,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      // Simple Column layout
      mainAxisSize: MainAxisSize.min, // Take minimum space
      children: [
        // Title above the image
        Padding(
          padding: const EdgeInsets.only(bottom: Sizes.xs),
          child: Text(title, style: Theme.of(context).textTheme.labelLarge),
        ),
        // Image container with fixed height
        InkWell(
          onTap: onTap, // Apply tap if provided
          borderRadius: BorderRadius.circular(Sizes.cardRadiusMd),
          child: SizedBox(
            // Constrain the height
            height: 140,
            width: double.infinity, // Take width from Expanded parent
            child: ClipRRect(
              borderRadius: BorderRadius.circular(Sizes.cardRadiusMd),
              child: Container(
                // Background color for placeholder/border effect
                decoration: BoxDecoration(
                  color: Theme.of(
                    context,
                  ).colorScheme.surfaceContainerHighest.withOpacity(0.5),
                  border: Border.all(
                    color: Theme.of(context).dividerColor.withOpacity(0.5),
                    width: 0.5,
                  ),
                  borderRadius: BorderRadius.circular(Sizes.cardRadiusMd),
                ),
                child: imageFile != null
                    ? Image.file(
                        imageFile!,
                        fit: BoxFit.cover, // Fill the SizedBox
                        // loadingBuilder: (context, child, loadingProgress) {
                        //   if (loadingProgress == null) return child;
                        //   return const Center(
                        //     child: CircularProgressIndicator(strokeWidth: 2),
                        //   );
                        // },
                        errorBuilder: (context, error, stackTrace) =>
                            const Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.broken_image_outlined,
                                    color: Colors.grey,
                                    size: 30,
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    "Error",
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: 10,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                      )
                    : const Center(
                        child: Icon(
                          Icons.image_not_supported_outlined,
                          color: Colors.grey,
                          size: 40,
                        ),
                      ), // Placeholder
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// IMPORTANT: Refactor required for helper widgets:
// - FoodItemCard: Needs to accept `MealItem` model.
// - TotalNutrientsCard: Needs to accept `NutrientInfo` model.
// If these are not updated, the UI rendering in `_buildResults` will fail.
// import 'dart:io';

// import 'package:dotted_border/dotted_border.dart';
// import 'package:eat_right/data/services/logic/new_logic/analysis_controller.dart';
// import 'package:eat_right/data/services/logic/new_logic/image_controller.dart';
// import 'package:eat_right/temp/widgets/ask_ai_widget.dart';
// import 'package:eat_right/temp/widgets/food_item_card.dart';
// import 'package:eat_right/temp/widgets/food_item_card_shimmer.dart';
// import 'package:eat_right/temp/widgets/total_nutrients_card.dart';
// import 'package:eat_right/temp/widgets/total_nutrients_card_shimmer.dart';
// import 'package:eat_right/utils/constants/colors.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:image_picker/image_picker.dart';

// import 'ask_ai_page.dart';

// class FoodScanPage extends StatelessWidget {
//   FoodScanPage({super.key});

//   final ImageController imageController = Get.put(ImageController());
//   final AnalysisController analysisController = Get.put(AnalysisController());

//   @override
//   Widget build(BuildContext context) {
//     return SingleChildScrollView(
//       physics: const BouncingScrollPhysics(),
//       child: Padding(
//         padding: EdgeInsets.only(
//           bottom: MediaQuery.of(context).padding.bottom + 80,
//         ),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.center,
//           children: [
//             const SizedBox(height: 100),
//             _buildScanningSection(context),
//             _buildAnalysisResults(context),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildScanningSection(BuildContext context) {
//     return Container(
//       margin: const EdgeInsets.all(20),
//       padding: const EdgeInsets.all(20),
//       decoration: BoxDecoration(
//         color: SColors.borderLight,
//         borderRadius: BorderRadius.circular(20),
//         border: Border.all(color: Colors.transparent),
//       ),
//       child: DottedBorder(
//         borderPadding: const EdgeInsets.all(-20),
//         borderType: BorderType.RRect,
//         radius: const Radius.circular(20),
//         color: Theme.of(context).colorScheme.onSurface.withOpacity(0.2),
//         strokeWidth: 1,
//         dashPattern: const [6, 4],
//         child: Column(
//           children: [
//             Obx(
//               () =>
//                   imageController.frontImage.value != null
//                       ? ClipRRect(
//                         borderRadius: BorderRadius.circular(20),
//                         child: Image.file(imageController.frontImage.value!),
//                       )
//                       : const SizedBox(),
//             ),
//             const SizedBox(height: 20),
//             Text(
//               "Snap a picture of your meal or pick one from your gallery",
//               textAlign: TextAlign.center,
//               style: TextStyle(
//                 color: Theme.of(context).colorScheme.onSurface,
//                 fontSize: 14,
//                 fontFamily: 'Poppins',
//                 fontWeight: FontWeight.w400,
//               ),
//             ),
//             const SizedBox(height: 20),
//             _buildImageCaptureButtons(),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildAnalysisResults(BuildContext context) {
//     return Obx(
//       () =>
//           analysisController.isAnalyzing.value
//               ? _buildLoadingShimmer()
//               : analysisController.analyzedFoodItems.isNotEmpty
//               ? _buildResults(context)
//               : const SizedBox(),
//     );
//   }

//   Widget _buildLoadingShimmer() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: const [
//         Padding(
//           padding: EdgeInsets.symmetric(horizontal: 20),
//           child: Text(
//             'Analysis Results',
//             style: TextStyle(
//               fontSize: 24,
//               fontWeight: FontWeight.bold,
//               fontFamily: 'Poppins',
//             ),
//           ),
//         ),
//         FoodItemCardShimmer(),
//         FoodItemCardShimmer(),
//         TotalNutrientsCardShimmer(),
//       ],
//     );
//   }

//   Widget _buildResults(BuildContext context) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 20),
//           child: Text(
//             'Analysis Results',
//             style: Theme.of(context).textTheme.displayMedium,
//           ),
//         ),
//         const SizedBox(height: 16),
//         ...analysisController.analyzedFoodItems.map(
//           (item) => FoodItemCard(item: item),
//         ),
//         const TotalNutrientsCard(),
//         InkWell(
//           onTap: () {
//             Get.to(
//               () => AskAiPage(
//                 mealName: analysisController.mealName.value,
//                 foodImage: imageController.frontImage.value!,
//               ),
//             );
//           },
//           child: const AskAiWidget(),
//         ),
//       ],
//     );
//   }

//   Widget _buildImageCaptureButtons() {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.center,
//       children: [
//         ElevatedButton.icon(
//           icon: Icon(
//             Icons.camera_alt_outlined,
//             color: Get.theme.colorScheme.onPrimary,
//           ),
//           label: const Text("Take Photo"),
//           onPressed: () => _handleFoodImageCapture(ImageSource.camera),
//         ),
//         const SizedBox(width: 16),
//         ElevatedButton.icon(
//           icon: Icon(
//             Icons.photo_library,
//             color: Get.theme.colorScheme.onPrimary,
//           ),
//           label: const Text("Gallery"),
//           onPressed: () => _handleFoodImageCapture(ImageSource.gallery),
//         ),
//       ],
//     );
//   }

//   void _handleFoodImageCapture(ImageSource source) async {
//     final imagePicker = ImagePicker();
//     final image = await imagePicker.pickImage(source: source);
//     if (image != null) {
//       imageController.frontImage.value = File(image.path);
//       await analysisController.analyzeFoodImage(
//         imageFile: imageController.frontImage.value!,
//       );
//     }
//   }
// }
