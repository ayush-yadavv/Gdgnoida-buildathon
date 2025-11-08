import 'package:eat_right/features/chat/models/chat_model.dart';
import 'package:get/get.dart';

class ChatController extends GetxController {
  var messages = <Message>[].obs;

  void sendMessage(String senderId, String text) {
    final newMessage = Message(
      senderId: senderId,
      text: text,
      time: DateTime.now(),
    );
    messages.add(newMessage);
  }
}
