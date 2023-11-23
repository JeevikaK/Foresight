import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:llava_flutter/take_picture.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  // final cameras = await availableCameras();
  // final firstCamera = cameras.first;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late CameraDescription camera;

  @override
  void initState() {
    super.initState();
    initializeCamera();
  }

  void initializeCamera() async {
    await availableCameras().then((cameras) {
      camera = cameras.first;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueAccent,
        centerTitle: true,
        title: const Text('See for Me'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Spacer(
              flex: 5,
            ),
            SizedBox(
              width: 280,
              height: 45,
              child: ElevatedButton(
                  onPressed: () {
                    Get.to(() => TakePictureScreen(camera: camera));
                  },
                  child: Text(
                    'I need Visual Assistance',
                    style: GoogleFonts.lato(
                        fontWeight: FontWeight.w500, fontSize: 19.0),
                  )),
            ),
            const Spacer(
              flex: 2,
            ),
          ],
        ),
      ),
    );
  }
}
