import 'dart:convert';
import 'dart:io';

import 'package:eat_right/comman/widgets/appbar/appbar.dart';
import 'package:eat_right/data/services/logic/new_data_model/food_consumption_models/analysis_models/meal_analysis_model.dart';
import 'package:eat_right/data/services/logic/new_data_model/food_consumption_models/analysis_models/product_analysis_model.dart';
import 'package:eat_right/temp/dv_values.dart';
import 'package:eat_right/temp/widgets/custom_llm_chatview.dart';
import 'package:eat_right/utils/constants/colors.dart';
import 'package:eat_right/utils/constants/images_str.dart';
import 'package:eat_right/utils/constants/sizes.dart';
import 'package:firebase_ai/firebase_ai.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ai_toolkit/flutter_ai_toolkit.dart';
import 'package:get/get.dart';

class AskAiController extends GetxController {
  // final LogicController logic = Get.find();

  final File?
  foodImage; // Image is optional now, context comes from analysisData
  final dynamic
  analysisData; // Can be MealAnalysisModel or ProductAnalysisModel

  // late GeminiProvider provider;
  final Rx<LlmProvider?> provider = Rx<LlmProvider?>(
    null,
  ); // Make provider reactive

  String nutritionContext = '';
  RxString currentItemName = ''.obs;
  final RxBool isInitializing = true.obs;
  // final nutrientController = NutrientController.instance;

  AskAiController({this.foodImage, required this.analysisData});

  @override
  void onInit() {
    super.onInit();
    _initialize();
  }

  Future<void> _initialize() async {
    isInitializing.value = true;
    // chatError.value = '';
    try {
      currentItemName.value = _getCurrentItemName(); // Set initial name
      final systemInstruction = _buildSystemInstruction();
      if (systemInstruction == null) {
        throw Exception("Could not generate AI context from analysis data.");
      }
      provider.value = await _createProvider(systemInstruction);
    } catch (e) {
      // chatError.value = "Error initializing AskAI: $e";
      // print(chatError.value);
      provider.value = null; // Ensure provider is null on error
    } finally {
      isInitializing.value = false;
    }
  }

  String _getCurrentItemName() {
    if (analysisData is MealAnalysisModel) {
      return (analysisData as MealAnalysisModel).mealDetails.nameSuggestion ??
          'Analyzed Meal';
    } else if (analysisData is ProductAnalysisModel) {
      return (analysisData as ProductAnalysisModel).productDetails.fullname;
    }
    return 'Item'; // Default fallback
  }

  String? _buildSystemInstruction() {
    final dvContext = _formatDvValues();
    String? analysisContext;

    if (analysisData is MealAnalysisModel) {
      analysisContext = _formatMealAnalysis(analysisData as MealAnalysisModel);
    } else if (analysisData is ProductAnalysisModel) {
      analysisContext = _formatProductAnalysis(
        analysisData as ProductAnalysisModel,
      );
    } else {
      return null; // Invalid data type
    }

    return """
You are a helpful, friendly, and slightly enthusiastic nutrition assistant chatbot named EatRight AI. 🤖✨
Your goal is to answer user questions about the specific food item (meal or product) they just analyzed.

**IMPORTANT:** ALWAYS base your answers *primarily* on the provided analysis data below. Avoid making assumptions or providing generic nutritional advice unless specifically asked to compare or broaden the scope. Be conversational and use relevant emojis.

**Daily Value (DV) Reference Context:**
These are general daily recommended values. Use them for context when interpreting the food's nutrient levels if relevant to the user's question (e.g., "is this high in sodium?").
$dvContext

**Analyzed Food Item Context:**
$analysisContext

Now, please answer the user's questions about this specific food item! 👇
""";
  }

  String _formatDvValues() {
    // Format the nutrientData list into a readable string
    return nutrientData
        .map(
          (n) =>
              "- ${n['Nutrient']}: ${n['Current Daily Value']} (${n['Goal']})",
        )
        .join('\n');
  }

  String _formatMealAnalysis(MealAnalysisModel meal) {
    // Convert the relevant parts of the model to a string format suitable for the prompt
    // Using JSON encoding for structure, but could be a custom format.
    try {
      final dataToInclude = {
        'Status': meal.status,
        'Confidence': meal.analysisConfidence?.toStringAsFixed(2) ?? 'N/A',
        'Meal Details': meal.mealDetails.toJson(), // Convert sub-model
        'Identified Items': meal.items
            .map(
              (item) => {
                // Map items
                'Name': item.itemName,
                'Category': item.itemCategory ?? 'N/A',
                'Quantity': item.estimatedQuantity.toJson(),
                'Est. Nutrients': item.nutrientsForEstimatedQuantity.toJson(),
                // Optionally include per 100g if needed for context
              },
            )
            .toList(),
        'Total Meal Nutrients': meal.totalMealNutrients.toJson(),
        'Health Assessment': meal.healthAssessment
            ?.toJson(), // Include if not null
      };
      // Remove null values from health assessment for cleaner output
      if (dataToInclude['Health Assessment'] == null) {
        dataToInclude.remove('Health Assessment');
      }

      return jsonEncode(
        dataToInclude,
      ); // Encode the selected data as JSON string
    } catch (e) {
      print("Error formatting meal analysis for context: $e");
      return "Error formatting meal data.";
    }
  }

  String _formatProductAnalysis(ProductAnalysisModel product) {
    try {
      final dataToInclude = {
        'Status': product.status,
        'Confidence': product.analysisConfidence?.toStringAsFixed(2) ?? 'N/A',
        'Product Details': product.productDetails.toJson(),
        'Nutrition Label Info': {
          'Serving Size':
              product
                  .nutritionLabel
                  .servingSize
                  ?.textDescription ?? // Prefer text
              product.nutritionLabel.servingSize
                  ?.toJson() ?? // Fallback to JSON
              'N/A',
          'Servings Per Container':
              product.nutritionLabel.servingsPerContainer ?? 'N/A',
          'Nutrients (per serving)': [
            // Combine macros and micros for prompt context
            ...product.nutritionLabel.macroNutrients,
            ...product.nutritionLabel.microNutrients,
          ].map((n) => n.toJson()).toList(), // List of nutrient details
          'Allergens': product.nutritionLabel.possibleAllergens,
          'Ingredients': product.nutritionLabel.ingredientsList?.join(
            ', ',
          ), // Join list
        },
        'Health Assessment': product.healthAssessment?.toJson(),
      };
      // Clean up nulls
      if (dataToInclude['Health Assessment'] == null) {
        dataToInclude.remove('Health Assessment');
      }
      if ((dataToInclude['Nutrition Label Info'] as Map)['Allergens'] == null) {
        (dataToInclude['Nutrition Label Info'] as Map).remove('Allergens');
      }
      if ((dataToInclude['Nutrition Label Info'] as Map)['Ingredients'] ==
          null) {
        (dataToInclude['Nutrition Label Info'] as Map).remove('Ingredients');
      }

      return jsonEncode(dataToInclude);
    } catch (e) {
      print("Error formatting product analysis for context: $e");
      return "Error formatting product data.";
    }
  }

  Future<LlmProvider> _createProvider(String systemInstruction) async {
    return FirebaseProvider(
      model: FirebaseAI.googleAI().generativeModel(
        model: 'gemini-2.5-flash',
        systemInstruction: Content.system(systemInstruction),
      ),
    );
  }
}

class AskAiPage extends StatelessWidget {
  final dynamic analysisData; // MealAnalysisModel or ProductAnalysisModel
  final File? foodImage; // Make image optional

  // final LogicController logic;

  const AskAiPage({
    super.key,
    required this.analysisData,
    this.foodImage, // Now optional
  });

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(
      AskAiController(analysisData: analysisData, foodImage: foodImage),
      // Use a tag based on analysis data ID if possible to ensure uniqueness if needed
      // tag: (analysisData is MealAnalysisModel ? analysisData.id : (analysisData is ProductAnalysisModel ? analysisData.id : UniqueKey().toString())),
    );

    return SafeArea(
      top: false,
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        appBar: SAppBar(
          centerTitle: true,
          showBackArrow: true,
          title: Text(
            'EatRight AI',
            style: Theme.of(context).textTheme.titleMedium!.copyWith(
              fontWeight: FontWeight.w600,
              color: Theme.of(context).appBarTheme.foregroundColor,
            ),
          ),
        ),
        body: Column(
          children: [
            // Image Header Section
            Obx(
              () => Container(
                width: double.infinity,
                height: 200,
                margin: const EdgeInsets.symmetric(
                  horizontal: Sizes.defaultSpace,
                  vertical: Sizes.s,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(Sizes.cardRadiusLg),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image(
                        image: foodImage != null
                            ? FileImage(foodImage!)
                            : AssetImage(SImages.defaultFoodImage)
                                  as ImageProvider,
                        fit: BoxFit.cover,
                        alignment: Alignment.center,
                      ),
                      // Gradient overlay for better text readability
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                            colors: [
                              Colors.black.withOpacity(0.7),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                      Positioned(
                        left: Sizes.m,
                        right: Sizes.m,
                        bottom: Sizes.m,
                        child: Text(
                          controller.currentItemName.value,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.headlineMedium!
                              .copyWith(
                                color: SColors.white,
                                fontWeight: FontWeight.w500,
                                shadows: [
                                  Shadow(
                                    offset: const Offset(1.0, 1.0),
                                    blurRadius: 6.0,
                                    color: Colors.black.withOpacity(0.8),
                                  ),
                                ],
                              ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // Chat Section
            Expanded(
              child: Obx(() {
                if (controller.isInitializing.value) {
                  return const Center(child: CircularProgressIndicator());
                }
                return CustomLlmChatView(
                  provider: controller.provider.value!,
                  suggestions: [
                    'how many calories it has?',
                    'is it healthy?',
                    'is it sugary?',
                    'is it fattening?',
                    'is it good for me?',
                  ],
                  welcomeMessage:
                      "👋 Hello, what would you like to know about ${controller.currentItemName.value}? 🍽️",
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}
