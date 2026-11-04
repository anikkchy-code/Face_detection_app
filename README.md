# Face Detection & Smile Analysis App

A Flutter application that utilizes **Google ML Kit Face Detection** to detect faces in uploaded images, analyze smile probabilities, calculate smiling percentages, and display individual face information with bounding boxes.

## Features

- **Image Picker**: Upload images from the device gallery.
- **Face Detection**: Detects single or multiple faces in an image using Google ML Kit.
- **Bounding Boxes**: Draws rectangular bounding boxes over the detected faces on the image preview.
- **Total Faces Card**: Displays the total number of faces detected automatically.
- **Smiling Percentage Card**: Calculates and displays the percentage of smiling faces based on a probability threshold ($\ge 0.7$).
- **Individual Face Information**: Displays detailed information (Face Number, Smile Status, and Smile Probability) for each detected face.

## Required Flutter Packages

Make sure your `pubspec.yaml` includes the following dependencies:

```yaml
dependencies:
  flutter:
    sdk: flutter
  google_mlkit_face_detection: ^0.13.0
  image_picker: ^1.1.2

flutter:
  uses-material-design: true

Folder Structures
lib/
├── main.dart
├── models/
│   └── face_model.dart
├── views/
│   └── home_screen.dart
└── controllers/
    └── face_controller.dart


Getting Started
​Clone the repository or set up the project files as structured above.
​Run flutter pub get to install the required packages.
​Run the application on your physical device or emulator using flutter run.
