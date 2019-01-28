import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import './screens/home_screen.dart';
// import '../src/widgets/dir_widget.dart';

class MyApp extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _MyAppState();
  }
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    SharedPreferences.getInstance().then((prefs) {
      prefs.setStringList('voiceNotes', []);
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: HomeScreen(),
      // home: Scaffold(
      //   body: Center(child: DirButton('dirName')),
      // ),
    );
  }
}
