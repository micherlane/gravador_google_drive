import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_audio_recorder2/flutter_audio_recorder2.dart';
import 'package:file/local.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io' as io;
import 'dart:developer' as developer;
import 'package:audioplayers/audioplayers.dart';
import '../models/google_upload.dart';

class Gravador extends StatefulWidget {
  final LocalFileSystem localFileSystem;

  // ignore: use_key_in_widget_constructors
  const Gravador({localFileSystem})
      : localFileSystem = localFileSystem ?? const LocalFileSystem();

  @override
  _GravadorState createState() => _GravadorState();
}

class _GravadorState extends State<Gravador> {
  FlutterAudioRecorder2? recorder;
  Recording? current;
  bool estaGravando = false;
  String caminhoArquivo = '';
  String status = "";
  bool isPlaying = false;
  AudioPlayer audioPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();
    init();
  }

  Widget _construirImagem() {
    return SizedBox(
      width: 400,
      child: Image.asset(
        "assets/images/img.png",
        fit: BoxFit.contain,
      ),
    );
  }

  Widget _construirBotaoGravacao() {
    return Container(
      decoration:
          const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
      child: IconButton(
        onPressed: () {
          if (estaGravando) {
            stop();
          } else {
            start();
          }
        },
        icon: Icon(estaGravando ? Icons.stop : Icons.mic_outlined),
        color: Colors.white,
        iconSize: 100,
      ),
    );
  }

  Widget _construirBordasArrendondas(Widget filho, double altura) {
    return Container(
      width: 400,
      height: altura,
      padding: const EdgeInsets.all(8.0),
      decoration: const BoxDecoration(
        color: Colors.white60,
        borderRadius: BorderRadius.all(Radius.circular(20.0)),
      ),
      child: filho,
    );
  }

  Widget _construirTexto(texto) {
    return Text(texto.toString().toUpperCase(),
        textAlign: TextAlign.center,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20));
  }

  Widget _construirBotaoAudio() {
    return Container(
      decoration:
          const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
      child: IconButton(
        onPressed: () {
          ouvirAudio();
        },
        icon: const Icon(Icons.play_arrow),
        color: Colors.white,
        iconSize: 100,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('RECORDER'),
      ),
      body: Container(
        margin: const EdgeInsets.all(10.0),
        padding: const EdgeInsets.all(10.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _construirImagem(),
            _construirBordasArrendondas(_construirTexto(status), 35),
            _construirBordasArrendondas(
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _construirBotaoGravacao(),
                  _construirBotaoAudio(),
                ],
              ),
              150,
            ),
          ],
        ),
      ),
    );
  }

  Future<io.Directory> criarDiretorio(String nomeDiretorio) async {
    io.Directory diretorioBase;

    if (io.Platform.isIOS) {
      diretorioBase = await getApplicationDocumentsDirectory();
    } else {
      diretorioBase = (await getExternalStorageDirectory())!;
    }

    var caminhoCompleto = diretorioBase.path + nomeDiretorio;

    var diretorioDoApp = io.Directory(caminhoCompleto);
    bool existDiretorio = await diretorioDoApp.exists();

    if (!existDiretorio) {
      diretorioDoApp.create();
    }

    return diretorioDoApp;
  }

  Future<String> getNomeDoArquivo() async {
    var diretorio = await criarDiretorio('/GravacaoApp');
    var caminhoArquivo =
        diretorio.path + '/audio_atividade' + Random().nextInt(4000).toString();

    return caminhoArquivo;
  }

  init() async {
    bool temPermissao = await FlutterAudioRecorder2.hasPermissions ?? false;

    try {
      caminhoArquivo = await getNomeDoArquivo();

      if (temPermissao) {
        recorder = FlutterAudioRecorder2(caminhoArquivo,
            audioFormat: AudioFormat.WAV, sampleRate: 44800);
        await recorder!.initialized;

        var current1 = await recorder!.current(channel: 1);
        setState(() async {
          current = current1;
        });
      }
    } catch (e) {
      developer.log('As permissões não foram aceitas.');
    }
    developer.log(temPermissao.toString());
  }

  start() async {
    try {
      await recorder!.start();
      var recording = await recorder!.current(channel: 1);

      setState(() {
        estaGravando = true;
        current = recording;
        status = "Gravando";
      });
    } catch (e) {
      developer.log('Não consegui iniciar a gravação.');
    }
  }

  stop() async {
    var result = await recorder!.stop();
    setState(() {
      estaGravando = false;
      status = "Gravação concluída";
      current = result;
    });
    var file = widget.localFileSystem.file(current!.path);
    developer.log(file.path);
  }

  ouvirAudio() async {
    audioPlayer.play(current!.path!, isLocal: true);
    io.sleep(Duration(seconds: current!.duration!.inSeconds));
    showAlertDialog(context);
    developer.log(current!.path!);
    setState(() {
      isPlaying = true;
      status = "Playing audio";
    });
  }

  apagarArquivo() {
    var caminho = current!.path!;
    var file = io.File(caminho);
    file.delete();
  }

  notificar(mensagem) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        elevation: 5,
        content: Text(
          mensagem,
          textAlign: TextAlign.center,
        )));
  }

  showAlertDialog(BuildContext context) {
    Widget apagarButton = TextButton(
        onPressed: () {
          apagarArquivo();
          audioPlayer.stop();

          setState(() {
            isPlaying = false;
            status = "";
          });
          notificar('Áudio descartado');
          Navigator.of(context).pop();
        },
        child: const Text("Não"));

    Widget salvarButton = TextButton(
        onPressed: () async {
          //correio.enviarArquivos();
          UploadFileDrive correio = UploadFileDrive(current!.path!);
          Future<String> mensagem = correio.enviarArquivos();
          mensagem.then((msg) {
            notificar(msg);
          });

          setState(() {
            isPlaying = false;
            status = "";
          });
          Navigator.of(context).pop();
        },
        child: const Text("Sim"));

    AlertDialog alert = AlertDialog(
        title: const Text("Gravação"),
        content: const Text("A qualidade do áudio estava boa?"),
        elevation: 5.0,
        actions: [
          apagarButton,
          salvarButton,
        ]);
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) {
          return alert;
        });
  }
}
