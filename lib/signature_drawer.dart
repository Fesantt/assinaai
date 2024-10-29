import 'dart:ui';
import 'package:flutter/material.dart';

class SignatureDrawer extends StatefulWidget {
  final List<Offset?> points;

  SignatureDrawer({required this.points});

  @override
  _SignatureDrawerState createState() => _SignatureDrawerState();
}

class _SignatureDrawerState extends State<SignatureDrawer> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanStart: (details) {
        setState(() {
          widget.points.add(details.localPosition);
        });
      },
      onPanUpdate: (details) {
        setState(() {
          widget.points.add(details.localPosition);
        });
      },
      onPanEnd: (details) {
        setState(() {
          widget.points.add(null); // Adiciona um separador para a linha
        });
      },
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.black),
        ),
        child: CustomPaint(
          painter: SignaturePainter(widget.points),
          child: Container(
            width: double.infinity, // Largura total disponível
            height: 200, // Altura fixa da assinatura
          ),
        ),
      ),
    );
  }
}

class SignaturePainter extends CustomPainter {
  final List<Offset?> points;

  SignaturePainter(this.points);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 5.0;

    for (int i = 0; i < points.length - 1; i++) {
      if (points[i] != null && points[i + 1] != null) {
        canvas.drawLine(points[i]!, points[i + 1]!, paint);
      }
    }
  }

  @override
  bool shouldRepaint(SignaturePainter oldDelegate) {
    return oldDelegate.points != points;
  }
}

class SignaturePage extends StatelessWidget {
  final List<Offset?> _points = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Desenho de Assinatura'),
      ),
      body: SingleChildScrollView( // Permite rolagem se necessário
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text('Desenhe sua assinatura abaixo:'),
            SizedBox(height: 20),
            SignatureDrawer(points: _points), // Passa a lista de pontos
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Aqui você pode implementar a lógica para salvar ou limpar a assinatura
                _points.clear();
              },
              child: Text('Limpar Assinatura'),
            ),
          ],
        ),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: SignaturePage(),
  ));
}
