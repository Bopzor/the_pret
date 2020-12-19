import 'package:flutter/material.dart';

class AdaptiveFontSize {
  const AdaptiveFontSize();

  getadaptiveTextSize(BuildContext context, dynamic value) {
    // 720 is medium screen height
    return (value / 720) * MediaQuery.of(context).size.height;
  }
}
