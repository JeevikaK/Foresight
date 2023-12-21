import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:llava_flutter/screens/home_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(
    GetMaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.light(),
      // home: TakePictureScreen(
      //   camera: firstCamera,
      // ),
      home: const HomeScreen(),
    ),
  );
}
