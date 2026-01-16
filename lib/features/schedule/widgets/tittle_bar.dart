import 'package:flutter/material.dart';
import '../../../core/constants/colors.dart';

class TitleBar extends StatelessWidget {
  const TitleBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text("Task schedule", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          Container(
            height: 63,
            width: 150,
            padding: const EdgeInsets.only(right: 10),
            decoration: BoxDecoration(
              color: OrColors.bg,
              borderRadius: BorderRadius.circular(45),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              mainAxisSize: MainAxisSize.min,
              children: const [
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 5 , horizontal: 3),
                  child: CircleAvatar(
                    backgroundColor: Colors.white70,
                    radius: 30,
                    child: Icon(Icons.calendar_today, size: 14),
                  ),
                ),

                Padding(
                  padding: EdgeInsets.all(6),
                  child: Text(
                    "Calendar",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            )

          ),
        ],
      ),
    );
  }
}
