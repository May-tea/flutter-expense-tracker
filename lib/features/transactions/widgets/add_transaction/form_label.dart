import 'package:flutter/material.dart';

import '../../../../core/utils/screen_utils.dart';

class FormLabel extends StatelessWidget {
  const FormLabel({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final screenWidth = ScreenUtils.width(context);

    return Text(
      label,
      style: .new(fontSize: screenWidth * 0.05, fontWeight: .w500),
    );
  }
}
