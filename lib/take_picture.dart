import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class TakePictureScreen extends StatefulWidget {
  const TakePictureScreen({
    super.key,
    required this.camera,
  });

  final CameraDescription camera;

  @override
  TakePictureScreenState createState() => TakePictureScreenState();
}

class TakePictureScreenState extends State<TakePictureScreen> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;

  @override
  void initState() {
    super.initState();
    _controller = CameraController(
      widget.camera,
      ResolutionPreset.max,
    );

    _initializeControllerFuture = _controller.initialize();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Take a picture')),
      body: Stack(children: <Widget>[
        SizedBox(
          height: double.infinity,
          child: FutureBuilder<void>(
            future: _initializeControllerFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                return CameraPreview(_controller);
              } else {
                return const Center(child: CircularProgressIndicator());
              }
            },
          ),
        ),
        Positioned(
          bottom: 40,
          left: 15,
          right: 15,
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  ElevatedButton(
                      onPressed: () async {
                        try {
                          await _initializeControllerFuture;
                          final image = await _controller.takePicture();

                          if (!mounted) return;

                          print(image.path);
                          Get.to(() =>
                              DisplayPictureScreen(imagePath: image.path));
                        } catch (e) {
                          print(e);
                        }
                      },
                      child: Text(
                        'Describe',
                        style: GoogleFonts.lato(
                            fontWeight: FontWeight.w500, fontSize: 19.0),
                      )),
                  ElevatedButton(
                      onPressed: () async {},
                      child: Text(
                        'Clear',
                        style: GoogleFonts.lato(
                            fontWeight: FontWeight.w500, fontSize: 19.0),
                      )),
                  ElevatedButton(
                      onPressed: () async {},
                      child: Text(
                        'Read Aloud',
                        style: GoogleFonts.lato(
                            fontWeight: FontWeight.w500, fontSize: 19.0),
                      )),
                ],
              ),
              const SizedBox(
                height: 6,
              ),
              ElevatedButton(
                onPressed: () {
                  Get.back();
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(15),
                  shape: const CircleBorder(),
                  backgroundColor: Colors.red,
                ),
                child: const Icon(
                  Icons.stop,
                  size: 35,
                ),
              )
            ],
          ),
        )
      ]),
    );
  }
}

class DisplayPictureScreen extends StatefulWidget {
  final String imagePath;

  const DisplayPictureScreen({super.key, required this.imagePath});

  @override
  State<DisplayPictureScreen> createState() => _DisplayPictureScreenState();
}

class _DisplayPictureScreenState extends State<DisplayPictureScreen> {
  late Image img;

  @override
  void initState() {
    super.initState();
    img = Image.file(File(widget.imagePath));
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text('Display the Picture')),
        body: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              img,
              const Spacer(
                flex: 1,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  ElevatedButton(
                      onPressed: () {
                        Get.back();
                      },
                      child: Text(
                        'Retake',
                        style: GoogleFonts.lato(
                            fontWeight: FontWeight.w500, fontSize: 19.0),
                      )),
                  ElevatedButton(
                      onPressed: () {},
                      child: Text(
                        'Confirm',
                        style: GoogleFonts.lato(
                            fontWeight: FontWeight.w500, fontSize: 19.0),
                      )),
                ],
              ),
              const Spacer(
                flex: 1,
              ),
            ],
          ),
        ));
  }
}
