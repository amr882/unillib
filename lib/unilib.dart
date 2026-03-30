import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import 'package:unilib/core/logic/user_provider.dart';
import 'package:unilib/core/routes/app_router.dart';
import 'package:unilib/core/routes/routes.dart';
import 'package:unilib/feature/home/logic/book_catalog_provider.dart';
import 'package:unilib/feature/home/logic/user_books_provider.dart';
import 'package:unilib/feature/home/ui/nav_pages/ai_page/logic/user/generative_ai_provider.dart';

class UniLib extends StatefulWidget {
  final AppRouter appRouter;
  const UniLib({super.key, required this.appRouter});

  @override
  State<UniLib> createState() => _UniLibState();
}

class _UniLibState extends State<UniLib> {
  late final Future<User?> _authFuture;

  @override
  void initState() {
    super.initState();
    _authFuture = FirebaseAuth.instance.authStateChanges().first.then((user) {
      debugPrint('Auth restored: ${user?.email ?? 'null'}');
      return user;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Sizer(
      builder: (context, orientation, deviceType) {
        return MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => UserProvider()),
            ChangeNotifierProvider(create: (_) => BookCatalogProvider()),
            ChangeNotifierProxyProvider<BookCatalogProvider, UserBooksProvider>(
              create: (ctx) =>
                  UserBooksProvider(ctx.read<BookCatalogProvider>()),
              update: (_, catalog, prev) => prev ?? UserBooksProvider(catalog),
            ),
            ChangeNotifierProvider(create: (_) => GenerativeAiProvider()),
          ],
          child: MaterialApp(
            useInheritedMediaQuery: true,

            theme: ThemeData(
              scaffoldBackgroundColor: Colors.white,
              fontFamily: GoogleFonts.dmSans().fontFamily,
            ),
            debugShowCheckedModeBanner: false,
            title: 'Unilib',
            onGenerateRoute: widget.appRouter.generateRoute,
            home: FutureBuilder<User?>(
              future: _authFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState != ConnectionState.done) {
                  return const _SplashScreen();
                }

                if (snapshot.data != null) {
                  return const _Redirect(route: Routes.mainScaffold);
                }

                return const _Redirect(route: Routes.loginScreen);
              },
            ),
          ),
        );
      },
    );
  }
}

class _Redirect extends StatefulWidget {
  final String route;
  const _Redirect({required this.route});

  @override
  State<_Redirect> createState() => _RedirectState();
}

class _RedirectState extends State<_Redirect> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) Navigator.pushReplacementNamed(context, widget.route);
    });
  }

  @override
  Widget build(BuildContext context) => const _SplashScreen();
}

class _SplashScreen extends StatelessWidget {
  const _SplashScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFF0C1B2E),
      body: Center(child: CircularProgressIndicator(color: Color(0xFFC9A84C))),
    );
  }
}
