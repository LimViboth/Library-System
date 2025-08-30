import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'library_login_logic.dart';
import 'library_login_screen.dart';
import 'library_screen.dart';

class LibraryApp extends StatelessWidget {
  const LibraryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chaptr'),
        centerTitle: true,
        actions: [
          Consumer<LibraryLoginLogic>(
            builder: (context, logic, _) => IconButton(
              tooltip: 'Logout',
              icon: const Icon(Icons.logout),
              onPressed: logic.isLoading
                  ? null
                  : () async {
                      final ok = await context.read<LibraryLoginLogic>().logoutUser();
                      if (ok) {
                        Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(builder: (_) => const LibraryLoginScreen()),
                          (_) => false,
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(logic.errorMessage ?? 'Logout failed')),
                        );
                      }
                    },
            ),
          ),
        ],
      ),
      body: LibraryScreen(),
    );
  }
}
