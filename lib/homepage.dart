import 'package:flutter/material.dart';
import 'main_shell.dart';

/// HomeScreen delegates to MainShell (bottom-nav app shell).
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) => const MainShell();
}