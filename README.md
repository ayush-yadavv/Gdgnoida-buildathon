# eat_right 🍎

**Intelligent Nutrition Analysis & Tracking**

`eat_right` is a mobile application built with Flutter, designed to help users understand and manage their nutrition through powerful AI-driven analysis and intuitive tracking features.

[![Flutter](https://img.shields.io/badge/Flutter-%2302569B.svg?style=for-the-badge&logo=Flutter&logoColor=white)](https://flutter.dev)
[![GetX](https://img.shields.io/badge/GetX-State_Management-blue?style=for-the-badge)](https://pub.dev/packages/get)
[![Firebase](https://img.shields.io/badge/Firebase-Firestore-orange?style=for-the-badge&logo=firebase&logoColor=white)](https://firebase.google.com/)
[![Gemini](https://img.shields.io/badge/Google-Gemini_AI-4285F4?style=for-the-badge&logo=google&logoColor=white)](https://ai.google.dev/)

## ✨ Key Features

- **🤖 AI Meal Analysis:**
  - Analyze meals by capturing an image or providing a text description.
  - Identifies individual food items and estimates quantities.
  - Provides detailed macro- and micronutrient breakdowns for items and the total meal.
- **🏷️ AI Product Label Analysis:**
  - Scan both the product front and the nutrition label using images.
  - Extracts product name, brand, serving size, ingredients, allergens.
  - Provides detailed nutritional information per serving, including health impact assessment based on Daily Values (DV).
- **📝 Consumption Logging:**
  - Easily log analyzed meals or products to your daily intake.
  - Specify consumed servings for accurate tracking of product consumption.
  - Records consumption time (`consumedAt`).
- **📊 Daily Intake Tracking:**
  - Aggregates logged food items into a daily summary.
  - Tracks total calories, protein, carbs, fat, fiber, and potentially other nutrients.
  - Provides a breakdown of calorie intake by meal type (Breakfast, Lunch, Dinner, Snacks).
  - Visualizes progress towards daily goals (based on DVs).
- **💬 Contextual AI Chat ("Ask AI"):**
  - Engage in a conversation with the AI assistant specifically about the meal or product you just analyzed.
  - The AI context includes the detailed analysis data and general DV guidelines for relevant answers.
- **👤 User Profiles:**
  - User authentication and profile management.
  - Stores user details, preferences, and potentially health goals (future enhancement).
- **📶 Offline-First Data:**
  - Utilizes local caching (`GetStorage`) for daily summaries and consumption details, ensuring app usability even without an internet connection.
  - Asynchronous background synchronization with Firebase Firestore for data persistence and multi-device access.

## 🛠️ Technology Stack

- **Framework:** Flutter
- **Language:** Dart
- **State Management:** GetX
- **AI:** Google Gemini API (Models: `gemini-1.5-flash`, `gemini-pro-vision`)
- **Cloud Database:** Firebase Firestore
- **Local Storage:** GetStorage
- **Image Handling:** `image_picker`
- **API Keys:** `flutter_dotenv`
- **UI Components:** `percent_indicator`, `flutter_ai_toolkit` (for `LlmChatView`), `chat_bubbles`

## 🏗️ Architecture Overview

The application follows a structured approach separating concerns:

- **UI Layer (`lib/features/.../screens`, `lib/temp/screens`, `lib/temp/widgets`):** Contains Flutter widgets for displaying information and capturing user input. Uses GetX `Obx` widgets for reactivity.
- **Controller Layer (`lib/features/.../controllers`, `lib/data/services/logic/new_logic/`):** Uses GetX Controllers (`GetxController`) to manage UI state and business logic. Key controllers include:
  - `ImageController`: Handles image selection/capture.
  - `MealAnalysisController`: Manages AI analysis for meals (image/text).
  - `ProductAnalysisController`: Manages AI analysis for products (images).
  - `FoodConsumptionController`: Orchestrates the logging process.
  - `DailyIntakeController`: Manages daily summary data, caching, and repository interaction.
  - `DetailedDayViewController`: Manages fetching and displaying detailed consumption for a specific day.
  - `AskAiController`: Manages the state and interaction for the contextual AI chat.
  - `UserController`: Manages user profile data.
  - `ScanLabelPageController`: Manages the state specific to the product scanning UI flow.
- **Repository Layer (`lib/data/repositories`, `lib/data/services/logic/new_repo/`):** Abstracts data sources (local and remote). Implements offline-first strategies. Key repositories include:
  - `AuthenticationRepository`: Handles user authentication.
  - `UserRepository`: Manages user profile data persistence.
  - `DailyIntakeRepository`: Handles persistence for daily summary data.
  - `FoodConsumptionRepository`: Handles persistence for individual food consumption logs.
  - _(Potential)_ `ImageStorageRepository`: (To be implemented) Handles image uploads.
- **Data Model Layer (`lib/data/services/logic/new_data_model/`):** Defines immutable data structures (`MealAnalysisModel`, `ProductAnalysisModel`, `FoodConsumptionModel`, `DailyIntakeModel`, etc.) for consistent data handling.
- **Utils:** Contains constants, helper functions, theme definitions, etc.

_(Note: The `lib/temp/` directory seems to contain work-in-progress or temporary UI components.)_

## 🚀 Getting Started

### Prerequisites

- Flutter SDK installed (check with `flutter doctor`)
- A configured Firebase project.
- An API Key for Google Gemini API.

### Setup

1.  **Clone the repository:**
    ```bash
    git clone <your-repository-url>
    cd eat_right
    ```
2.  **Install dependencies:**
    ```bash
    flutter pub get
    ```
3.  **Firebase Setup:**
    - Place your `google-services.json` (Android) and/or `GoogleService-Info.plist` (iOS) files in the appropriate directories (`android/app/` and `ios/Runner/`). Follow Firebase setup guides for Flutter.
4.  **Configure API Keys:**
    - Create a file named `.env` in the root directory of the project.
    - Add your Google Gemini API key to the `.env` file:
      ```env
      GEMINI_API_KEY=YOUR_GEMINI_API_KEY_HERE
      ```
    - **Important:** Ensure the `.env` file is added to your `.gitignore` file to prevent committing sensitive keys.

### Running the App

```bash
flutter run
```

## 📁 Folder Structure (Conceptual)
