import 'package:flutter/material.dart';
import 'package:sound_library/sound_library.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sound library',
      theme: ThemeData(
        primarySwatch: Colors.blueGrey,
      ),
      home: const MyHomePage(title: 'Sounds'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black54,
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            buildSoundButton('Click', Sounds.click),
          ],
        ),
      ),
    );
  }

  Widget buildSoundButton(String name, Sounds sound) => Padding(
        padding: const EdgeInsets.all(8.0),
        child: Card(
          child: TextButton(
            child: Text(name),
            onPressed: () {
              SoundPlayer.i.play(sound);
            },
          ),
        ),
      );
}
