import 'package:flutter/material.dart';

class ControlsWidget extends StatelessWidget {
  final VoidCallback onConfirm;
  final VoidCallback onClear;

  ControlsWidget({required this.onConfirm, required this.onClear});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        ElevatedButton(
          onPressed: onConfirm,
          child: Text('Confirmar'),
        ),
        ElevatedButton(
          onPressed: onClear,
          child: Text('Limpar'),
        ),
      ],
    );
  }
}
