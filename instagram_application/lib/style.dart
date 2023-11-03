import 'package:flutter/material.dart';

// 다른 파일에서 쓸 수없는 변수 ( 접근제어자 느낌 ) => private느낌.
var _var1;

var theme = ThemeData(
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        backgroundColor: Colors.blue,
        // textStyle: TextStyle(
        //   color: Colors.white,
        // ),
      ),
    ),
    appBarTheme: AppBarTheme(
        color: Colors.white,
        elevation: 1,
        titleTextStyle: TextStyle(
          fontSize: 26,
          color: Colors.black,
        ),
        actionsIconTheme: IconThemeData(
          size: 35,
          color: Color.fromARGB(255, 0, 0, 0),
        ),
        iconTheme: IconThemeData(color: Colors.black)),
    textTheme: TextTheme(
      bodyText2: TextStyle(color: Colors.black),
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      selectedItemColor: Colors.black,
    ));
