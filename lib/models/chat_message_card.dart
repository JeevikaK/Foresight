import 'package:flutter/material.dart';

class ChatMessageCard extends StatelessWidget {
  const ChatMessageCard({super.key, required this.msg, required this.time});
  final String msg;
  final String time;

  @override
  Widget build(BuildContext context) {
    return Align(
        alignment: Alignment.centerRight,
        child: ConstrainedBox(
          constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width - 80, minWidth: 105),
          child: Card(
            elevation: 1,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            color: Colors.purple[100],
            margin: EdgeInsets.symmetric(horizontal: 15, vertical: 5),
            child: Stack(children: [
              Padding(
                padding: const EdgeInsets.only(
                    left: 8, right: 8, top: 5, bottom: 20),
                child: Text(
                  msg,
                  style: TextStyle(
                    fontSize: 16,
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                right: 6,
                child: Row(
                  children: [
                    Text(time,
                        style:
                            TextStyle(fontSize: 13, color: Colors.grey[600])),
                    SizedBox(
                      width: 5,
                    ),
                    Icon(Icons.done_all, size: 20)
                  ],
                ),
              )
            ]),
          ),
        ));
  }
}
