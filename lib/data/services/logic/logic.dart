import 'package:eat_right/data/repositories/Food_repository/food_history_controller.dart';
import 'package:get/get.dart';

class LogicController extends GetxController {
  static LogicController get instance => Get.find();

  // temp putting controllers
  // final NutrientController nutrientController = Get.put(NutrientController());

  final FoodHistoryController foodHistoryController = Get.put(
    FoodHistoryController(),
  );

  // final DailyIntakeController dailyIntakeController = Get.put(
  //   DailyIntakeController(),
  // );

  // final ImageController imageController = Get.put(ImageController());
  // final AnalysisController analysisController = Get.put(AnalysisController());

  // final ImageController imageController = Get.put(ImageController());
  // final AnalysisController analysisController = Get.put(AnalysisController());
  // final FoodHistoryController foodHistoryController = Get.put(
  //   FoodHistoryController(),
  // );
  // final NutrientController nutrientController = Get.put(NutrientController());
  // final DailyIntakeController dailyIntakeController = Get.put(
  //   DailyIntakeController(),
  // );

  // Reactive variables
  // image
  // var frontImage = Rx<File?>(null);
  // var foodImage = Rx<File?>(null);
  // var nutritionLabelImage = Rx<File?>(null);

  // Nutrient
  // var parsedNutrients = <Map<String, dynamic>>[].obs;
  // var goodNutrients = <Map<String, dynamic>>[].obs;
  // var badNutrients = <Map<String, dynamic>>[].obs;
  // var totalPlateNutrients = <String, dynamic>{}.obs;
  // var servingSize = 0.0.obs;
  // var sliderValue = 0.0.obs;

  // analysis
  // var generatedText = ''.obs;
  // var productName = ''.obs;
  // var nutritionAnalysis = <String, dynamic>{}.obs;
  // var mealName = ''.obs;
  // var analyzedFoodItems = <FoodItem>[].obs;
  // var isAnalyzing = false.obs;

  // dailyintake
  // var dailyIntake = <String, double>{}.obs;

  // food history
  // var foodHistory = <FoodConsumption>[].obs;

  // logic controller
  // var isLoading = false.obs;

  //   void updateSliderValue(double value) {
  //     sliderValue.value = value;
  //     if (parsedNutrients.isNotEmpty) {
  //       final ratio = value / (servingSize.value == 0 ? 1 : servingSize.value);
  //       updateNutrientsForServing(ratio);
  //     }
  //   }

  //   void updateNutrientsForServing(double ratio) {
  //     for (var nutrient in parsedNutrients) {
  //       if (nutrient.containsKey('quantity')) {
  //         nutrient['quantity'] = (nutrient['quantity'] as num).toDouble() * ratio;
  //       }
  //     }
  //   }

  //   void updateTotalNutrients() {
  //     totalPlateNutrients.value = {
  //       'calories': 0.0,
  //       'protein': 0.0,
  //       'carbohydrates': 0.0,
  //       'fat': 0.0,
  //       'fiber': 0.0,
  //     };
  //     for (var item in analyzedFoodItems) {
  //       var itemNutrients = item.calculateTotalNutrients();
  //       totalPlateNutrients.updateAll(
  //         (key, value) => (value + (itemNutrients[key] ?? 0.0)),
  //       );
  //     }
  //   }

  //   Future<void> addToDailyIntake(String source) async {
  //     dailyIntake.value = {};
  //     print("Adding to daily intake. Source: $source");
  //     print("Current daily intake before: $dailyIntake");

  //     Map<String, double> newNutrients = {};
  //     File? imageFile;

  //     if (source == 'label' && parsedNutrients.isNotEmpty) {
  //       for (var nutrient in parsedNutrients) {
  //         final name = nutrient['name'];
  //         final quantity =
  //             double.tryParse(
  //               nutrient['quantity'].replaceAll(RegExp(r'[^0-9\.]'), ''),
  //             ) ??
  //             0;
  //         double adjustedQuantity =
  //             quantity * (sliderValue.value / servingSize.value);
  //         newNutrients[name] = adjustedQuantity;
  //       }
  //       imageFile = frontImage.value;
  //     } else if (source == 'food' && totalPlateNutrients.isNotEmpty) {
  //       newNutrients = {
  //         'Energy': (totalPlateNutrients['calories'] ?? 0).toDouble(),
  //         'Protein': (totalPlateNutrients['protein'] ?? 0).toDouble(),
  //         'Carbohydrate': (totalPlateNutrients['carbohydrates'] ?? 0).toDouble(),
  //         'Fat': (totalPlateNutrients['fat'] ?? 0).toDouble(),
  //         'Fiber': (totalPlateNutrients['fiber'] ?? 0).toDouble(),
  //       };
  //       imageFile = foodImage.value;
  //     }

  //     // Save the image to the device storage
  //     String imagePath = '';
  //     if (imageFile != null) {
  //       final directory = await getApplicationDocumentsDirectory();
  //       final imageName = '${DateTime.now().millisecondsSinceEpoch}.png';
  //       final savedImage = await imageFile.copy('${directory.path}/$imageName');
  //       imagePath = savedImage.path;
  //     }

  //     // Update dailyIntake with new nutrients
  //     newNutrients.forEach((key, value) {
  //       dailyIntake[key] = (dailyIntake[key] ?? 0.0) + value;
  //     });

  //     await addToFoodHistory(
  //       foodName: source == 'label' ? productName.value : mealName.value,
  //       nutrients: newNutrients,
  //       source: source,
  //       imagePath: imagePath,
  //     );

  //     await saveDailyIntake();
  //     // dailyIntakeNotifier.value = Map.from(logic.dailyIntake);
  //     print("⚡Daily intake at end of addToDailyIntake(): $dailyIntake");
  //   }

  //   String getUnit(String nutrient) {
  //     switch (nutrient.toLowerCase()) {
  //       case 'calories':
  //         return ' kcal';
  //       case 'protein':
  //       case 'carbohydrates':
  //       case 'fat':
  //       case 'fiber':
  //         return ' g';
  //       default:
  //         return '';
  //     }
  //   }

  //   Future<void> captureImage({
  //     required ImageSource source,
  //     required bool isFrontImage,
  //   }) async {
  //     final imagePicker = ImagePicker();
  //     final image = await imagePicker.pickImage(source: source);
  //     if (image != null) {
  //       if (isFrontImage) {
  //         frontImage.value = File(image.path);
  //       } else {
  //         nutritionLabelImage.value = File(image.path);
  //       }
  //     }
  //   }

  //   bool canAnalyze() => frontImage.value != null;

  //   Future<String> analyzeImages() async {
  //     isLoading.value = true;

  //     final apiKey = getApiKey();

  //     if (apiKey == null) {
  //       throw Exception(
  //         "API key is not set. Please configure GEMINI_API_KEY in the environment variables.",
  //       );
  //     }
  //     final model = GenerativeModel(model: 'gemini-1.5-flash', apiKey: apiKey);

  //     final frontImageBytes = await frontImage.value!.readAsBytes();
  //     final labelImageBytes = await nutritionLabelImage.value!.readAsBytes();

  //     final imageParts = [
  //       DataPart('image/jpeg', frontImageBytes),
  //       DataPart('image/jpeg', labelImageBytes),
  //     ];

  //     final nutrientParts =
  //         nutrientData
  //             .map(
  //               (nutrient) => TextPart(
  //                 "${nutrient['Nutrient']}: ${nutrient['Current Daily Value']}",
  //               ),
  //             )
  //             .toList();
  //     final prompt = TextPart(
  //       """Analyze the food product, product name and its nutrition label. Provide response in this strict JSON format:
  // {
  //   "product": {
  //     "name": "Product name from front image",
  //     "category": "Food category (e.g., snack, beverage, etc.)"
  //   },
  //   "nutrition_analysis": {
  //     "serving_size": "Serving size with unit",
  //     "nutrients": [
  //       {
  //         "name": "Nutrient name",
  //         "quantity": "Quantity with unit",
  //         "daily_value": "Percentage of daily value",
  //         "status": "High/Moderate/Low based on DV%",
  //         "health_impact": "Good/Bad/Moderate"
  //       }
  //     ],
  //     "primary_concerns": [
  //       {
  //         "issue": "Primary nutritional concern",
  //         "explanation": "Brief explanation of health impact",
  //         "recommendations": [
  //           {
  //             "food": "Complementary food suitable to add to this product, consider product name for determining suitability for complementary food additions",
  //             "quantity": "Recommended quantity to add",
  //             "reasoning": "How this addition helps balance the nutrition (e.g., slows sugar absorption, adds fiber, reduces glycemic index)"
  //           }
  //         ]
  //       }
  //     ]
  //   }
  // }

  // Strictly follow these rules:
  // 1. Mention Quantity with units in the label
  // 2. Do not include any extra characters or formatting outside of the JSON object
  // 3. Use accurate escape sequences for any special characters
  // 4. Avoid including nutrients that aren't mentioned in the label
  // 5. For primary_concerns, focus on major nutritional imbalances
  // 6. For recommendations:
  //    - Suggest foods that can be added to or consumed with the product to improve its nutritional balance
  //    - Focus on practical additions that complement the main product
  //    - Explain how each addition helps balance the nutrition (e.g., adding fiber to slow sugar absorption)
  //    - Consider cultural context and common food pairings
  //    - Provide specific quantities for the recommended additions
  // 7. Use %DV to determine if a serving is high or low in an individual nutrient:
  //    5% DV or less is considered low
  //    20% DV or more is considered high
  //    5% < DV < 20% is considered moderate
  // 8. For health_impact determination:
  //    For "At least" nutrients (like fiber, protein):
  //      High status → Good health_impact
  //      Moderate status → Moderate health_impact
  //      Low status → Bad health_impact
  //    For "Less than" nutrients (like sodium, saturated fat):
  //      Low status → Good health_impact
  //      Moderate status → Moderate health_impact
  //      High status → Bad health_impact
  // """,
  //     );

  //     final response = await model.generateContent([
  //       Content.multi([prompt, ...nutrientParts, ...imageParts]),
  //     ]);

  //     generatedText.value = response.text!;
  //     print("This is response content: $generatedText");
  //     try {
  //       final jsonString = generatedText.substring(
  //         generatedText.indexOf('{'),
  //         generatedText.lastIndexOf('}') + 1,
  //       );
  //       final jsonResponse = jsonDecode(jsonString);

  //       productName = jsonResponse['product']['name'];
  //       nutritionAnalysis = jsonResponse['nutrition_analysis'];

  //       if (nutritionAnalysis.containsKey("serving_size")) {
  //         servingSize.value =
  //             double.tryParse(
  //               nutritionAnalysis["serving_size"].replaceAll(
  //                 RegExp(r'[^0-9\.]'),
  //                 '',
  //               ),
  //             ) ??
  //             0.0;
  //       }

  //       parsedNutrients.value =
  //           (nutritionAnalysis['nutrients'] as List).cast<Map<String, dynamic>>();

  //       parsedNutrients.value =
  //           (nutritionAnalysis['nutrients'] as List)
  //               .cast<Map<String, dynamic>>()
  //               .map((nutrient) {
  //                 // Handle null values by providing default values
  //                 return {
  //                   'name': nutrient['name'] ?? 'Unknown',
  //                   'quantity': nutrient['quantity'] ?? '0',
  //                   'daily_value': nutrient['daily_value'] ?? '0%',
  //                   'status': nutrient['status'] ?? 'Moderate',
  //                   'health_impact': nutrient['health_impact'] ?? 'Moderate',
  //                 };
  //               })
  //               .toList();

  //       // Clear and update good/bad nutrients
  //       goodNutrients.clear();
  //       badNutrients.clear();
  //       for (var nutrient in parsedNutrients) {
  //         if (nutrient["health_impact"] == "Good" ||
  //             nutrient["health_impact"] == "Moderate") {
  //           goodNutrients.add(nutrient);
  //         } else {
  //           badNutrients.add(nutrient);
  //         }
  //       }
  //     } catch (e) {
  //       print("Error parsing JSON: $e");
  //     }

  //     isLoading.value = false;

  //     return generatedText.value;
  //   }

  //   void updateServingSize(double newSize) {
  //     servingSize.value = newSize;
  //   }

  //   double getCalories() {
  //     var energyNutrient = parsedNutrients.firstWhere(
  //       (nutrient) => nutrient['name'] == 'Energy',
  //       orElse: () => {'quantity': '0.0'},
  //     );
  //     // Parse the quantity string to remove any non-numeric characters except decimal points
  //     var quantity = energyNutrient['quantity'].toString().replaceAll(
  //       RegExp(r'[^0-9\.]'),
  //       '',
  //     );
  //     return double.tryParse(quantity) ?? 0.0;
  //   }

  //   Future<String> analyzeFoodImage({required File imageFile}) async {
  //     isLoading.value = true;
  //     final apiKey = getApiKey();
  //     final model = GenerativeModel(model: 'gemini-1.5-flash', apiKey: apiKey!);
  //     final imageBytes = await imageFile.readAsBytes();

  //     final prompt = TextPart(
  //       """Analyze this food image and break down each visible food item.
  // Provide response in this strict JSON format:
  // {
  //   "plate_analysis": {
  //   "meal_name": "Name of the meal",
  //     "items": [
  //       {
  //         "food_name": "Name of the food item",
  //         "estimated_quantity": {
  //           "amount": 0,
  //           "unit": "g",
  //         },
  //         "nutrients_per_100g": {
  //           "calories": 0,
  //           "protein": {"value": 0, "unit": "g"},
  //           "carbohydrates": {"value": 0, "unit": "g"},
  //           "fat": {"value": 0, "unit": "g"},
  //           "fiber": {"value": 0, "unit": "g"}
  //         },
  //         "total_nutrients": {
  //           "calories": 0,
  //           "protein": {"value": 0, "unit": "g"},
  //           "carbohydrates": {"value": 0, "unit": "g"},
  //           "fat": {"value": 0, "unit": "g"},
  //           "fiber": {"value": 0, "unit": "g"}
  //         },
  //         "visual_cues": ["List of visual indicators used for estimation"],
  //         "position": "Description of item location in the image"
  //       }
  //     ],
  //     "total_plate_nutrients": {
  //       "calories": 0,
  //       "protein": {"value": 0, "unit": "g"},
  //       "carbohydrates": {"value": 0, "unit": "g"},
  //       "fat": {"value": 0, "unit": "g"},
  //       "fiber": {"value": 0, "unit": "g"}
  //     }
  //   }
  // }

  // Consider:
  // 1. Use visual cues to estimate portions (size relative to plate, height of food, etc.)
  // 2. Provide nutrients both per 100g and for estimated total quantity
  // 3. Consider common serving sizes and preparation methods
  // """,
  //     );
  //     try {
  //       final isConnected = await NetworkManager.instance.isConnected();
  //       if (!isConnected) {
  //         // SFullScreenLoader.stopLoading();
  //         return "No internet connection";
  //       }
  //       final response = await model.generateContent([
  //         Content.multi([prompt, DataPart('image/jpeg', imageBytes)]),
  //       ]);

  //       if (response.text != null) {
  //         try {
  //           final jsonString = response.text!.substring(
  //             response.text!.indexOf('{'),
  //             response.text!.lastIndexOf('}') + 1,
  //           );
  //           final jsonResponse = jsonDecode(jsonString);
  //           final plateAnalysis = jsonResponse['plate_analysis'];
  //           mealName.value = plateAnalysis['meal_name'] ?? 'Unknown Meal';

  //           analyzedFoodItems.clear();
  //           if (plateAnalysis['items'] != null) {
  //             for (var item in plateAnalysis['items']) {
  //               analyzedFoodItems.add(
  //                 FoodItem(
  //                   name: item['food_name'],
  //                   quantity: item['estimated_quantity']['amount'].toDouble(),
  //                   unit: item['estimated_quantity']['unit'],
  //                   nutrientsPer100g: {
  //                     'calories': item['nutrients_per_100g']['calories'],
  //                     'protein': item['nutrients_per_100g']['protein']['value'],
  //                     'carbohydrates':
  //                         item['nutrients_per_100g']['carbohydrates']['value'],
  //                     'fat': item['nutrients_per_100g']['fat']['value'],
  //                     'fiber': item['nutrients_per_100g']['fiber']['value'],
  //                   },
  //                 ),
  //               );
  //             }
  //           }

  //           totalPlateNutrients.value = {
  //             'calories': plateAnalysis['total_plate_nutrients']['calories'],
  //             'protein':
  //                 plateAnalysis['total_plate_nutrients']['protein']['value'],
  //             'carbohydrates':
  //                 plateAnalysis['total_plate_nutrients']['carbohydrates']['value'],
  //             'fat': plateAnalysis['total_plate_nutrients']['fat']['value'],
  //             'fiber': plateAnalysis['total_plate_nutrients']['fiber']['value'],
  //           };

  //           isLoading.value = false;
  //           return response.text!;
  //         } catch (e) {
  //           print("Error parsing JSON response: $e");
  //           isLoading.value = false;
  //           return "Error parsing response";
  //         }
  //       }

  //       isLoading.value = false;
  //       return "No response received";
  //     } catch (e) {
  //       print("Error analyzing food image: $e");
  //       isLoading.value = false;
  //       return "Error analyzing image";
  //     }
  //   }

  //   String? getApiKey() {
  //     final key = dotenv.env['GEMINI_API_KEY'];
  //     print("api key fetched $key");
  //     return key;
  //   }

  //   Future<void> saveDailyIntake() async {
  //     try {
  //       final prefs = await SharedPreferences.getInstance();
  //       final today = DateTime.now();
  //       final storageKey = getStorageKey(today);
  //       final existingData = prefs.getString(storageKey);
  //       Map<String, double> updatedIntake = {};

  //       if (existingData != null) {
  //         final decoded = jsonDecode(existingData) as Map<String, dynamic>;
  //         decoded.forEach(
  //           (key, value) => updatedIntake[key] = (value as num).toDouble(),
  //         );
  //       }

  //       dailyIntake.forEach((key, value) {
  //         updatedIntake[key] = (updatedIntake[key] ?? 0.0) + value;
  //       });

  //       await prefs.setString(storageKey, jsonEncode(updatedIntake));
  //       dailyIntake.value = updatedIntake;
  //     } catch (e) {
  //       print("Error saving daily intake: $e");
  //     }
  //   }

  //   String getStorageKey(DateTime date) {
  //     return 'dailyIntake_${date.year}-${date.month}-${date.day}';
  //   }

  //   Future<void> loadFoodHistory() async {
  //     print("✅Start of loadFoodHistory()");
  //     print("Loading food history from storage...");
  //     final prefs = await SharedPreferences.getInstance();
  //     final String? storedHistory = prefs.getString('food_history');

  //     if (storedHistory != null) {
  //       print("Found stored food history");
  //       try {
  //         final List<dynamic> decoded = jsonDecode(storedHistory);
  //         print("Decoded food history items: ${decoded.length}");

  //         // Update food history with new list
  //         foodHistory.value =
  //             decoded.map((item) => FoodConsumption.fromJson(item)).toList();

  //         print("Successfully loaded ${foodHistory.length} food items");
  //         for (var item in foodHistory) {
  //           print("Loaded item: ${item.foodName} on ${item.dateTime}");
  //         }
  //         print("✅End of loadFoodHistory()");
  //       } catch (e) {
  //         print("Error loading food history: $e");
  //         foodHistory.value = [];
  //       }
  //     } else {
  //       print("No stored food history found");
  //       foodHistory.value = [];
  //     }
  //   }

  //   Future<String> logMealViaText({required String foodItemsText}) async {
  //     try {
  //       isAnalyzing.value = true;

  //       print("Processing logging food items via text: \n$foodItemsText");
  //       final apiKey = getApiKey();
  //       print("Apikey is: ");
  //       final model = GenerativeModel(model: 'gemini-1.5-flash', apiKey: apiKey!);

  //       final prompt = TextPart(
  //         """You are a nutrition expert. Analyze these food items and their quantities:\n$foodItemsText\n. Generate nutritional info for each of the mentioned food items and their respective quantities and respond using this JSON schema:
  // {
  //   "meal_analysis": {
  //   "meal_name": "Name of the meal",
  //     "items": [
  //       {
  //         "food_name": "Name of the food item",
  //         "mentioned_quantity": {
  //           "amount": 0,
  //           "unit": "g",
  //         },
  //         "nutrients_per_100g": {
  //           "calories": 0,
  //           "protein": {"value": 0, "unit": "g"},
  //           "carbohydrates": {"value": 0, "unit": "g"},
  //           "fat": {"value": 0, "unit": "g"},
  //           "fiber": {"value": 0, "unit": "g"}
  //         },
  //         "nutrients_in_mentioned_quantity": {
  //           "calories": 0,
  //           "protein": {"value": 0, "unit": "g"},
  //           "carbohydrates": {"value": 0, "unit": "g"},
  //           "fat": {"value": 0, "unit": "g"},
  //           "fiber": {"value": 0, "unit": "g"}
  //         },
  //       }
  //     ],
  //     "total_nutrients": {
  //       "calories": 0,
  //       "protein": {"value": 0, "unit": "g"},
  //       "carbohydrates": {"value": 0, "unit": "g"},
  //       "fat": {"value": 0, "unit": "g"},
  //       "fiber": {"value": 0, "unit": "g"}
  //     }
  //   }
  // }

  // Important considerations:
  // 1. Use standard USDA database values when available
  // 2. Account for common preparation methods
  // 3. Convert all measurements to standard units
  // 4. Consider regional variations in portion sizes
  // 5. Round values to one decimal place
  // 6. Account for density and volume-to-weight conversions

  // Provide accurate nutritional data based on the most reliable food databases and scientific sources.
  // """,
  //       );
  //       final response = await model.generateContent([
  //         Content.multi([prompt]),
  //       ]);
  //       if (response.text == null) {
  //         throw Exception("Empty response from model");
  //       }
  //       print("\n\nGot response from model! ${response.text}\n\n");

  //       try {
  //         // Extract JSON from response
  //         final jsonString = response.text!.substring(
  //           response.text!.indexOf('{'),
  //           response.text!.lastIndexOf('}') + 1,
  //         );
  //         final jsonResponse = jsonDecode(jsonString);
  //         final plateAnalysis = jsonResponse['meal_analysis'];
  //         mealName.value = plateAnalysis['meal_name'] ?? 'Unknown Meal';
  //         // Clear previous analysis
  //         analyzedFoodItems.clear();

  //         // Process each food item
  //         if (plateAnalysis['items'] != null) {
  //           for (var item in plateAnalysis['items']) {
  //             analyzedFoodItems.add(
  //               FoodItem(
  //                 name: item['food_name'],
  //                 quantity: item['mentioned_quantity']['amount'].toDouble(),
  //                 unit: item['mentioned_quantity']['unit'],
  //                 nutrientsPer100g: {
  //                   'calories': item['nutrients_per_100g']['calories'],
  //                   'protein': item['nutrients_per_100g']['protein']['value'],
  //                   'carbohydrates':
  //                       item['nutrients_per_100g']['carbohydrates']['value'],
  //                   'fat': item['nutrients_per_100g']['fat']['value'],
  //                   'fiber': item['nutrients_per_100g']['fiber']['value'],
  //                 },
  //               ),
  //             );
  //           }
  //         }

  //         // Store total nutrients
  //         totalPlateNutrients.value = {
  //           'calories': plateAnalysis['total_nutrients']['calories'],
  //           'protein': plateAnalysis['total_nutrients']['protein']['value'],
  //           'carbohydrates':
  //               plateAnalysis['total_nutrients']['carbohydrates']['value'],
  //           'fat': plateAnalysis['total_nutrients']['fat']['value'],
  //           'fiber': plateAnalysis['total_nutrients']['fiber']['value'],
  //         };

  //         // Print statements to check values
  //         print("Total Plate Nutrients:");
  //         print("Calories: ${totalPlateNutrients['calories']}");
  //         print("Protein: ${totalPlateNutrients['protein']}");
  //         print("Carbohydrates: ${totalPlateNutrients['carbohydrates']}");
  //         print("Fat: ${totalPlateNutrients['fat']}");
  //         print("Fiber: ${totalPlateNutrients['fiber']}");
  //         isAnalyzing.value = false;
  //         print("\n\nsetting _isLoading to false\n\n");
  //         return response.text!;
  //       } catch (e) {
  //         print("Error analyzing food: $e");
  //         isAnalyzing.value = false;
  //         return "Error";
  //       }
  //     } catch (e) {
  //       print("Error: $e");
  //       return "Unexpected error";
  //     }
  //   }

  //   Color getColorForPercent(double percent) {
  //     if (percent > 1.0) return Colors.red; // Exceeded daily value
  //     if (percent > 0.8) return Colors.green; // High but not exceeded
  //     if (percent > 0.6) return Colors.yellow; // Moderate
  //     if (percent > 0.4) return Colors.yellow; // Low to moderate
  //     return Colors.green; // Low
  //   }

  //   Future<void> addToFoodHistory({
  //     required String foodName,
  //     required Map<String, double> nutrients,
  //     required String source,
  //     required String imagePath,
  //   }) async {
  //     print("✅Start of addToFoodHistory()");
  //     print("⚡Daily intake at start of addToFoodHistory(): $dailyIntake");
  //     print("Adding to food history: $foodName");
  //     print("With nutrients: $nutrients");
  //     print("Source: $source");
  //     print("Image path: $imagePath");

  //     // Load existing historSy first
  //     await loadFoodHistory();

  //     final consumption = FoodConsumption(
  //       foodName: foodName,
  //       dateTime: DateTime.now(),
  //       nutrients: nutrients,
  //       source: source,
  //       imagePath: imagePath,
  //     );

  //     // Add new item to existing history
  //     foodHistory.add(consumption);
  //     print("Updated food history length: ${foodHistory.length}");

  //     await _saveFoodHistory();
  //     print("✅End of addToFoodHistory()");
  //     print("⚡Daily intake at end of addToFoodHistory(): $dailyIntake");
  //   }

  //   Future<void> _saveFoodHistory() async {
  //     try {
  //       print("✅Start of _saveFoodHistory()");
  //       print("⚡Daily intake at start of _saveFoodHistory(): $dailyIntake");
  //       final prefs = await SharedPreferences.getInstance();
  //       final historyJson = foodHistory.map((item) => item.toJson()).toList();
  //       print("Saving food history with ${historyJson.length} items");

  //       await prefs.setString('food_history', jsonEncode(historyJson));

  //       // Verify the save
  //       final savedData = prefs.getString('food_history');
  //       final decodedSave =
  //           savedData != null ? jsonDecode(savedData) as List : [];
  //       print("Verification - Saved food history items: ${decodedSave.length}");
  //       print("⚡Daily intake at end of _saveFoodHIistory(): $dailyIntake");
  //       print("✅End of _saveFoodHistory()");
  //     } catch (e) {
  //       print("Error saving food history: $e");
  //     }
  //   }

  //   Future<void> debugCheckStorage() async {
  //     final prefs = await SharedPreferences.getInstance();
  //   }
}
