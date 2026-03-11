import 'package:device_preview/device_preview.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:unilib/core/routes/app_router.dart';
import 'package:unilib/unilib.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,     
    ),
  );

  runApp(
    DevicePreview(
      enabled: true,
      builder: (context) => UniLib(appRouter: AppRouter()),
    ),
  );
}
