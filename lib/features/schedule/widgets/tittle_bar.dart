import 'package:flutter/material.dart';
import '../../../core/constants/colors.dart';

class TitleBar extends StatelessWidget {
  const TitleBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: Row(
        children: [
          /// Title
          Expanded(
            child: Text(
              "Task schedule",
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          const SizedBox(width: 10),

          /// Calendar Button
          ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: 140,
              minHeight: 52,
            ),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                color: OrColors.bg,
                borderRadius: BorderRadius.circular(45),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Row(
                children: const [
                  CircleAvatar(
                    radius: 22,
                    backgroundColor: Colors.white70,
                    child: Icon(Icons.calendar_today, size: 14),
                  ),
                  SizedBox(width: 6),

                  /// 🔥 THIS FIXES OVERFLOW
                  Expanded(
                    child: Text(
                      "Calendar",
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      softWrap: false,
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}