// lib/data/services/logic/new_logic/meal_analysis_controller.dart

import 'dart:convert';
import 'dart:io';

import 'package:eat_right/data/services/logic/new_data_model/food_consumption_models/analysis_models/meal_analysis_model.dart'; // Updated Model Import
import 'package:eat_right/data/services/logic/new_logic/analysis_prompts.dart';
import 'package:eat_right/temp/dv_values.dart';
import 'package:eat_right/utils/network_manager/network_manager.dart'; // Keep network manager
// TODO: Import your image upload service repository
// import 'package:eat_right/data/repositories/storage/image_storage_repository.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

class MealAnalysisController extends GetxController {
  static MealAnalysisController get instance => Get.find();

  // Dependencies (Example - adjust if using DI)
  // final ImageStorageRepository _imageRepo = Get.put(ImageStorageRepository()); // TODO: Inject image repo

  // Reactive State
  final Rx<MealAnalysisModel?> mealAnalysisResult = Rx<MealAnalysisModel?>(
    null,
  );
  final RxBool isAnalyzing = false.obs;
  final RxString errorMessage = ''.obs;
  final nutrientParts = nutrientData
      .map(
        (nutrient) => TextPart(
          "${nutrient['Nutrient']}: ${nutrient['Current Daily Value']}",
        ),
      )
      .toList();

  // --- Public Methods ---

  /// Analyzes a food image using Gemini API.
  /// Returns true on success, false on failure.
  Future<bool> analyzeFoodImage({required File imageFile}) async {
    _startAnalysis();
    try {
      final apiKey = _getApiKey();
      if (apiKey == null) throw Exception("API Key not found.");

      final model = GenerativeModel(model: 'gemini-2.5-flash', apiKey: apiKey);
      final imageBytes = await imageFile.readAsBytes();
      final prompt = TextPart(
        AnalysisPrompts.analyseFoodImageV1,
      ); // Using V1 prompt

      if (!await NetworkManager.instance.isConnected()) {
        throw Exception("No internet connection");
      }

      final response = await model.generateContent([
        Content.multi([
          prompt,
          ...nutrientParts,
          DataPart('image/jpeg', imageBytes),
        ]),
        // Content.multi([prompt, ...nutrientParts, ...imageParts]),
      ]);

      if (response.text == null || response.text!.isEmpty) {
        throw Exception("Received empty response from analysis service.");
      }

      // Parse the JSON response
      final jsonResponse = _extractJson(response.text!);
      final parsedModel = MealAnalysisModel.fromJson(jsonResponse);
      print(parsedModel);
      if (parsedModel.status.toLowerCase() == 'failure') {
        throw Exception(
          parsedModel.errorMessage ?? "Analysis failed without specific error.",
        );
      }

      // --- TODO: Image Upload Logic ---
      // Upload the image *after* successful analysis parsing
      // String? imageUrl;
      // try {
      //   // Assume _imageRepo.uploadMealImage returns the download URL
      //   imageUrl = await _imageRepo.uploadMealImage(imageFile, /* optional userId? */);
      // } catch (uploadError) {
      //   print("Warning: Failed to upload meal image: $uploadError");
      //   // Decide if analysis should still proceed without image URL
      // }
      // --- End Image Upload ---

      // Set the result (potentially including the uploaded image URL)
      // final finalModel = parsedModel.copyWith(frontImageUrl: () => imageUrl);
      // mealAnalysisResult.value = finalModel;

      // TEMPORARY: Set result without image URL until upload is implemented
      mealAnalysisResult.value = parsedModel;

      _completeAnalysis();
      return true;
    } catch (e) {
      _handleError("Error analyzing food image: $e");
      return false;
    } finally {
      isAnalyzing.value = false; // Ensure this always runs
    }
  }

  // void _navigateToAskAi() {
  //   final analysisResult = mealAnalysisResult.value;
  //   final imageFile = ImageController.instance.frontImage.value;

  //   if (analysisResult != null && imageFile != null) {
  //     Get.to(
  //       () => AskAiPage(
  //         mealAnalysis: analysisResult, // Pass the whole model
  //         foodImage: imageFile,
  //         // Removed mealName as it's derived inside AskAiController now
  //       ),
  //     );
  //   } else {
  //     Get.snackbar(
  //       'Missing Info',
  //       'Please analyze a meal first.',
  //       snackPosition: SnackPosition.BOTTOM,
  //     );
  //   }
  // }

  /// Analyzes food items described in text using Gemini API.
  /// Returns true on success, false on failure.
  Future<bool> analyzeFoodViaText({required String foodItemsText}) async {
    _startAnalysis();
    try {
      final apiKey = _getApiKey();
      if (apiKey == null) throw Exception("API Key not found.");

      final model = GenerativeModel(model: 'gemini-1.5-flash', apiKey: apiKey);
      // TODO: Ensure this prompt requests JSON matching MealAnalysisModel V1 structure
      final prompt = TextPart(_getFoodTextAnalysisPrompt(foodItemsText));

      if (!await NetworkManager.instance.isConnected()) {
        throw Exception("No internet connection");
      }

      final response = await model.generateContent([
        Content.multi([prompt, ...nutrientParts]),
        // Content.multi([prompt, , ...imageParts]),
      ]);

      if (response.text == null || response.text!.isEmpty) {
        throw Exception("Received empty response from analysis service.");
      }

      // Parse the JSON response
      final jsonResponse = _extractJson(response.text!);
      // Assuming the text prompt returns the whole object, not nested under "meal_analysis"
      final parsedModel = MealAnalysisModel.fromJson(jsonResponse);

      if (parsedModel.status.toLowerCase() == 'failure') {
        throw Exception(
          parsedModel.errorMessage ?? "Analysis failed without specific error.",
        );
      }

      mealAnalysisResult.value = parsedModel; // No image URL for text analysis
      _completeAnalysis();
      return true;
    } catch (e) {
      _handleError("Error analyzing food via text: $e");
      return false;
    } finally {
      isAnalyzing.value = false;
    }
  }

  /// Clears the current analysis result and error message.
  void clearAnalysis() {
    mealAnalysisResult.value = null;
    errorMessage.value = '';
    isAnalyzing.value = false;
  }

  // --- Private Helpers ---

  void _startAnalysis() {
    isAnalyzing.value = true;
    errorMessage.value = '';
    mealAnalysisResult.value = null; // Clear previous result
  }

  void _completeAnalysis() {
    isAnalyzing.value = false;
    errorMessage.value = '';
  }

  void _handleError(String errorMsg) {
    print(errorMsg);
    errorMessage.value = errorMsg;
    isAnalyzing.value = false;
    mealAnalysisResult.value = null; // Clear potentially partial results
  }

  String? _getApiKey() {
    // Consider moving API key fetching to a dedicated service
    return dotenv.env['GEMINI_API_KEY'];
  }

  Map<String, dynamic> _extractJson(String text) {
    try {
      // Find the start and end of the outermost JSON object
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

  // Example: Generate the text prompt (Adapt based on your V1 text prompt needs)
  // TODO:
  String _getFoodTextAnalysisPrompt(String foodItemsText) {
    // IMPORTANT: This prompt MUST request a JSON structure matching MealAnalysisModel V1
    // Re-use or adapt the structure from AnalysisPrompts.analyseFoodImageV1 if suitable
    return """
You are a nutrition expert. Analyze these food items and their quantities:
$foodItemsText

Generate nutritional info for each item and respond ONLY with a valid JSON object matching this exact schema (mirroring the analyseFoodImageV1 schema):
{
    "status": "Success | Partial Success | Failure",
    "error_message": null, // Only include if status is not Success
    "analysis_confidence": 0.0-1.0,
    "food_image_quality": null, // Null for text analysis
    "meal_details": {
        "name_suggestion": "String",
        "meal_type": "Vegan | Vegetarian | Pescatarian | Non-Vegetarian | Unknown",
        "cuisine_style": "String | null",
        "estimated_total_weight": {"amount": Number, "unit": "g"} // Use 'amount' key
    },
    "items": [
      {
        "item_name": "String",
        "item_category": "Main Protein | ... | Other",
        "preparation_method": "Raw | ... | Unknown",
        "estimated_quantity": {
          "amount": Number,
          "unit": "String",
          "visual_estimation_method": null // Null for text
        },
        "nutrients_for_estimated_quantity": {
          "macro_nutrients": [ /* List<NutrientDetail> format */ ],
          "micro_nutrients": [ /* List<NutrientDetail> format */ ]
        },
        "nutrients_per_100g": {
          "macro_nutrients": [ /* List<NutrientDetail> format */ ],
          "micro_nutrients": [ /* List<NutrientDetail> format */ ]
        },
        "possible_allergens": ["String"] | null,
        "dietary_flags": ["String"] | null,
        "estimation_details": {
            "visual_cues": null, // Null for text
            "reasoning": "String | null",
            "confidence": 0.0-1.0
        }
      }
    ],
    "total_meal_nutrients": {
      "macro_nutrients": [ /* List<NutrientDetail> format */ ],
      "micro_nutrients": [ /* List<NutrientDetail> format */ ]
    },
    "health_assessment": { /* Same structure as V1 prompt */ }
}

Important Considerations:
- Base nutrients on standard databases (e.g., USDA).
- Accurately calculate nutrients for the specified quantities.
- Ensure the 'macro_nutrients' list in each section contains the 5 core nutrients (Calories, Protein, Total Fat, Total Carbohydrate, Dietary Fiber), using 0 value if not applicable/found.
- Output ONLY the JSON.
""";
  }
}
