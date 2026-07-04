# bluetooth-camera-receiver
Flutter Bluetooth Camera Receiver using Camera Plugin, Kotlin MethodChannel and Bluetooth Classic RFCOMM.

# Bluetooth Camera Receiver

A Flutter application that receives Bluetooth commands from another Android device and controls the camera remotely.

## Features

- Camera Preview
- Start Video Recording
- Stop & Save Recording
- Pause Recording
- Resume Recording
- Switch Front/Rear Camera
- Live Recording Timer
- Bluetooth RFCOMM Server
- Auto Save Video to Gallery
- Connection Status

## Tech Stack

- Flutter
- Dart
- Camera Plugin
- Provider
- MethodChannel
- Native Android (Kotlin)
- Bluetooth Classic (RFCOMM)

## Project Structure

lib/
├── core/
├── provider/
├── screens/
├── widgets/
└── main.dart

## How to Run

1. Enable Bluetooth.
2. Install Receiver app.
3. Open Receiver.
4. Wait for Sender connection.
5. Start controlling remotely.
