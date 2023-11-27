// import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tflite_v2/tflite_v2.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: ImagePickerDemo(),
    );
  }
}

class ImagePickerDemo extends StatefulWidget {
  @override
  _ImagePickerDemoState createState() => _ImagePickerDemoState();
}

class _ImagePickerDemoState extends State<ImagePickerDemo> {
  final ImagePicker _picker = ImagePicker();
  XFile? _image;
  File? file;
  var _recognitions;
  var v = "";
  // var dataList = [];
  @override
  void initState() {
    super.initState();
    loadmodel().then((value) {
      setState(() {});
    });
  }

  loadmodel() async {
    await Tflite.loadModel(
      model: "assets/model_resnet50.tflite",
      labels: "assets/labels.txt",
    );
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      setState(() {
        _image = image;
        file = File(image!.path);
      });
      detectimage(file!);
    } catch (e) {
      print('Error picking image: $e');
    }
  }

  Future<void> detectimage(File image) async {
  int startTime = DateTime.now().millisecondsSinceEpoch;
  var recognitions = await Tflite.runModelOnImage(
    path: image.path,
    numResults: 6,
    threshold: 0.05,
    imageMean: 127.5,
    imageStd: 127.5,
  );

  if (recognitions != null && recognitions.isNotEmpty) {
    setState(() {
      _recognitions = recognitions;
      v = formatPredictions(recognitions);
    });
  } else {
    setState(() {
      v = 'No predictions';
    });
  }

  int endTime = DateTime.now().millisecondsSinceEpoch;
  // ignore: avoid_print
  print("Inference took ${endTime - startTime}ms");
}

String formatPredictions(List<dynamic>? recognitions) {
  if (recognitions == null || recognitions.isEmpty) {
    return 'No predictions';
  }

  String result = 'Predictions: ';

  for (var recognition in recognitions) {
    result +=
        ' ${recognition['label']}   Confidence: ${(recognition['confidence'] as double).toStringAsFixed(3)}\n';
  }

  return result;
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Cotton Disease Prediction App'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            if (_image != null)
              Image.file(
                File(_image!.path),
                height: 200,
                width: 200,
                fit: BoxFit.cover,
              )
            else
              Text('No image selected'),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _pickImage,
              child: Text('Pick Image from Gallery'),
            ),
            SizedBox(height: 20),
            Text(v),
          ],
        ),
      ),
    );
  }
}