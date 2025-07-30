import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_midi_command/flutter_midi_command.dart';

class DeviceListPage extends StatefulWidget {
  const DeviceListPage({super.key});

  @override
  State<DeviceListPage> createState() => _DeviceListPageState();
}

class _DeviceListPageState extends State<DeviceListPage> {
  Future<List<MidiDevice>>? devices;

  @override
  void initState() {
    super.initState();

    refreshDevices();

    MidiCommand().onMidiSetupChanged?.listen((event) {
      print('MIDI setup changed: ${event}');
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
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: const Text(
          'Settings',
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w600,
            inherit: true,
          ),
        ),
      ),
      child: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'List of MIDI devices:',
            ),
            ListView(
              shrinkWrap: true,
              children: [
                FutureBuilder<List<MidiDevice>>(
                  future: devices,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting ||
                        snapshot.connectionState == ConnectionState.none) {
                      return const CupertinoActivityIndicator();
                    } else if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Text(
                        'No MIDI devices found.',
                        textAlign: TextAlign.center,
                      );
                    } else {
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: snapshot.data!
                            .where((device) =>
                                !device.name.toLowerCase().contains("network"))
                            .map((device) => Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    children: [
                                      Wrap(
                                          alignment: WrapAlignment.center,
                                          children: [
                                            Text(
                                              'Device: ${device.name}, ID: ${device.id}',
                                              textAlign: TextAlign.center,
                                              style:
                                                  const TextStyle(fontSize: 16),
                                            ),
                                          ]),
                                      const SizedBox(height: 8),
                                      if (device.connected)
                                        Text('Connected')
                                      else
                                        CupertinoButton.tinted(
                                          sizeStyle: CupertinoButtonSize.small,
                                          onPressed: () async {
                                            try {
                                              await MidiCommand()
                                                  .connectToDevice(device);
                                              print(
                                                  'Connected to ${device.name}');
                                            } catch (e) {
                                              print(
                                                  'Error connecting to device: $e');
                                            }
                                            refreshDevices();
                                          },
                                          child: const Text('Connect'),
                                        )
                                    ],
                                  ),
                                ))
                            .toList(),
                      );
                    }
                  },
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: CupertinoButton.filled(
                sizeStyle: CupertinoButtonSize.small,
                onPressed: refreshDevices,
                child: const Text('Refresh Devices'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
