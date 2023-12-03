import 'package:flutter/material.dart';

class MessageModel {
  String type;
  String message;
  String time;
  MessageModel({required this.type, required this.message, required this.time});
}

class ChatModel {
  String name;
  IconData icon;
  bool isGroup;
  String time;
  String currentMessage;
  String status;
  bool select = false;
  int id;
  ChatModel({
    required this.name,
    required this.icon,
    required this.isGroup,
    required this.time,
    required this.currentMessage,
    required this.status,
    required this.id,
  });
}
