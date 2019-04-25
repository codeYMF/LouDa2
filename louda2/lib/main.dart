import 'package:flutter/material.dart';
import 'LoginPage.dart';
import 'MainPage.dart';
import 'SplashPage.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {

  @override
  MyAppState createState() => MyAppState();
}

class MyAppState extends State<MyApp> {

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      routes: {
        '/login':(context) => LoginPage(),
        '/main':(context) => MainPage()
      },
      home: SplashPage(),//MainPage(title: 'Flutter Demo Home Page'),
    );
  }
}
