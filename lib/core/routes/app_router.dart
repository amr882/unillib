import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:unilib/core/logic/user_provider.dart';
import 'package:unilib/core/routes/routes.dart';
import 'package:unilib/feature/home/logic/book_catalog_provider.dart';
import 'package:unilib/feature/home/logic/user_books_provider.dart';
import 'package:unilib/feature/home/ui/main_scaffold.dart';
import 'package:unilib/feature/login/logic/login_controller.dart';
import 'package:unilib/feature/login/ui/login_screen.dart';
import 'package:unilib/feature/sign_up/ui/signup_screen.dart';

class AppRouter {
  Route generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case Routes.mainScaffold:
        return MaterialPageRoute(
          builder: (_) => MultiProvider(
            providers: [
              ChangeNotifierProvider(create: (_) => UserProvider()),
              ChangeNotifierProvider(create: (_) => BookCatalogProvider()),
              ChangeNotifierProxyProvider<BookCatalogProvider, UserBooksProvider>(
                create: (ctx) => UserBooksProvider(ctx.read<BookCatalogProvider>()),
                update: (_, catalog, prev) => prev ?? UserBooksProvider(catalog),
              ),
            ],
            child: const MainScaffold(),
          ),
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

      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(child: Text('No route defined for ${settings.name}')),
          ),
        );
    }
  }
}
