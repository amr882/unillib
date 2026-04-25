import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:unilib/core/routes/routes.dart';
import 'package:unilib/feature/admin/ui/admin_dashboard_screen.dart';
import 'package:unilib/feature/home/ui/main_scaffold.dart';
import 'package:unilib/feature/home/ui/nav_pages/ai_page/ai_chat_screen.dart';
import 'package:unilib/feature/home/ui/nav_pages/profile_page/profile_screen.dart';
import 'package:unilib/feature/login/logic/login_controller.dart';
import 'package:unilib/feature/login/ui/login_screen.dart';
import 'package:unilib/feature/sign_up/ui/signup_screen.dart';
import 'package:unilib/feature/admin/ui/screens/stat_details_screen.dart';
import 'package:unilib/feature/legal/ui/terms_of_service_screen.dart';
import 'package:unilib/feature/legal/ui/borrow_policy_screen.dart';
import 'package:unilib/core/routes/custom_page_route.dart';
import 'package:unilib/core/logic/user_provider.dart';
import 'package:unilib/feature/home/logic/book_catalog_provider.dart';
import 'package:unilib/feature/home/logic/user_books_provider.dart';
import 'package:unilib/feature/home/ui/nav_pages/ai_page/logic/user/generative_ai_provider.dart';
import 'package:unilib/feature/admin/logic/admin_provider.dart';
import 'package:unilib/feature/admin/logic/book_management_provider.dart';
import 'package:unilib/feature/admin/ui/screens/add_book_screen.dart';

class AppRouter {
  Route generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case Routes.mainScaffold:
        return MaterialPageRoute(
          builder: (_) => ChangeNotifierProvider(
            create: (_) => UserProvider(),
            child: ChangeNotifierProvider(
              create: (_) => BookCatalogProvider(),
              child: ChangeNotifierProxyProvider<BookCatalogProvider, UserBooksProvider>(
                create: (ctx) => UserBooksProvider(ctx.read<BookCatalogProvider>()),
                update: (_, catalog, prev) => prev ?? UserBooksProvider(catalog),
                child: const MainScaffold(),
              ),
            ),
          ),
        );

      case Routes.adminDashboard:
        return MaterialPageRoute(
          builder: (_) => ChangeNotifierProvider(
            create: (_) => UserProvider(),
            child: ChangeNotifierProvider(
              create: (_) => AdminProvider(),
              child: ChangeNotifierProvider(
                create: (_) => BookCatalogProvider(),
                child: ChangeNotifierProvider(
                  create: (_) => BookManagementProvider(),
                  child: const AdminDashboardScreen(),
                ),
              ),
            ),
          ),
        );

      case Routes.statDetailsScreen:
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => StatDetailsScreen(
            type: args['type'] as StatType,
            title: args['title'] as String,
          ),
        );

      case Routes.profileScreen:
        return MaterialPageRoute(
          builder: (_) => ChangeNotifierProvider(
            create: (_) => UserProvider(),
            child: const ProfileScreen(),
          ),
        );

      case Routes.aiChatScreen:
        return MaterialPageRoute(
          builder: (_) => ChangeNotifierProvider(
            create: (_) => GenerativeAiProvider(),
            child: const AiChatScreen(),
          ),
        );

      case Routes.loginScreen:
        return SharedAxisPageRoute(
          settings: settings,
          child: ChangeNotifierProvider(
            create: (_) => LoginController(),
            child: const LoginScreen(),
          ),
          reverse: true, // Login is "back"
        );

      case Routes.signupScreen:
        return SharedAxisPageRoute(
          settings: settings,
          child: const SignupScreen(),
          reverse: false, // Signup is "forward"
        );

      case Routes.termsOfService:
        return MaterialPageRoute(builder: (_) => const TermsOfServiceScreen());

      case Routes.borrowPolicy:
        return MaterialPageRoute(builder: (_) => const BorrowPolicyScreen());

      case Routes.addBookScreen:
        return MaterialPageRoute(
          builder: (_) => ChangeNotifierProvider(
            create: (_) => BookManagementProvider(),
            child: const AddBookScreen(),
          ),
        );

      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(child: Text('No route defined for ${settings.name}')),
          ),
        );
    }
  }
}
