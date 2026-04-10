import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:unilib/core/routes/routes.dart';
import 'package:unilib/feature/home/ui/main_scaffold.dart';
import 'package:unilib/feature/home/ui/nav_pages/profile_page/profile_screen.dart';
import 'package:unilib/feature/login/logic/login_controller.dart';
import 'package:unilib/feature/login/ui/login_screen.dart';
import 'package:unilib/feature/sign_up/ui/signup_screen.dart';
import 'package:unilib/feature/admin/admin_qr_scanner_screen.dart';

class AppRouter {
  Route generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case Routes.mainScaffold:
        return MaterialPageRoute(
          builder: (_) => const MainScaffold(),
        );
      
      case Routes.profileScreen:
        return MaterialPageRoute(
          builder: (_) => const ProfileScreen(),
        );

      case Routes.loginScreen:
        return MaterialPageRoute(
          builder: (_) => ChangeNotifierProvider(
            create: (_) => LoginController(),
            child: const LoginScreen(),
          ),
        );

      case Routes.signupScreen:
        return MaterialPageRoute(builder: (_) => const SignupScreen());

      case Routes.adminQrScanner:
        return MaterialPageRoute(builder: (_) => const AdminQrScannerScreen());

      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(child: Text('No route defined for ${settings.name}')),
          ),
        );
    }
  }
}
