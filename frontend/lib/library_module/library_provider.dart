import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'library_login_logic.dart';
import 'library_splash_screen.dart';

Widget libraryProvider() {
  return MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (context) => LibraryLoginLogic()),
    ],
    child: LibrarySplashScreen(),
  );
}
