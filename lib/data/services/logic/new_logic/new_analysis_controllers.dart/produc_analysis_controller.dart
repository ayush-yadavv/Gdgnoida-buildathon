// lib/data/services/logic/new_logic/product_analysis_controller.dart

import 'dart:convert';
import 'dart:io';

import 'package:eat_right/data/services/logic/new_data_model/food_consumption_models/analysis_models/product_analysis_model.dart'; // Updated Model Import
import 'package:eat_right/data/services/logic/new_logic/analysis_prompts.dart';
import 'package:eat_right/temp/dv_values.dart'; // Assuming this provides 'nutrientData'
import 'package:eat_right/utils/network_manager/network_manager.dart';
// TODO: Import your image upload service repository
// import 'package:eat_right/data/repositories/storage/image_storage_repository.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

class ProductAnalysisController extends GetxController {
  static ProductAnalysisController get instance => Get.find();

  // Dependencies (Example)
  // final ImageStorageRepository _imageRepo = Get.find(); // TODO: Inject image repo

  // Reactive State
  final Rx<ProductAnalysisModel?> productAnalysisResult =
      Rx<ProductAnalysisModel?>(null);
  final RxBool isAnalyzing = false.obs;
  final RxString errorMessage = ''.obs;

  // --- Public Methods ---

  /// Analyzes product front and label images using Gemini API.
  /// Returns true on success, false on failure.
  Future<bool> analyzeImages({
    required File frontImage,
    required File nutritionLabelImage,
  }) async {
    _startAnalysis();
    try {
      final apiKey = _getApiKey();
      if (apiKey == null) throw Exception("API Key not found.");

      final model = GenerativeModel(model: 'gemini-1.5-flash', apiKey: apiKey);
      final frontImageBytes = await frontImage.readAsBytes();
      final labelImageBytes = await nutritionLabelImage.readAsBytes();

      final imageParts = [
        DataPart('image/jpeg', frontImageBytes),
        DataPart('image/jpeg', labelImageBytes),
      ];

      // Include nutrient context if needed by the prompt (from dv_values.dart)
      final nutrientParts =
          nutrientData // Assuming nutrientData is available
              .map(
                (nutrient) => TextPart(
                  "${nutrient['Nutrient']}: ${nutrient['Current Daily Value']}",
                ),
              )
              .toList();

      final prompt = TextPart(
        AnalysisPrompts.analyseProductImagesV1,
      ); // Using V1 prompt

      if (!await NetworkManager.instance.isConnected()) {
        throw Exception("No internet connection");
      }

      final response = await model.generateContent([
        Content.multi([prompt, ...nutrientParts, ...imageParts]),
      ]);

      if (response.text == null || response.text!.isEmpty) {
        throw Exception("Received empty response from analysis service.");
      }

      // Parse the JSON response
      final jsonResponse = _extractJson(response.text!);
      final parsedModel = ProductAnalysisModel.fromJson(jsonResponse);
      print(parsedModel);

      if (parsedModel.status.toLowerCase() == 'failure') {
        throw Exception(
          parsedModel.errorMessage ?? "Analysis failed without specific error.",
        );
      }

      // --- TODO: Image Upload Logic ---
      // Upload the front image *after* successful analysis parsing
      // String? imageUrl;
      // try {
      //   // Assume _imageRepo.uploadProductImage returns the download URL
      //   imageUrl = await _imageRepo.uploadProductImage(frontImage, /* optional userId? */);
      // } catch (uploadError) {
      //   print("Warning: Failed to upload product image: $uploadError");
      // }
      // --- End Image Upload ---

      // Set the result (potentially including the uploaded image URL)
      // final finalModel = parsedModel.copyWith(frontImageUrl: () => imageUrl);
      // productAnalysisResult.value = finalModel;

      // TEMPORARY: Set result without image URL
      productAnalysisResult.value = parsedModel;

      _completeAnalysis();
      return true;
    } catch (e) {
      _handleError("Error analyzing product images: $e");
      return false;
    } finally {
      isAnalyzing.value = false;
    }
  }

  // void _navigateToAskAi() {
  //   final analysisResult = productAnalysisResult.value;
  //   final imageFile =
  //       ImageController.instance.frontImage.value; // Use front image

  //   if (analysisResult != null && imageFile != null) {
  //     Get.to(
  //       () => AskAiPage(
  //         productAnalysis: analysisResult, // Pass the product model
  //         foodImage: imageFile,
  //         // Removed mealName
  //       ),
  //     );
  //   } else {
  //     Get.snackbar(
  //       'Missing Info',
  //       'Please analyze a product first.',
  //       snackPosition: SnackPosition.BOTTOM,
  //     );
  //   }
  // }

  /// Clears the current analysis result and error message.
  void clearAnalysis() {
    productAnalysisResult.value = null;
    errorMessage.value = '';
    isAnalyzing.value = false;
  }

  // --- Private Helpers ---
  // (Include _startAnalysis, _completeAnalysis, _handleError, _getApiKey, _extractJson - identical to MealAnalysisController)
  void _startAnalysis() {
    isAnalyzing.value = true;
    errorMessage.value = '';
    productAnalysisResult.value = null; // Clear previous result
  }

  void _completeAnalysis() {
    isAnalyzing.value = false;
    errorMessage.value = '';
  }

  void _handleError(String errorMsg) {
    print(errorMsg);
    errorMessage.value = errorMsg;
    isAnalyzing.value = false;
    productAnalysisResult.value = null; // Clear potentially partial results
  }

  String? _getApiKey() {
    // Consider moving API key fetching to a dedicated service
    return dotenv.env['GEMINI_API_KEY'];
  }

  Map<String, dynamic> _extractJson(String text) {
    try {
      final startIndex = text.indexOf('{');
      final endIndex = text.lastIndexOf('}');
      if (startIndex == -1 || endIndex == -1 || endIndex < startIndex) {
        throw FormatException("Could not find valid JSON object in response.");
      }
      final jsonString = text.substring(startIndex, endIndex + 1);
      return jsonDecode(jsonString) as Map<String, dynamic>;
    } on FormatException catch (e) {
      print("JSON Parsing Error: $e\nOriginal Text: $text");
      throw FormatException(
        "Failed to parse analysis response: Invalid JSON format.",
      );
    } catch (e) {
      print("JSON Extraction Error: $e");
      throw Exception(
        "An unexpected error occurred while processing the analysis response.",
      );
    }
  }
}
