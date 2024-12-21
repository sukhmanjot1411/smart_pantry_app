import 'package:flutter/material.dart';
import 'package:recipe_app_final/screens/auth/login_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:recipe_app_final/screens/auth/onboarding_screen.dart';


Future<void> main() async {



  WidgetsFlutterBinding.ensureInitialized(); // Ensure binding is initialized
  await Firebase.initializeApp(); // Initialize Firebase
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Smart Pantry',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        initialRoute: '/onboarding',
        routes: {
          '/login': (context) =>LoginPage(),
          '/onboarding': (context) => OnBoardingScreen(),
        },
        );
  }
}
