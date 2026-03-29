import 'package:flutter/material.dart';
import 'package:unilib/core/theme/app_colors.dart';

class UserMessage extends StatelessWidget {
  final String msg;
  const UserMessage({super.key, required this.msg});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 8.0, bottom: 8.0, left: 64.0, right: 16.0),
      padding: const EdgeInsets.all(16.0),
      decoration: const BoxDecoration(
        color: AppColors.blue,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
          bottomLeft: Radius.circular(16),
          bottomRight: Radius.circular(4),
        ),
      ),
      child: Text(
        msg,
        style: const TextStyle(
          color: AppColors.white,
          fontSize: 14,
          height: 1.4,
        ),
      ),
    );
  }
}
