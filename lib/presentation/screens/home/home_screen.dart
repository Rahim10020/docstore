import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/home_controller.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/custom_bottom_nav_bar.dart';
import '../ecoles/ecoles_facultes_screen.dart';
import '../concours/concours_list_screen.dart';
import '../search/search_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(HomeController());

    return Obx(() {
      final screens = [
        const EcolesFacultesScreen(),
        const ConcoursListScreen(),
        const SearchScreen(),
      ];

      return Scaffold(
        body: screens[controller.currentTabIndex.value],
        bottomNavigationBar: CustomBottomNavBar(
          currentIndex: controller.currentTabIndex.value,
          onTap: controller.changeTab,
        ),
      );
    });
  }
}
