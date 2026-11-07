import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

/// Drag handle shown at the top of bottom sheets.
class SheetHandle extends StatelessWidget {
  const SheetHandle({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 36,
        height: 4,
        decoration: BoxDecoration(
          color: context.colorBorder,
          borderRadius: BorderRadius.circular(999),
        ),
      ),
    );
  }
}
