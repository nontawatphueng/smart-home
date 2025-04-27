import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'homepage_1.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
    DeviceOrientation.landscapeRight,
    DeviceOrientation.landscapeLeft,
  ]).then((_) {
    runApp(MyApp());
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'MyHome',
      theme: ThemeData(
        primaryColor: Color.fromARGB(255, 234, 202, 164),
        scaffoldBackgroundColor: Color.fromARGB(255, 234, 202, 164),
      ),
      home: HomePage(),
    );
  }
}
