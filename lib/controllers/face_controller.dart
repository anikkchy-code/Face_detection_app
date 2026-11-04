import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:image_picker/image_picker.dart';
import 'face_model.dart';

class FaceController {
  final ImagePicker _imagePicker = ImagePicker();
  
  final FaceDetector _faceDetector = FaceDetector(
    options: FaceDetectorOptions(
      enableClassification: true,
      performanceMode: FaceDetectorMode.accurate,
    ),
  );

  Future<File?> pickImage() async {
    final XFile? pickedFile = await _imagePicker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      return File(pickedFile.path);
    }
    return null;
  }

  Future<Size?> getImageSize(File imageFile) async {
    final decodedImage = await decodeImageFromList(imageFile.readAsBytesSync());
    return Size(decodedImage.width.toDouble(), decodedImage.height.toDouble());
  }

  Future> processImage(File imageFile) async {
    final inputImage = InputImage.fromFile(imageFile);
    final List<Face> faces = await _faceDetector.processImage(inputImage);

    List<FaceModel> faceModels = [];
    List<Rect> boundingBoxes = [];
    
    int smilingCount = 0;
    int totalFaces = faces.length;

    for (int i = 0; i < faces.length; i++) {
      final face = faces[i];
      boundingBoxes.add(face.boundingBox);

      double smileProb = face.smileProbability ?? 0.0;
      bool isSmiling = smileProb >= 0.7;

      if (isSmiling) {
        smilingCount++;
      }

      faceModels.add(
        FaceModel(
          faceNumber: i + 1,
          isSmiling: isSmiling,
          smileProbability: smileProb,
        ),
      );
    }

    double percentage = totalFaces > 0 ? (smilingCount / totalFaces) * 100 : 0.0;

    return {
      'faces': faceModels,
      'percentage': percentage,
      'boxes': boundingBoxes,
    };
  }

  void dispose() {
    _faceDetector.close();
  }
}