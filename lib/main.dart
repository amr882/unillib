import 'package:device_preview/device_preview.dart';
import 'package:flutter/material.dart';
import 'package:unilib/core/routes/app_router.dart';
import 'package:unilib/unilib.dart';

void main() {
  runApp(
    DevicePreview(
      enabled: true,
      builder: (context) => UniLib(appRouter: AppRouter()),
    ),
  );
}
