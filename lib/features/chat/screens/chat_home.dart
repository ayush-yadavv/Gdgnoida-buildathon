import 'package:eat_right/features/chat/controllers/chat_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class chatHomeScreen extends StatelessWidget {
  const chatHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final chatController = Get.put(ChatController());

    return Scaffold(
      appBar: AppBar(title: const Text('Chat')),
      body: Column(
        children: [
          Expanded(
            child: Obx(
              () => ListView.builder(
                itemCount: chatController.messages.length,
                itemBuilder: (context, index) {
                  final message = chatController.messages[index];
                  return ListTile(
                    title: Text(message.text),
                    subtitle: Text(message.senderId),
                    trailing: Text(message.time.toString()),
                  );
                },
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: const InputDecoration(
                      labelText: 'Enter Message',
                    ),
                    onSubmitted: (value) {
                      chatController.sendMessage("user_id", value);
                    },
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: () {
                    // You can implement sending logic here as well
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
