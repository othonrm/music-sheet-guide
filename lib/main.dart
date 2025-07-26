import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_midi_command/flutter_midi_command.dart';
import 'package:music_sheet_guide/midiDictionary.dart';
import 'dart:math';

void main() {
  runApp(const MusicSheetGuideApp());
}

class MusicSheetGuideApp extends StatelessWidget {
  const MusicSheetGuideApp({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoApp(
      title: 'Music Sheet Guide',
      theme: CupertinoThemeData(
        brightness: Brightness.light,
        primaryColor: CupertinoColors.activeBlue,
        scaffoldBackgroundColor: CupertinoColors.systemBackground,
        textTheme: CupertinoTextThemeData(
          textStyle: TextStyle(
            fontSize: 16,
            color: CupertinoColors.label,
          ),
          navTitleTextStyle: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: CupertinoColors.label,
          ),
        ),
      ),
      home: const MyHomePage(title: 'Music Sheet Guide - Note Guesser'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Future<List<MidiDevice>>? devices;

  int lastPressedNote = -1;
  bool lastPressedNoteCorrect = false;
  int expectedNote = begginerTrebleClefNotes[0];

  @override
  void initState() {
    super.initState();

    print('Initializing App...');

    refreshDevices();

    MidiCommand().onMidiSetupChanged?.listen((event) {
      print('MIDI setup changed: ${event}');
    });

    bool isConnected = false;

    MidiCommand().onMidiDataReceived?.listen((event) {
      if (event.data[0] == 254) {
        print('Active sensing received from ${event.device.name}');
      }

      if (event.data.length > 1) {
        int noteCode = event.data[1];
        String noteName = midiNoteNames[noteCode];

        if (event.data[0] == 144) {
          print('Note On: $noteName (${event.data[1]})');
          setState(() {
            lastPressedNote = noteCode;
            print(lastPressedNote % 12);

            if (lastPressedNote == expectedNote) {
              print('Correct note pressed: $noteName');
              lastPressedNoteCorrect = true;
              int min = 0;
              int max = begginerTrebleClefNotes.length - 1;
              int randomNoteIndex = min + Random().nextInt(max - min);
              print('Random note index: $randomNoteIndex');
              print('Note: ${begginerTrebleClefNotes[randomNoteIndex]}');
              expectedNote = begginerTrebleClefNotes[randomNoteIndex];
            } else {
              print(
                  'Incorrect note pressed: $noteName, expected: ${midiNoteNames[expectedNote]}');
              lastPressedNoteCorrect = false;
            }
          });
        } else if (event.data[0] == 128) {
          print('Note Off: $noteName');
        }
      }
    });
  }

  Future<List<MidiDevice>> loadDevices() async {
    try {
      // Fetch the list of MIDI devices
      List<MidiDevice> devices = await (MidiCommand().devices) ?? [];
      return devices;
    } catch (e) {
      print('Error fetching MIDI devices: $e');
      return [];
    }
  }

  void refreshDevices() {
    setState(() {
      devices = loadDevices();
    });
  }

  @override
  Widget build(BuildContext context) {
    // int topMargin = 4; // Margin for the top of the treble clef image
    int bottomMargin = 10;
    double noteSpacing = 37.2; // Spacing between notes in pixels

    int trebleClefStart = 60;

    // expectedNote = 61;

    double blackAdjuster = 0; // Counter for black notes

    // Positioning Tester
    // expectedNote = begginerTrebleClefNotes[0];

    if ((expectedNote % 12) % 2 == 0) {
      blackAdjuster = expectedNote % 12 / 2;
    } else if ((expectedNote % 12) % 2 == 1) {
      blackAdjuster = (expectedNote % 12 / 2) - 0.5;
    } else {
      blackAdjuster = 0;
    }

    // Calculate the position of the expected note
    double bottomPosition = (bottomMargin + (noteSpacing / 2)) +
        ((noteSpacing / 2) *
            ((expectedNote - trebleClefStart) - blackAdjuster));

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text(widget.title),
      ),
      child: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              SizedBox(height: 20),
              Text('Expected Note: $expectedNote'),
              SizedBox(height: 20),
              Text(
                'Last Pressed Note: ${(lastPressedNote != -1) ? lastPressedNote : '-'}',
                style: TextStyle(
                    color: (lastPressedNote == -1)
                        ? CupertinoColors.systemGrey
                        : (lastPressedNoteCorrect
                            ? CupertinoColors.systemGreen
                            : CupertinoColors.systemRed),
                    fontSize: 16),
              ),
              Stack(
                alignment: Alignment.center,
                children: [
                  Image.asset(
                    'assets/images/treble-clef.jpg',
                  ),
                  Positioned(
                    // top: 4 + (37.2 * 7),
                    bottom: bottomPosition,
                    child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 0, 0),
                        child: Image.asset('assets/images/whole-note.png')),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const Text(
                'List of MIDI devices:',
              ),
              Expanded(
                child: ListView(
                  shrinkWrap: true,
                  padding: const EdgeInsets.all(16.0),
                  children: [
                    FutureBuilder<List<MidiDevice>>(
                      future: devices,
                      builder: (context, snapshot) {
                        print(snapshot);
                        if (snapshot.connectionState ==
                                ConnectionState.waiting ||
                            snapshot.connectionState == ConnectionState.none) {
                          return const CupertinoActivityIndicator();
                        } else if (snapshot.hasError) {
                          return Text('Error: ${snapshot.error}');
                        } else if (!snapshot.hasData ||
                            snapshot.data!.isEmpty) {
                          return const Text('No MIDI devices found.');
                        } else {
                          return Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: snapshot.data!
                                .map((device) => Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              'Device: ${device.name}, ID: ${device.id}',
                                              style:
                                                  const TextStyle(fontSize: 16),
                                            ),
                                            const SizedBox(width: 10),
                                            if (device.connected)
                                              Text('Connected')
                                            else
                                              ElevatedButton(
                                                onPressed: () async {
                                                  try {
                                                    await MidiCommand()
                                                        .connectToDevice(
                                                            device);
                                                    print(
                                                        'Connected to ${device.name}');
                                                  } catch (e) {
                                                    print(
                                                        'Error connecting to device: $e');
                                                  }
                                                },
                                                child: const Text('Connect'),
                                              ),
                                          ]),
                                    ))
                                .toList(),
                          );
                        }
                      },
                    ),
                    const SizedBox(height: 20),
                    CupertinoButton(
                      onPressed: refreshDevices,
                      child: const Text('Refresh Devices'),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'To use this app, make sure you have a MIDI device connected to your computer or mobile device. The app will automatically detect and list the available MIDI devices. You can then connect to a device by clicking the "Connect" button next to it.',
                      style: TextStyle(
                          fontSize: 14, color: CupertinoColors.systemGrey),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
