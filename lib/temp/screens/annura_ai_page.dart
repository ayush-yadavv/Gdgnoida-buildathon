import 'package:eat_right/comman/widgets/appbar/appbar.dart';
import 'package:eat_right/temp/dv_values.dart';
import 'package:eat_right/temp/widgets/custom_llm_chatview.dart';
import 'package:eat_right/utils/constants/sizes.dart';
import 'package:firebase_ai/firebase_ai.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ai_toolkit/flutter_ai_toolkit.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

class AnnuraAiController extends GetxController {
  final Rx<LlmProvider?> provider = Rx<LlmProvider?>(null);

  final List<String> suggestions = [
    "What are the benefits of a plant-based diet?",
    "How can I improve my digestion?",
    "What are some healthy meal ideas?",
    "How can I lose weight?",
    "What are some healthy snack ideas?",
    "How can I improve my sleep?",
    "What are some healthy breakfast ideas?",
    "How can I improve my energy levels?",
    "What are some healthy lunch ideas?",
    "How can I improve my digestion?",
  ];
  final String welcomeMessage =
      "Welcome to EatRight AI! Ask me anything about your nutrition and healthy eating.";

  //rx
  final RxBool isInitializing = true.obs;

  @override
  void onInit() {
    super.onInit();
    _initialize();
  }

  Future<void> _initialize() async {
    isInitializing.value = true;
    try {
      final systemInstruction = _buildSystemInstruction();
      provider.value = await _createProvider(systemInstruction);
    } catch (e) {
      provider.value = null; // Ensure provider is null on error
    } finally {
      isInitializing.value = false;
    }
  }

  Future<LlmProvider> _createProvider(systemInstruction) async {
    return FirebaseProvider(
      model: FirebaseAI.googleAI().generativeModel(
        model: 'gemini-2.5-flash',
        systemInstruction: Content.system(systemInstruction),
      ),
    );
  }

  String _buildSystemInstruction() {
    try {
      final dvContext = _formatDvValues();

      return '''You are EatRight AI, a nutrition assistant. Provide accurate, concise nutrition info.

**CORE RULES:**
1. Use evidence-based information
2. Consider user context and goals
3. Explain simply, avoid jargon

**DAILY VALUES:**
$dvContext

**RESPONSE STYLE:**
- Be clear and concise
- Use simple language
- Flag important points
- Provide context''';
    } catch (e) {
      // Return a default instruction if there's an error
      return '''You are EatRight AI, a nutrition assistant. Provide accurate, concise nutrition info.

**CORE RULES:**
1. Use evidence-based information
2. Consider user context and goals
3. Explain simply, avoid jargon

**RESPONSE STYLE:**
- Be clear and concise
- Use simple language
- Flag important points
- Provide context''';
    }
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

  void showInfoDialog() {
    Get.dialog(
      AlertDialog(
        title: const Text('Information'),
        content: const Text(
          'This is a nutrition assistant. Provide accurate, concise nutrition info.',
        ),
        actions: [
          TextButton(child: const Text('OK'), onPressed: () => Get.back()),
        ],
      ),
    );
  }
}

class AnnuraAiPage extends StatelessWidget {
  const AnnuraAiPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AnnuraAiController());

    return Scaffold(
      appBar: SAppBar(
        title: const Text("EatRight AI"),
        actions: [
          IconButton(
            icon: const Icon(Iconsax.info_circle_copy),
            onPressed: controller.showInfoDialog,
          ),
          SizedBox(width: Sizes.defaultSpace / 2),
        ],
      ),
      body: Obx(() {
        if (controller.isInitializing.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.provider.value == null) {
          return const Center(child: Text('Failed to initialize AI provider'));
        }

        return Expanded(
          child: CustomLlmChatView(
            provider: controller.provider.value!,
            suggestions: controller.suggestions,
            welcomeMessage: controller.welcomeMessage,
          ),
        );
      }),
    );
  }
}
