import 'dart:io';

import 'package:eat_right/data/services/logic/new_data_model/food_consumption_models/analysis_models/product_analysis_model.dart';
import 'package:eat_right/data/services/logic/new_data_model/food_consumption_models/nutrients_data_models/nutrient_detail_model.dart';
import 'package:eat_right/temp/nutrient_insights.dart';
import 'package:eat_right/temp/screens/scan_label_controller.dart'; // Controller for this page
import 'package:eat_right/temp/widgets/ask_ai_widget.dart';
import 'package:eat_right/temp/widgets/nutrient_balance_card.dart';
import 'package:eat_right/temp/widgets/nutrient_info_shimmer.dart';
import 'package:eat_right/temp/widgets/nutrient_tile.dart';
import 'package:eat_right/utils/constants/colors.dart';
import 'package:eat_right/utils/constants/sizes.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class ScanLabelPage extends StatelessWidget {
  const ScanLabelPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Initialize controller using Get.put - ensures a unique controller instance for this page visit
    final controller = Get.put(ScanLabelPageController());
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Scan Product Label',
          style: TextStyle(color: SColors.white),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent, // Make AppBar transparent
        elevation: 0, // No shadow
        flexibleSpace: Container(
          // Apply gradient background
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors:
                  isDarkMode
                      ? [SColors.darkerGrey, SColors.dark]
                      : [SColors.darkerGrey, SColors.dark],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        actions: [
          Obx(
            // Reset button reacts to scanning step
            () =>
                controller.scanningStep.value > 0
                    ? IconButton(
                      icon: const Icon(
                        Icons.refresh_rounded,
                        color: SColors.white,
                      ), // Use rounded icon
                      onPressed:
                          controller.resetScanning, // Use controller method
                      tooltip: 'Start Over',
                    )
                    : const SizedBox.shrink(),
          ),
        ],
      ),
      body: Obx(
        () => // Body reacts to logging state
            controller
                    .isLoggingConsumption
                    .value // Use controller's getter
                ? _buildLoggingOverlay(context)
                : _buildMainContent(context, controller),
      ),
      floatingActionButton: Obx(
        () => // FAB reacts to scanning step and analysis status
            controller.scanningStep.value == 3 &&
                    !controller.isAnalyzingProduct.value &&
                    controller.productAnalysisResult.value?.status
                            .toLowerCase() !=
                        'failture'
                ? FloatingActionButton.extended(
                  onPressed: controller.logConsumption, // Use controller method
                  icon: const Icon(Icons.add_chart_rounded),
                  label: const Text("Log Consumption"),
                  tooltip: "Save this item to your daily intake",
                )
                : const SizedBox.shrink(),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  // --- Logging Overlay ---
  Widget _buildLoggingOverlay(BuildContext context) {
    return Container(
      color: Colors.black.withOpacity(0.6), // Slightly darker overlay
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
            SizedBox(height: Sizes.m), // Use Sizes constant
            Text(
              "Logging Consumption...",
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  // --- Main Content Area ---
  Widget _buildMainContent(
    BuildContext context,
    ScanLabelPageController controller,
  ) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(), // Nice scroll physics
      child: Padding(
        // Adjust bottom padding based on FAB visibility for better spacing
        padding: EdgeInsets.only(
          bottom:
              controller.scanningStep.value == 3
                  ? Sizes.buttonHeight * 2.5
                  : Sizes.defaultSpace,
          left: Sizes.defaultSpace / 4,
          right: Sizes.defaultSpace / 4,
          top: Sizes.s,
        ),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.center, // Center items like cards
          mainAxisSize: MainAxisSize.min,
          children: [
            // Step-by-step instruction cards
            _buildScanningStepsUI(context, controller),

            // Image previews (shown when images are available)
            _buildImagePreviewSection(context, controller),

            // Analysis results, loading indicator, or error message
            _buildAnalysisSection(context, controller),

            // Add extra space at the bottom if analysis is complete for scrolling
            if (controller.scanningStep.value == 3)
              const SizedBox(height: Sizes.spaceBtwSections),
          ],
        ),
      ),
    );
  }

  // --- Build Methods for UI Sections ---

  Widget _buildScanningStepsUI(
    BuildContext context,
    ScanLabelPageController controller,
  ) {
    // Obx listens to the scanningStep value from the controller
    return Obx(() {
      switch (controller.scanningStep.value) {
        case 0:
          return _buildScanStepCard(
            context,
            controller,
            1,
          ); // Step 1: Scan Front
        case 1:
          return _buildScanStepCard(
            context,
            controller,
            2,
          ); // Step 2: Scan Label
        case 2:
          return _buildScanStepCard(context, controller, 3); // Step 3: Analyze
        // Step 4 (Analysis Complete) doesn't need a card, results are shown below
        case 3:
          return const SizedBox.shrink();
        default:
          return const SizedBox.shrink();
      }
    });
  }

  // Builds the instructional card for each scanning step
  Widget _buildScanStepCard(
    BuildContext context,
    ScanLabelPageController controller,
    int stepNumber,
  ) {
    String title, instruction;
    IconData icon;
    Color iconColor;
    bool showAnalyzeButton = false;
    Widget
    actionButtons; // To hold either capture buttons or analyze button/loading

    switch (stepNumber) {
      case 1: // Scan Product Front
        title = "Step 1: Scan Product Front";
        instruction = "Take or select a clear picture of the product's front.";
        icon = Icons.camera_enhance_outlined;
        iconColor = Colors.blueAccent;
        actionButtons = _buildCaptureButtons(
          context: context,
          onCamera: () => controller.captureFoodImage(ImageSource.camera),
          onGallery: () => controller.captureFoodImage(ImageSource.gallery),
        );
        break;
      case 2: // Scan Label
        title = "Step 2: Scan Nutrition Label";
        instruction = "Take or select a clear picture of the nutrition facts.";
        icon = Icons.document_scanner_outlined;
        iconColor = Colors.orangeAccent;
        actionButtons = _buildCaptureButtons(
          context: context,
          onCamera: () => controller.captureLabelImage(ImageSource.camera),
          onGallery: () => controller.captureLabelImage(ImageSource.gallery),
        );
        break;
      case 3: // Analyze
        title = "Ready to Analyze!";
        instruction = "Both images captured. Let's see the details!";
        icon = Icons.auto_fix_high_outlined;
        iconColor = Colors.purpleAccent;
        showAnalyzeButton = true;
        actionButtons = Obx(
          () =>
              controller
                      .isAnalyzingProduct
                      .value // Observe analyzing state
                  ? _buildLoadingIndicator("Analyzing...", context)
                  : ElevatedButton.icon(
                    icon: const Icon(Icons.science_outlined),
                    label: const Text("Analyze Now"),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 12,
                      ),
                      textStyle: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    onPressed: controller.analyzeImages,
                  ),
        );
        break;
      default:
        return const SizedBox.shrink();
    }

    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: Sizes.defaultSpace / 2,
        vertical: Sizes.s,
      ),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Sizes.cardRadiusLg),
      ),
      child: Padding(
        padding: const EdgeInsets.all(Sizes.m),
        child: Column(
          children: [
            Icon(icon, size: 48, color: iconColor),
            const SizedBox(height: Sizes.spaceBtwItems),
            Text(
              title,
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: Sizes.xs),
            Text(
              instruction,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: Sizes.m),
            actionButtons, // Display the relevant buttons/indicator
          ],
        ),
      ),
    );
  }

  // Helper to build Camera/Gallery buttons consistently
  Widget _buildCaptureButtons({
    required context,
    required VoidCallback onCamera,
    required VoidCallback onGallery,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        ElevatedButton.icon(
          icon: const Icon(Icons.camera_alt),
          label: const Text("Camera"),
          style: Theme.of(context).elevatedButtonTheme.style,
          onPressed: onCamera,
        ),
        ElevatedButton.icon(
          icon: const Icon(Icons.photo_library),
          label: const Text("Gallery"),
          onPressed: onGallery,
        ),
      ],
    );
  }

  // Builds the section displaying the captured image previews
  Widget _buildImagePreviewSection(
    BuildContext context,
    ScanLabelPageController controller,
  ) {
    return Obx(() {
      // Reacts to changes in imageController's Rx<File?> variables
      final frontImg = controller.imageController.frontImage.value;
      final labelImg = controller.imageController.nutritionLabelImage.value;

      if (frontImg == null && labelImg == null) {
        return const SizedBox.shrink(); // Hide if no images
      }

      return Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: Sizes.defaultSpace,
          vertical: Sizes.m,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Captured Images",
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: Sizes.spaceBtwItems / 2),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Show front image preview if available
                if (frontImg != null)
                  Expanded(
                    flex:
                        labelImg != null
                            ? 1
                            : 0, // Takes half width if label image also exists
                    child: ImagePreviewTileSimple(
                      // Use the simplified preview widget
                      title: "Product Front",
                      imageFile: frontImg,
                      // Allow retaking the image by tapping
                      onTap:
                          () => controller.captureFoodImage(
                            ImageSource.camera,
                          ), // Example: Retake with camera
                    ),
                  ),
                // Spacer if both images exist
                if (frontImg != null && labelImg != null)
                  const SizedBox(width: Sizes.spaceBtwItems),
                // Show label image preview if available
                if (labelImg != null)
                  Expanded(
                    flex: frontImg != null ? 1 : 0,
                    child: ImagePreviewTileSimple(
                      title: "Nutrition Label",
                      imageFile: labelImg,
                      onTap:
                          () =>
                              controller.captureLabelImage(ImageSource.camera),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: Sizes.s),
            // const Divider(),
          ],
        ),
      );
    });
  }

  // Builds the section showing analysis results, loading shimmer, or error message
  Widget _buildAnalysisSection(
    BuildContext context,
    ScanLabelPageController controller,
  ) {
    return Obx(() {
      // Reacts to analysis state changes
      final analysisResult = controller.productAnalysisResult.value;
      final isAnalyzing = controller.isAnalyzingProduct.value;
      final errorMsg = controller.productAnalysisController.errorMessage.value;

      // Show shimmer ONLY when actively analyzing AFTER step 2 (images provided)
      if (isAnalyzing && controller.scanningStep.value >= 2) {
        return const NutrientInfoShimmer();
      }
      // Show results if analysis succeeded
      else if (analysisResult != null &&
          analysisResult.status.toLowerCase() != 'failure') {
        return _buildNutrientInfoSection(context, controller, analysisResult);
      }
      // Show error if analysis was attempted (after step 2) and failed
      else if (!isAnalyzing &&
          errorMsg.isNotEmpty &&
          controller.scanningStep.value >= 2) {
        return Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: Sizes.defaultSpace,
            vertical: Sizes.m,
          ),
          child: Text(
            "Analysis Error: $errorMsg",
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          ),
        );
      }
      // Otherwise, show nothing (initial state or before analysis attempt)
      else {
        return const SizedBox.shrink();
      }
    });
  }

  // Builds the detailed nutrient info, concerns, and serving input section
  Widget _buildNutrientInfoSection(
    BuildContext context,
    ScanLabelPageController controller,
    ProductAnalysisModel analysisResult,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Sizes.defaultSpace / 2),
      child: Column(
        children: [
          const Divider(), // Separator before details
          const SizedBox(height: Sizes.s),
          _buildCategorizedNutrientSections(
            context,
            controller,
            analysisResult,
          ), // Categorized Tiles
          _buildConcernsSection(
            context,
            controller,
            analysisResult,
          ), // Health Insights/Concerns
          _buildServingConsumptionSection(
            context,
            controller,
            analysisResult,
          ), // Serving Input
          const SizedBox(height: Sizes.spaceBtwItems),
          InkWell(
            onTap: controller.navigateToAskAi,
            child: const AskAiWidget(),
          ), // Ask AI prompt
        ],
      ),
    );
  }

  // Builds the sections for Good/Moderate/Bad nutrients using NutrientTile
  Widget _buildCategorizedNutrientSections(
    BuildContext context,
    ScanLabelPageController controller,
    ProductAnalysisModel analysisResult,
  ) {
    final allNutrients = [
      ...analysisResult.nutritionLabel.macroNutrients,
      ...analysisResult.nutritionLabel.microNutrients,
    ];
    final List<NutrientDetail> goodNutrients =
        allNutrients
            .where((n) => n.healthImpact?.toLowerCase() == 'good')
            .toList();
    final List<NutrientDetail> moderateNutrients =
        allNutrients
            .where((n) => n.healthImpact?.toLowerCase() == 'moderate')
            .toList();
    final List<NutrientDetail> badNutrients =
        allNutrients
            .where((n) => n.healthImpact?.toLowerCase() == 'bad')
            .toList();

    if (allNutrients.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: Sizes.m),
        child: Text(
          "Could not extract nutrients from label.",
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      );
    }

    return Column(
      children: [
        if (goodNutrients.isNotEmpty)
          _buildNutrientSection(
            context,
            title: "✅ Optimal Nutrients",
            nutrients: goodNutrients,
            color: Colors.green.shade600,
          ),
        if (moderateNutrients.isNotEmpty)
          _buildNutrientSection(
            context,
            title: "⚠️ Moderate Levels",
            nutrients: moderateNutrients,
            color: Colors.orange.shade700,
          ),
        if (badNutrients.isNotEmpty)
          _buildNutrientSection(
            context,
            title: "🚫 Watch Out For",
            nutrients: badNutrients,
            color: Colors.red.shade600,
          ),
        if (goodNutrients.isEmpty &&
            moderateNutrients.isEmpty &&
            badNutrients.isEmpty &&
            allNutrients.isNotEmpty)
          _buildNutrientSection(
            context,
            title: "ℹ️ Nutrients Found",
            nutrients: allNutrients,
            color: Theme.of(context).colorScheme.secondary,
          ),
      ],
    );
  }

  // Builds the health concerns/recommendations section using NutrientBalanceCard
  Widget _buildConcernsSection(
    BuildContext context,
    ScanLabelPageController controller,
    ProductAnalysisModel analysisResult,
  ) {
    final primaryConcerns =
        analysisResult.healthAssessment?.primaryConcerns ?? [];
    if (primaryConcerns.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: Sizes.defaultSpace / 2,
        vertical: Sizes.spaceBtwItems,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "💡 Health Insights",
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: Sizes.spaceBtwItems),
          ...primaryConcerns.map(
            (concern) => Padding(
              padding: const EdgeInsets.only(bottom: Sizes.spaceBtwItems),
              child: NutrientBalanceCard(
                issue: concern.issue,
                explanation: concern.explanation,
                recommendations:
                    concern.recommendations
                        .map(
                          (rec) => {
                            'food': rec.food,
                            'quantity': rec.quantity,
                            'reasoning': rec.reasoning,
                          },
                        )
                        .toList(),
              ),
            ),
          ),
          const Divider(),
        ],
      ),
    );
  }

  // Helper to build a section (heading + wrap of tiles) for a nutrient category
  Widget _buildNutrientSection(
    BuildContext context, {
    required String title,
    required List<NutrientDetail> nutrients,
    required Color color,
  }) {
    if (nutrients.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.symmetric(vertical: Sizes.s),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: Sizes.s),
            child: SectionHeadingWithAccent(color: color, title: title),
          ),
          const SizedBox(height: Sizes.s),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: Sizes.xs),
            child: Wrap(
              spacing: Sizes.s,

              runSpacing: Sizes.s,
              children:
                  nutrients
                      .map(
                        (nutrientDetail) => NutrientTile.fromNutrientDetail(
                          nutrientDetail,
                          nutrientInsights[nutrientDetail.name],
                        ),
                      )
                      .toList(),
            ),
          ),
          const SizedBox(height: Sizes.m),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: Sizes.s),
            child: const Divider(thickness: 0.5),
          ),
        ],
      ),
    );
  }

  // Builds the input section for the number of servings consumed
  Widget _buildServingConsumptionSection(
    BuildContext context,
    ScanLabelPageController controller,
    ProductAnalysisModel analysisResult,
  ) {
    final labelServingSize = analysisResult.nutritionLabel.servingSize;
    final servingValue = labelServingSize?.value?.toDouble();
    final servingUnitText =
        (servingValue != null
            ? "${servingValue.toStringAsFixed(servingValue.truncateToDouble() == servingValue ? 0 : 1)} ${labelServingSize?.unit ?? 'units'}"
            : null);

    // Hide if label serving size couldn't be determined
    if (servingValue == null || servingValue <= 0) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: Sizes.defaultSpace,
        vertical: Sizes.m,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Display detected label serving size
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  "Label Serving Size:",
                  style: Theme.of(context).textTheme.labelLarge,
                ),
              ),
              const SizedBox(width: Sizes.s),
              Flexible(
                child: Text(
                  servingUnitText ?? "",
                  style: Theme.of(
                    context,
                  ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
              ),
              IconButton(
                icon: Icon(
                  Icons.info_outline_rounded,
                  size: 18,
                  color: Theme.of(context).textTheme.bodySmall?.color,
                ),
                onPressed:
                    () => controller.showEditServingSizeDialog(
                      context,
                    ), // Use controller method
                tooltip: "View Detected Serving Size",
                visualDensity: VisualDensity.compact,
                padding: EdgeInsets.zero,
              ),
            ],
          ),
          const SizedBox(height: Sizes.m),
          // Prompt for user consumption
          Text(
            "How many servings did you consume?",
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: Sizes.spaceBtwItems),
          // Input field for servings consumed
          TextField(
            controller:
                controller
                    .servingInputController, // Connect to controller's text controller
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
            ], // Allow numbers and up to 2 decimals
            decoration: InputDecoration(
              hintText: "e.g., 0.5, 1, 1.5 servings",
              prefixIcon: const Icon(Icons.pie_chart_outline_rounded),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(Sizes.inputFieldRadius),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
            onChanged:
                controller
                    .updateServingsConsumed, // Update reactive variable via controller method
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  // Helper for consistent loading indicators
  Widget _buildLoadingIndicator(String message, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: Sizes.m),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(
              height: 24,
              width: 24,
              child: CircularProgressIndicator(strokeWidth: 2),
            ), // Smaller indicator
            const SizedBox(height: Sizes.s),
            Text(message, style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}

// --- Image Preview Tile Widget ---
class ImagePreviewTileSimple extends StatelessWidget {
  final String title;
  final File? imageFile;
  final VoidCallback? onTap;

  const ImagePreviewTileSimple({
    super.key,
    required this.title,
    required this.imageFile,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: Sizes.xs),
          child: Text(title, style: Theme.of(context).textTheme.labelLarge),
        ),
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(Sizes.cardRadiusMd),
          child: SizedBox(
            height: 100,
            width: 100,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(Sizes.cardRadiusMd),
              child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest
                      .withOpacity(0.5), // Use theme color
                  border: Border.all(
                    color: Theme.of(context).dividerColor.withOpacity(0.5),
                    width: 0.5,
                  ),
                  borderRadius: BorderRadius.circular(Sizes.cardRadiusMd),
                ),
                child:
                    imageFile != null
                        ? Image.file(
                          imageFile!,
                          fit: BoxFit.cover,
                          // loadingBuilder: (context, child, loadingProgress) {
                          //   if (loadingProgress == null) return child;
                          //   return const Center(
                          //     child: CircularProgressIndicator(strokeWidth: 2),
                          //   );
                          // },
                          errorBuilder:
                              (context, error, stackTrace) => const Center(
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
                        ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// --- Section Heading Helper Widget ---
class SectionHeadingWithAccent extends StatelessWidget {
  const SectionHeadingWithAccent({
    super.key,
    this.color = SColors.primary,
    required this.title,
  });
  final String title;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 20,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: Sizes.s),
        Expanded(
          child: Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
// import 'package:eat_right/data/services/logic/logic.dart';
// import 'package:eat_right/data/services/logic/new_logic/analysis_controller.dart';
// import 'package:eat_right/data/services/logic/new_logic/image_controller.dart';
// import 'package:eat_right/data/services/logic/new_logic/nutrient_controller.dart';
// import 'package:eat_right/temp/nutrient_insights.dart';
// import 'package:eat_right/temp/screens/ask_ai_page.dart';
// import 'package:eat_right/temp/widgets/ask_ai_widget.dart';
// import 'package:eat_right/temp/widgets/nutrient_balance_card.dart';
// import 'package:eat_right/temp/widgets/nutrient_info_shimmer.dart';
// import 'package:eat_right/temp/widgets/nutrient_tile.dart';
// import 'package:eat_right/temp/widgets/portion_buttons.dart';
// import 'package:eat_right/utils/constants/colors.dart';
// import 'package:eat_right/utils/constants/sizes.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:image_picker/image_picker.dart';

// class ScanLabelController extends GetxController {
//   // Inject required controllers
//   final imageController = ImageController.instance;
//   final nutrientController = NutrientController.instance;
//   final analysisController = AnalysisController.instance;
//   final logicController = Get.find<LogicController>();

//   // Scanning steps
//   final RxInt scanningStep =
//       0.obs; // 0: initial, 1: food scanned, 2: label scanned

//   // Custom portion observable
//   final RxDouble customPortion = 0.0.obs;

//   // Capture food image
//   void captureFoodImage({required ImageSource source}) {
//     imageController.captureImage(source: source, isFrontImage: true).then((_) {
//       if (imageController.frontImage.value != null) {
//         scanningStep.value = 1;
//       }
//     });
//   }

//   // Capture label image
//   void captureLabelImage({required ImageSource source}) {
//     imageController.captureImage(source: source, isFrontImage: false).then((_) {
//       if (imageController.nutritionLabelImage.value != null) {
//         scanningStep.value = 2;
//       }
//     });
//   }

//   // Analyze images
//   void analyzeImages() {
//     if (imageController.frontImage.value != null &&
//         imageController.nutritionLabelImage.value != null) {
//       analysisController.analyzeImages(
//         frontImage: imageController.frontImage.value!,
//         nutritionLabelImage: imageController.nutritionLabelImage.value!,
//       );
//     } else if (imageController.frontImage.value != null) {
//       // If we only have the front image, still try to analyze
//       analysisController.analyzeFoodImage(
//         imageFile: imageController.frontImage.value!,
//       );
//     } else {
//       Get.snackbar(
//         'Missing Images',
//         'Please scan both food and label images before analyzing',
//         snackPosition: SnackPosition.BOTTOM,
//       );
//     }
//   }

//   // Reset scanning
//   void resetScanning() {
//     scanningStep.value = 0;
//     imageController.clearImages();
//   }

//   void updateServingSize(double value) {
//     nutrientController.updateServingSize(value);
//   }

//   void updateCustomPortion(double value) {
//     customPortion.value = value;
//     nutrientController.updateSliderValue(value);
//   }

//   void navigateToAskAi() {
//     if (imageController.frontImage.value != null) {
//       Get.to(
//         () => AskAiPage(
//           mealName: analysisController.productName.value,
//           foodImage: imageController.frontImage.value!,
//         ),
//       );
//     }
//   }
// }

// class ScanLabelPage extends StatelessWidget {
//   const ScanLabelPage({super.key});

//   @override
//   Widget build(BuildContext context) {
//     // Initialize controller using Get.put to ensure it's created when the page loads
//     final controller = Get.put(ScanLabelController());

//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Scan Label'),
//         centerTitle: true,
//         backgroundColor: Theme.of(context).colorScheme.surface,
//         actions: [
//           Obx(
//             () =>
//                 controller.scanningStep.value > 0
//                     ? IconButton(
//                       icon: const Icon(Icons.refresh),
//                       onPressed: controller.resetScanning,
//                       tooltip: 'Reset scanning',
//                     )
//                     : const SizedBox.shrink(),
//           ),
//         ],
//       ),
//       body: SingleChildScrollView(
//         physics: const BouncingScrollPhysics(),
//         child: Padding(
//           padding: EdgeInsets.only(
//             bottom: MediaQuery.of(context).padding.bottom + 80,
//           ),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.center,
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               const SizedBox(height: 20),
//               Obx(() {
//                 switch (controller.scanningStep.value) {
//                   case 0:
//                     return _buildFoodScanSection(context, controller);
//                   case 1:
//                     return _buildLabelScanSection(context, controller);
//                   case 2:
//                     return _buildAnalyzeButton(context, controller);
//                   default:
//                     return const SizedBox.shrink();
//                 }
//               }),
//               _buildImagePreviewSection(context, controller),
//               _buildNutrientInfoSection(context, controller),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildFoodScanSection(
//     BuildContext context,
//     ScanLabelController controller,
//   ) {
//     return Container(
//       margin: const EdgeInsets.all(20),
//       padding: const EdgeInsets.all(20),
//       decoration: BoxDecoration(
//         color: SColors.borderLight,
//         borderRadius: BorderRadius.circular(20),
//         border: Border.all(color: Colors.transparent),
//       ),
//       child: Column(
//         children: [
//           const Icon(Icons.fastfood, size: 48, color: Colors.amberAccent),
//           const SizedBox(height: 20),
//           Text(
//             "Step 1: Scan the food",
//             style: Theme.of(context).textTheme.headlineSmall,
//             textAlign: TextAlign.center,
//           ),
//           const SizedBox(height: 10),
//           Text(
//             "Take a picture of the food item you want to analyze",
//             textAlign: TextAlign.center,
//             style: Theme.of(context).textTheme.bodyMedium,
//           ),
//           const SizedBox(height: 20),
//           Row(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               ElevatedButton.icon(
//                 icon: const Icon(Icons.camera_alt_outlined),
//                 label: const Text("Take Photo"),
//                 onPressed:
//                     () =>
//                         controller.captureFoodImage(source: ImageSource.camera),
//               ),
//               const SizedBox(width: 16),
//               ElevatedButton.icon(
//                 icon: const Icon(Icons.photo_library_outlined),
//                 label: const Text("Gallery"),
//                 onPressed:
//                     () => controller.captureFoodImage(
//                       source: ImageSource.gallery,
//                     ),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildLabelScanSection(
//     BuildContext context,
//     ScanLabelController controller,
//   ) {
//     return Container(
//       margin: const EdgeInsets.all(20),
//       padding: const EdgeInsets.all(20),
//       decoration: BoxDecoration(
//         color: SColors.borderLight,
//         borderRadius: BorderRadius.circular(20),
//         border: Border.all(color: Colors.transparent),
//       ),
//       child: Column(
//         children: [
//           const Icon(Icons.receipt_long, size: 48, color: Colors.greenAccent),
//           const SizedBox(height: 20),
//           Text(
//             "Step 2: Scan the nutrition label",
//             style: Theme.of(context).textTheme.headlineSmall,
//             textAlign: TextAlign.center,
//           ),
//           const SizedBox(height: 10),
//           Text(
//             "Take a clear picture of the nutrition facts label",
//             textAlign: TextAlign.center,
//             style: Theme.of(context).textTheme.bodyMedium,
//           ),
//           const SizedBox(height: 20),
//           Row(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               ElevatedButton.icon(
//                 icon: const Icon(Icons.camera_alt_outlined),
//                 label: const Text("Take Photo"),
//                 onPressed:
//                     () => controller.captureLabelImage(
//                       source: ImageSource.camera,
//                     ),
//               ),
//               const SizedBox(width: 16),
//               ElevatedButton.icon(
//                 icon: const Icon(Icons.photo_library_outlined),
//                 label: const Text("Gallery"),
//                 onPressed:
//                     () => controller.captureLabelImage(
//                       source: ImageSource.gallery,
//                     ),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildAnalyzeButton(
//     BuildContext context,
//     ScanLabelController controller,
//   ) {
//     return Container(
//       margin: const EdgeInsets.all(20),
//       padding: const EdgeInsets.all(20),
//       decoration: BoxDecoration(
//         color: SColors.borderLight,
//         borderRadius: BorderRadius.circular(20),
//         border: Border.all(color: Colors.transparent),
//       ),
//       child: Column(
//         children: [
//           const Icon(Icons.analytics, size: 48, color: Colors.purpleAccent),
//           const SizedBox(height: 20),
//           Text(
//             "Ready to analyze!",
//             style: Theme.of(context).textTheme.headlineSmall,
//             textAlign: TextAlign.center,
//           ),
//           const SizedBox(height: 10),
//           Text(
//             "Both food and label images captured successfully",
//             textAlign: TextAlign.center,
//             style: Theme.of(context).textTheme.bodyMedium,
//           ),
//           const SizedBox(height: 20),
//           ElevatedButton.icon(
//             icon: const Icon(Icons.science),
//             label: const Text("Analyze Now"),
//             style: ElevatedButton.styleFrom(
//               padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
//               textStyle: const TextStyle(fontSize: 18),
//             ),
//             onPressed: () => controller.analyzeImages(),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildImagePreviewSection(
//     BuildContext context,
//     ScanLabelController controller,
//   ) {
//     return Obx(() {
//       if (controller.imageController.frontImage.value == null &&
//           controller.imageController.nutritionLabelImage.value == null) {
//         return const SizedBox.shrink();
//       }

//       return Container(
//         margin: const EdgeInsets.symmetric(horizontal: Sizes.defaultSpace),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text("Your images", style: Theme.of(context).textTheme.titleLarge),
//             const SizedBox(height: 10),
//             Row(
//               children: [
//                 if (controller.imageController.frontImage.value != null)
//                   Expanded(
//                     child: Column(
//                       children: [
//                         ClipRRect(
//                           borderRadius: BorderRadius.circular(12),
//                           child: Stack(
//                             children: [
//                               Image.file(
//                                 controller.imageController.frontImage.value!,
//                                 height: 120,
//                                 width: double.infinity,
//                                 fit: BoxFit.cover,
//                               ),
//                               Positioned(
//                                 bottom: 0,
//                                 left: 0,
//                                 right: 0,
//                                 child: Container(
//                                   color: Colors.black54,
//                                   padding: const EdgeInsets.symmetric(
//                                     vertical: 4,
//                                   ),
//                                   child: const Text(
//                                     "Food Image",
//                                     textAlign: TextAlign.center,
//                                     style: TextStyle(color: Colors.white),
//                                   ),
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 const SizedBox(width: 10),
//                 if (controller.imageController.nutritionLabelImage.value !=
//                     null)
//                   Expanded(
//                     child: Column(
//                       children: [
//                         ClipRRect(
//                           borderRadius: BorderRadius.circular(12),
//                           child: Stack(
//                             children: [
//                               Image.file(
//                                 controller
//                                     .imageController
//                                     .nutritionLabelImage
//                                     .value!,
//                                 height: 120,
//                                 width: double.infinity,
//                                 fit: BoxFit.cover,
//                               ),
//                               Positioned(
//                                 bottom: 0,
//                                 left: 0,
//                                 right: 0,
//                                 child: Container(
//                                   color: Colors.black54,
//                                   padding: const EdgeInsets.symmetric(
//                                     vertical: 4,
//                                   ),
//                                   child: const Text(
//                                     "Label Image",
//                                     textAlign: TextAlign.center,
//                                     style: TextStyle(color: Colors.white),
//                                   ),
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//               ],
//             ),
//           ],
//         ),
//       );
//     });
//   }

//   Widget _buildNutrientInfoSection(
//     BuildContext context,
//     ScanLabelController controller,
//   ) {
//     return Obx(
//       () =>
//           controller.analysisController.isAnalyzing.value
//               ? const NutrientInfoShimmer()
//               : Column(
//                 children: [
//                   if (controller.nutrientController.goodNutrients.isNotEmpty)
//                     _buildNutrientSection(
//                       context,
//                       title: "Optimal Nutrients",
//                       nutrients: controller.nutrientController.goodNutrients,
//                       color: const Color(0xFF4CAF50),
//                     ),
//                   if (controller.nutrientController.badNutrients.isNotEmpty)
//                     _buildNutrientSection(
//                       context,
//                       title: "Watch Out",
//                       nutrients: controller.nutrientController.badNutrients,
//                       color: const Color(0xFFFF5252),
//                     ),
//                   _buildConcernsSection(controller),
//                   _buildServingSizeSection(context, controller),
//                   if (controller.nutrientController.servingSize.value > 0)
//                     InkWell(
//                       onTap: controller.navigateToAskAi,
//                       child: const AskAiWidget(),
//                     ),
//                 ],
//               ),
//     );
//   }

//   Widget _buildConcernsSection(ScanLabelController controller) {
//     final primaryConcerns =
//         controller.analysisController.nutritionAnalysis['primary_concerns'];

//     if (primaryConcerns == null) return const SizedBox.shrink();

//     return Column(
//       children: List.generate(
//         primaryConcerns.length,
//         (index) => NutrientBalanceCard(
//           issue: primaryConcerns[index]['issue'] ?? '',
//           explanation: primaryConcerns[index]['explanation'] ?? '',
//           recommendations:
//               (primaryConcerns[index]['recommendations'] as List?)
//                   ?.map(
//                     (rec) => {
//                       'food': rec['food'] ?? '',
//                       'quantity': rec['quantity'] ?? '',
//                       'reasoning': rec['reasoning'] ?? '',
//                     },
//                   )
//                   .toList() ??
//               [],
//         ),
//       ),
//     );
//   }

//   Widget _buildNutrientSection(
//     BuildContext context, {
//     required String title,
//     required List<Map<String, dynamic>> nutrients,
//     required Color color,
//   }) {
//     return Container(
//       margin: const EdgeInsets.symmetric(vertical: 24.0),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 24.0),
//             child: SectionHeadingWithAccent(color: color, title: title),
//           ),
//           const SizedBox(height: 16),
//           Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 20.0),
//             child: Wrap(
//               spacing: 12,
//               runSpacing: 12,
//               children:
//                   nutrients
//                       .map(
//                         (nutrient) => NutrientTile(
//                           nutrient: nutrient['name'],
//                           healthSign: nutrient['health_impact'],
//                           quantity: nutrient['quantity'].toString(),
//                           insight: nutrientInsights[nutrient['name']],
//                           dailyValue: nutrient['daily_value'],
//                         ),
//                       )
//                       .toList(),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildServingSizeSection(
//     BuildContext context,
//     ScanLabelController controller,
//   ) {
//     return Obx(() {
//       // Show manual entry if serving size is 0 but we have parsed nutrients
//       if (controller.nutrientController.servingSize.value == 0 &&
//           controller.nutrientController.parsedNutrients.isNotEmpty) {
//         return _buildManualServingSizeSection(context, controller);
//       }

//       // Show standard serving size section if we have a valid serving size
//       if (controller.nutrientController.servingSize.value > 0) {
//         return Padding(
//           padding: const EdgeInsets.all(16.0),
//           child: Column(
//             children: [
//               Row(
//                 children: [
//                   Text(
//                     "Serving Size: ${controller.nutrientController.servingSize.value.round()} g",
//                     style: TextStyle(
//                       color: Theme.of(context).textTheme.bodyLarge!.color,
//                       fontSize: 16,
//                       fontFamily: 'Poppins',
//                     ),
//                   ),
//                   IconButton(
//                     icon: Icon(
//                       Icons.edit,
//                       color: Theme.of(context).textTheme.titleSmall!.color,
//                       size: 20,
//                     ),
//                     onPressed: () {
//                       _showEditServingSizeDialog(context, controller);
//                     },
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 16),
//               Align(
//                 alignment: Alignment.centerLeft,
//                 child: Text(
//                   "How much did you consume?",
//                   style: Theme.of(context).textTheme.bodyMedium,
//                   // TextStyle(
//                   //   color: Theme.of(context).textTheme.bodyMedium!.color,
//                   //   fontSize: 16,
//                   //   fontFamily: 'Poppins',
//                   // ),
//                 ),
//               ),
//               const SizedBox(height: 8),
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                 children: [
//                   PortionButton(portion: 0.25, label: "¼"),
//                   PortionButton(portion: 0.5, label: "½"),
//                   PortionButton(portion: 0.75, label: "¾"),
//                   PortionButton(portion: 1.0, label: "1"),
//                   CustomPortionButton(),
//                 ],
//               ),
//             ],
//           ),
//         );
//       }

//       // Return empty container if no serving size and no parsed nutrients
//       return const SizedBox.shrink();
//     });
//   }

//   Widget _buildManualServingSizeSection(
//     BuildContext context,
//     ScanLabelController controller,
//   ) {
//     return Padding(
//       padding: const EdgeInsets.all(16.0),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           const Text(
//             'Serving size not found, please enter it manually',
//             style: TextStyle(color: Colors.white, fontSize: 16),
//           ),
//           const SizedBox(height: 8),
//           TextField(
//             keyboardType: TextInputType.number,
//             onChanged: (value) {
//               controller.updateCustomPortion(double.tryParse(value) ?? 0.0);
//             },
//             decoration: const InputDecoration(
//               hintText: "Enter serving size in grams or ml",
//               hintStyle: TextStyle(color: Colors.white54),
//               border: OutlineInputBorder(),
//               contentPadding: EdgeInsets.symmetric(
//                 horizontal: 16,
//                 vertical: 12,
//               ),
//             ),
//             style: const TextStyle(color: Colors.white),
//           ),
//           const SizedBox(height: 8),
//           ElevatedButton(
//             onPressed: () {
//               if (controller.customPortion.value > 0) {
//                 controller.updateServingSize(controller.customPortion.value);
//               }
//             },
//             child: const Text("Apply"),
//           ),
//         ],
//       ),
//     );
//   }

//   void _showEditServingSizeDialog(
//     BuildContext context,
//     ScanLabelController controller,
//   ) {
//     final TextEditingController textController = TextEditingController(
//       text: controller.nutrientController.servingSize.value.toString(),
//     );

//     showDialog(
//       context: context,
//       builder:
//           (context) => AlertDialog(
//             backgroundColor: SColors.textSecondary,
//             title: Text(
//               'Edit Serving Size',
//               style: TextStyle(
//                 color: Theme.of(context).textTheme.titleLarge!.color,
//                 fontFamily: 'Poppins',
//               ),
//             ),
//             content: TextField(
//               controller: textController,
//               keyboardType: TextInputType.number,
//               style: TextStyle(
//                 color: Theme.of(context).textTheme.titleLarge!.color,
//               ),
//               decoration: InputDecoration(
//                 hintText: 'Enter serving size in grams',
//                 hintStyle: TextStyle(
//                   color: Theme.of(context).textTheme.titleLarge!.color,
//                   fontFamily: 'Poppins',
//                 ),
//               ),
//             ),
//             actions: [
//               TextButton(
//                 child: Text(
//                   'Cancel',
//                   style: TextStyle(
//                     fontFamily: 'Poppins',
//                     color: Theme.of(context).textTheme.titleMedium!.color,
//                   ),
//                 ),
//                 onPressed: () => Navigator.of(context).pop(),
//               ),
//               ElevatedButton(
//                 child: Text('Apply', style: TextStyle(fontFamily: 'Poppins')),
//                 onPressed: () {
//                   double value = double.tryParse(textController.text) ?? 0.0;
//                   if (value > 0) {
//                     controller.updateServingSize(value);
//                   }
//                   Navigator.of(context).pop();
//                 },
//               ),
//             ],
//           ),
//     );
//   }
// }

// class SectionHeadingWithAccent extends StatelessWidget {
//   const SectionHeadingWithAccent({
//     super.key,
//     this.color = SColors.primary,
//     required this.title,
//   });

//   final String title;
//   final Color? color;

//   @override
//   Widget build(BuildContext context) {
//     return Row(
//       children: [
//         Container(
//           width: 4,
//           height: 24,
//           decoration: BoxDecoration(
//             color: color,
//             borderRadius: BorderRadius.circular(2),
//           ),
//         ),
//         const SizedBox(width: 12),
//         Text(
//           title,
//           style: Theme.of(context).textTheme.titleLarge!.copyWith(
//             color: Theme.of(context).textTheme.titleLarge!.color,
//             fontSize: 20,
//             // fontWeight: FontWeight.w400,
//             // fontFamily: 'Poppins',
//           ),
//           // TextStyle(
//           //   color: Theme.of(context).textTheme.titleLarge!.color,
//           //   fontSize: 20,
//           //   fontWeight: FontWeight.w400,
//           //   fontFamily: 'Poppins',
//           // ),
//         ),
//       ],
//     );
//   }
// }
