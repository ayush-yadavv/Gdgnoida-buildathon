import 'package:eat_right/data/services/Image_handler/image_controller.dart';
import 'package:eat_right/data/services/logic/new_data_model/food_consumption_models/analysis_models/product_analysis_model.dart';
import 'package:eat_right/data/services/logic/new_logic/new_analysis_controllers.dart/food_consumption_controller.dart';
import 'package:eat_right/data/services/logic/new_logic/new_analysis_controllers.dart/produc_analysis_controller.dart'; // Ensure correct path
import 'package:eat_right/temp/screens/ask_ai_page.dart';
import 'package:eat_right/utils/popups/full_screen_loader.dart';
import 'package:eat_right/utils/constants/lottie_Str.dart';
import 'package:flutter/material.dart'; // For BuildContext, TextEditingController etc.
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class ScanLabelPageController extends GetxController {
  static ScanLabelPageController get instance => Get.find();

  // --- Dependencies ---
  // These are typically injected or found using Get.find() if registered elsewhere
  final imageController = ImageController();
  final productAnalysisController = ProductAnalysisController.instance;
  final foodConsumptionController = FoodConsumptionController.instance;

  // --- State ---
  final RxInt scanningStep =
      0.obs; // 0: initial, 1: food scanned, 2: label scanned, 3: analyzed
  final RxDouble servingsConsumed = 1.0.obs; // Default to 1 serving
  final TextEditingController servingInputController = TextEditingController(
    text: '1.0',
  );

  // --- Getters (Convenience) ---
  // Optional: provide getters for reactive states in dependent controllers if needed often
  Rx<ProductAnalysisModel?> get productAnalysisResult =>
      productAnalysisController.productAnalysisResult;
  RxBool get isAnalyzingProduct => productAnalysisController.isAnalyzing;
  RxBool get isLoggingConsumption => foodConsumptionController.isLogging;

  // --- Lifecycle Methods ---
  @override
  void onInit() {
    super.onInit();
    _resetScanningInternal(); // Ensure clean state on init (using internal method to avoid notify)

    // Listener for analysis results finishing
    ever(
      productAnalysisController.productAnalysisResult,
      _handleAnalysisResult,
    );
    // Listener to reset servings if analysis is cleared elsewhere
    ever(productAnalysisController.productAnalysisResult, (
      ProductAnalysisModel? result,
    ) {
      if (result == null) {
        // If analysis is cleared, reset servings input too
        servingsConsumed.value = 1.0;
        servingInputController.text = '1.0';
        if (scanningStep.value == 3) {
          scanningStep.value = 0; // Go back if analysis cleared
        }
      }
    });
  }

  @override
  void onClose() {
    servingInputController.dispose();
    // Optional: Clear state when controller is removed
    // clearAllState();
    super.onClose();
  }

  // --- Actions ---
  void captureFoodImage(ImageSource source) {
    // Clear previous analysis if starting over
    if (scanningStep.value > 0) {
      productAnalysisController.clearAnalysis();
    }
    imageController.captureImage(source: source, isFrontImage: true).then((_) {
      if (imageController.frontImage.value != null) {
        scanningStep.value = 1; // Move to next step
      }
    });
  }

  void captureLabelImage(ImageSource source) {
    imageController.captureImage(source: source, isFrontImage: false).then((_) {
      if (imageController.nutritionLabelImage.value != null) {
        scanningStep.value = 2; // Move to analyze step
      }
    });
  }

  Future<void> analyzeImages() async {
    // Make async if needed (although controller handles async internally)
    if (imageController.frontImage.value != null &&
        imageController.nutritionLabelImage.value != null) {
      // Analysis result will be handled by the 'ever' listener (_handleAnalysisResult)
      await productAnalysisController.analyzeImages(
        frontImage: imageController.frontImage.value!,
        nutritionLabelImage: imageController.nutritionLabelImage.value!,
      );
      scanningStep.value = 3;
    } else {
      Get.snackbar(
        'Missing Images',
        'Please scan both images before analyzing.',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  /// Resets the entire scanning process and clears all related data.
  void resetScanning() {
    _resetScanningInternal();
    update(); // Force UI update if needed, though Obx should handle it
  }

  /// Internal reset logic without forcing update immediately.
  void _resetScanningInternal() {
    scanningStep.value = 0;
    imageController.clearImages();
    productAnalysisController.clearAnalysis();
    servingsConsumed.value = 1.0;
    servingInputController.text = '1.0';
    print("Scanning state has been reset.");
  }

  // Optional: Method to only clear images if needed separately
  // void clearImagesAndResetStep() { ... }

  void updateServingsConsumed(String value) {
    // Allow empty input temporarily without setting servingsConsumed to 0
    if (value.isEmpty || value == '.') {
      servingsConsumed.value = 0.0; // Or handle intermediate state if needed
    } else {
      servingsConsumed.value = double.tryParse(value) ?? 0.0;
    }
  }

  Future<void> logConsumption() async {
    try {
      // Show loading dialog
      SFullScreenLoader.openLoadingDialog('Logging your consumption...', Slottie.loading);
      
      final analysisResult = productAnalysisController.productAnalysisResult.value;
      if (analysisResult == null) {
        SFullScreenLoader.stopLoading();
        Get.snackbar(
          'Error',
          'No analysis result available.',
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }
      
      if (servingsConsumed.value <= 0) {
        SFullScreenLoader.stopLoading();
        Get.snackbar(
          'Error',
          'Please enter servings consumed (> 0).',
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      // Optional: Show DateTime picker for consumedAt
      DateTime consumedAtTime = DateTime.now();

      // Log the consumption
      bool success = await foodConsumptionController.logProductConsumption(
        analysis: analysisResult,
        servingsConsumed: servingsConsumed.value,
        consumedAt: consumedAtTime,
      );

      // Stop loading regardless of success/failure
      SFullScreenLoader.stopLoading();

      if (success) {
        resetScanning(); // Reset the page after successful log
      }
    } catch (e) {
      // Ensure loader is stopped if an error occurs
      SFullScreenLoader.stopLoading();
      
      // Show error to user
      Get.snackbar(
        'Error',
        'Failed to log consumption: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  void navigateToAskAi() {
    final analysisResult =
        productAnalysisController.productAnalysisResult.value;
    if (analysisResult != null) {
      Get.to(
        () => AskAiPage(
          analysisData: analysisResult,
          foodImage:
              imageController.frontImage.value, // Pass image if available
        ),
      );
    } else {
      Get.snackbar(
        'Missing Info',
        'Please analyze a product first.',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // --- Private Listeners / Helpers ---
  void _handleAnalysisResult(ProductAnalysisModel? result) {
    if (result != null && scanningStep.value == 2) {
      if (result.status.toLowerCase() == 'success') {
        scanningStep.value = 3;
        servingsConsumed.value =
            1.0; // Reset servings on new successful analysis
        servingInputController.text = '1.0';
      } else {
        // Error message shown by the ProductAnalysisController's error handling
        // Decide how to handle UI state on failure
        // Option 1: Stay on step 2 to allow re-analysis
        scanningStep.value = 2;
        // Option 2: Reset everything
        // resetScanning();
      }
    }
  }

  void showEditServingSizeDialog(BuildContext context) {
    final analysisResult =
        productAnalysisController.productAnalysisResult.value;
    if (analysisResult == null) return;

    final labelServingSize = analysisResult.nutritionLabel.servingSize;
    final servingValue = labelServingSize?.value?.toDouble();
    final servingUnitText =
        labelServingSize?.textDescription ??
        (servingValue != null
            ? "${servingValue.toStringAsFixed(servingValue.truncateToDouble() == servingValue ? 0 : 1)} ${labelServingSize?.unit ?? 'units'}"
            : "N/A");

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).cardColor,
        title: const Text('Label Serving Size Info'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Detected Label Serving Size:",
              style: Theme.of(context).textTheme.labelMedium,
            ),
            Text(
              servingUnitText,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 15),
            Text(
              "This is the serving size read from the label by the AI. If this looks incorrect, the analysis might be flawed. Adjust the 'Servings Consumed' value below based on how much you actually ate relative to this label serving size.",
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
        actions: [
          TextButton(
            child: const Text('OK'),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }
}
// // lib/features/main_app/controllers/scan_label_page_controller.dart (Create this file)

// import 'package:eat_right/data/services/logic/new_data_model/food_consumption_models/analysis_models/product_analysis_model.dart';
// import 'package:eat_right/data/services/logic/new_logic/image_controller.dart';
// import 'package:eat_right/data/services/logic/new_logic/new_analysis_controllers.dart/food_consumption_controller.dart';
// import 'package:eat_right/data/services/logic/new_logic/new_analysis_controllers.dart/produc_analysis_controller.dart';
// import 'package:eat_right/temp/screens/ask_ai_page.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:image_picker/image_picker.dart';

// class ScanLabelPageController extends GetxController {
//   static ScanLabelPageController get instance => Get.find();

//   // --- Dependencies ---
//   final imageController = ImageController.instance;
//   final productAnalysisController = ProductAnalysisController.instance;
//   final foodConsumptionController = FoodConsumptionController.instance;

//   // --- State ---
//   final RxInt scanningStep =
//       0.obs; // 0: initial, 1: food scanned, 2: label scanned, 3: analyzed
//   final RxDouble servingsConsumed = 1.0.obs; // Default to 1 serving
//   final TextEditingController servingInputController = TextEditingController(
//     text: '1.0',
//   );

//   // --- Lifecycle Methods ---
//   @override
//   void onInit() {
//     super.onInit();
//     resetScanning();

//     // Listener for analysis results
//     ever(
//       productAnalysisController.productAnalysisResult,
//       _handleAnalysisResult,
//     );
//   }

//   @override
//   void onClose() {
//     servingInputController.dispose();
//     // Optionally clear analysis/images when controller is removed
//     // clearAll();
//     super.onClose();
//   }

//   // --- Actions ---
//   void captureFoodImage(ImageSource source) {
//     imageController.captureImage(source: source, isFrontImage: true).then((_) {
//       if (imageController.frontImage.value != null) {
//         scanningStep.value = 1;
//       }
//     });
//   }

//   void captureLabelImage(ImageSource source) {
//     imageController.captureImage(source: source, isFrontImage: false).then((_) {
//       if (imageController.nutritionLabelImage.value != null) {
//         scanningStep.value = 2;
//       }
//     });
//   }

//   void analyzeImages() {
//     if (imageController.frontImage.value != null &&
//         imageController.nutritionLabelImage.value != null) {
//       // Analysis result will be handled by the 'ever' listener (_handleAnalysisResult)
//       productAnalysisController.analyzeImages(
//         frontImage: imageController.frontImage.value!,
//         nutritionLabelImage: imageController.nutritionLabelImage.value!,
//       );
//     } else {
//       Get.snackbar(
//         'Missing Images',
//         'Please scan both images before analyzing.',
//         snackPosition: SnackPosition.BOTTOM,
//       );
//     }
//   }

//   void resetScanning() {
//     scanningStep.value = 0;
//     imageController.clearImages();
//     productAnalysisController.clearAnalysis();
//     servingsConsumed.value = 1.0;
//     servingInputController.text = '1.0';
//   }

//   void clearImagesAndResetStep() {
//     imageController.clearImages();
//     productAnalysisController.clearAnalysis();
//     servingsConsumed.value = 1.0;
//     servingInputController.text = '1.0';
//     scanningStep.value = 0; // Go back to first step
//   }

//   void updateServingsConsumed(String value) {
//     servingsConsumed.value = double.tryParse(value) ?? 0.0;
//   }

//   void logConsumption() {
//     final analysisResult =
//         productAnalysisController.productAnalysisResult.value;
//     if (analysisResult == null) {
//       Get.snackbar(
//         'Error',
//         'No analysis result available.',
//         snackPosition: SnackPosition.BOTTOM,
//       );
//       return;
//     }
//     if (servingsConsumed.value <= 0) {
//       Get.snackbar(
//         'Error',
//         'Please enter servings consumed (> 0).',
//         snackPosition: SnackPosition.BOTTOM,
//       );
//       return;
//     }

//     DateTime consumedAtTime =
//         DateTime.now(); // Default, consider allowing user selection

//     foodConsumptionController.logProductConsumption(
//       analysis: analysisResult,
//       servingsConsumed: servingsConsumed.value,
//       consumedAt: consumedAtTime,
//     );
//   }

//   void navigateToAskAi() {
//     final analysisResult =
//         productAnalysisController.productAnalysisResult.value;
//     if (analysisResult != null) {
//       Get.to(
//         () => AskAiPage(
//           analysisData: analysisResult,
//           foodImage:
//               imageController.frontImage.value, // Pass image if available
//         ),
//       );
//     } else {
//       Get.snackbar(
//         'Missing Info',
//         'Please analyze a product first.',
//         snackPosition: SnackPosition.BOTTOM,
//       );
//     }
//   }

//   // --- Private Listeners / Helpers ---
//   void _handleAnalysisResult(ProductAnalysisModel? result) {
//     if (result != null && scanningStep.value == 2) {
//       // Only transition if we were waiting for analysis
//       if (result.status.toLowerCase() == 'success') {
//         scanningStep.value = 3; // Analysis complete state
//         // Reset servings to 1 when new analysis is successful
//         servingsConsumed.value = 1.0;
//         servingInputController.text = '1.0';
//       } else {
//         Get.snackbar(
//           'Analysis Failed',
//           productAnalysisController.errorMessage.value.isNotEmpty
//               ? productAnalysisController.errorMessage.value
//               : "Please try again.",
//           snackPosition: SnackPosition.BOTTOM,
//         );
//         // Decide whether to stay on step 2 (allow retry) or reset fully
//         // Staying on step 2:
//         scanningStep.value = 2;
//         // Or reset completely:
//         // resetScanning();
//       }
//     }
//   }

//   void showEditServingSizeDialog(BuildContext context) {
//     final analysisResult =
//         productAnalysisController.productAnalysisResult.value;
//     if (analysisResult == null) return;

//     final currentServingValue =
//         analysisResult.nutritionLabel.servingSize?.value?.toString() ?? 'N/A';
//     final currentServingUnit =
//         analysisResult.nutritionLabel.servingSize?.unit ?? 'units';

//     showDialog(
//       context: context,
//       builder:
//           (context) => AlertDialog(
//             backgroundColor: Theme.of(context).cardColor, // Use theme color
//             title: const Text('Label Serving Size Info'),
//             content: Column(
//               mainAxisSize: MainAxisSize.min,
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   "Detected Label Serving Size:",
//                   style: Theme.of(context).textTheme.labelMedium,
//                 ),
//                 Text(
//                   "$currentServingValue $currentServingUnit",
//                   style: Theme.of(context).textTheme.titleMedium?.copyWith(
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//                 const SizedBox(height: 15),
//                 Text(
//                   "This is the serving size read from the label. Adjust the 'Servings Consumed' below if you ate a different amount.",
//                   style: Theme.of(context).textTheme.bodySmall,
//                 ),
//               ],
//             ),
//             actions: [
//               TextButton(
//                 child: const Text('OK'),
//                 onPressed: () => Navigator.of(context).pop(),
//               ),
//             ],
//           ),
//     );
//   }
// }
