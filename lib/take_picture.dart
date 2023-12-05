import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;

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
  String prompt = "please describe this image";
  String convo_prompt = "tell me more about the object present in the image";
  var response = '';
  late bool reload;

  @override
  void initState() {
    super.initState();
    _controller = CameraController(
      widget.camera,
      ResolutionPreset.max,
    );
    reload = true;

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
        reload
            ? Positioned(
                top: 420,
                left: 12,
                right: 12,
                bottom: 175,
                child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: Column(
                    children: [
                      Text(
                        response,
                        style: TextStyle(
                            fontSize: 17.5,
                            fontWeight: FontWeight.normal,
                            color: Colors.white),
                      ),
                    ],
                  ),
                ),
              )
            : Positioned(
                top: 350,
                left: 0,
                right: 0,
                child: Center(
                    child: CircularProgressIndicator(
                  color: Colors.white,
                ))),
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
                          // Get.to(() =>
                          //     DisplayPictureScreen(imagePath: image.path));
                          setState(() {
                            reload = false;
                          });
                          begin_conversation(image.path, prompt);
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
                      onPressed: () async {
                        setState(() {
                          reload = false;
                        });
                        continueConversation(convo_prompt);
                      },
                      child: Text(
                        'Converse',
                        style: GoogleFonts.lato(
                            fontWeight: FontWeight.w500, fontSize: 19.0),
                      )),
                  ElevatedButton(
                      onPressed: () async {
                        getConversationHistory();
                      },
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

  begin_conversation(String filePath, String prompt) async {
    // final response = await http.get(Uri.parse('https://server.loca.lt/begin_conversation'));
    File file = File(filePath);
    var request = http.MultipartRequest(
      'POST',
      Uri.parse("https://server.loca.lt/begin_conversation"),
    );
    Map<String, String> headers = {"Content-type": "multipart/form-data"};
    request.files.add(http.MultipartFile.fromBytes(
        'image', file.readAsBytesSync(),
        filename: filePath.split("/").last));
    request.headers.addAll(headers);
    request.fields.addAll({"prompt": prompt});
    var request_send = await request.send();
    final post_response = await http.Response.fromStream(request_send);
    final json_response = json.decode(post_response.body);
    setState(() {
      response = json_response['response'];
      reload = true;
    });
    // print("This is response:" + post_response.body);
  }

  continueConversation(String prompt) async {
    final post_response = await http.post(
        Uri.parse('https://server.loca.lt/converse'),
        body: {"prompt": prompt});

    final json_response = json.decode(post_response.body);

    setState(() {
      response = json_response['response'];
      reload = true;
    });
    // print("This is response:" + post_response.body);
  }

  getConversationHistory() async {
    final response = await http.get(
      Uri.parse('https://server.loca.lt/get_convo_history'),
    );

    print("This is response:" + response.body);
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
