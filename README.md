# Music Sheet Guide

For now, a simple 'note guesser' app to help you learn to read music notes. It is designed to assist musicians (mostly piano players) in identifying musical notes on a staff, specifically for treble and bass clefs. The app provides a visual representation of the staff and highlights the notes as they are played, allowing users to practice and improve their note-reading skills.

It works by detecting played notes via a MIDI interface connected to your computer or mobile device. Users can connect their MIDI devices, and the app will display the corresponding note on the staff in real-time as they play.

## Features
- **MIDI Support**: Connect your MIDI device via USB or Bluetooth to play notes (BLE: TBD).
- **Device List**: View and select available MIDI devices for connection.
- **Real-time Note Display**: As you play notes on your MIDI device, the app will display the corresponding note on the staff.
- **Note Guessing**: The app will prompt you to guess the note being played, and you can check your answer.

### Future Features
- **Clef Selection**: Choose between treble and bass clefs to practice reading notes.
- **Practice Mode**: A mode where you can practice reading notes without guessing, focusing on improving your skills.
- **Customizable Settings**: Options to adjust the difficulty level, note range, and other preferences.
- **Score Tracking**: Keep track of your performance over time, including correct guesses and response times.
- **Audio Feedback**: Play back the notes you guessed to hear how they sound.
- **Visual Cues**: Highlight the notes on the staff as they are played, providing visual feedback.
- **Note Range Selection**: Choose a specific range of notes to practice, such as only the notes in the treble clef or bass clef.
- **Tutorial Mode**: A guided mode that teaches you how to read music notes step by step.
- **Score Creation**: Create and save custom scores to practice with specific note sequences.

## Getting Started

This project is a Flutter application, so you can run it on any platform supported by Flutter.

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## Running the app

To run the app, you can use the following command in your terminal:

```bash
flutter run
```
You can also run it from your IDE, such as Android Studio or Visual Studio Code, by opening the project and clicking the run button.

## Package Dependencies
[flutter_midi_command](https://pub.dev/packages/flutter_midi_command): the most important package used here, the one to handle MIDI connections and communication.

## Why?

Because I'm currently learning Piano and I want to improve my note reading skills. Most of the apps I found were either too complex or paid, and at the same time, I wanted ~~to improve my Dart (Flutter) skills~~ a good excuse to code something cause I love it, so I decided to build this app 😬.