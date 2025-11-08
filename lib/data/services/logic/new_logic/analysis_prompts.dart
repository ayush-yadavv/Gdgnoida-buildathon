class AnalysisPrompts {
  //   static String analyseFoodImage = """
  // You are a nutrition expert. Analyze the food image. Break down the meal into items & estimate nutrition. Respond strictly with this JSON (descriptions in comments):
  // {    // meal analysis
  //     "status": "Success | Partial Success | Failure",
  //     "error_message": "String | null", // Reason for non-success, null if Success
  //     "analysis_confidence": 0.0-1.0,
  //     "meal_details": {
  //         "name_suggestion": "String" ,// Suggested meal name (e.g., "Chicken Salad Lunch")
  //         "meal_type": "Vegan | Vegetarian | Pescatarian | Non-Vegetarian | Unknown",
  //         "cuisine_style": "String | null",
  //         "estimated_total_weight": {"value": Number, "unit": "g"}
  //     },
  //     "items": [ // Identified distinct food items
  //       {
  //         "item_name": "String", // Name of this specific item (e.g., "Grilled Chicken Breast")
  //           "item_category": "Main Protein | Grain/Starch | Vegetable | Fruit | Dairy | Sauce/Condiment | Beverage | Dessert | Mixed Dish | Other",
  //         "preparation_method": "Raw | Grilled | Baked | Fried | Steamed | Boiled | Unknown",
  //         "estimated_quantity": { // Estimated quantity of this item
  //           "amount": Number, // Numeric quantity value
  //           "unit": "String", // Quantity unit (e.g., "g", "ml")
  //           "visual_estimation_method": "String" | null
  //         },
  //         // **Nutrients for the ESTIMATED quantity, categorized:**
  //         "nutrients_for_estimated_quantity": {
  //           "macro_nutrients": { // **MANDATORY** object containing the 5 core macronutrients (Calories, Protein, Fat, Carbohydrates, Fiber).  May include additional macronutrients.
  //              "Calories": {"value": 0, "unit": "kcal"}, // Estimated energy for portion
  //              "Protein": {"value": 0, "unit": "g"},
  //              "Fat": {"value": 0, "unit": "g"},
  //              "Carbohydrates": {"value": 0, "unit": "g"},
  //              "Fiber": {"value": 0, "unit": "g"}
  //             // Example: "Sugar": {"value": 5, "unit": "g"}, ...
  //           },
  //           "micro_nutrients": { // Object containing OTHER estimated nutrients (vitamins, minerals, sodium, sugars etc.)
  //              // Example: "Sodium": {"value": 300, "unit": "mg"}, "Vitamin C": {"value": 15, "unit": "mg"}, ...
  //              // Include only nutrients the AI can reasonably estimate. Empty object if none.
  //           }
  //         },
  //          "nutrients_per_100g": {
  //          "macro_nutrients": {/* Same structure as above */},
  //           "micro_nutrients": {/* Same structure as above */}
  //         },
  //         "possible_allergens": ["String"] | null, // Inferred allergens (e.g., ["Dairy"])
  //         "dietary_flags": ["High Protein", "Low Fat", "Gluten Free", "High Fiber"] | null,
  //         "estimation_details": { // Analysis metadata for this item
  //             "visual_cues": ["String"] | null, // Cues used (if image)
  //             "reasoning": "String | null", // Estimation logic explanation
  //             "confidence": 0.0-1.0 // Confidence for THIS item
  //         }
  //       }
  //     ],
  //     "total_meal_nutrients": {
  //       "macro_nutrients": {/* Same structure as above */},
  //       "micro_nutrients": {/* Same structure as above */}
  //     },
  //     "health_assessment": {
  //       "nutrition_quality_score": Number,
  //       "primary_concerns": [
  //         {
  //             "issue": "Primary nutritional concern",
  //             "explanation": "Brief explanation of health impact",
  //           "recommendations": [
  //             {
  //               "food": "Complementary food suitable to add to this product, consider product name for determining suitability for complementary food additions",
  //               "quantity": "Recommended quantity to add",
  //               "reasoning": "How this addition helps balance the nutrition (e.g., slows sugar absorption, adds fiber, reduces glycemic index)"
  //             }
  //           ]
  //         }
  //       ],
  //       "dietary_considerations": [
  //         // Relevant dietary information
  //         {"diet_type": "String", "suitability": "Suitable | May Contain | Not Suitable", "reason": "String"}
  //       ]
  //     }
  // }
  // Rules & Considerations:
  // 1. Output ONLY the valid JSON object requested. No extra text or markdown.
  // 2. Provide nutrients both per 100g and for estimated total quantity
  // 3. Ensure all strings within the JSON are properly escaped.
  // 4. Use visual cues to estimate portions (size relative to plate, height of food, etc.)
  // 5. Base estimations on standard databases (e.g., USDA).
  // 6. Consider common serving sizes and preparation methods.
  // 7. The `macro_nutrients` objects/lists within nutrient sections MUST contain entries/keys for 'Calories', 'Protein', 'Fat', 'Carbohydrates', 'Fiber'. Use `0` for `value` if missing/zero.
  // 8. The `micro_nutrients` objects/lists should contain all other estimated/detected nutrients. They can be empty.
  // 9. Use consistent nutrient names (e.g., "Fat", "Carbohydrates").
  // 10. For health_assessment:
  //    - Complete this section only if confident in the nutritional analysis
  //    - Focus on major nutritional imbalances in primary_concerns
  //    - For recommendations, suggest practical food additions that complement the product with specific quantities
  //    - Explain how each addition helps balance nutrition (e.g., adds fiber, reduces glycemic index)
  //    - Consider product context and common food pairings

  // """;

  static String analyseFoodImageV1 = """
  You are a nutrition expert. Analyze the food image. Break down the meal into items & estimate nutrition. Respond strictly with this JSON:
  {
      "status": "Success | Partial Success | Failure",
      "error_message": null, // Only include reason if status is not Success
      "analysis_confidence": 0.0-1.0,
      "food_image_quality": "High | Medium | Low | Missing",
      "meal_details": {
          "name_suggestion": "String",
          "meal_type": "Vegan | Vegetarian | Pescatarian | Non-Vegetarian | Unknown",
          "cuisine_style": "String | null",
          "estimated_total_weight": {"value": Number, "unit": "g"}
      },
      "items": [
        {
          "item_name": "String",
          "item_category": "Main Protein | Grain/Starch | Vegetable | Fruit | Dairy | Sauce/Condiment | Beverage | Dessert | Mixed Dish | Other",
          "preparation_method": "Raw | Grilled | Baked | Fried | Steamed | Boiled | Unknown",
          "estimated_quantity": {
            "amount": Number,
            "unit": "String",
            "visual_estimation_method": "String | null"
          },
          "nutrients_for_estimated_quantity": {
            "macro_nutrients": [
        {"name": "Calories", "value": Number | 0, "unit": "kcal", "health_impact": "Good | Bad | Moderate"},
        {"name": "Total Fat", "value": Number | 0, "unit": "g", "health_impact": "Good | Bad | Moderate"},
        {"name": "Total Carbohydrate", "value": Number | 0, "unit": "g", "health_impact": "Good | Bad | Moderate"},
        {"name": "Dietary Fiber", "value": Number | 0, "unit": "g", "health_impact": "Good | Bad | Moderate"},
        {"name": "Protein", "value": Number | 0, "unit": "g", "health_impact": "Good | Bad | Moderate"}
      ],
            "micro_nutrients": {}
          },
          "nutrients_per_100g": {
            "macro_nutrients": {/* Same structure as above */},
            "micro_nutrients": {}
          },
          "possible_allergens": ["String"] | null,
          "dietary_flags": ["High Protein", "Low Fat", "Gluten Free", "High Fiber"] | null,
          "estimation_details": {
              "visual_cues": ["String"] | null,
              "reasoning": "String | null",
              "confidence": 0.0-1.0
          }
        }
      ],
      "total_meal_nutrients": {
        "macro_nutrients": {/* Same structure as above */},
        "micro_nutrients": {}
      },
      "health_assessment": {
        "nutrition_quality_score": Number,
        "primary_concerns": [
          {
              "issue": "String",
              "explanation": "String",
              "recommendations": [
                {
                  "food": "String",
                  "quantity": "String",
                  "reasoning": "String"
                }
              ]
          }
        ],
        "dietary_considerations": [
          {"diet_type": "String", "suitability": "Suitable | May Contain | Not Suitable", "reason": "String"}
        ]
      }
  }

  RULES:
  1. Output ONLY valid JSON. No extra text or markdown.
  2. For EVERY item, include nutrients per 100g AND for estimated quantity
  3. The macro_nutrients section MUST include: Calories, Protein, Total Fat, Totoal Carbohydrates, Dietary Fiber (use 0 for missing values)
  4. Micro_nutrients should contain other detected nutrients; can be empty
  5. Health impact determination:
   - "At least" nutrients (fiber, protein): High=Good, Moderate=Moderate, Low=Bad
   - "Less than" nutrients (sodium, saturated fat): Low=Good, Moderate=Moderate, High=Bad
  6. Use visual cues (size relative to plate, height) for portion estimation
  7. Base nutrient values on standard databases (USDA)
  8. For mixed dishes, break down into component parts when possible
  9. Health assessment should focus on imbalances and practical food additions with specific quantities
  10. For confidence levels: >0.8=high confidence, 0.5-0.8=medium, <0.5=low
  11. When uncertain about values, err on the side of caution rather than speculation
  """;

  //   static String analyseProductImages = """
  //       Analyze the product using front & label images. Respond strictly with this JSON (descriptions in comments):
  // {
  //     // product analysis
  //     "status": "Success | Partial Success | Failure",
  //     "error_message": "String | null", // Reason for non-success, null if Success
  //     "image_quality": { // clarity of imagges
  //       "front_image": "High | Medium | Low | Missing",
  //       "label_image": "High | Medium | Low | Missing"
  //     },
  //     "analysis_confidence": 0.0-1.0,

  //     "product_details": { // Product info (front image/label header)
  //       "fullname": "String",
  //       "brandname": "String | null",
  //       "variant": "String | null", // Flavor/type variant
  //       "category_guess": "String | null", // Guessed category (e.g., "Snack", "Beverage")
  //       "packaging_size":  {"value": Number, "unit": "g"} // Package size (e.g., {"value": 1, "unit": "L"})
  //     },
  //     "nutrition_label": {
  //       "serving_size": {
  //         "value": Number | null, // Numeric serving value
  //         "unit": "String | null", // Serving unit (e.g., "g", "cup")
  //         "text_description": "String | null" // Raw serving text (e.g., "1 cup (240g)")
  //       },
  //       "servings_per_container": Number | null, // Number of servings per container considering the packing size
  //       "macro_nutrients": [
  //         // Core macronutrients with consistent formatting
  //         // Include these 5 even if missing from label (use 0 value)
  //         {"name": "Calories", "value": Number | 0, "unit": "kcal", "health_impact": "Good | Bad | Moderate"},
  //         {"name": "Total Fat", "value": Number | 0, "unit": "g", "health_impact": "Good | Bad | Moderate"},
  //         {"name": "Total Carbohydrate", "value": Number | 0, "unit": "g", "health_impact": "Good | Bad | Moderate"},
  //         {"name": "Dietary Fiber", "value": Number | 0, "unit": "g", "health_impact": "Good | Bad | Moderate"},
  //         {"name": "Protein", "value": Number | 0, "unit": "g", "health_impact": "Good | Bad | Moderate"}
  //         // Include ONLY macro nutrients explicitly listed on the label besides the 5 macros
  //       ],

  //       "micro_nutrients": [
  //         // All other nutrients found on label (vitamins, minerals, sodium, etc.)
  //         // Example format: {"name": "Sodium", "value": 150, "unit": "mg", "health_impact": "Good | Bad | Moderate"}
  //         // Include ONLY micro nutrients explicitly listed on the label besides the macros
  //       ],

  //       "possible_allergens": ["String"] | null, // Inferred allergens (e.g., ["Dairy"])
  //       "dietary_flags": ["High Protein", "Low Fat", "Gluten Free", "High Fiber"] | null,

  //       "ingredients_list": ["String"] | null, // Full ingredients list text
  //       "country_of_origin": "String | null", // Origin country if listed
  //       "label_format": "US | EU | UK | Canada | Australia | Other | Unknown" // Identified label format
  //     },

  //     "health_assessment": {
  //       "nutrition_quality_score": Number,
  //       "primary_concerns": [
  //         {
  //             "issue": "Primary nutritional concern",
  //             "explanation": "Brief explanation of health impact",
  //           "recommendations": [
  //             {
  //               "food": "Complementary food suitable to add to this product, consider product name for determining suitability for complementary food additions",
  //               "quantity": "Recommended quantity to add",
  //               "reasoning": "How this addition helps balance the nutrition (e.g., slows sugar absorption, adds fiber, reduces glycemic index)"
  //             }
  //           ]
  //         }
  //       ],
  //       "dietary_considerations": [
  //         // Relevant dietary information
  //         {"diet_type": "String", "suitability": "Suitable | May Contain | Not Suitable", "reason": "String"}
  //       ]
  //     }
  //   }
  // Strictly follow these rules:
  // 1. Output ONLY the valid JSON object described, with no additional text, explanations, or markdown formatting.
  // 2. The macro_nutrients list MUST include all 5 core nutrients (Calories, Total Fat, Total Carbohydrate, Dietary Fiber, Protein). Use 0 for values not found on the label.
  // 3. Include in micro_nutrients only nutrients explicitly found on the label besides the core macros.
  // 4. Use appropriate units as shown on the label (g, mg, mcg, kcal, IU, etc.) and maintain numeric precision.
  // 5. Use null for information that cannot be confidently determined rather than guessing.
  // 6. Ensure proper JSON formatting with escaped special characters and no extra characters outside the object.
  // 7. For health_assessment:
  //    - Complete this section only if confident in the nutritional analysis
  //    - Focus on major nutritional imbalances in primary_concerns
  //    - For recommendations, suggest practical food additions that complement the product with specific quantities
  //    - Explain how each addition helps balance nutrition (e.g., adds fiber, reduces glycemic index)
  //    - Consider product context and common food pairings
  // 8. For health_impact determination:
  //    For "At least" nutrients (like fiber, protein):
  //    High status → Good health_impact
  //    Moderate status → Moderate health_impact
  //    Low status → Bad health_impact
  //    For "Less than" nutrients (like sodium, saturated fat):
  //    Low status → Good health_impact
  //    Moderate status → Moderate health_impact
  //    High status → Bad health_impact
  // 9. Adapt international label information appropriately while maintaining the structure.
  // """;
  static String analyseProductImagesV1 = """
Analyze the product using front & label images. Respond strictly with this JSON:
{
    "status": "Success | Partial Success | Failure",
    "error_message": null, // Only include if status is not Success
    "image_quality": {
      "front_image": "High | Medium | Low | Missing",
      "label_image": "High | Medium | Low | Missing"
    },
    "analysis_confidence": 0.0-1.0,
    "product_details": {
      "fullname": "String",
      "brandname": "String | null",
      "variant": "String | null",
      "category_guess": "String | null",
      "packaging_size": {"value": Number, "unit": "g"}
    },
    "nutrition_label": {
      "serving_size": {
        "value": Number | null,
        "unit": "String | null",
        "text_description": "String | null"
      },
      "servings_per_container": Number | null,
      "macro_nutrients": [
        {"name": "Calories", "value": Number | 0, "unit": "kcal", "health_impact": "Good | Bad | Moderate"},
        {"name": "Total Fat", "value": Number | 0, "unit": "g", "health_impact": "Good | Bad | Moderate"},
        {"name": "Total Carbohydrate", "value": Number | 0, "unit": "g", "health_impact": "Good | Bad | Moderate"},
        {"name": "Dietary Fiber", "value": Number | 0, "unit": "g", "health_impact": "Good | Bad | Moderate"},
        {"name": "Protein", "value": Number | 0, "unit": "g", "health_impact": "Good | Bad | Moderate"}
      ],
      "micro_nutrients": [
        // Only include nutrients explicitly found on label
      ],
      "possible_allergens": ["String"] | null,
      "dietary_flags": ["High Protein", "Low Fat", "Gluten Free", "High Fiber"] | null,
      "ingredients_list": ["String"] | null,
      "country_of_origin": "String | null",
      "label_format": "US | EU | UK | Canada | Australia | Other | Unknown"
    },
    "health_assessment": {
      "nutrition_quality_score": Number,
      "primary_concerns": [
        {
          "issue": "String",
          "explanation": "String",
          "recommendations": [
            {
              "food": "String",
              "quantity": "String",
              "reasoning": "String"
            }
          ]
        }
      ],
      "dietary_considerations": [
        {"diet_type": "String", "suitability": "Suitable | May Contain | Not Suitable", "reason": "String"}
      ]
    }
}

RULES:
1. Output ONLY valid JSON without additional text.
2. Macro_nutrients MUST include all 5 core nutrients regardless of label presence (use 0 for missing)
3. Include in micro_nutrients only nutrients explicitly found on label
4. Health impact determination:
   - "At least" nutrients (fiber, protein): High=Good, Moderate=Moderate, Low=Bad
   - "Less than" nutrients (sodium, saturated fat): Low=Good, Moderate=Moderate, High=Bad
5. For international labels:
   - EU: Convert kJ to kcal (divide by 4.184)
   - Use standardized nutrient names across regions
   - Maintain consistent units (g, mg, mcg)
6. For poor quality images:
   - Note confidence level accordingly
   - Prioritize accuracy over completeness
7. For complementary food recommendations:
   - Consider product type and common pairings
   - Specify quantities (e.g., "30g of almonds" not just "almonds")
   - Explain nutritional balance improvement specifically
""";
}
