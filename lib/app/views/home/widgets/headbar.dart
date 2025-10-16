import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:talkliner/app/config/routes.dart';
import 'package:talkliner/app/views/home/widgets/signalbars_widget.dart';

class HeadBar extends StatelessWidget {
  const HeadBar({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
        title: SvgPicture.asset('assets/logos/talkliner.svg', height: 36),
        actions: [
          SignalBarsWidget(),
          IconButton(
            onPressed: () => Get.toNamed(Routes.userSettings),
            icon: const Icon(LucideIcons.user),
          ),
        ],
      );
  }
}