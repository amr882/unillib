import 'package:flutter/material.dart';
import 'package:unilib/core/theme/app_text_styles.dart';

class BrowseScreen extends StatelessWidget {
  const BrowseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(child: Text("BrowseScreen", style: AppTextStyles.heading));
  }
}
