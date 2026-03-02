import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:note_sphere/utils/colors.dart';
import 'package:note_sphere/utils/text_style.dart';

class MainScreenTodoCard extends StatelessWidget {
  final String title;
  final String date;
  final String time;
  final bool isDone;
  const MainScreenTodoCard({
    super.key,
    required this.title,
    required this.date,
    required this.time,
    required this.isDone,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.kCardColor,
        borderRadius: BorderRadius.circular(10),
      ),
      padding: const EdgeInsets.all(16.0), // Adjust padding as needed
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.appDescription.copyWith(
                    fontWeight: FontWeight.w400, // Adjust font size as needed
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${DateFormat.yMMMd().format(DateTime.parse(date))} ${DateFormat.Hm().format(DateTime.parse(time))}',
                  style: AppTextStyles.appDescriptionSmall.copyWith(
                    color: AppColors.kWhiteColor.withOpacity(0.3),
                  ),
                ),
              ],
            ),
          ),
          Icon(
            isDone ? Icons.done_all_outlined : Icons.done_outlined,
            color: isDone ? Colors.green : Colors.red,
          ),
        ],
      ),
    );
  }
}
