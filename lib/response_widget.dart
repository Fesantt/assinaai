import 'package:flutter/material.dart';

class ResponseWidget extends StatelessWidget {
  final String response;

  ResponseWidget({required this.response});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Resposta do servidor:', style: TextStyle(fontWeight: FontWeight.bold)),
        Text(response),
      ],
    );
  }
}
