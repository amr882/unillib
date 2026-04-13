import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:unilib/core/routes/app_router.dart';
import 'package:unilib/firebase_options.dart';
import 'package:unilib/core/service/notification_service.dart';
import 'package:unilib/unilib.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await NotificationService().init();

  runApp(UniLib(appRouter: AppRouter()));
}
