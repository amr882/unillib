import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:unilib/core/routes/app_router.dart';
import 'package:unilib/core/routes/routes.dart';

class UniLib extends StatelessWidget {
  final AppRouter appRouter;
  const UniLib({super.key, required this.appRouter});

  @override
  Widget build(BuildContext context) {
    return Sizer(
      builder: (context, orientation, deviceType) {
        return MaterialApp(
          theme: ThemeData(scaffoldBackgroundColor: Colors.white),
          debugShowCheckedModeBanner: false,
          title: 'Unilib',

          onGenerateRoute: appRouter.generateRoute,
          initialRoute: Routes.onBoardingScreen,
        );
      },
    );
  }
}
