import 'package:intl/intl.dart';

class SFormatter {
  static String formatDate(DateTime? date) {
    date ??= DateTime.now();
    return DateFormat('dd/MM/yyyy').format(date);
  }

  static String formatTime(DateTime? date) {
    date ??= DateTime.now();
    return DateFormat('HH:mm').format(date);
  }

  static String formatLikes(int likes) {
    if (likes < 1000) {
      return likes.toString();
    } else if (likes < 1000000) {
      String formatted = (likes / 1000).toStringAsFixed(1).substring(0, 3);
      return '${formatted.endsWith('.') ? formatted.substring(0, 2) : formatted}K';
    } else if (likes < 1000000000) {
      String formatted = (likes / 1000000).toStringAsFixed(1).substring(0, 3);
      return '${formatted.endsWith('.') ? formatted.substring(0, 2) : formatted}M';
    } else {
      String formatted = (likes / 1000000000)
          .toStringAsFixed(1)
          .substring(0, 3);
      return '${formatted.endsWith('.') ? formatted.substring(0, 2) : formatted}T';
    }
  }

  static String formatPhoneNumber(String phoneNumber) {
    // Split the phone number into parts based on '-'
    List<String> parts = phoneNumber.split('-');

    // Extract the country code and the rest of the number
    String countryCode = parts[0];
    // try{}
    String restOfNumber = phoneNumber;
    // parts[1];

    // Format the rest of the number
    String formattedNumber = phoneNumber;
    // restOfNumber
    //     .replaceRange(3, 3, '-')
    //     .replaceRange(6, 6, '-');

    // Combine the country code and the formatted number
    return '+($countryCode) $formattedNumber';
  }

  // static String? formatDob(DateTime? dob) {
  //   // return dob.toIso8601String();
  //   return DateFormat('dd/MM/yyyy').format(dob!);
  // }

  // static String internationalFormatPhoneNumber(String phoneNumber) {
  //   if (phoneNumber.length == 10) {
  //     return '+1 ${phoneNumber}';
  //   } else {
  //     return phoneNumber;
  //   }
}
