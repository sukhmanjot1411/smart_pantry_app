import 'dart:ui';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:recipe_app_final/screens/auth/login_page.dart';

import '../navbar/navbar.dart';

class OnBoardingScreen extends StatefulWidget {
  const OnBoardingScreen({super.key});

  @override
  State<OnBoardingScreen> createState() => _OnBoardingScreenState();
}

class _OnBoardingScreenState extends State<OnBoardingScreen> 
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final h = constraints.maxHeight;
            final w = constraints.maxWidth;
            return Container(
              height: h,
              width: w,
              child: Stack(
                children: [
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      height: h * 0.75,
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                image: AssetImage("assets/OnboardingTitle.png"),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.black.withOpacity(0.1),
                                  Colors.black.withOpacity(0.4),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      height: h * 0.28,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            offset: Offset(0, -5),
                          ),
                        ],
                        borderRadius: BorderRadius.only(
                          topRight: Radius.circular(min(w * 0.1, 40)),
                          topLeft: Radius.circular(min(w * 0.1, 40)),
                        ),
                      ),
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: min(w * 0.08, 32),
                          vertical: min(h * 0.032, 24),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Flexible(
                              child: Text(
                                'Lets cook some good food',
                                style: TextStyle(
                                  fontSize: min(w * 0.06, 24),
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF2C3E50),
                                  letterSpacing: 0.5,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            SizedBox(height: min(h * 0.015, 12)),
                            Flexible(
                              child: Text(
                                'Try the app now!',
                                style: TextStyle(
                                  fontSize: min(w * 0.045, 18),
                                  fontWeight: FontWeight.w400,
                                  color: Colors.grey[600],
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            SizedBox(height: min(h * 0.032, 20)),
                            MouseRegion(
                              onEnter: (_) => _controller.forward(),
                              onExit: (_) => _controller.reverse(),
                              child: ScaleTransition(
                                scale: _scaleAnimation,
                                child: Container(
                                  width: min(w * 0.8, 300),
                                  height: min(h * 0.06, 50),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(min(w * 0.04, 15)),
                                    gradient: LinearGradient(
                                      colors: [
                                        Color(0xFFF49619),
                                        Color(0xFFFF8C00),
                                        Color(0xFFFFA500),
                                      ],
                                      begin: Alignment.centerLeft,
                                      end: Alignment.centerRight,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Color(0xFFF49619).withOpacity(0.3),
                                        blurRadius: 8,
                                        offset: Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: Material(
                                    color: Colors.transparent,
                                    child: InkWell(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(builder: (context) => LoginPage()),
                                        );
                                      },
                                      borderRadius: BorderRadius.circular(min(w * 0.04, 15)),
                                      child: Center(
                                        child: Text(
                                          'Get Started',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w600,
                                            fontSize: min(w * 0.045, 18),
                                            letterSpacing: 1.2,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
