import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_signature_pad/flutter_signature_pad.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'signature_widget.dart';
import 'waiting_page.dart';
import 'package:flutter/services.dart';


void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WebSocket Signature Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.white,
      ),
      home: WebSocketPage(),
    );
  }
}

class WebSocketPage extends StatefulWidget {
  @override
  _WebSocketPageState createState() => _WebSocketPageState();
}

class _WebSocketPageState extends State<WebSocketPage> {
  late WebSocketChannel channel;
  String _response = "";
  final GlobalKey<SignatureState> _signatureKey = GlobalKey<SignatureState>();
  bool _isSigning = false;

  @override
  void initState() {
    super.initState();
    channel = WebSocketChannel.connect(
      Uri.parse('ws://192.168.1.5:6789'),
    );

    channel.stream.listen((message) {
      setState(() {
        _response = message;
        if (message == "start") {
          _isSigning = true;
        }
      });
    });
  }

  @override
  void dispose() {
    channel.sink.close();
    super.dispose();
  }

  void _sendSignature() async {
    final signature = _signatureKey.currentState!;
    final image = await signature.getData();
    final byteData = await image.toByteData(format: ImageByteFormat.png);

    if (byteData != null) {
      final pngBytes = byteData.buffer.asUint8List();
      final base64String = base64Encode(pngBytes);
      channel.sink.add(base64String);
      setState(() {
        _isSigning = false;
      });
    } else {
      print('Erro ao converter a imagem para PNG.');
    }
  }

  void _clearSignature() {
    _signatureKey.currentState!.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: Text('WebSocket Signature Demo'),
      // ),
      body: _isSigning ? _buildSignaturePage() : WaitingPage(),
    );
  }

  Widget _buildSignaturePage() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Desenhe sua assinatura abaixo:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Container(
              alignment: Alignment.center,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(10),
              ),
              child: SignatureWidget(signatureKey: _signatureKey),
            ),
            SizedBox(height: 10),
            ControlsWidget(
              onConfirm: _sendSignature,
              onClear: _clearSignature,
            ),
          ],
        ),
      ),
    );
  }
}

class ControlsWidget extends StatelessWidget {
  final VoidCallback onConfirm;
  final VoidCallback onClear;

  const ControlsWidget({Key? key, required this.onConfirm, required this.onClear}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: SquareButton(
            color: Colors.green,
            text: 'Confirmar',
            onPressed: onConfirm,
          ),
        ),
        SizedBox(width: 15),
        Expanded(
          child: SquareButton(
            color: Colors.red,
            text: 'Limpar',
            onPressed: onClear,
          ),
        ),
      ],
    );
  }
}

class SquareButton extends StatelessWidget {
  final Color color;
  final String text;
  final VoidCallback onPressed;

  const SquareButton({Key? key, required this.color, required this.text, required this.onPressed}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        height: 100,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(10),
        ),
        alignment: Alignment.center,
        child: Text(
          text,
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
