import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_midi_command/flutter_midi_command.dart';
import 'package:music_sheet_guide/midiDictionary.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  Future<List<MidiDevice>> devices = Future<List<MidiDevice>>(() async {
    try {
      // Fetch the list of MIDI devices
      List<MidiDevice> devices = await (MidiCommand().devices) ?? [];
      return devices;
    } catch (e) {
      print('Error fetching MIDI devices: $e');
      return [];
    }
  });

  @override
  void initState() {
    super.initState();

    print('Initializing App...');

    MidiCommand().onMidiSetupChanged?.listen((event) {
      print('MIDI setup changed: ${event}');
    });

    bool isConnected = false;

    MidiCommand().onMidiDataReceived?.listen((event) {
      // print('MIDI data received from: ${event.device.name}');
      // print('Data: ${event.data}');

      if (event.data[0] == 254) {
        // This is a MIDI active sensing message
        print('Active sensing received from ${event.device.name}');
      } else {
        // Handle other MIDI messages
        print('MIDI message: ${event.data}');
      }

      if (event.data.length > 1) {
        int noteCode = event.data[1];
        String noteName = midiNoteNames[noteCode];

        if (event.data[0] == 144) {
          print('Note On: $noteName (${event.data[2]})');
        } else if (event.data[0] == 128) {
          print('Note Off: $noteName');
        }
      }
    });
  }

  void refreshDevices() {
    setState(() {
      devices = Future<List<MidiDevice>>(() async {
        try {
          // Fetch the list of MIDI devices
          List<MidiDevice> devices = await (MidiCommand().devices) ?? [];
          return devices;
        } catch (e) {
          print('Error fetching MIDI devices: $e');
          return [];
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // TRY THIS: Try changing the color here to a specific color (to
        // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
        // change color while the other colors stay the same.
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          //
          // TRY THIS: Invoke "debug painting" (choose the "Toggle Debug Paint"
          // action in the IDE, or press "p" in the console), to see the
          // wireframe for each widget.
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'List of MIDI devices:',
            ),
            ListView(
              shrinkWrap: true,
              children: [
                FutureBuilder<List<MidiDevice>>(
                  future: devices,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const CircularProgressIndicator();
                    } else if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Text('No MIDI devices found.');
                    } else {
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: snapshot.data!
                            .map((device) =>
                                // Text(
                                // 'Device: ${device.name}, ID: ${device.id}'))
                                Row(children: [
                                  Text(
                                    'Device: ${device.name}, ID: ${device.id}',
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                  const SizedBox(width: 10),
                                  ElevatedButton(
                                    onPressed: () async {
                                      try {
                                        await MidiCommand()
                                            .connectToDevice(device);
                                        print('Connected to ${device.name}');
                                      } catch (e) {
                                        print('Error connecting to device: $e');
                                      }
                                    },
                                    child: const Text('Connect'),
                                  ),
                                ]))
                            .toList(),
                      );
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: refreshDevices,
        tooltip: 'Refresh',
        child: const Icon(CupertinoIcons.arrow_counterclockwise),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
