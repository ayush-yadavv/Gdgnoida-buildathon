import 'package:eat_right/data/services/logic/new_logic/daily_intake_controller.dart';
import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:intl/intl.dart';

class HeaderCard extends StatelessWidget {
  final DateTime selectedDate;

  const HeaderCard({super.key, required this.selectedDate});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Daily Nutrition',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            Text(
              DateFormat('EEEE, MMMM d').format(selectedDate),
              style: Theme.of(context).textTheme.labelMedium,
            ),
          ],
        ),
        IconButton.filledTonal(
          icon: const Icon(Iconsax.calendar_search_copy),
          onPressed: () {
            showDatePicker(
              context: context,
              initialDate: selectedDate,
              firstDate: DateTime(2010),
              lastDate: DateTime.now(),
            ).then((DateTime? newDate) {
              if (newDate != null) {
                // TODO: reset the dailyIntake
                DailyIntakeController.instance.selectDate(newDate);
              }
            });
          },
        ),
      ],
    );
  }
}
