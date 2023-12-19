import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'chat_message_card.dart';
import 'reply_message_card.dart';
import 'models.dart';
import 'package:http/http.dart' as http;

class IndividualChats extends StatefulWidget {
  const IndividualChats({super.key, required this.imagePath});
  final String imagePath;

  @override
  _IndividualChatsState createState() => _IndividualChatsState();
}

class _IndividualChatsState extends State<IndividualChats> {
  bool showEmoji = false;
  FocusNode focusNode = FocusNode();
  TextEditingController _textController = TextEditingController();
  ScrollController _scrollController = ScrollController();
  bool sendChatButton = false;
  List<MessageModel> messages = [];
  late Image image;
  late var response;

  @override
  void initState() {
    super.initState();
    focusNode.addListener(() {
      if (focusNode.hasFocus) {
        setState(() {
          showEmoji = false;
        });
      }
    });
    image = Image.file(File(widget.imagePath));
  }

  Future<void> sendChatMsg(String prompt) async {
    MessageModel userInput = MessageModel(
        type: 'user',
        message: prompt,
        time: DateTime.now().toString().substring(10, 16));
    setState(() {
      messages.add(userInput);
    });

    final post_response = await http.post(
        Uri.parse('https://server.loca.lt/converse'),
        body: {"prompt": prompt});
    final json_response = json.decode(post_response.body);
    response = json_response['response'];

    MessageModel llmOutput = MessageModel(
        type: 'llm',
        message: response,
        time: DateTime.now().toString().substring(10, 16));
    setState(() {
      messages.add(llmOutput);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.lightBlue.shade100,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: AppBar(
          backgroundColor: Colors.purple.shade400,
          leadingWidth: 70,
          centerTitle: true,
          leading: InkWell(
            onTap: () {
              Get.back();
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.arrow_back, size: 24),
              ],
            ),
          ),
          title: InkWell(
            onTap: () {},
            child: Container(
              margin: const EdgeInsets.all(6),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("ASK MORE",
                      style: const TextStyle(
                          fontSize: 21, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ),
        ),
      ),
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: WillPopScope(
          child: Column(
            children: [
              const SizedBox(
                height: 8,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Spacer(
                    flex: 12,
                  ),
                  SizedBox(
                    height: 265,
                    width: 195,
                    child: Image.file(
                      File(widget.imagePath),
                      fit: BoxFit.fill,
                    ),
                  ),
                  Spacer(
                    flex: 1,
                  ),
                ],
              ),
              const SizedBox(
                height: 8,
              ),
              Expanded(
                  child: ListView.builder(
                      shrinkWrap: true,
                      controller: _scrollController,
                      itemCount: messages.length + 1,
                      itemBuilder: (context, index) {
                        if (index == messages.length) {
                          return Container(height: 70);
                        }
                        if (messages[index].type == "user") {
                          return ChatMessageCard(
                            msg: messages[index].message,
                            time: messages[index].time,
                          );
                        } else {
                          return ReplyMessageCard(
                            msg: messages[index].message,
                            time: messages[index].time,
                          );
                        }
                      })),
              Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  height: 70,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Row(
                        children: [
                          Container(
                              width: MediaQuery.of(context).size.width - 55,
                              child: Card(
                                  margin: const EdgeInsets.only(
                                      left: 2, right: 2, bottom: 8),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(25)),
                                  child: TextFormField(
                                    controller: _textController,
                                    focusNode: focusNode,
                                    textAlignVertical: TextAlignVertical.top,
                                    textAlign: TextAlign.center,
                                    keyboardType: TextInputType.multiline,
                                    maxLines: 5,
                                    minLines: 1,
                                    onChanged: (value) {
                                      if (value.length > 0) {
                                        setState(() {
                                          sendChatButton = true;
                                        });
                                      } else {
                                        setState(() {
                                          sendChatButton = false;
                                        });
                                      }
                                    },
                                    decoration: InputDecoration(
                                      border: InputBorder.none,
                                      hintText: "Type your message",
                                      contentPadding: const EdgeInsets.all(5),
                                    ),
                                  ))),
                          Padding(
                            padding:
                                const EdgeInsets.only(bottom: 8.0, right: 2),
                            child: CircleAvatar(
                              radius: 25,
                              backgroundColor: Colors.purple.shade400,
                              child: IconButton(
                                  onPressed: () {
                                    if (sendChatButton) {
                                      _scrollController.animateTo(
                                          _scrollController
                                              .position.maxScrollExtent,
                                          duration:
                                              const Duration(milliseconds: 300),
                                          curve: Curves.easeOut);
                                      sendChatMsg(_textController.text);
                                      _textController.clear();
                                      setState(() {
                                        sendChatButton = false;
                                      });
                                    }
                                  },
                                  icon: Icon(
                                    sendChatButton ? Icons.send : Icons.mic,
                                    color: Colors.white,
                                  )),
                            ),
                          ),
                        ],
                      ),
                      Container(),
                    ],
                  ),
                ),
              ),
            ],
          ),
          onWillPop: () {
            if (showEmoji == true) {
              setState(() {
                showEmoji = false;
              });
            } else {
              Navigator.pop(context);
            }
            return Future.value(false);
          },
        ),
      ),
    );
  }
}
