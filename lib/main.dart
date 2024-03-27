import 'package:flutter/material.dart';
import 'package:mock_users/ui/pages/app.dart';
import 'package:window_size/window_size.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  setWindowMaxSize(const Size(800, 500));
  setWindowMinSize(const Size(600, 400));
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: AppScreen(),
    );
  }
}
