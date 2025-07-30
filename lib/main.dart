import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_midi_command/flutter_midi_command.dart';
import 'package:music_sheet_guide/device_list_page.dart';
import 'package:music_sheet_guide/midi_dictionary.dart';
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
          navTitleTextStyle:
              CupertinoTheme.of(context).textTheme.navTitleTextStyle.copyWith(
                    fontWeight: FontWeight.bold,
                    color: CupertinoColors.label,
                    fontSize: 20,
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
  int lastPressedNote = -1;
  bool lastPressedNoteCorrect = false;
  int expectedNote = begginerTrebleClefNotes[0];
  int points = 0;
  final GlobalKey _clefKey = GlobalKey();
  double clefHeight = 0;

  @override
  void initState() {
    super.initState();

    print('Initializing App...');

    MidiCommand().onMidiSetupChanged?.listen((event) {
      print('MIDI setup changed: ${event}');
    });

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
              points++;
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
              points = max(0, points - 1);
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

  @override
  Widget build(BuildContext context) {
    // TODO: not the best place to put, also should use LayoutBuilder
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final renderBox =
          _clefKey.currentContext?.findRenderObject() as RenderBox?;
      if (renderBox != null) {
        final size = renderBox.size;
        setState(() {
          clefHeight = size.height;
        });
      }
    });

    // int topMargin = 4;
    double bottomMargin = (10 / 313) * clefHeight;
    double fullClefHeight = 313;
    double noteHeight = 38;
    double noteHeightProportion = noteHeight / fullClefHeight;
    double noteSpacing = noteHeightProportion * clefHeight;

    int trebleClefStart = 60;

    // expectedNote = 61;

    double blackAdjuster = 0;

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
        middle: Text(
          widget.title,
          textAlign: TextAlign.center,
        ),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: () {
            Navigator.push(
                context,
                CupertinoPage(child: const DeviceListPage())
                    .createRoute(context));
          },
          child: const Icon(CupertinoIcons.back),
        ),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(8.0),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height -
                  MediaQuery.of(context).padding.top -
                  kToolbarHeight,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  children: [
                    Text(
                      'Points: $points',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Last Pressed Note: ${(lastPressedNote != -1) ? '${midiNoteNames[lastPressedNote].toString().substring(0, 1)} / ${angloSaxonToLatin[midiNoteNames[lastPressedNote].toString().substring(0, 1)]}' : '-'}',
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
                        Container(
                          key: _clefKey,
                          child: Image.asset(
                            'assets/images/treble-clef.jpg',
                            fit: BoxFit.contain,
                          ),
                        ),
                        Positioned(
                          // top: 4 + (37.2 * 7),
                          bottom: bottomPosition,
                          child: Padding(
                              padding: const EdgeInsets.fromLTRB(16, 0, 0, 0),
                              child: Image.asset(
                                'assets/images/whole-note.png',
                                height: noteSpacing,
                              )),
                        ),
                      ],
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    'To use this app, make sure you have a MIDI device connected to your computer or mobile device. The app will automatically detect and list the available MIDI devices. You can then connect to a device by clicking the "Connect" button next to it.',
                    style: TextStyle(
                      fontSize: 14,
                      color: CupertinoColors.systemGrey,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
