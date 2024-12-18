import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_signature_pad/flutter_signature_pad.dart';

class SignatureWidget extends StatelessWidget {
  final GlobalKey<SignatureState> signatureKey;

  SignatureWidget({required this.signatureKey});

  @override
  Widget build(BuildContext context) {
    return Container(

      width: double.infinity,
      height: 250,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black),
      ),
      child: Signature(
        key: signatureKey,
        color: Colors.black,
        strokeWidth: 1.0,
        onSign: () {
          print('User signed');
        },
      ),
    );
  }
}
