import 'package:flutter/material.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'package:sound_library/sound_library.dart';

void main() {
  //Url strategy
  usePathUrlStrategy();
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
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFc1c1c1),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0E0E43),
        title: const Text("Sound Library", style: TextStyle(color: Colors.white)),
      ),
      body: ListView(
        children: [
          Wrap(
            alignment: WrapAlignment.center,
            runAlignment: WrapAlignment.center,
            spacing: 10,
            runSpacing: 10,
            children: [
              buildSoundButton(
                'Click ',
                Sounds.click,
                icon: Icon(
                  Icons.input,
                  color: Colors.blue[800],
                  size: 30,
                ),
              ),
              buildSoundButton(
                'Welcome ',
                Sounds.welcome,
                icon: Icon(
                  Icons.home,
                  color: Colors.blue[800],
                  size: 30,
                ),
              ),
              buildSoundButton(
                'Open',
                Sounds.open,
                icon: const Icon(
                  Icons.door_back_door_outlined,
                  color: Colors.black,
                  size: 30,
                ),
              ),
              buildSoundButton(
                'Close (Wood hit) ',
                Sounds.woodHit,
                icon: Icon(
                  Icons.emoji_objects,
                  color: Colors.brown[800],
                  size: 30,
                ),
              ),
              buildSoundButton(
                'Order Complete ',
                Sounds.orderComplete,
                icon: Icon(
                  Icons.check,
                  color: Colors.green[800],
                  size: 30,
                ),
              ),
              buildSoundButton(
                'Deleted ',
                Sounds.deleted,
                icon: Icon(
                  Icons.delete,
                  color: Colors.red[800],
                  size: 30,
                ),
              ),
              buildSoundButton(
                'Add to cart ',
                Sounds.addToCart,
                icon: Icon(
                  Icons.add_shopping_cart,
                  color: Colors.amber[800],
                  size: 30,
                ),
              ),
              buildSoundButton(
                'Success ',
                Sounds.success,
                icon: Icon(
                  Icons.check_circle,
                  color: Colors.green[800],
                  size: 30,
                ),
              ),
              buildSoundButton(
                'Cashing Machine ',
                Sounds.cashingMachine,
                icon: Icon(
                  Icons.monetization_on,
                  color: Colors.yellow[800],
                  size: 30,
                ),
              ),
              //Agroferia updates quantities and prices given by the producers every week
            ],
          )
        ],
      ),
      floatingActionButton: const Text('By MIS Develop'),
    );
  }

  Widget buildSoundButton(String name, Sounds sound, {Icon? icon}) => Padding(
        padding: const EdgeInsets.all(8.0),
        child: SizedBox(
          width: 200,
          child: Card(
            child: TextButton(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(name),
                  const Spacer(),
                  icon ?? const SizedBox(),
                ],
              ),
              onPressed: () {
                SoundPlayer.play(sound);
              },
            ),
          ),
        ),
      );
}
