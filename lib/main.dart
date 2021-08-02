import 'package:flutter/material.dart';
import 'telas/gravador.dart';

void main() => runApp(const Recorder());

class Recorder extends StatefulWidget {
  const Recorder({Key? key}) : super(key: key);

  @override
  State<Recorder> createState() => _RecorderState();
}

class _RecorderState extends State<Recorder> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: const Gravador(),
      theme: ThemeData(
        primaryColor: Colors.teal[700],
        scaffoldBackgroundColor: Colors.teal[400],
      ),
    );
  }
}
