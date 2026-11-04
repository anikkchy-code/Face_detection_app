import 'dart:io';
import 'package:flutter/material.dart';
import 'face_controller.dart';
import 'face_model.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FaceController _controller = FaceController();
  File? _imageFile;
  bool _isAnalyzing = false;
  List<FaceModel> _detectedFaces = [];
  double _smilingPercentage = 0.0;
  List<Rect> _boundingBoxes = [];
  Size? _imageSize;

  Future<void> _pickAndProcessImage() async {
    final File? image = await _controller.pickImage();
    if (image == null) return;

    setState(() {
      _imageFile = image;
      _isAnalyzing = true;
      _detectedFaces = [];
      _boundingBoxes = [];
      _smilingPercentage = 0.0;
      _imageSize = null;
    });

    final Size? size = await _controller.getImageSize(image);
    final results = await _controller.processImage(image);

    setState(() {
      _imageSize = size;
      _detectedFaces = results['faces'];
      _smilingPercentage = results['percentage'];
      _boundingBoxes = results['boxes'];
      _isAnalyzing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Face Detection & Smile Analysis'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton.icon(
              onPressed: _isAnalyzing ? null : _pickAndProcessImage,
              icon: const Icon(Icons.image),
              label: Text(_imageFile == null ? 'Upload Image' : 'Upload Another Image'),
            ),
            const SizedBox(height: 16),
            if (_imageFile != null) ...[
              Center(
                child: Container(
                  constraints: const BoxConstraints(maxHeight: 350),
                  child: FittedBox(
                    child: SizedBox(
                      width: _imageSize?.width ?? 300,
                      height: _imageSize?.height ?? 300,
                      child: Stack(
                        children: [
                          Image.file(_imageFile!),
                          if (!_isAnalyzing)
                            CustomPaint(
                              size: Size(_imageSize?.width ?? 300, _imageSize?.height ?? 300),
                              painter: FacePainter(boundingBoxes: _boundingBoxes),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
            if (_isAnalyzing)
              const Center(child: CircularProgressIndicator())
            else ...[
              Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      const Text(
                        'Total Faces',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${_detectedFaces.length}',
                        style: const TextStyle(fontSize: 24, color: Colors.blue),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      const Text(
                        'Smiling Percentage',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${_smilingPercentage.toStringAsFixed(1)}%',
                        style: const TextStyle(fontSize: 24, color: Colors.green),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Individual Face Information',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              if (_detectedFaces.isEmpty)
                const Text('No faces detected.')
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _detectedFaces.length,
                  itemBuilder: (context, index) {
                    final face = _detectedFaces[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      child: ListTile(
                        title: Text('Face Number: Face ${face.faceNumber}'),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Smile Status: ${face.isSmiling ? 'Smiling' : 'Not Smiling'}'),
                            Text('Smile Probability: ${(face.smileProbability * 100).toStringAsFixed(1)}%'),
                          ],
                        ),
                      ),
                    );
                  },
                ),
            ],
          ],
        ),
      ),
    );
  }
}

class FacePainter extends CustomPainter {
  final List<Rect> boundingBoxes;

  FacePainter({required this.boundingBoxes});

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = Colors.red
      ..strokeWidth = 4.0
      ..style = PaintingStyle.stroke;

    for (var rect in boundingBoxes) {
      canvas.drawRect(rect, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}