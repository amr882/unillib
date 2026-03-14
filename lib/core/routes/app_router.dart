import 'package:flutter/material.dart';
import 'package:unilib/core/routes/routes.dart';
import 'package:unilib/feature/home/ui/home_screen.dart';
import 'package:unilib/feature/login/ui/login_screen.dart';
import 'package:unilib/feature/sign_up/ui/signup_screen.dart';

class AppRouter {
  Route generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case Routes.homeScreen:
        return MaterialPageRoute(builder: (_) => HomeScreen());
      case Routes.loginScreen:
        return MaterialPageRoute(builder: (_) => LoginScreen());
      case Routes.signupScreen:
        return MaterialPageRoute(builder: (_) => SignupScreen());

      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(child: Text('No route defined for ${settings.name}')),
          ),
        );
    }
  }
}
