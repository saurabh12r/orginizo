import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/colors.dart';
import '../../../routes/app_routes.dart';

class HeaderBar extends StatelessWidget implements PreferredSizeWidget {
  const HeaderBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(70);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            CircleAvatar(
              radius: 25,
              backgroundColor: OrColors.bg,
              child: const Icon(Icons.arrow_back_ios_new, size: 25, color: Colors.black),
            ),
            Row(
              children: [
                InkWell( onTap: (){Get.toNamed(Routes.addTask);

                },  child: const CircleAvatar(
                  radius: 25,
                    backgroundColor: Colors.black, child: Icon(Icons.add, color: Colors.white , size: 27))),
                const SizedBox(width: 10),
                InkWell( onTap: (){
                  Get.toNamed(Routes.test);
                },
                    child: CircleAvatar(radius: 25,backgroundColor: OrColors.bg, child: const Icon(Icons.notifications_none, color: Colors.black , size: 27,) )),
              ],
            )
          ],
        ),
      ),
    );
  }
}
