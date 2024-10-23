import 'package:flutter/material.dart';

class MessageWidget extends StatelessWidget {
  final String? message;

  const MessageWidget({
    super.key,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Text(message == '' ? '' : '$message');
  }
}
