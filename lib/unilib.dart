import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:unilib/core/routes/app_router.dart';
import 'package:unilib/core/routes/routes.dart';

class UniLib extends StatefulWidget {
  final AppRouter appRouter;
  const UniLib({super.key, required this.appRouter});

  @override
  State<UniLib> createState() => _UniLibState();
}

class _UniLibState extends State<UniLib> {
  @override
  void initState() {
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (user == null) {
        print('User is currently signed out!');
      } else {
        print('User is signed in!');
      }
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Sizer(
      builder: (context, orientation, deviceType) {
        return MaterialApp(
          theme: ThemeData(scaffoldBackgroundColor: Colors.white),
          debugShowCheckedModeBanner: false,
          title: 'Unilib',

          onGenerateRoute: widget.appRouter.generateRoute,
          initialRoute: FirebaseAuth.instance.currentUser == null
              ? Routes.loginScreen
              : Routes.mainScaffold,
        );
      },
    );
  }
}
