# eat_right 🍎

**Intelligent Nutrition Analysis & Tracking**

## 📋 Table of Contents

- [✨ Key Features](#-key-features)
- [🛠️ Technology Stack](#%EF%B8%8F-technology-stack)
- [🏗️ Architecture Overview](#%EF%B8%8F-architecture-overview)
- [🚀 Getting Started](#-getting-started)
- [📸 Screenshots](#-screenshots)
- [🤝 Contributing](#-contributing)
- [📄 License](#-license)
- [📬 Support](#-support)

---

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
- **AI:** Google Gemini API (Models: `gemini-2.5-flash`, `gemini-pro-vision`)
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

- Flutter SDK (latest stable version)
- Dart SDK (comes with Flutter)
- Android Studio / Xcode (for emulator/simulator)
- Physical device or emulator for testing
- Firebase project with Firestore database
- Google Gemini API key

### Installation

1. **Clone the repository:**

   ```bash
   # Clone the repository
   git clone https://github.com/yourusername/Gdgnoida-buildathon.git

   # Rename the directory to 'eat_right' for local development
   mv Gdgnoida-buildathon-main eat_right

   # Navigate to the project directory
   cd eat_right
   ```

2. **Install dependencies:**

   ```bash
   flutter pub get
   ```

3. **Firebase Setup:**

   - Create a new Firebase project at [Firebase Console](https://console.firebase.google.com/)
   - Add Android/iOS app to your Firebase project
   - Download the configuration files:
     - Android: `google-services.json` → `android/app/`
     - iOS: `GoogleService-Info.plist` → `ios/Runner/`
   - Enable Firestore Database in your Firebase project

4. **Configure Environment Variables:**
   - Create a `.env` file in the root directory
   - Add your Gemini API key:
     ```env
     GEMINI_API_KEY=your_gemini_api_key_here
     ```
   - Add `.env` to `.gitignore` if not already present

### Running the App

1. **Start the emulator or connect a device**
2. **Run the app:**
   ```bash
   flutter run
   ```
3. **For release build:**
   ```bash
   flutter build apk --release  # For Android
   ```

## 🎥 Demo Video

Here's a quick demo of eat_right in action:

<div style="margin: 20px 0; text-align: center;">
  <video width="80%" controls style="border-radius: 8px; box-shadow: 0 4px 8px rgba(0,0,0,0.1);">
    <source src="screenshots/WhatsApp Video 2025-11-08 at 23.34.32_341b3a18.mp4" type="video/mp4">
    Your browser does not support the video tag.
  </video>
</div>

## 📸 Screenshots

<div style="display: grid; grid-template-columns: repeat(4, 1fr); gap: 10px; margin: 20px 0;">
  <img src="screenshots/WhatsApp Image 2025-11-08 at 23.09.19_8fb323be.jpg" alt="Screenshot 1" style="width:100%; border-radius: 6px; box-shadow: 0 2px 4px rgba(0,0,0,0.1); max-width: 200px;">
  <img src="screenshots/WhatsApp Image 2025-11-08 at 23.09.20_6239aeb7.jpg" alt="Screenshot 2" style="width:100%; border-radius: 6px; box-shadow: 0 2px 4px rgba(0,0,0,0.1); max-width: 200px;">
  <img src="screenshots/WhatsApp Image 2025-11-08 at 23.09.20_889557e7.jpg" alt="Screenshot 3" style="width:100%; border-radius: 6px; box-shadow: 0 2px 4px rgba(0,0,0,0.1); max-width: 200px;">
  <img src="screenshots/WhatsApp Image 2025-11-08 at 23.09.20_bc954f93.jpg" alt="Screenshot 4" style="width:100%; border-radius: 6px; box-shadow: 0 2px 4px rgba(0,0,0,0.1); max-width: 200px;">
  <img src="screenshots/WhatsApp Image 2025-11-08 at 23.09.21_30bec8c3.jpg" alt="Screenshot 5" style="width:100%; border-radius: 6px; box-shadow: 0 2px 4px rgba(0,0,0,0.1); max-width: 200px;">
  <img src="screenshots/WhatsApp Image 2025-11-08 at 23.09.21_8d3056d6.jpg" alt="Screenshot 6" style="width:100%; border-radius: 6px; box-shadow: 0 2px 4px rgba(0,0,0,0.1); max-width: 200px;">
  <img src="screenshots/WhatsApp Image 2025-11-08 at 23.09.21_d7da7e86.jpg" alt="Screenshot 7" style="width:100%; border-radius: 6px; box-shadow: 0 2px 4px rgba(0,0,0,0.1); max-width: 200px;">
  <img src="screenshots/WhatsApp Image 2025-11-08 at 23.09.21_ee625210.jpg" alt="Screenshot 8" style="width:100%; border-radius: 6px; box-shadow: 0 2px 4px rgba(0,0,0,0.1); max-width: 200px;">
  <img src="screenshots/WhatsApp Image 2025-11-08 at 23.09.22_4d47dfc9.jpg" alt="Screenshot 9" style="width:100%; border-radius: 6px; box-shadow: 0 2px 4px rgba(0,0,0,0.1); max-width: 200px;">
  <img src="screenshots/WhatsApp Image 2025-11-08 at 23.09.22_9540bf90.jpg" alt="Screenshot 10" style="width:100%; border-radius: 6px; box-shadow: 0 2px 4px rgba(0,0,0,0.1); max-width: 200px;">
  <img src="screenshots/WhatsApp Image 2025-11-08 at 23.09.22_98e515de.jpg" alt="Screenshot 11" style="width:100%; border-radius: 6px; box-shadow: 0 2px 4px rgba(0,0,0,0.1); max-width: 200px;">
  <img src="screenshots/WhatsApp Image 2025-11-08 at 23.09.22_ae60ed3c.jpg" alt="Screenshot 12" style="width:100%; border-radius: 6px; box-shadow: 0 2px 4px rgba(0,0,0,0.1); max-width: 200px;">
  <img src="screenshots/WhatsApp Image 2025-11-08 at 23.09.23_651e77df.jpg" alt="Screenshot 13" style="width:100%; border-radius: 6px; box-shadow: 0 2px 4px rgba(0,0,0,0.1); max-width: 200px;">
  <img src="screenshots/WhatsApp Image 2025-11-08 at 23.09.23_7a9859d8.jpg" alt="Screenshot 14" style="width:100%; border-radius: 6px; box-shadow: 0 2px 4px rgba(0,0,0,0.1); max-width: 200px;">
  <img src="screenshots/WhatsApp Image 2025-11-08 at 23.09.23_abd18b5c.jpg" alt="Screenshot 15" style="width:100%; border-radius: 6px; box-shadow: 0 2px 4px rgba(0,0,0,0.1); max-width: 200px;">
  <img src="screenshots/WhatsApp Image 2025-11-08 at 23.09.24_3b011dc4.jpg" alt="Screenshot 16" style="width:100%; border-radius: 6px; box-shadow: 0 2px 4px rgba(0,0,0,0.1); max-width: 200px;">
</div>

## 🤝 Contributing

We welcome contributions to make eat_right even better! Here's how you can help:

1. **Fork** the repository
2. Create a **branch** for your feature (`git checkout -b feature/amazing-feature`)
3. **Commit** your changes (`git commit -m 'Add some amazing feature'`)
4. **Push** to the branch (`git push origin feature/amazing-feature`)
5. Open a **Pull Request**

### Code Style

- Follow the [Dart style guide](https://dart.dev/guides/language/effective-dart/style)
- Use meaningful commit messages
- Keep your code clean and well-documented

## 📬 Support

For support, questions, or feature requests, please:

- Open an [issue](https://github.com/ayush-yadavv/Gdgnoida-buildathon/issues)
- Email us at yadav.ayushx1@gmail.com
