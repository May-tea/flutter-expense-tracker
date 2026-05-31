import 'package:flutter/material.dart';

abstract final class ScreenUtils {
  static double width(BuildContext context) => MediaQuery.sizeOf(context).width;

  static double height(BuildContext context) =>
      MediaQuery.sizeOf(context).height;
}
