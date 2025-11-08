import 'package:eat_right/utils/constants/sizes.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

Widget DateSelector(
  BuildContext context,
  DateTime selectedDate,
  Function(DateTime) onDateSelected,
) {
  final List<DateTime> dates = List.generate(
    7,
    (index) => DateTime.now().subtract(Duration(days: 6 - index)),
  );
  return SizedBox(
    height: 70,
    // margin: const EdgeInsets.symmetric(vertical: 10),
    child: ListView.builder(
      // dragStartBehavior: DragStartBehavior.start,
      physics: const BouncingScrollPhysics(),
      scrollDirection: Axis.horizontal,
      itemCount: dates.length,
      itemBuilder: (context, index) {
        final date = dates[index];
        final isSelected = selectedDate.day == date.day;
        return Padding(
          padding: EdgeInsets.only(
            left: index == 0 ? Sizes.defaultSpace / 2 : 4,
            right: index == dates.length - 1 ? Sizes.defaultSpace / 2 : 4,
          ),
          child: InkWell(
            // borderRadius: BorderRadius.circular(16),
            onTap: () => onDateSelected(date),
            child: Card(
              color: isSelected
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).cardColor,

              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
                // side: BorderSide(width: 1, color: Colors.grey),
              ),
              elevation: 0.5,

              child: Container(
                width: 42,
                padding: const EdgeInsets.symmetric(vertical: 2),
                // decoration: BoxDecoration(
                //   color: isSelected
                //       ? Theme.of(context).colorScheme.primary
                //       : Theme.of(context).colorScheme.surfaceContainerLow,
                //   borderRadius: BorderRadius.circular(16),
                // boxShadow: [
                //   BoxShadow(
                //     color: Theme.of(context)
                //         .colorScheme
                //         .primary
                //         .withOpacity(0.1),
                //     blurRadius: 10,
                //     offset: const Offset(5, 5),
                //   ),
                // ],
                // ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      DateFormat('EEE').format(date).toUpperCase(),
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: isSelected
                            ? Theme.of(context).colorScheme.onPrimary
                            : Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 1),
                    // Divider()
                    const SizedBox(height: 1),
                    Text(
                      '${date.day}',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: isSelected
                            ? Theme.of(context).colorScheme.onPrimary
                            : Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    ),
  );
}
