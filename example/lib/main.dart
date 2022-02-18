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
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white70,
      appBar: AppBar(
        title: const Text("Sound Library"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            buildSoundButton('Click ', Sounds.click,
                icon: Icon(
                  Icons.input,
                  color: Colors.blue[800],
                  size: 30,
                )),
            buildSoundButton('Welcome ', Sounds.welcome,
                icon: Icon(
                  Icons.home,
                  color: Colors.blue[800],
                  size: 30,
                )),
            buildSoundButton('Wood hit ', Sounds.wood_hit),
            buildSoundButton('Order Complete ', Sounds.order_complete,
                icon: Icon(
                  Icons.check,
                  color: Colors.green[800],
                  size: 30,
                )),
            buildSoundButton('Trash ', Sounds.trash,
                icon: Icon(
                  Icons.delete,
                  color: Colors.red[800],
                  size: 30,
                )),
            buildSoundButton('Add to cart ', Sounds.add_to_cart,
                icon: Icon(
                  Icons.add_shopping_cart,
                  color: Colors.amber[800],
                  size: 30,
                )),
            buildSoundButton('Success ', Sounds.success),
            //Agroferia updates quantities and prices given by the producers every week
          ],
        ),
      ),
    );
  }

  Widget buildSoundButton(String name, Sounds sound, {Icon? icon}) => Padding(
        padding: const EdgeInsets.all(8.0),
        child: Card(
          child: icon != null
              ? IconButton(
                  onPressed: () {
                    SoundPlayer.i.play(sound);
                  },
                  icon: icon)
              : TextButton(
                  child: Text(name),
                  onPressed: () {
                    SoundPlayer.i.play(sound);
                  },
                ),
        ),
      );
}
