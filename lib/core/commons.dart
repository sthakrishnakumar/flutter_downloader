import 'package:flutter/material.dart';

class NavigationService {
  static GlobalKey<NavigatorState> materialKey = GlobalKey<NavigatorState>();
}

snackbar({required String title, Color color = Colors.black}) {
  ScaffoldMessenger.of(NavigationService.materialKey.currentContext!)
      .clearSnackBars();
  ScaffoldMessenger.of(NavigationService.materialKey.currentContext!)
      .showSnackBar(
    SnackBar(
      content: Text(title),
      duration: const Duration(milliseconds: 600),
      backgroundColor: color,
    ),
  );
}

final globalContext = NavigationService.materialKey.currentContext!;
