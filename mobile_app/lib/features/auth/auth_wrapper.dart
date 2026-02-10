import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'auth_provider.dart';
import 'login_screen.dart';
import '../home/home_screen.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);

    // If user is null, show Login. Otherwise, show Home.
    if (auth.user == null) {
      return const LoginScreen();
    } else {
      return const HomeScreen();
    }
  }
}
