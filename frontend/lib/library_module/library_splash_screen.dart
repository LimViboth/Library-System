import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'logged_user_model.dart';
import 'library_app.dart';
import 'library_login_logic.dart';
import 'library_login_screen.dart';
import 'library_service.dart';

class LibrarySplashScreen extends StatefulWidget {
  const LibrarySplashScreen({super.key});

  @override
  State<LibrarySplashScreen> createState() => _LibrarySplashScreenState();
}

class _LibrarySplashScreenState extends State<LibrarySplashScreen> {
  late Future<int> _futureData;
  bool _retrying = false;
  bool _navigated = false;

  @override
  void initState() {
    super.initState();
    _futureData = _testLoggedUser();
  }

  Future<int> _testLoggedUser() async {
    LoggedUserModel loggedUser =
        await context.read<LibraryLoginLogic>().readLoggedUser();
    if (!await _hasNetwork()) return 0;
    if (loggedUser.token.isEmpty) {
      return 401;
    }

    try {
      final statusCode = await LibraryService.testToken(loggedUser.token);

      if (statusCode == 401) {
        await context.read<LibraryLoginLogic>().clearLoggedUser();
      }

      return statusCode;
    } catch (e) {
      await context.read<LibraryLoginLogic>().clearLoggedUser();
      return 401;
    }
  }

  Future<bool> _hasNetwork() async {
    try {
      final result = await InternetAddress.lookup(
        'example.com',
      ).timeout(const Duration(seconds: 8));
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  Future<int> _delayedRetry({int seconds = 3}) async {
    _retrying = true;
    await Future.delayed(Duration(seconds: seconds));
    _retrying = false;
    return _testLoggedUser();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.system,
      theme: ThemeData(brightness: Brightness.light, useMaterial3: true),
      darkTheme: ThemeData(brightness: Brightness.dark, useMaterial3: true),
      home: Builder(
        builder: (context) {
          return Scaffold(
            body: FutureBuilder<int>(
              future: _futureData,
              builder: (context, snapshot) {
                final brightness = Theme.of(context).brightness;
                final isOffline = snapshot.hasData && snapshot.data == 0;

                // Navigate once when the future completes (avoid swapping widgets)
                if (snapshot.connectionState == ConnectionState.done &&
                    !_navigated) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (_navigated) return;
                    if (snapshot.hasError) return; // show error overlay instead

                    if (snapshot.data == 200) {
                      _navigated = true;
                      Navigator.of(context).pushReplacement(
                        PageRouteBuilder(
                          pageBuilder: (_, __, ___) => const LibraryApp(),
                          transitionsBuilder:
                              (_, a, __, c) =>
                                  FadeTransition(opacity: a, child: c),
                          transitionDuration: const Duration(milliseconds: 350),
                        ),
                      );
                    } else if (snapshot.data == 401) {
                      _navigated = true;
                      Navigator.of(context).pushReplacement(
                        PageRouteBuilder(
                          pageBuilder:
                              (_, __, ___) => const LibraryLoginScreen(),
                          transitionsBuilder:
                              (_, a, __, c) =>
                                  FadeTransition(opacity: a, child: c),
                          transitionDuration: const Duration(milliseconds: 350),
                        ),
                      );
                    } else if (isOffline) {
                      // schedule automatic retry when offline
                      if (!_retrying) {
                        setState(() {
                          _futureData = _delayedRetry(seconds: 4);
                        });
                      }
                    } else {
                      // fallback -> login
                      _navigated = true;
                      Navigator.of(context).pushReplacement(
                        PageRouteBuilder(
                          pageBuilder:
                              (_, __, ___) => const LibraryLoginScreen(),
                          transitionsBuilder:
                              (_, a, __, c) =>
                                  FadeTransition(opacity: a, child: c),
                          transitionDuration: const Duration(milliseconds: 350),
                        ),
                      );
                    }
                  });
                }
                return AnimatedContainer(
                  duration: Duration(milliseconds: 300),
                  decoration: BoxDecoration(
                    color:
                        brightness == Brightness.dark
                            ? Colors.black
                            : Colors.white,
                  ),
                  child: SafeArea(
                    child: Stack(
                      children: [
                        Center(child: _loadingScreen()),
                        if (snapshot.hasError) _errorOverlay(snapshot.error),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  Widget _loadingScreen() {
    // Return the central content only (background controlled by parent).
    final brightness = Theme.of(context).brightness;
    final iconBg =
        brightness == Brightness.dark ? Colors.white10 : Colors.white;
    final iconColor =
        brightness == Brightness.dark ? Colors.white : const Color(0xFF0072FF);
    final titleColor =
        brightness == Brightness.dark ? Colors.white : Colors.black87;
    final subtitleColor =
        brightness == Brightness.dark ? Colors.white70 : Colors.black54;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.85, end: 1.0),
          duration: const Duration(milliseconds: 900),
          curve: Curves.easeOutBack,
          builder:
              (context, scale, child) =>
                  Transform.scale(scale: scale, child: child),
          child: Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: iconBg,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.12),
                  blurRadius: 12,
                  offset: Offset(0, 6),
                ),
              ],
            ),
            child: Icon(Icons.menu_book_rounded, color: iconColor, size: 88),
          ),
        ),
        const SizedBox(height: 22),
        const SizedBox(height: 6),
        const SizedBox(height: 26),
        SizedBox(
          width: 140,
          child: LinearProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(
              brightness == Brightness.dark
                  ? Colors.white
                  : const Color(0xFF0072FF),
            ),
            backgroundColor: Colors.white24,
          ),
        ),
        const SizedBox(height: 14),
      ],
    );
  }

  Widget _errorOverlay(Object? error) {
    // show a small centered error card
    return Center(
      child: Card(
        color: Colors.red.shade700,
        margin: const EdgeInsets.symmetric(horizontal: 36),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Text(
            error?.toString() ?? 'Error',
            style: const TextStyle(color: Colors.white),
          ),
        ),
      ),
    );
  }
}
