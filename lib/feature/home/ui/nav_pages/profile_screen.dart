import 'package:flutter/material.dart';
import 'package:unilib/core/theme/app_text_styles.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(child: Text("Profile", style: AppTextStyles.heading));
  }
}
