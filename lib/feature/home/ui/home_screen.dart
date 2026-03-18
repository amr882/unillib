import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:unilib/core/helper/extention.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: MaterialButton(
          onPressed: () async {
            try {
              await FirebaseAuth.instance.signOut();
              if (context.mounted) {
                context.pushNamedAndRemoveUntil(
                  'loginScreen',
                  predicate: (_) => false,
                );
              }
            } catch (e) {
              throw 'Logout failed: $e';
            }
          },
          child: Text('Home Screen'),
        ),
      ),
    );
  }
}
